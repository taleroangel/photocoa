import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:photocoa/providers/camera_hardware_provider.dart';
import 'package:photocoa/screens/home_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  // Flutter initialization
  WidgetsFlutterBinding.ensureInitialized();
  // Set orientation
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // Dependency injection
  GetIt.I.registerSingleton<AudioPlayer>(
      AudioPlayer()..setSourceAsset('sound/shutter_click.mp3'));
  // Run application
  runApp(const Application());
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
                primarySwatch: Colors.deepOrange,
                useMaterial3: true,
                brightness: Brightness.dark),
            home: const HomeScreen()),
      );
}
