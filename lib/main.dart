import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_it/get_it.dart';
import 'package:global_configs/global_configs.dart';
import 'package:intl/intl.dart';
import 'package:native_exif/native_exif.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photocoa/providers/camera_hardware_provider.dart';
import 'package:photocoa/screens/home_screen.dart';
import 'package:photocoa/tools/datetime_tools.dart';
import 'package:provider/provider.dart';

void main() async {
  // Flutter initialization
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // Set orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Dependency injection
  GetIt.I.registerSingleton<AudioPlayer>(AudioPlayer());
  // Run application
  FlutterNativeSplash.remove();
  runApp(const Application());
}

Future<void> initialize() async {
  // Load settings
  GlobalConfigs().loadJsonFromdir('assets/config/settings.json');
  // Create settings file
  final settingsPath =
      '${(await getApplicationSupportDirectory()).path}/settings.json';
  final settingsFile = File(settingsPath);

  try {
    // Create settings file if missing
    if (!await settingsFile.exists()) {
      await settingsFile.create();
      final json = jsonEncode(GlobalConfigs().configs);
      await settingsFile.writeAsString(json);
    }

    final settingsJson = jsonDecode(await settingsFile.readAsString());

    for (var element in settingsJson.entries) {
      GlobalConfigs().set(element.key, element.value);
    }
  } catch (_) {
    settingsFile.delete();
  }

  // Erase photos
  final filesPath = await getApplicationDocumentsDirectory();
  final allfiles = filesPath
      .listSync()
      .where((event) => (extension(event.path) == '.jpg'))
      .map((event) => File(event.path));

  final deleteDays = GlobalConfigs().get('delete_days');

  for (var file in allfiles) {
    // Get image date
    final exif = await Exif.fromPath(file.path);
    // Parse datetime from image data
    final datetime = DateFormat('yyyy:MM:dd HH:mm:ss')
        .parse(await exif.getAttribute('DateTime'));
    // Calculate days from now
    final daysSince = DateTimeTools.daysSinceDate(datetime);
    // Delete if days greater than settings days
    if (daysSince >= deleteDays) {
      await file.delete();
    }
  }

  return Future.value();
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CameraHardwareProvider())
        ],
        child: MaterialApp(
            theme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.deepOrange,
              colorScheme: ColorScheme.fromSwatch(
                  primarySwatch: Colors.deepOrange,
                  brightness: Brightness.dark),
              useMaterial3: true,
            ),
            home: const _LoadScreen()),
      );
}

class _LoadScreen extends StatefulWidget {
  const _LoadScreen({Key? key}) : super(key: key);

  @override
  State<_LoadScreen> createState() => _LoadScreenState();
}

class _LoadScreenState extends State<_LoadScreen> {
  late final Future<void> future;

  @override
  void initState() {
    super.initState();
    future = initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Push replacement
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(28.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    "Updating settings and erasing old photos, this process may take a while\n",
                    textAlign: TextAlign.center,
                  ),
                  LinearProgressIndicator(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
