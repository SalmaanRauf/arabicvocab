import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ScriptType { uthmani, indopak }

final scriptPreferenceProvider =
    StateProvider<ScriptType>((ref) => ScriptType.uthmani);
