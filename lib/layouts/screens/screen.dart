import 'package:flutter/material.dart';
import 'package:fparted/core/base.dart';
import 'package:fparted/layouts/components/disk_screen.dart';

class Screen extends StatefulWidget {
  final List<Disk> disks;
  final VoidCallback reload;
  const Screen(this.disks, this.reload,{super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  late final List<Disk> disks;
  final List<Widget> contents = [
    Center(
      child: Column(
        children: [
          Text('No disks'),
          IconButton.filled(onPressed: () {}, icon: Icon(Icons.add)),
        ],
      ),
    ),
  ];
  int selectedIndex = 0;

  @override
  void initState() {
    disks = widget.disks;
    if (disks.isNotEmpty) {
      selectedIndex = 1;
      for (final disk in disks) {
        contents.add(DiskScreen(disk, key: UniqueKey()));
      }
    }
    super.initState();
  }

  void setSelected(int index) => setState(() => selectedIndex = index + 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              destinations:
                  disks.map((disk) {
                    return NavigationRailDestination(
                      icon: Icon(
                        Icons.drive_file_move_rounded,
                        semanticLabel: disk.device.raw,
                      ),
                      label: Text(disk.device.raw.split('/').last),
                      // label: Text(disk.device.raw),
                    );
                  }).toList(),
              selectedIndex: selectedIndex == 0 ? null : (selectedIndex - 1),
              onDestinationSelected: setSelected,
              leading: Column(
                children: [
                  IconButton.filled(
                    onPressed: widget.reload,
                    icon: Icon(Icons.refresh),
                  ),
                ],
              ),
              trailing: Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.add_outlined),
                      tooltip: "Penetrate custom device",
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.download_outlined),
                      tooltip: "Dump whole disk",
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.settings_outlined),
                      tooltip: "Settings",
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
              // extended: true,
              labelType: NavigationRailLabelType.all,
            ),
            Expanded(child: contents[selectedIndex]),
          ],
        ),
      ),
    );
  }
}
