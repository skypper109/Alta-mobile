library;

import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../presentation/router/app_router.dart';

export '../presentation/router/app_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return ref.watch(appRouterProvider);
});
