import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:tralala_app/core/data/db.dart';
import 'package:tralala_app/core/models/identity.dart';
import 'package:tralala_app/core/providers/chat.provider.dart';
import 'package:tralala_app/core/providers/user.provider.dart';
import 'package:tralala_app/core/providers/onboarding.provider.dart';
import 'package:tralala_app/core/services/keys.dart';
import 'package:tralala_app/core/data/sockets.dart';
import 'package:tralala_app/ui/screens/onboarding/intro.dart';
import 'package:tralala_app/ui/screens/onboarding/permissions.dart';
import 'package:tralala_app/ui/screens/onboarding/phone.dart';
import 'package:tralala_app/ui/screens/onboarding/profile.dart';
import 'package:tralala_app/ui/screens/root.dart';
import 'package:tralala_app/ui/widgets/shared/splash_screen.dart';
import 'package:unique_and_permanent_device_identifier/device_identifier_manager/device_identifier_manager.dart';

void main() async {
  // call this method to allow flutter draw its first frame
  // before performing any async action
  WidgetsFlutterBinding.ensureInitialized();

  final storage = const FlutterSecureStorage();

  final user = await storage.read(key: "UserData");
  final hasCompletedOnboarding = await storage.read(
    key: "HasCompletedOnboarding",
  );
  await DatabaseHelper.instance.database;

  // According to Sesame protocol:
  //  Each device stores an identity key pair (a public key and private key)
  //  for cryptographic authentication. A device will always have
  //  the same DeviceID and identity key pair (to change these for some
  //  physical device the device must be uninstalled and then added with new values).

  String? deviceId = await storage.read(key: "DeviceID");
  String? identity = await storage.read(key: "IdentityKey");

  if (deviceId == null) {
    print("No device id found, generating new one");

    // Initialize device identifier manager and database
    DeviceIdentifierManager.initialize('tralala_app');
    final newDeviceId = await DeviceIdentifierManager.instance.getDeviceId();

    print("Generated new device ID: $newDeviceId");
    await storage.write(key: "DeviceID", value: newDeviceId);

    deviceId = newDeviceId;
  }

  if (identity == null) {
    print("No identity key found, generating new one");

    final newIdentity = await Identity.generate();

    print("Registering identity");
    await KeyService.registerIdentity(newIdentity, deviceId);
    print("Uploaded identity");

    await storage.write(
      key: "IdentityKey",
      value: jsonEncode(await newIdentity.toJson()),
    );

    identity = jsonEncode(await newIdentity.toJson());
  }

  print("has identity key $identity");
  print("has device id $deviceId");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider()..tryAutoLogin(user),
        ),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
      ],
      child: MyApp(
        user: user,
        hasCompletedOnboarding: hasCompletedOnboarding == 'true',
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final String? user;
  final bool hasCompletedOnboarding;

  const MyApp({super.key, this.user, this.hasCompletedOnboarding = false});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Schedule the auto-login for the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user == null) {
        userProvider.tryAutoLogin(widget.user);
      } else {
        await SocketHelper.instance.socket;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (_, userProvider, __) {
        return MaterialApp(
          title: 'Tralala',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              primary: Colors.blue,
              secondary: Colors.blue.shade700,
              background: Colors.white,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              },
            ),
          ),
          initialRoute: '/',
          routes: {
            '/':
                (context) => SplashScreen(
                  initialDelay: const Duration(milliseconds: 800),
                  animationDuration: const Duration(milliseconds: 1200),
                  child:
                      userProvider.user == null
                          ? const OnboardingStart()
                          : const Root(),
                ),
            '/onboarding/start': (context) => const OnboardingStart(),
            '/onboarding/permissions':
                (context) => const OnboardingPermissions(),
            '/onboarding/phone': (context) => const OnboardingPhone(),
            '/onboarding/profile': (context) => const OnboardingProfile(),
          },
        );
      },
    );
  }
}
