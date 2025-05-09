class DataSize {
  final int byte;
  static final ratio = 1024;
  static final ratioSI = 1000;

  static final zero = DataSize._init(0);
  static final max = DataSize._init(-1);

  DataSize._init(this.byte);
  factory DataSize(BigInt byte) => DataSize._init(byte.toSigned(64).toInt());
  factory DataSize.B(BigInt b) => DataSize(b);
  factory DataSize.kiB(BigInt kiB) => DataSize.B(kiB * BigInt.from(ratio));
  factory DataSize.miB(BigInt miB) => DataSize.kiB(miB * BigInt.from(ratio));
  factory DataSize.giB(BigInt giB) => DataSize.miB(giB * BigInt.from(ratio));
  factory DataSize.tiB(BigInt tiB) => DataSize.giB(tiB * BigInt.from(ratio));
  factory DataSize.piB(BigInt piB) => DataSize.tiB(piB * BigInt.from(ratio));
  factory DataSize.eiB(BigInt eiB) => DataSize.piB(eiB * BigInt.from(ratio));
  factory DataSize.kB(BigInt kB) => DataSize.B(kB * BigInt.from(ratioSI));
  factory DataSize.mB(BigInt mb) => DataSize.kB(mb * BigInt.from(ratioSI));
  factory DataSize.gB(BigInt gb) => DataSize.mB(gb * BigInt.from(ratioSI));
  factory DataSize.tB(BigInt tb) => DataSize.gB(tb * BigInt.from(ratioSI));
  factory DataSize.pB(BigInt pb) => DataSize.tB(pb * BigInt.from(ratioSI));
  factory DataSize.eB(BigInt eb) => DataSize.pB(eb * BigInt.from(ratioSI));
  factory DataSize.fromBlock(BigInt blockCount, DataSize blockSize) =>
      DataSize(blockCount * blockSize.inB);
  factory DataSize.parse(String source, {int? radix}) =>
      DataSize(BigInt.parse(source));
  factory DataSize.fromString(String string) {
    final String lowerCase = string.toLowerCase();
    if (lowerCase.endsWith("ib")) {
      final BigInt value = BigInt.parse(string.substring(0, string.length - 3));
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
    } else if (RegExp(r"[0-9]+b$").hasMatch(lowerCase)) {
      return DataSize.B(BigInt.parse(string.substring(0, string.length - 1)));
    } else {
      final BigInt value = BigInt.parse(string.substring(0, string.length - 2));
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

  BigInt get inB => BigInt.from(byte).toUnsigned(64);
  double get inKB => inB / BigInt.from(ratioSI);
  double get inMB => inKB / ratioSI;
  double get inGB => inMB / ratioSI;
  double get inTB => inGB / ratioSI;
  double get inPB => inTB / ratioSI;
  double get inEB => inPB / ratioSI;
  double get inZB => inEB / ratioSI;
  double get inYB => inZB / ratioSI;
  double get inKiB => inB / BigInt.from(ratio);
  double get inMiB => inKiB / ratio;
  double get inGiB => inMiB / ratio;
  double get inTiB => inGiB / ratio;
  double get inPiB => inTiB / ratio;
  double get inEiB => inPiB / ratio;
  double get inZiB => inEiB / ratio;
  double get inYiB => inZiB / ratio;

  (double, String) _inKiB() => (inKiB, "KiB");
  (double, String) _inMiB() => (inMiB, "MiB");
  (double, String) _inGiB() => (inGiB, "GiB");
  (double, String) _inTiB() => (inTiB, "TiB");
  (double, String) _inPiB() => (inPiB, "PiB");
  (double, String) _inEiB() => (inEiB, "EiB");
  (double, String) _inZiB() => (inZiB, "ZiB");
  (double, String) _inYiB() => (inYiB, "YiB");

  DataSize operator +(DataSize other) => DataSize(inB + other.inB);
  DataSize operator -(DataSize other) => DataSize(inB - other.inB);

  // DataSize operator *(double scalar) => DataSize(BigInt.from(byte) * scalar);
  // DataSize operator /(double scalar) => DataSize(BigInt.from(byte) / scalar);

  @override
  bool operator ==(Object other) => other is DataSize && byte == other.byte;

  bool operator >(DataSize other) => byte > other.byte;
  bool operator <(DataSize other) => byte < other.byte;
  bool operator >=(DataSize other) => byte >= other.byte;
  bool operator <=(DataSize other) => byte <= other.byte;

  @override
  int get hashCode => byte.hashCode;

  @override
  String toString() => "${inB.toString()}B";

  String humanReadable() {
    var result = toString();
    for (final func in [
      _inKiB,
      _inMiB,
      _inGiB,
      _inTiB,
      _inPiB,
      _inEiB,
      _inZiB,
      _inYiB,
    ]) {
      final value = func();
      if (value.$1 <= 1) break;
      result = "${value.$1.toStringAsFixed(2)}${value.$2}";
    }
    return result;
  }
}
