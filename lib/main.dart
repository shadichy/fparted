import 'package:flutter/material.dart';
import 'package:fparted/core/base.dart';
import 'package:fparted/core/cached/cached.dart';
import 'package:fparted/core/runner/job.dart';
import 'package:fparted/core/runner/wrapper.dart';
import 'package:fparted/layouts/dialogs/dialog.dart';
import 'package:fparted/layouts/screens/loading.dart';
import 'package:fparted/layouts/screens/screen.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'FPARTED',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
      ),
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      locale: Locale("en", "US"),
      supportedLocales: [Locale("en", "US"), Locale("vi", "VN")],
      home: const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final loading = const Loading();
  late Widget content;

  void setContent() => Disk.all.then((l) {
    Cached().disks = l;
    setState(() => content = Screen(l, reload));
  });

  void reload() async {
    final b =
        Jobs.jobs.isEmpty ||
        await showConfirmDialog(
          context,
          "All panding jobs will be lost! Continue?",
        );

    if (b) {
      Jobs.clear();
      setState(() => content = loading);
      setContent();
    }
  }

  @override
  void initState() {
    super.initState();
    content = loading;

    Wrapper.init().then((_) => setContent()).onError((e, s) {
      print(e);
      print(s);
      setState(() {
        content = Scaffold(
          body: Center(child: Text("Failed: Missing toolchain")),
        );
      });
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return content;
  }
}
