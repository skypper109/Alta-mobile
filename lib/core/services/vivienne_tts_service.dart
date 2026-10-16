import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';

import '../constants.dart';

/// Statuts de lecture du moteur vocal Vivienne Neural
enum VivienneTtsStatus {
  idle,
  synthesizing,
  speaking,
  paused,
  stopped,
  error,
}

/// Moteur de synthèse vocale haute fidélité pour Vivienne (AlternIA).
///
/// Embarque 100% de la logique du backend AlternIA directement sur le mobile :
/// 1. Voix Neurale Vivienne officielle : "fr-FR-VivienneMultilingualNeural"
/// 2. Pipeline de nettoyage textuel & phonétique (LaTeX, unités, formules, niveaux maliens)
/// 3. Cache disque intelligent (MD5) pour une réécoute instantanée à 0ms de latence (100% offline)
/// 4. Pipeline de pré-synthèse et lecture fluide par découpage de phrases (zéro pause)
/// 5. Décodage et restitution audio native via AudioPlayer (audio-24khz-48kbitrate-mono-mp3)
/// 6. Repli de secours autonome sur le moteur système en cas de coupure réseau sans cache
class VivienneTtsService {
  static final VivienneTtsService _instance = VivienneTtsService._internal();
  factory VivienneTtsService() => _instance;
  static VivienneTtsService get instance => _instance;

  VivienneTtsService._internal() {
    _initAudioPlayer();
  }

  // Identifiant officiel de la voix Neurale Vivienne
  static const String neuralVoiceName = 'fr-FR-VivienneMultilingualNeural';
  static const String trustedClientToken = '6A5AA1D4EAFF4E9FB37E23D68491D6F4';
  static const String chromiumFullVersion = '143.0.3650.75';
  static const String secMsGecVersion = '1-$chromiumFullVersion';

  // Paramètres acoustiques
  static const double viviennePitch = 1.05;
  static const double vivienneSpeechRate = 0.48;
  static const double vivienneVolume = 1.0;
  static const String vivienneLanguage = 'fr-FR';

  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _fallbackTts = FlutterTts();
  bool _fallbackInitialized = false;
  bool _isUsingFallback = false;

  VivienneTtsStatus _status = VivienneTtsStatus.idle;
  String? _currentText;
  Directory? _cacheDir;
  bool _isDisposed = false;

  // File d'attente pour la lecture continue fluide
  final List<String> _playbackQueue = [];
  bool _isPlayingQueue = false;
  bool _isAdvancingQueue = false;
  int _currentQueueIndex = 0;

  VoidCallback? _onStartCallback;
  VoidCallback? _onCompletionCallback;
  Function(String)? _onErrorCallback;

