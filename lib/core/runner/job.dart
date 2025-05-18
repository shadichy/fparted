import 'dart:async';
import 'dart:io';

import 'package:fparted/core/model/device.dart';
import 'package:fparted/core/runner/wrapper.dart';

class Job {
  final String label;
  final String command;
  final List<String> arguments;

  const Job(this.command, this.arguments, [this.label = ""]);

  @override
  String toString() => "command: '$command ${arguments.join(" ")}'";
}

class DeviceJob {
  final Device device;
  final List<String> arguments;
  final String label;
  DeviceJob(this.device, this.arguments, [this.label = ""]);
}

class JobResult {
  final Job job;
  final ProcessResult result;

  const JobResult(this.job, this.result);
}

abstract final class Jobs {
  static List<Job> get jobs => _Jobs()._jobs;
  static void add(Job job) => _Jobs()._add(job);
  static void addAll(List<Job> jobs) => _Jobs()._addAll(jobs);
  static void clear() => _Jobs()._clear();
  static void undo() => _Jobs()._undo();
  static Future<List<JobResult>> runJobs() => _Jobs()._runJobs();
  static List<JobResult> runJobsSync() => _Jobs()._runJobsSync();
  static Stream<JobResult> get runJobsStream => _Jobs()._runJobsStream;
}

final class _Jobs {
  static final _i = _Jobs._();
  _Jobs._();
  factory _Jobs() => _i;

  final List<int> _tasksToUndo = [];

  final List<Job> _jobs = [];

  void _add(Job job) {
    _jobs.add(job);
    _tasksToUndo.add(1);
  }

  void _addAll(List<Job> jobs) {
    _jobs.addAll(jobs);
    _tasksToUndo.add(jobs.length);
  }

  void _clear() {
    _jobs.clear();
    _tasksToUndo.clear();
  }

  void _undo() {
    if (_tasksToUndo.isEmpty) return;
    _jobs.removeRange(_jobs.length - _tasksToUndo.last, _jobs.length);
    _tasksToUndo.removeLast();
  }

  Future<List<JobResult>> _runJobs() async {
    List<JobResult> results = [];
    for (final job in _jobs) {
      results.add(JobResult(job, await Wrapper.runJob(job)));
    }
    return results;
  }

  List<JobResult> _runJobsSync() {
    List<JobResult> results = [];
    for (final job in _jobs) {
      results.add(JobResult(job, Wrapper.runJobSync(job)));
    }
    return results;
  }

  Stream<JobResult> get _runJobsStream async* {
    for (final job in _jobs) {
      yield JobResult(job, await Wrapper.runJob(job));
    }
  }
}
