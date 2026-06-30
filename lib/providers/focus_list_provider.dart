import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FocusListState {
  final FocusNode? focusNodeAward;
  final FocusNode? focusNodeNumberSpecWinners;

  FocusListState({
    this.focusNodeAward,
    this.focusNodeNumberSpecWinners,
  });

  FocusListState copyWith({
    FocusNode? focusNodeAward,
    FocusNode? focusNodeNumberSpecWinners,
  }) {
    return FocusListState(
      focusNodeAward: focusNodeAward ?? this.focusNodeAward,
      focusNodeNumberSpecWinners: focusNodeNumberSpecWinners ?? this.focusNodeNumberSpecWinners,
    );
  }
}

class FocusListProvider extends StateNotifier<FocusListState> {
  FocusListProvider() : super(FocusListState());

  void setFocusNodes({
    required FocusNode focusNodeAward,
    required FocusNode focusNodeNumberSpecWinners,
  }) {
    state = FocusListState(
      focusNodeAward: focusNodeAward,
      focusNodeNumberSpecWinners: focusNodeNumberSpecWinners,
    );
  }

  void unfocusAll() {
    state.focusNodeAward?.unfocus();
    state.focusNodeNumberSpecWinners?.unfocus();
  }

  void disposeAll() {
    state.focusNodeAward?.dispose();
    state.focusNodeNumberSpecWinners?.dispose();
  }

  void focusAward() {
    state.focusNodeAward?.requestFocus();
  }

  void focusNumberSpec() {
    state.focusNodeNumberSpecWinners?.requestFocus();
  }
}

final focusListProvider = StateNotifierProvider<FocusListProvider, FocusListState>(
  (ref) => FocusListProvider(),
);