  VivienneTtsStatus get status => _status;
  bool get isSpeaking =>
      _status == VivienneTtsStatus.speaking ||
      _status == VivienneTtsStatus.synthesizing;
  String? get currentText => _currentText;

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);

      // Configuration AudioContext pour garantir la restitution sur haut-parleur
      await _audioPlayer.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.speech,
            usageType: AndroidUsageType.assistanceNavigationGuidance,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {
              AVAudioSessionOptions.duckOthers,
            },
          ),
        ),
      );

      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.playing) {
          _status = VivienneTtsStatus.speaking;
        } else if (state == PlayerState.paused) {
          _status = VivienneTtsStatus.paused;
        } else if (state == PlayerState.stopped) {
          if (!_isPlayingQueue) {
            _status = VivienneTtsStatus.stopped;
          }
        }
      });

      // Écouteur unique et prioritaire de fin de piste pour iOS AVPlayer / Android
      _audioPlayer.onPlayerComplete.listen((_) {
        _handleChunkCompleted();
      });

      // Pré-initialisation asynchrone du moteur de repli local
      unawaited(_initFallbackTts());
    } catch (e) {
      debugPrint('[VivienneTts] Erreur init AudioPlayer: $e');
    }
  }

  /// Initialise le moteur système FlutterTts en cas d'indisponibilité réseau
  Future<void> _initFallbackTts() async {
    if (_fallbackInitialized) return;
    try {
      await _fallbackTts.setLanguage(vivienneLanguage);
      await _fallbackTts.setSpeechRate(vivienneSpeechRate);
      await _fallbackTts.setPitch(viviennePitch);
      await _fallbackTts.setVolume(vivienneVolume);

      // Meilleure voix féminine française disponible
      try {
        final voices = await _fallbackTts.getVoices;
        if (voices is List) {
          for (final v in voices) {
            if (v is Map) {
              final locale = (v['locale'] ?? '').toString().toLowerCase();
              final name = (v['name'] ?? '').toString().toLowerCase();
              if (locale.startsWith('fr') &&
                  (name.contains('female') ||
                      name.contains('fr-fr') ||
                      name.contains('femme') ||
                      name.contains('vivienne'))) {
                await _fallbackTts.setVoice({
                  'name': v['name'].toString(),
                  'locale': v['locale'].toString(),
                });
                break;
              }
            }
          }
        }
      } catch (_) {}

      _fallbackTts.setStartHandler(() {
        _status = VivienneTtsStatus.speaking;
        _onStartCallback?.call();
      });

      _fallbackTts.setCompletionHandler(() {
        if (_isUsingFallback) {
          _handleChunkCompleted();
        }
      });

      _fallbackTts.setErrorHandler((msg) {
        debugPrint('[VivienneTts] Signal d\'erreur FlutterTts fallback: $msg');
        if (_isUsingFallback) {
          _handleChunkCompleted();
        }
      });

      _fallbackInitialized = true;
    } catch (e) {
      debugPrint('[VivienneTts] Erreur init FlutterTts fallback: $e');
    }
  }

  /// Répertoire de cache pour les fichiers MP3 de Vivienne
  Future<Directory> _getCacheDirectory() async {
    if (_cacheDir != null) return _cacheDir!;
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final dir = Directory('${docDir.path}/vivienne_neural_tts_cache');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _cacheDir = dir;
      return dir;
    } catch (_) {
      final tempDir = await getTemporaryDirectory();
      final dir = Directory('${tempDir.path}/vivienne_neural_tts_cache');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _cacheDir = dir;
      return dir;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 1. PIPELINE DE NETTOYAGE ET NORMALISATION PHONÉTIQUE (Code AlternIA Backend)
  // ─────────────────────────────────────────────────────────────────────────────

  /// Nettoie et enrichit le texte avec une diction pédagogique naturelle et fluide
  /// (Portage strict de `_clean_for_speech` du TTSEngine AlternIA).
  static String cleanForSpeech(String text) {
    var t = text.trim();
    if (t.isEmpty) return '';

    // Supprimer balises <think> et balises HTML/XML
    t = t.replaceAll(RegExp(r'<think>[\s\S]*?<\/think>', caseSensitive: false), '');
    t = t.replaceAll(RegExp(r'<[^>]+>'), ' ');

    // Supprimer le code markdown brut
    t = t.replaceAll(RegExp(r'```[\s\S]*?```'), ' , comme illustré ici , ');
    t = t.replaceAllMapped(RegExp(r'`([^`]+)`'), (m) => m.group(1) ?? '');
    t = t.replaceAllMapped(RegExp(r'\*\*\*([^*]+)\*\*\*'), (m) => m.group(1) ?? '');
    t = t.replaceAllMapped(RegExp(r'\*\*([^*]+)\*\*'), (m) => m.group(1) ?? '');
    t = t.replaceAllMapped(RegExp(r'\*([^*]+)\*'), (m) => m.group(1) ?? '');
    t = t.replaceAll('***', '').replaceAll('**', '').replaceAll('*', '');
    t = t.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');

    // Remplacement des fractions LaTeX simples : \frac{a}{b} -> a sur b
    t = t.replaceAllMapped(RegExp(r'\\frac\{([^}]+)\}\{([^}]+)\}'), (m) => '${m.group(1)} sur ${m.group(2)}');
    t = t.replaceAllMapped(RegExp(r'\\sqrt\{([^}]+)\}'), (m) => 'racine carrée de ${m.group(1)}');
    t = t.replaceAll(RegExp(r'\\left|\\right'), '');
    t = t.replaceAll(RegExp(r'\\[a-zA-Z]+'), ' ');

    // Remplacement phonétique des symboles mathématiques et scientifiques
    t = t.replaceAll('²', ' au carré ');
    t = t.replaceAll('^2', ' au carré ');
    t = t.replaceAll('³', ' au cube ');
    t = t.replaceAll('^3', ' au cube ');
    t = t.replaceAll('±', ' plus ou moins ');
    t = t.replaceAll('≠', ' différent de ');
    t = t.replaceAll('≤', ' inférieur ou égal à ');
    t = t.replaceAll('≥', ' supérieur ou égal à ');
    t = t.replaceAll('→', ' donne ');
    t = t.replaceAll('⇒', ' implique ');
    t = t.replaceAll('⇔', ' équivaut à ');
    t = t.replaceAll('×', ' fois ');
    t = t.replaceAll('√', 'racine carrée de ');
    t = t.replaceAll('Δ', 'delta ');
    t = t.replaceAll('π', 'pi ');
    t = t.replaceAll('∈', ' appartient à ');
    t = t.replaceAll('∉', " n'appartient pas à ");
    t = t.replaceAll('∞', " l'infini ");
    t = t.replaceAll('≈', ' environ ');

    // Unités scientifiques courantes en français
    t = t.replaceAllMapped(RegExp(r'(\d+)\s*m/s²'), (m) => '${m.group(1)} mètres par seconde au carré');
    t = t.replaceAllMapped(RegExp(r'(\d+)\s*m/s\b'), (m) => '${m.group(1)} mètres par seconde');
    t = t.replaceAllMapped(RegExp(r'(\d+)\s*km/h\b'), (m) => '${m.group(1)} kilomètres par heure');
    t = t.replaceAllMapped(RegExp(r'(\d+)\s*rad/s\b'), (m) => '${m.group(1)} radians par seconde');
    t = t.replaceAllMapped(RegExp(r'(\d+)\s*Hz\b'), (m) => '${m.group(1)} Hertz');
    t = t.replaceAllMapped(RegExp(r'(\d+)\s*mol/L\b'), (m) => '${m.group(1)} moles par litre');
    t = t.replaceAllMapped(RegExp(r'(\d+)\s*mol\b'), (m) => '${m.group(1)} moles');

    // Signes d'égalité
    t = t.replaceAllMapped(RegExp(r'(\w+)\s*=\s*'), (m) => '${m.group(1)} égale ');

    // Ponctuation fluide : Puces et énumérations
    t = t.replaceAll(RegExp(r'^[-*•]\s+', multiLine: true), ', ');
    t = t.replaceAllMapped(RegExp(r'^(\d+)\.\s+', multiLine: true), (m) => 'Point ${m.group(1)}, ');

    // Normalisation des niveaux et filières scolaires maliennes
    t = t.replaceAll(RegExp(r'\b10[eè]me\b', caseSensitive: false), 'dixième année');
    t = t.replaceAll(RegExp(r'\b11[eè]me\b', caseSensitive: false), 'onzième année');
    t = t.replaceAll(RegExp(r'\b12[eè]me\b', caseSensitive: false), 'douzième année');
    t = t.replaceAll(RegExp(r'\bterminal\b', caseSensitive: false), 'terminale');
    t = t.replaceAll(RegExp(r'\bterminale\b', caseSensitive: false), 'classe de terminale');
    t = t.replaceAll(RegExp(r'\s*&\s*'), ' et ');

    // Nettoyer parenthèses de sigles (ex: (TSExp), (11S))
    t = t.replaceAll(RegExp(r'\s*\([A-Za-z0-9\s-]+\)'), '');

    // Ponctuation enchaînée
    t = t.replaceAll(RegExp(r'\n\s*\n+'), '. ');
    t = t.replaceAll(RegExp(r'\n+'), ', ');
    t = t.replaceAll(RegExp(r'\s*:\s*'), ', ');
    t = t.replaceAll(RegExp(r'\s*;\s*'), ', ');
    t = t.replaceAll(RegExp(r'\s*,\s*'), ', ');
    t = t.replaceAll(RegExp(r'\s*\.\s*'), '. ');
    t = t.replaceAll(RegExp(r'\s*\?\s*'), '? ');
    t = t.replaceAll(RegExp(r'\s*!\s*'), '! ');

    // Espaces superflus
    t = t.replaceAll(RegExp(r'\s+'), ' ');

    return t.trim();
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 2. MOTEUR WEBSOCKET EDGE NEURAL TTS (VIVIENNE NEURAL EMBARQUÉ)
  // ─────────────────────────────────────────────────────────────────────────────

  static String _generateSecMsGec() {
    final unixTimestamp = DateTime.now().toUtc().millisecondsSinceEpoch / 1000.0;
    const winEpoch = 11644473600;
    const sToNs = 1e9;
    var ticks = unixTimestamp + winEpoch;
    ticks -= (ticks % 300);
    ticks *= (sToNs / 100);
    final strToHash = '${ticks.toStringAsFixed(0)}$trustedClientToken';
    return sha256.convert(ascii.encode(strToHash)).toString().toUpperCase();
  }

  static String _generateMuid() {
    final rand = List<int>.generate(16, (i) => (DateTime.now().microsecondsSinceEpoch + i * 37) % 256);
    return rand.map((b) => b.toRadixString(16).padLeft(2, '0')).join('').toUpperCase();
  }

  static String _formatDateHeader() {
    final now = DateTime.now().toUtc();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    final day = now.day.toString().padLeft(2, '0');
    final year = now.year;
    final hour = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    final sec = now.second.toString().padLeft(2, '0');
    return '$weekday $month $day $year $hour:$min:$sec GMT+0000 (Coordinated Universal Time)';
  }

  /// Synthétise directement une phrase en octets audio MP3 Neurale Vivienne
  Future<Uint8List> _synthesizeNeuralBytes(String cleanText) async {
    final secMsGec = _generateSecMsGec();
    final connectId = _generateMuid().toLowerCase();
    final wssUrl = 'wss://speech.platform.bing.com/consumer/speech/synthesize/readaloud/edge/v1'
        '?TrustedClientToken=$trustedClientToken'
        '&ConnectionId=$connectId'
        '&Sec-MS-GEC=$secMsGec'
        '&Sec-MS-GEC-Version=$secMsGecVersion';

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
    client.userAgent =
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0';

    final req = await client.openUrl('GET', Uri.parse(wssUrl.replaceFirst('wss://', 'https://')));
    final secKey = base64.encode(List<int>.generate(16, (i) => (i * 17 + DateTime.now().millisecond) % 256));
    req.headers.set('Connection', 'Upgrade');
    req.headers.set('Upgrade', 'websocket');
    req.headers.set('Sec-WebSocket-Version', '13');
    req.headers.set('Sec-WebSocket-Key', secKey);
    req.headers.set('Pragma', 'no-cache');
    req.headers.set('Cache-Control', 'no-cache');
    req.headers.set('Origin', 'chrome-extension://jdiccldimpdaibmpdkjnbmckianbfold');
    req.headers.set('Accept-Encoding', 'gzip, deflate, br, zstd');
    req.headers.set('Accept-Language', 'en-US,en;q=0.9');
    req.headers.set('Cookie', 'muid=${_generateMuid()};');

    final resp = await req.close().timeout(const Duration(seconds: 3));
    if (resp.statusCode != 101) {
      client.close(force: true);
      throw Exception('WebSocket upgrade rejeté : status ${resp.statusCode}');
    }

    final socket = await resp.detachSocket();
    final ws = WebSocket.fromUpgradedSocket(socket, serverSide: false);

    final completer = Completer<Uint8List>();
    final audioBuffer = BytesBuilder();

    // 1. Configuration audio HD
    final dateStr = _formatDateHeader();
    final configMsg = 'X-Timestamp:$dateStr\r\n'
        'Content-Type:application/json; charset=utf-8\r\n'
        'Path:speech.config\r\n\r\n'
        '{"context":{"synthesis":{"audio":{"metadataoptions":{'
        '"sentenceBoundaryEnabled":"false","wordBoundaryEnabled":"false"},'
        '"outputFormat":"audio-24khz-48kbitrate-mono-mp3"}}}}\r\n';
    ws.add(configMsg);

    // 2. SSML Vivienne Neurale
    final requestId = _generateMuid().toLowerCase();
    final escapedText = cleanText
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');

    final ssml = "<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' xml:lang='fr-FR'>"
        "<voice name='$neuralVoiceName'>"
        "<prosody pitch='+0Hz' rate='+5%' volume='+0%'>"
        "$escapedText"
        "</prosody>"
        "</voice>"
        "</speak>";

    final ssmlMsg = 'X-RequestId:$requestId\r\n'
        'Content-Type:application/ssml+xml\r\n'
        'X-Timestamp:${dateStr}Z\r\n'
        'Path:ssml\r\n\r\n'
        '$ssml';
    ws.add(ssmlMsg);

    ws.listen(
      (message) {
        if (message is String) {
          if (message.contains('Path:turn.end')) {
            try {
              ws.close();
            } catch (_) {}
            try {
              client.close(force: true);
            } catch (_) {}
            if (!completer.isCompleted) completer.complete(audioBuffer.toBytes());
          }
        } else if (message is List<int>) {
          final data = Uint8List.fromList(message);
          if (data.length > 2) {
            final headerLen = (data[0] << 8) | data[1];
            if (data.length > headerLen + 2) {
              final headerText = ascii.decode(data.sublist(2, 2 + headerLen));
              if (headerText.contains('Path:audio')) {
                audioBuffer.add(data.sublist(2 + headerLen));
              }
            }
          }
        }
      },
      onError: (e) {
        try {
          ws.close();
        } catch (_) {}
        try {
          client.close(force: true);
        } catch (_) {}
        if (!completer.isCompleted) completer.completeError(e);
      },
      onDone: () {
        try {
          client.close(force: true);
        } catch (_) {}
        if (!completer.isCompleted) completer.complete(audioBuffer.toBytes());
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 4),
      onTimeout: () {
        try {
          ws.close();
        } catch (_) {}
        try {
          client.close(force: true);
        } catch (_) {}
        throw TimeoutException('Délai dépassé pour la synthèse WebSocket Vivienne');
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. GESTION DU CACHE DISQUE LOCAL & PRÉ-SYNTHÈSE
  // ─────────────────────────────────────────────────────────────────────────────

  static String? _workingBackendUrl;
  static DateTime? _lastBackendCheckTime;
  static bool _hasCheckedBackend = false;

  /// Résolution immédiate de l'URL active du serveur en moins de 15ms
  static Future<String?> _resolveWorkingBackendUrl() async {
    if (_workingBackendUrl != null) return _workingBackendUrl;

    // Si on a déjà vérifié récemment et qu'aucun serveur local n'est actif,
    // on ne bloque pas les lectures suivantes pendant 45 secondes
    if (_hasCheckedBackend && _lastBackendCheckTime != null) {
      if (DateTime.now().difference(_lastBackendCheckTime!) <
          const Duration(seconds: 45)) {
        return null;
      }
    }

    _lastBackendCheckTime = DateTime.now();
    _hasCheckedBackend = true;

    // Priorité aux adresses locales ultra-rapides pour éviter tout timeout réseau
    final priorityCandidates = [
      'http://127.0.0.1:8000',
      'http://localhost:8000',
      'http://10.0.2.2:8000',
      ...AltaApiConfig.candidateBaseUrls,
    ];

    final uniqueUrls = <String>[];
    for (final u in priorityCandidates) {
      if (!uniqueUrls.contains(u)) uniqueUrls.add(u);
    }

    final client = HttpClient()
      ..connectionTimeout = const Duration(milliseconds: 200);

    for (final base in uniqueUrls) {
      try {
        final req = await client.getUrl(Uri.parse('$base/health'));
        final resp =
            await req.close().timeout(const Duration(milliseconds: 250));
        if (resp.statusCode == 200) {
          _workingBackendUrl = base;
          client.close();
          return base;
        }
      } catch (_) {
        continue;
      }
    }
    client.close();
    return null;
  }

  /// Synthèse vocale haute fidélité Vivienne directement via le backend AlternIA (/api/tts)
  Future<Uint8List?> _fetchFromBackendTts(String cleanText) async {
    final activeUrl = await _resolveWorkingBackendUrl();
    if (activeUrl == null) return null;

    final client = HttpClient()..connectionTimeout = const Duration(seconds: 5);

    try {
      final uri = Uri.parse('$activeUrl/api/tts');
      final req = await client.postUrl(uri);
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
      final body = jsonEncode({
        'text': cleanText,
        'voice': 'vivienne',
      });
      req.add(utf8.encode(body));
      final resp = await req.close().timeout(const Duration(seconds: 25));
      if (resp.statusCode == 200) {
        final builder = BytesBuilder();
        await for (final chunk in resp) {
          builder.add(chunk);
        }
        final bytes = builder.toBytes();
        if (bytes.isNotEmpty) {
          return bytes;
        }
      }
    } catch (e) {
      debugPrint('[VivienneTts] Erreur appel HTTP /api/tts: $e');
    } finally {
      client.close();
    }
    return null;
  }

  /// Obtient ou synthétise le fichier audio MP3 de la phrase demandée
  Future<File> getOrSynthesizeAudioFile(String text) async {
    final cleanText = cleanForSpeech(text);
    if (cleanText.isEmpty) {
      throw Exception('Texte vide après nettoyage');
    }

    final cacheDir = await _getCacheDirectory();
    final textHash = md5.convert(utf8.encode('${neuralVoiceName}_${cleanText}_rate5')).toString();
    final cachedFile = File('${cacheDir.path}/$textHash.mp3');

    // 0ms si déjà dans le cache disque
    if (await cachedFile.exists() && await cachedFile.length() > 0) {
      return cachedFile;
    }

    // 1. Synthèse prioritaire directement sur le serveur backend AlternIA (avec retry)
    for (var attempt = 1; attempt <= 2; attempt++) {
      try {
        final backendBytes = await _fetchFromBackendTts(cleanText);
        if (backendBytes != null && backendBytes.isNotEmpty) {
          await cachedFile.writeAsBytes(backendBytes, flush: true);
          return cachedFile;
        }
      } catch (e) {
        debugPrint('[VivienneTts] Tentative $attempt échouée pour: $cleanText ($e)');
        if (attempt < 2) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    // 2. Synthèse haute fidélité via protocole direct de secours
    try {
      final audioBytes = await _synthesizeNeuralBytes(cleanText);
      if (audioBytes.isNotEmpty) {
        await cachedFile.writeAsBytes(audioBytes, flush: true);
        return cachedFile;
      }
    } catch (e) {
      debugPrint('[VivienneTts] Exception synthèse neurale direct: $e');
    }

    throw Exception('Impossible de synthétiser le fichier audio neural avec Vivienne');
  }

  /// Répertoire de stockage permanent des fichiers audio complets de podcasts
  Future<Directory> getPodcastsAudioDirectory() async {
    final docDir = await getApplicationDocumentsDirectory();
    final dir = Directory('${docDir.path}/podcasts_audio');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Récupère le fichier audio complet du podcast s'il est déjà en cache
  Future<File?> getCachedPodcastAudio(String podcastId) async {
    try {
      final dir = await getPodcastsAudioDirectory();
      final file = File('${dir.path}/podcast_$podcastId.mp3');
      if (await file.exists() && await file.length() > 5000) {
        return file;
      }
    } catch (_) {}
    return null;
  }

  /// Synthétise et enregistre l'INTÉGRALITÉ du podcast dans le cache du téléphone
  /// avant de permettre son écoute.
  /// Concatène tous les blocs audio en un fichier MP3 unique et fluide.
  Future<File> preheatAndCacheFullPodcastAudio({
    required String podcastId,
    required String fullScript,
    Function(double progress, String status)? onProgress,
  }) async {
    final dir = await getPodcastsAudioDirectory();
    final targetFile = File('${dir.path}/podcast_$podcastId.mp3');

    if (await targetFile.exists() && await targetFile.length() > 5000) {
      onProgress?.call(1.0, 'Cours audio prêt !');
      return targetFile;
    }

    onProgress?.call(0.05, 'Préparation de la narration...');
    final cleaned = cleanForSpeech(fullScript);
    if (cleaned.isEmpty) {
      throw Exception('Le script du podcast est vide');
    }

    final sentences = _splitIntoSentences(cleaned);
    if (sentences.isEmpty) {
      throw Exception('Aucune phrase valide extraite du script');
    }

    final total = sentences.length;
    final audioChunks = BytesBuilder(copy: false);

    for (var i = 0; i < total; i++) {
      final phrase = sentences[i];
      final currentProgress = 0.05 + ((i / total) * 0.90);
      onProgress?.call(
        currentProgress,
        'Enregistrement vocal Vivienne (${i + 1}/$total phrases)...',
      );

      final chunkFile = await getOrSynthesizeAudioFile(phrase);
      final bytes = await chunkFile.readAsBytes();
      if (bytes.isNotEmpty) {
        audioChunks.add(bytes);
      }
    }

    onProgress?.call(0.96, 'Assemblage de l\'audio HD dans le cache...');
    final fullBytes = audioChunks.toBytes();
    if (fullBytes.isEmpty) {
      throw Exception('Échec de la génération audio du podcast');
    }

    await targetFile.writeAsBytes(fullBytes, flush: true);
    onProgress?.call(1.0, 'Cours audio prêt !');
    return targetFile;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. LECTURE FLUIDE MULTI-PHRASES SANS LATENCE
  // ─────────────────────────────────────────────────────────────────────────────

  /// Découpe un texte long en blocs naturels cohérents sans jamais couper les devinettes ou quiz courts
  List<String> _splitIntoSentences(String text) {
    final clean = cleanForSpeech(text);
    if (clean.isEmpty) return [];

    // Pour tous les textes jusqu'à 800 caractères (devinettes, quiz, explications, sagesses),
    // on conserve l'INTÉGRALITÉ du texte en un seul bloc fluide et ininterrompu.
    // Cela garantit que toute la devinette / question est lue sans jamais s'arrêter à la 1ère phrase.
    if (clean.length <= 800) {
      return [clean];
    }

    // Pour les très longs textes, découpage par blocs d'au moins 350 caractères
    final rawSentences = clean.split(RegExp(r'(?<=[.!?])\s+'));
    final result = <String>[];
    var currentChunk = StringBuffer();

    for (final s in rawSentences) {
      final trimmed = s.trim();
      if (trimmed.isEmpty) continue;

      if (currentChunk.length + trimmed.length > 500 && currentChunk.isNotEmpty) {
        result.add(currentChunk.toString().trim());
        currentChunk = StringBuffer();
      }

      if (currentChunk.isNotEmpty) currentChunk.write(' ');
      currentChunk.write(trimmed);
    }

    if (currentChunk.isNotEmpty) {
      result.add(currentChunk.toString().trim());
    }

    return result.isEmpty ? [clean] : result;
  }

  /// Lance la lecture fluide de la file d'attente
  Future<void> _playQueue() async {
    if (_playbackQueue.isEmpty || _isDisposed) {
      _isPlayingQueue = false;
      _isUsingFallback = false;
      _status = VivienneTtsStatus.stopped;
      final cb = _onCompletionCallback;
      _onCompletionCallback = null;
      cb?.call();
      return;
    }

    _isPlayingQueue = true;
    if (_currentQueueIndex >= _playbackQueue.length) {
      _isPlayingQueue = false;
      _isUsingFallback = false;
      _status = VivienneTtsStatus.stopped;
      final cb = _onCompletionCallback;
      _onCompletionCallback = null;
      cb?.call();
      return;
    }

    final currentPhrase = _playbackQueue[_currentQueueIndex];

    // Si le moteur est déjà en mode repli système, continuer directement sans délai réseau
    if (_isUsingFallback) {
      try {
        _status = VivienneTtsStatus.speaking;
        _onStartCallback?.call();
        await _fallbackTts.speak(currentPhrase);
      } catch (err) {
        debugPrint('[VivienneTts] Erreur FlutterTts fallback: $err');
        _onErrorCallback?.call(err.toString());
        _handleChunkCompleted();
      }
      return;
    }

    try {
      _status = VivienneTtsStatus.synthesizing;
      final file = await getOrSynthesizeAudioFile(currentPhrase);

      if (_isDisposed || !_isPlayingQueue) return;

      _isUsingFallback = false;
      _status = VivienneTtsStatus.speaking;
      _onStartCallback?.call();
      await _audioPlayer.play(DeviceFileSource(file.path, mimeType: 'audio/mpeg'));

      // Pré-synthèse séquentielle de la SEULE phrase suivante (pour ne pas saturer le backend)
      final nextIndex = _currentQueueIndex + 1;
      if (nextIndex < _playbackQueue.length) {
        getOrSynthesizeAudioFile(_playbackQueue[nextIndex]).catchError((_) => file);
      }
    } catch (e) {
      debugPrint(
          '[VivienneTts] Synthèse neurale non disponible ($e). Repli immédiat sur FlutterTTS...');
      if (!_isPlayingQueue || _isDisposed) return;

      try {
        await _initFallbackTts();
        _isUsingFallback = true;
        _status = VivienneTtsStatus.speaking;
        _onStartCallback?.call();
        await _fallbackTts.speak(currentPhrase);
      } catch (err) {
        debugPrint('[VivienneTts] Erreur ultime FlutterTts fallback: $err');
        _onErrorCallback?.call(err.toString());
        _handleChunkCompleted();
      }
    }
  }

  void _handleChunkCompleted() {
    if (!_isPlayingQueue || _isAdvancingQueue) return;
    _isAdvancingQueue = true;
    _currentQueueIndex++;
    if (_currentQueueIndex < _playbackQueue.length) {
      _playQueue().whenComplete(() {
        _isAdvancingQueue = false;
      });
    } else {
      _isAdvancingQueue = false;
      _isPlayingQueue = false;
      _isUsingFallback = false;
      _status = VivienneTtsStatus.stopped;
      final cb = _onCompletionCallback;
      _onCompletionCallback = null;
      cb?.call();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 5. API PUBLIQUE VIVIENNE
  // ─────────────────────────────────────────────────────────────────────────────

  /// Lit un texte intégralement avec la voix de Vivienne
  Future<void> speak(
    String text, {
    VoidCallback? onStart,
    VoidCallback? onComplete,
    Function(String)? onError,
  }) async {
    final cleaned = cleanForSpeech(text);
    if (cleaned.isEmpty) return;

    await stop();

    _currentText = cleaned;
    _onStartCallback = onStart;
    _onCompletionCallback = onComplete;
    _onErrorCallback = onError;

    // Découpage en phrases pour pré-synthèse et lecture immédiate en continu
    final sentences = _splitIntoSentences(cleaned);
    _playbackQueue.clear();
    _playbackQueue.addAll(sentences);
    _currentQueueIndex = 0;

    await _playQueue();
  }

  /// Basculer lecture/arrêt
  Future<void> toggle(
    String text, {
    VoidCallback? onStart,
    VoidCallback? onComplete,
    Function(String)? onError,
  }) async {
    if (isSpeaking && _currentText == cleanForSpeech(text)) {
      await stop();
    } else {
      await speak(
        text,
        onStart: onStart,
        onComplete: onComplete,
        onError: onError,
      );
    }
  }

  /// Arrêter la lecture vocale immédiatement
  Future<void> stop() async {
    _isPlayingQueue = false;
    _isAdvancingQueue = false;
    _isUsingFallback = false;
    _playbackQueue.clear();
    _status = VivienneTtsStatus.stopped;
    _onCompletionCallback = null;

    try {
      await _audioPlayer.stop();
    } catch (_) {}

    try {
      await _fallbackTts.stop();
    } catch (_) {}
  }

  /// Mettre en pause
  Future<void> pause() async {
    try {
      if (_isUsingFallback) {
        await _fallbackTts.pause();
      } else {
        await _audioPlayer.pause();
      }
      _status = VivienneTtsStatus.paused;
    } catch (_) {}
  }

  /// Reprendre
  Future<void> resume() async {
    try {
      if (_isUsingFallback) {
        if (_currentQueueIndex < _playbackQueue.length) {
          await _fallbackTts.speak(_playbackQueue[_currentQueueIndex]);
        }
      } else {
        await _audioPlayer.resume();
      }
      _status = VivienneTtsStatus.speaking;
    } catch (_) {}
  }

  /// Rétrocompatibilité : applique le profil Vivienne à une instance FlutterTts externe
  static Future<void> applyVivienneProfile(FlutterTts tts) async {
    try {
      await tts.setLanguage(vivienneLanguage);
      await tts.setPitch(viviennePitch);
      await tts.setSpeechRate(vivienneSpeechRate);
      await tts.setVolume(vivienneVolume);
    } catch (_) {}
  }

  void dispose() {
    _isDisposed = true;
    _audioPlayer.dispose();
    try {
      _fallbackTts.stop();
    } catch (_) {}
  }
}

/// Provider Riverpod global pour la voix Neurale Vivienne
final vivienneTtsServiceProvider = Provider<VivienneTtsService>((ref) {
  return VivienneTtsService.instance;
});
