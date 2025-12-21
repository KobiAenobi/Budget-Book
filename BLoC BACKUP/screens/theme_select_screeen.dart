import 'package:budget_book_app/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class ThemeSelectScreeen extends StatefulWidget {
  const ThemeSelectScreeen({super.key});

  @override
  State<ThemeSelectScreeen> createState() => _ThemeSelectScreeenState();
}

class _ThemeSelectScreeenState extends State<ThemeSelectScreeen> {
  @override
  Widget build(BuildContext context) {
    final myThemeVar = Theme.of(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: myThemeVar.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: myThemeVar.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          "System Themes",
          style: TextStyle(
            fontFamily: GoogleFonts.workSans().fontFamily,
            fontWeight: FontWeight.w900,
            fontSize: myThemeVar.textTheme.bodyLarge!.fontSize,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choose appearance",
                style: myThemeVar.textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              Card(
                color: myThemeVar.cardColor,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, currentTheme, _) {
                      return Column(
                        children: [
                          RadioListTile<ThemeMode>(
                            title: const Text("System"),
                            subtitle: const Text("system theme"),
                            value: ThemeMode.system,
                            groupValue: currentTheme,
                            onChanged: (mode) => setTheme(mode!),
                          ),

                          const Divider(height: 1),

                          RadioListTile<ThemeMode>(
                            title: const Text("Light"),
                            subtitle: const Text("Always light"),
                            value: ThemeMode.light,
                            groupValue: currentTheme,
                            onChanged: (mode) => setTheme(mode!),
                          ),

                          const Divider(height: 1),

                          RadioListTile<ThemeMode>(
                            title: const Text("Dark"),
                            subtitle: const Text("Always dark"),
                            value: ThemeMode.dark,
                            groupValue: currentTheme,
                            onChanged: (mode) => setTheme(mode!),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void setTheme(ThemeMode mode) {
    themeNotifier.value = mode;
    Hive.box('appSettings').put('themeMode', mode.index);
  }
}
