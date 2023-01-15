import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:global_configs/global_configs.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photocoa/tools/alert_tools.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final future = PackageInfo.fromPlatform();
  var automaticDelete = false;
  var deleteDays = 1;

  @override
  void initState() {
    automaticDelete = GlobalConfigs().get('delete_auto');
    deleteDays = GlobalConfigs().get('delete_days');
    super.initState();
  }

  Future<void> saveSettings() async {
    GlobalConfigs().set<bool>('delete_auto', automaticDelete);
    GlobalConfigs().set<int>('delete_days', deleteDays);

    // Create settings file
    final settingsPath =
        '${(await getApplicationSupportDirectory()).path}/settings.json';
    final settingsFile = File(settingsPath);

    // Create settings file if missing
    if (await settingsFile.exists()) {
      await settingsFile.delete();
      await settingsFile.create();
      await settingsFile.writeAsString(jsonEncode(GlobalConfigs().configs));
    }

    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              FutureBuilder(
                future: future,
                builder: (_, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    final data = snapshot.data!;
                    return Text.rich(
                        TextSpan(text: "${data.appName} (v${data.version})"));
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
              Text(
                "Powered by Flutter 🐦️\nCopyright © Ángel Talero 2022 - ${DateTime.now().year}\n",
                textAlign: TextAlign.center,
              ),
              ElevatedButton.icon(
                  onPressed: () => showAboutDialog(
                      applicationName: "photocoa",
                      applicationLegalese:
                          "Powered by Flutter 🐦️\nCopyright © Ángel Talero 2022 - ${DateTime.now().year}",
                      children: <Widget>[
                        //TODO: GitHub
                        //Text("GITHUB HERE"),
                      ],
                      context: context),
                  icon: const Icon(Icons.info),
                  label: const Text("About")),
              const Divider(),
              // Automatic deletion
              Row(
                children: [
                  const Expanded(child: Text("Automatically delete pictures")),
                  Switch(
                    activeColor: Theme.of(context).colorScheme.primary,
                    value: automaticDelete,
                    onChanged: (value) =>
                        setState(() => (automaticDelete = value)),
                  )
                ],
              ),

              // Time deletion selector
              if (automaticDelete)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text.rich(TextSpan(children: [
                        TextSpan(
                            text: "Deletion time:\n",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 18)),
                        TextSpan(
                            text:
                                "Pictures will be automatically deleted after $deleteDays days")
                      ])),
                    ),
                    NumberPicker(
                        textStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 15),
                        selectedTextStyle: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 25),
                        minValue: 1,
                        maxValue: 31,
                        value: deleteDays,
                        onChanged: (value) =>
                            setState(() => ((deleteDays = value)))),
                  ],
                ),
              const Divider(),
              ElevatedButton.icon(
                  onPressed: () {
                    saveSettings().then((_) {
                      AlertTools.infoSnackbar(
                          context, "Settings were saved successfully");
                    }).onError((error, stackTrace) {
                      AlertTools.errorSnackbar(
                          context, "Error while storing settings");
                    });
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Save"))
            ],
          ),
        ));
  }
}
