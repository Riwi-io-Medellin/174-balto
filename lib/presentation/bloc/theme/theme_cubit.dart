import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/token_storage.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._tokenStorage) : super(ThemeMode.light) {
    _init();
  }

  final TokenStorage _tokenStorage;

  Future<void> _init() async {
    final isDark = await _tokenStorage.readDarkMode();
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _tokenStorage.saveDarkMode(next == ThemeMode.dark);
    emit(next);
  }
}
