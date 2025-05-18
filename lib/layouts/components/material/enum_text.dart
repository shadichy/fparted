String renderEnum(Enum e) {
  String s = e.name.toLowerCase();
  return s[0].toUpperCase() + s.substring(1);
}