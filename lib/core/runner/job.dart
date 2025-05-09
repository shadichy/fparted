import 'package:fparted/core/model/device.dart';

class Job {
  final String command;
  final List<String> arguments;

  const Job(this.command, this.arguments);

  @override
  String toString() => "command: '$command ${arguments.join(" ")}'";
}

class PartedJob extends Job {
  final Device device;
  PartedJob(this.device, final List<String> arguments)
    : super(device.raw, arguments);

  Job toJob() => Job(device.raw, arguments);
}
