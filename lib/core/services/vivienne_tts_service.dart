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

  VivienneTtsStatus _status = VivienneTtsStatus.idle;
  String? _currentText;
  Directory? _cacheDir;
  bool _isDisposed = false;

  // File d'attente pour la lecture continue fluide
  final List<String> _playbackQueue = [];
  bool _isPlayingQueue = false;
  int _currentQueueIndex = 0;

  VoidCallback? _onStartCallback;
  VoidCallback? _onCompletionCallback;
  Function(String)? _onErrorCallback;

  VivienneTtsStatus get status => _status;
  bool get isSpeaking => _status == VivienneTtsStatus.speaking || _status == VivienneTtsStatus.synthesizing;
  String? get currentText => _currentText;

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);

      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.playing) {
          _status = VivienneTtsStatus.speaking;
        } else if (state == PlayerState.paused) {
          _status = VivienneTtsStatus.paused;
        } else if (state == PlayerState.stopped) {
          if (!_isPlayingQueue) {
            _status = VivienneTtsStatus.stopped;
          }
        } else if (state == PlayerState.completed) {
          _handleChunkCompleted();
        }
      });
    } catch (e) {
      debugPrint('[VivienneTts] Erreur init AudioPlayer: $e');
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

    final client = HttpClient();
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

    final resp = await req.close();
    if (resp.statusCode != 101) {
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
            ws.close();
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
        if (!completer.isCompleted) completer.completeError(e);
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete(audioBuffer.toBytes());
      },
    );

    return completer.future;
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 3. GESTION DU CACHE DISQUE LOCAL & PRÉ-SYNTHÈSE
  // ─────────────────────────────────────────────────────────────────────────────

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

    // Synthèse haute fidélité via protocole neural
    try {
      final audioBytes = await _synthesizeNeuralBytes(cleanText);
      if (audioBytes.isNotEmpty) {
        await cachedFile.writeAsBytes(audioBytes, flush: true);
        return cachedFile;
      }
    } catch (e) {
      debugPrint('[VivienneTts] Exception synthèse neurale: $e');
    }

    throw Exception('Impossible de synthétiser le fichier audio neural');
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // 4. LECTURE FLUIDE MULTI-PHRASES SANS LATENCE
  // ─────────────────────────────────────────────────────────────────────────────

  /// Découpe un texte long en phrases naturelles
  List<String> _splitIntoSentences(String text) {
    final clean = cleanForSpeech(text);
    if (clean.isEmpty) return [];

    final rawSentences = clean.split(RegExp(r'(?<=[.!?])\s+'));
    final result = <String>[];

    for (final s in rawSentences) {
      final trimmed = s.trim();
      if (trimmed.length > 5) {
        result.add(trimmed);
      } else if (result.isNotEmpty && trimmed.isNotEmpty) {
        result[result.length - 1] = '${result.last} $trimmed';
      }
    }

    return result.isEmpty ? [clean] : result;
  }

  /// Lance la lecture fluide de la file d'attente
  Future<void> _playQueue() async {
    if (_playbackQueue.isEmpty || _isDisposed) {
      _isPlayingQueue = false;
      _status = VivienneTtsStatus.stopped;
      _onCompletionCallback?.call();
      return;
    }

    _isPlayingQueue = true;
    final currentPhrase = _playbackQueue[_currentQueueIndex];

    try {
      _status = VivienneTtsStatus.synthesizing;
      final file = await getOrSynthesizeAudioFile(currentPhrase);

      if (_isDisposed || !_isPlayingQueue) return;

      _status = VivienneTtsStatus.speaking;
      _onStartCallback?.call();
      await _audioPlayer.play(DeviceFileSource(file.path, mimeType: 'audio/mpeg'));

      // Pré-synthèse en tâche de fond de la phrase suivante pour 0ms de coupure
      final nextIndex = _currentQueueIndex + 1;
      if (nextIndex < _playbackQueue.length) {
        getOrSynthesizeAudioFile(_playbackQueue[nextIndex]).catchError((_) => file);
      }
    } catch (e) {
      debugPrint('[VivienneTts] Erreur lecture phrase neurale: $e');
      // Repli immédiat de secours
      _fallbackSpeak(currentPhrase);
    }
  }

  void _handleChunkCompleted() {
    if (!_isPlayingQueue) return;
    _currentQueueIndex++;
    if (_currentQueueIndex < _playbackQueue.length) {
      _playQueue();
    } else {
      _isPlayingQueue = false;
      _status = VivienneTtsStatus.stopped;
      final cb = _onCompletionCallback;
      _onCompletionCallback = null;
      cb?.call();
    }
  }

  /// Repli automatique si le réseau est totalement indisponible et qu'aucun cache n'existe
  Future<void> _fallbackSpeak(String text) async {
    try {
      await _fallbackTts.setLanguage(vivienneLanguage);
      await _fallbackTts.setPitch(viviennePitch);
      await _fallbackTts.setSpeechRate(vivienneSpeechRate);
      await _fallbackTts.speak(text);
    } catch (e) {
      _status = VivienneTtsStatus.error;
      _onErrorCallback?.call(e.toString());
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
    _playbackQueue.clear();
    _status = VivienneTtsStatus.stopped;
    _onCompletionCallback = null;

    try {
      await _audioPlayer.stop();
      await _fallbackTts.stop();
    } catch (_) {}
  }

  /// Mettre en pause
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      _status = VivienneTtsStatus.paused;
    } catch (_) {}
  }

  /// Reprendre
  Future<void> resume() async {
    try {
      await _audioPlayer.resume();
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
    _fallbackTts.stop();
  }
}

/// Provider Riverpod global pour la voix Neurale Vivienne
final vivienneTtsServiceProvider = Provider<VivienneTtsService>((ref) {
  return VivienneTtsService.instance;
});
