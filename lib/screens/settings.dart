import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:package_info/package_info.dart';
import 'package:photocoa/tools/alert_tools.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late final SharedPreferences settings;
  final future = PackageInfo.fromPlatform();
  var deleteAuto = false;
  var deleteDays = 1;

  @override
  void initState() {
    settings = GetIt.I.get<SharedPreferences>();
    deleteAuto = settings.getBool('delete_auto')!;
    deleteDays = settings.getInt('delete_days')!;
    super.initState();
  }

  void launchGithub() {
    launchUrl(Uri.parse('https://github.com/taleroangel/photocoa'),
            mode: LaunchMode.externalApplication)
        .onError((error, _) {
      AlertTools.errorSnackbar(context, "Failed to launch web link: $error");
      return true;
    });
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
              Expanded(child: Image.asset('assets/icons/cocoa_icon.png')),
              FutureBuilder(
                future: future,
                builder: (_, snapshot) {
                  if ((snapshot.connectionState == ConnectionState.done) &&
                      (snapshot.hasData)) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                      onPressed: () async => showAboutDialog(
                          applicationIcon: Image.asset(
                              'assets/icons/cocoa_icon.png',
                              width: 50),
                          applicationName: (await future).appName,
                          applicationLegalese:
                              "Powered by Flutter 🐦️\nCopyright © Ángel Talero ${DateTime.now().year}",
                          applicationVersion: (await future).version,
                          children: <Widget>[
                            const Divider(),
                            Text.rich(TextSpan(
                                text:
                                    "To see the source code for this app, please visit ",
                                children: [
                                  TextSpan(
                                      text: "photocoa GitHub repository",
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = launchGithub)
                                ]))
                          ],
                          context: context),
                      icon: const Icon(Icons.info),
                      label: const Text("About")),
                  ElevatedButton.icon(
                      onPressed: launchGithub,
                      icon: const Icon(Icons.people),
                      label: const Text("Contribute on GitHub"))
                ],
              ),
              const Divider(),
              // Automatic deletion
              Row(
                children: [
                  const Expanded(
                      child: Text.rich(TextSpan(
                          text: "Automatically delete pictures\n",
                          children: [
                        TextSpan(
                            text:
                                "NOTE: Pictures are erased once the application is opened, they'll continue existing inside your device's memory until then",
                            style: TextStyle(fontSize: 10))
                      ]))),
                  Switch(
                    activeColor: Theme.of(context).colorScheme.primary,
                    value: deleteAuto,
                    onChanged: (value) => setState(() => (deleteAuto = value)),
                  )
                ],
              ),

              // Time deletion selector
              if (deleteAuto)
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
                  (() async {
                    await settings.setBool('delete_auto', deleteAuto);
                    await settings.setInt('delete_days', deleteDays);
                  })()
                      .then((_) {
                    AlertTools.infoSnackbar(
                        context, "Settings were saved successfully");
                  }).onError((error, stackTrace) {
                    AlertTools.errorSnackbar(
                        context, "Error while storing settings");
                  });
                },
                icon: const Icon(Icons.save),
                label: const Text("Save Settings"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white),
              )
            ],
          ),
        ));
  }
}
