import 'package:intl/intl.dart';
import 'package:native_exif/native_exif.dart';

class DateTimeTools {
  static Future<DateTime> fromExif(Exif exif) async =>
      DateFormat('yyyy:MM:dd HH:mm:ss')
          .parse(await exif.getAttribute('DateTime'));
}
