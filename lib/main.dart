import 'dart:io';

import 'package:budget_book_app/firebase_options.dart';
import 'package:budget_book_app/helper/my_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/budget_item.dart';
import 'screens/homeScreen.dart';

// // ===============================================================
// // overlayEntryPoint()
// // ---------------------------------------------------------------
// // This function is marked as a VM entry point, meaning it can be
// // invoked not only by the main Flutter app, but ALSO by a second
// // Flutter engine (such as a background isolate or overlay engine).
// //
// // Why this exists?
// // Android overlays or background services often run a SECOND
// // Flutter engine. That engine cannot automatically run `main()`,
// // so we explicitly give it a separate entry point.
// //
// // ⚙ What it does:
// // - Ensures Flutter binding is initialized (important for plugins).
// // - Initializes Hive for local storage.
// // - Opens the Hive box for BudgetItem.
// // - Creates a MethodChannel to communicate with native Android
// //   overlay code.
// // - Responds to method calls for:
// //     • adding a new budget item
// //     • returning suggestions (existing items)
// //
// // NOTHING here is changed — only documented.
// // ===============================================================

// ==============================
// This function runs for both:
// - Main UI engine
// - Shared background engine
// ==============================

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

    
@pragma('vm:entry-point')
Future<void> overlayEntryPoint() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await Hive.initFlutter();

  final path = await getExternalHivePath();
  Hive.init(path);

  Hive.registerAdapter(BudgetItemAdapter());
  await Hive.openBox<BudgetItem>('itemsBox');
  await Hive.openBox('appSettings');

  const channel = MethodChannel("overlay_channel");

  channel.setMethodCallHandler((call) async {
    final box = Hive.box<BudgetItem>('itemsBox');

    // if (call.method == "addItemFromOverlay") {
    //   final data = Map<String, dynamic>.from(call.arguments);

    //   box.add(BudgetItem(
    //     id: DateTime.now().millisecondsSinceEpoch.toString(),
    //     name: data["name"],
    //     quantity: int.parse(data["quantity"]),
    //     price: int.parse(data["price"]),
    //     dateTime: DateTime.now(),
    //     imagePath: "",
    //   ));

    //   return null;
    // }

    // ======================================================
    // FIXED : ALWAYS SAVE USING item.id AS THE HIVE KEY
    // ======================================================
    if (call.method == "addItemFromOverlay") {
      final data = Map<String, dynamic>.from(call.arguments);

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      // final id = const Uuid().v4();

      final item = BudgetItem(
        id: id,
        name: data["name"],
        quantity: int.parse(data["quantity"]),
        price: int.parse(data["price"]),
        dateTime: DateTime.now(),
        imagePath: "",
      );

      // Old: box.add(item);  → creates duplicate
      // New (correct):
      await box.put(item.id, item);

      return {"savedId": item.id};
    }

    if (call.method == "getSuggestions") {
      return box.values
          .map(
            (item) => {
              "name": item.name,
              "quantity": item.quantity,
              "price": item.price,
            },
          )
          .toList();
    }

    return null;
  });
}

// ==============================
// Normal UI main() function
// ==============================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2) Initialize Hive (your overlayEntryPoint handles this)
  await overlayEntryPoint();

  // await migrateUuidToDateTimeIds();

  // // 3) Sign user in (anonymous or Google)
  // await signInAnonymouslyIfNeeded();     // <-- ADD THIS

  // // 4) Sync Firestore → Hive before UI shows
  // await initialSync();                    // <-- EXACT CORRECT SPOT

  // >>> CLEAR NOTIFICATIONS ON APP OPEN
  const MethodChannel("clear_notifications").invokeMethod("clearAll");
  // <<< CLEAR NOTIFICATIONS

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );

  // 5) Start app
  runApp(MyApp());
}

// Future<void> main() async {
//     WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   await overlayEntryPoint(); // important: shared with background engine

// //   final path = await getExternalHivePath();
// // Hive.init(path);

// // Hive.registerAdapter(BudgetItemAdapter());
// // await Hive.openBox<BudgetItem>('itemsBox');

//   runApp(MyApp());
// }

Future<String> getExternalHivePath() async {
  // final dir = await getExternalStorageDirectory();
  // /storage/emulated/0/Android/data/<package>/files
  final hiveDir = Directory(
    "/storage/emulated/0/Android/media/com.kobi.budget_book_test_version/hive",
  );

  if (!hiveDir.existsSync()) {
    hiveDir.createSync(recursive: true);
  }

  return hiveDir.path;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      scaffoldMessengerKey: scaffoldMessengerKey,


      title: 'Budget Book',
      // theme: ThemeData(
      //   textTheme: GoogleFonts.workSansTextTheme().apply(
      //     bodyColor: const Color.fromARGB(179, 151, 0, 0),
      //     displayColor: const Color.fromARGB(255, 182, 58, 58),
      //   ),
      //   appBarTheme: AppBarTheme(
      //     backgroundColor: const Color.fromRGBO(250, 243, 225, 1.000),
      //     titleTextStyle: GoogleFonts.workSans(
      //       color: const Color.fromARGB(255, 34, 0, 0),
      //       fontWeight: FontWeight.bold,
      //       fontSize: 24,
      //     ),
      //   ),
      // ),
      theme: MyAppTheme.lightTheme,
      darkTheme: MyAppTheme.darkTheme,
      themeMode: ThemeMode.system,

      home: Homescreen(),
    );
  }
}

// class RootApp extends StatefulWidget {
//   const RootApp({super.key});

//   @override
//   State<RootApp> createState() => _RootAppState();
// }

// class _RootAppState extends State<RootApp> {
//   @override
//   Widget build(BuildContext context) {
//     return MyApp();
//   }
// }
