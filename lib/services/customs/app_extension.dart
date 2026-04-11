extension OnString on String? {
  bool get notEmptyNotNull {
    return this != null && this!.trim().isNotEmpty && runtimeType != Null;
  }
}
