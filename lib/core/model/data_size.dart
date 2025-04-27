class DataSize {
  final double byte;
  static final ratio = 1024;
  static final ratioSI = 1000;

  const DataSize(this.byte);
  factory DataSize.B(double b) => DataSize(b);
  factory DataSize.kiB(double kiB) => DataSize.B(kiB * ratio);
  factory DataSize.miB(double miB) => DataSize.kiB(miB * ratio);
  factory DataSize.giB(double giB) => DataSize.miB(giB * ratio);
  factory DataSize.tiB(double tiB) => DataSize.giB(tiB * ratio);
  factory DataSize.piB(double piB) => DataSize.tiB(piB * ratio);
  factory DataSize.eiB(double eiB) => DataSize.piB(eiB * ratio);
  factory DataSize.kB(double kB) => DataSize.B(kB * ratioSI);
  factory DataSize.mB(double mb) => DataSize.kB(mb * ratioSI);
  factory DataSize.gB(double gb) => DataSize.mB(gb * ratioSI);
  factory DataSize.tB(double tb) => DataSize.gB(tb * ratioSI);
  factory DataSize.pB(double pb) => DataSize.tB(pb * ratioSI);
  factory DataSize.eB(double eb) => DataSize.pB(eb * ratioSI);
  factory DataSize.fromString(String string) {
    final String lowerCase = string.toLowerCase();
    if (lowerCase.endsWith("ib")) {
      final double value = double.parse(string.substring(0, string.length - 3));
      if (lowerCase.endsWith("eib")) {
        return DataSize.eiB(value);
      } else if (lowerCase.endsWith("pib")) {
        return DataSize.piB(value);
      } else if (lowerCase.endsWith("tib")) {
        return DataSize.tiB(value);
      } else if (lowerCase.endsWith("gib")) {
        return DataSize.giB(value);
      } else if (lowerCase.endsWith("mib")) {
        return DataSize.miB(value);
      } else if (lowerCase.endsWith("kib")) {
        return DataSize.kiB(value);
      } else {
        throw FormatException("Invalid data size string");
      }
    } else if (RegExp(r"[0-9]b$").hasMatch(lowerCase)) {
      return DataSize.B(double.parse(string.substring(0, string.length - 1)));
    } else {
      final double value = double.parse(string.substring(0, string.length - 2));
      if (lowerCase.endsWith("eb")) {
        return DataSize.eB(value);
      } else if (lowerCase.endsWith("pb")) {
        return DataSize.pB(value);
      } else if (lowerCase.endsWith("tb")) {
        return DataSize.tB(value);
      } else if (lowerCase.endsWith("gb")) {
        return DataSize.gB(value);
      } else if (lowerCase.endsWith("mb")) {
        return DataSize.mB(value);
      } else if (lowerCase.endsWith("kb")) {
        return DataSize.kB(value);
      } else {
        throw FormatException("Invalid data size string");
      }
    }
  }

  double get inB => byte;
  double get inKB => inB / ratio;
  double get inMB => inKB / ratio;
  double get inGB => inMB / ratio;
  double get inTB => inGB / ratio;
  double get inPB => inTB / ratio;
  double get inEB => inPB / ratio;
  double get inZB => inEB / ratio;
  double get inYB => inZB / ratio;

  DataSize operator +(DataSize other) => DataSize(byte + other.byte);
  DataSize operator -(DataSize other) => DataSize(byte - other.byte);
  DataSize operator *(double scalar) => DataSize(byte * scalar);
  DataSize operator /(double scalar) => DataSize(byte / scalar);

  @override
  bool operator ==(Object other) => other is DataSize && byte == other.byte;

  bool operator >(DataSize other) => byte > other.byte;
  bool operator <(DataSize other) => byte < other.byte;
  bool operator >=(DataSize other) => byte >= other.byte;
  bool operator <=(DataSize other) => byte <= other.byte;

  @override
  int get hashCode => byte.hashCode;
}
