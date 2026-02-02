import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ScriptType { uthmani, indopak }

/// Default to IndoPak script which is more readable for non-Arabs
final scriptPreferenceProvider =
    StateProvider<ScriptType>((ref) => ScriptType.indopak);
