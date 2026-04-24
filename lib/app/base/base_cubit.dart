import 'package:video_toolkit/core/utils/app_logger.dart';
import 'package:video_toolkit/app/base/app_state.dart';
import 'package:video_toolkit/widgets/loading.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BaseCubit<T> extends Cubit<CubitState<T>> {
  BaseCubit.normal(T initialState) : super(CubitState.normal(initialState));

  BaseCubit.loading(T initialState) : super(CubitState.loading(initialState));

  BaseCubit.error(String message, T initialState)
      : super(CubitState.error(message: message, data: initialState));

  void emitNormal([T? data]) {
    emit(CubitState.normal(data ?? state.data));
  }

  void emitLoading() {
    emit(CubitState.loading(state.data));
  }

  void emitError(String message) {
    emit(CubitState.error(message: message, data: state.data));
  }


  Future<void> makeAnAction(Future<void> Function() action, {
    bool showLoading = true,
    Function(Object)? onError,
  }) async {
    if (showLoading) {
      LoadingUtil.show();
    }
    try {
      final result = await action();
    } catch (e) {
      if (onError != null) {
        onError(e);
      }
    } finally {
      if (showLoading) {
        LoadingUtil.dismiss();
      }
    }
    return;
  }

  T get currentData => state.data;

  /// Maximum length for an inline value before [_formatValue] summarises it.
  static const int _maxInlineValueLength = 80;

  /// Bloc hook fired before every state transition. We use it as the single
  /// place to log a concise, field-level diff of the outgoing vs. incoming
  /// state so screens don't each log the whole object themselves.
  @override
  void onChange(Change<CubitState<T>> change) {
    super.onChange(change);
    final diffMessage = _buildStateDiff(change.currentState, change.nextState);
    if (diffMessage != null) {
      appLogger.d('${state.runtimeType} in $runtimeType: $diffMessage');
    }
  }

  /// Builds a single-line human-readable diff between two [CubitState]s.
  ///
  /// Returns `null` when the two states are effectively equal (same runtime
  /// type, same data, same error message) so that callers can skip logging.
  String? _buildStateDiff(CubitState<T> oldState, CubitState<T> newState) {
    final stateTypeChanged = oldState.runtimeType != newState.runtimeType;
    final dataFieldDiff = _diffFreezedToString(
      oldState.data?.toString() ?? 'null',
      newState.data?.toString() ?? 'null',
    );
    final errorMessageDiff = _diffErrorMessage(oldState, newState);
    if (!stateTypeChanged && dataFieldDiff.isEmpty && errorMessageDiff == null) {
      return null;
    }

    final diffParts = <String>[];
    if (stateTypeChanged) {
      diffParts.add('${oldState.runtimeType} -> ${newState.runtimeType}');
    }
    if (errorMessageDiff != null) diffParts.add(errorMessageDiff);
    dataFieldDiff.forEach((fieldPath, change) {
      diffParts.add('$fieldPath: $change');
    });
    return diffParts.join(', ');
  }

  /// Returns a `"message: old -> new"` fragment when either state is an
  /// [ErrorState] with a different message. Returns `null` when the messages
  /// are equal or neither state is an error.
  String? _diffErrorMessage(CubitState<T> oldState, CubitState<T> newState) {
    final oldMessage = oldState is ErrorState<T> ? oldState.message : null;
    final newMessage = newState is ErrorState<T> ? newState.message : null;
    if (oldMessage == newMessage) return null;
    return 'message: ${_formatValue(oldMessage ?? '-')} '
        '-> ${_formatValue(newMessage ?? '-')}';
  }

  /// Diffs two freezed `toString()` outputs and returns a map of
  /// `fieldPath -> "oldValue -> newValue"` for fields that actually differ.
  ///
  /// When a field holds a nested freezed object of the same class on both
  /// sides, the function recurses and emits dotted paths
  /// (e.g. `encodeSettings.textOverlaySize`) so deep changes stay readable
  /// instead of being lost inside a truncated summary.
  Map<String, String> _diffFreezedToString(String oldString, String newString) {
    if (oldString == newString) return const {};

    final oldFields = _parseFreezedToString(oldString);
    final newFields = _parseFreezedToString(newString);
    if (oldFields == null || newFields == null) {
      return {
        'data': '${_formatValue(oldString)} -> ${_formatValue(newString)}',
      };
    }

    final allFieldNames = <String>{...oldFields.keys, ...newFields.keys};
    final diff = <String, String>{};
    for (final fieldName in allFieldNames) {
      final oldValue = oldFields[fieldName];
      final newValue = newFields[fieldName];
      if (oldValue == newValue) continue;

      if (oldValue != null &&
          newValue != null &&
          _haveSameClassName(oldValue, newValue)) {
        final nestedDiff = _diffFreezedToString(oldValue, newValue);
        if (nestedDiff.isNotEmpty) {
          nestedDiff.forEach((nestedField, nestedChange) {
            diff['$fieldName.$nestedField'] = nestedChange;
          });
          continue;
        }
      }

      if (oldValue != null &&
          newValue != null &&
          _isListLiteral(oldValue) &&
          _isListLiteral(newValue)) {
        final listDiff = _diffListLiteral(oldValue, newValue);
        if (listDiff.isNotEmpty) {
          listDiff.forEach((indexPath, indexChange) {
            diff['$fieldName$indexPath'] = indexChange;
          });
          continue;
        }
      }
      diff[fieldName] =
          '${_formatValue(oldValue ?? '-')} -> ${_formatValue(newValue ?? '-')}';
    }
    return diff;
  }

  /// Returns `true` when [value] is a string in the form `[...]`, i.e. the
  /// `toString()` of a Dart list.
  bool _isListLiteral(String value) =>
      value.startsWith('[') && value.endsWith(']');

  /// Diffs two list literals element-by-element. Keys returned are suffixes
  /// like `[2].fontSize` meant to be appended to the owning field name so
  /// callers can produce paths such as `textOverlays[2].fontSize`.
  ///
  /// When lists differ in length, falls back to a single `-> ` summary so the
  /// caller can render it with [_formatValue].
  Map<String, String> _diffListLiteral(
    String oldListLiteral,
    String newListLiteral,
  ) {
    final oldElements = _splitTopLevel(
      oldListLiteral.substring(1, oldListLiteral.length - 1),
      separator: ',',
    ).map((e) => e.trim()).toList();
    final newElements = _splitTopLevel(
      newListLiteral.substring(1, newListLiteral.length - 1),
      separator: ',',
    ).map((e) => e.trim()).toList();

    if (oldElements.length != newElements.length) {
      return {
        '': '${_formatValue(oldListLiteral)} -> ${_formatValue(newListLiteral)}',
      };
    }

    final diff = <String, String>{};
    for (var index = 0; index < oldElements.length; index++) {
      final oldElement = oldElements[index];
      final newElement = newElements[index];
      if (oldElement == newElement) continue;

      if (_haveSameClassName(oldElement, newElement)) {
        final nestedDiff = _diffFreezedToString(oldElement, newElement);
        if (nestedDiff.isNotEmpty) {
          nestedDiff.forEach((nestedField, nestedChange) {
            diff['[$index].$nestedField'] = nestedChange;
          });
          continue;
        }
      }
      diff['[$index]'] =
          '${_formatValue(oldElement)} -> ${_formatValue(newElement)}';
    }
    return diff;
  }

  /// Returns `true` when both strings look like `ClassName(...)` with the
  /// same `ClassName`, signalling it's safe to recurse into them.
  bool _haveSameClassName(String firstToString, String secondToString) {
    final firstParenIndex = firstToString.indexOf('(');
    final secondParenIndex = secondToString.indexOf('(');
    if (firstParenIndex <= 0 || secondParenIndex <= 0) return false;
    if (!firstToString.endsWith(')') || !secondToString.endsWith(')')) {
      return false;
    }
    return firstToString.substring(0, firstParenIndex) ==
        secondToString.substring(0, secondParenIndex);
  }

  /// Parses `ClassName(field1: value1, field2: value2)` into a
  /// `{fieldName: valueString}` map. Returns `null` when the input is not in
  /// that shape (e.g. a primitive or a non-freezed `toString()`).
  Map<String, String>? _parseFreezedToString(String freezedToString) {
    final openParenIndex = freezedToString.indexOf('(');
    if (openParenIndex <= 0 || !freezedToString.endsWith(')')) return null;

    final body = freezedToString.substring(
      openParenIndex + 1,
      freezedToString.length - 1,
    );
    if (body.isEmpty) return const {};

    final rawFields = _splitTopLevel(body, separator: ',');
    final parsedFields = <String, String>{};
    for (final rawField in rawFields) {
      // Don't trim first: an empty value like `text: ` becomes `text:` after
      // trimming and hides the `: ` separator we need. Locate the colon on
      // the untrimmed segment, then trim name and value independently.
      final colonIndex = rawField.indexOf(':');
      if (colonIndex <= 0) return null;
      final fieldName = rawField.substring(0, colonIndex).trim();
      final fieldValue = rawField.substring(colonIndex + 1).trim();
      if (fieldName.isEmpty) return null;
      parsedFields[fieldName] = fieldValue;
    }
    return parsedFields;
  }

  /// Splits [input] on [separator] characters that sit at bracket depth zero.
  /// Used to parse freezed field lists without being confused by commas that
  /// appear inside nested `(...)`, `[...]` or `{...}` values.
  List<String> _splitTopLevel(String input, {required String separator}) {
    final segments = <String>[];
    final currentSegment = StringBuffer();
    var bracketDepth = 0;
    for (var i = 0; i < input.length; i++) {
      final character = input[i];
      if (character == '(' || character == '[' || character == '{') {
        bracketDepth++;
      } else if (character == ')' || character == ']' || character == '}') {
        bracketDepth--;
      }
      if (character == separator && bracketDepth == 0) {
        segments.add(currentSegment.toString());
        currentSegment.clear();
      } else {
        currentSegment.write(character);
      }
    }
    if (currentSegment.isNotEmpty) segments.add(currentSegment.toString());
    return segments;
  }

  /// Renders a single value for the diff line. Long lists/maps are summarised
  /// to `[N items]` / `{N entries}`; other long strings are truncated with an
  /// ellipsis so one noisy field can't dominate the log line.
  String _formatValue(String value) {
    if (value.length <= _maxInlineValueLength) return value;
    if (value.startsWith('[') && value.endsWith(']')) {
      final itemCount = _countTopLevelElements(value.substring(1, value.length - 1));
      return '[$itemCount items]';
    }
    if (value.startsWith('{') && value.endsWith('}')) {
      final entryCount = _countTopLevelElements(value.substring(1, value.length - 1));
      return '{$entryCount entries}';
    }
    return '${value.substring(0, _maxInlineValueLength - 3)}...';
  }

  /// Counts elements in the comma-separated body of a collection literal
  /// (the content between the surrounding brackets). Returns `0` when the
  /// body is empty so a summary like `[0 items]` reads naturally.
  int _countTopLevelElements(String collectionBody) {
    if (collectionBody.isEmpty) return 0;
    return _splitTopLevel(collectionBody, separator: ',').length;
  }
}
