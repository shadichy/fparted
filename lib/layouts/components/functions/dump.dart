import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/runner/dd/binarry.dart';
import 'package:fparted/core/runner/job.dart';
import 'package:fparted/layouts/components/functions/pick_folder.dart';

Future<List<Job>> dumpDevice(Device device) async {
  final folder = await FolderPicker.pickFolder();
  if (folder == null) return [];
  return [
    DDBinary().copy(
      inFile: device.raw,
      outFile: "$folder/${device.raw.split('/').last}.img",
    ),
  ];
}
