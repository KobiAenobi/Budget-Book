import 'dart:async';
import 'dart:developer';
import 'dart:math' hide log;

import 'package:animations/animations.dart';
import 'package:budget_book_app/apis/api.dart';
import 'package:budget_book_app/helper/appBar.dart';
import 'package:budget_book_app/helper/my_colors.dart';
import 'package:budget_book_app/helper/my_theme.dart';
import 'package:budget_book_app/helper/fab_speed_dial.dart';
import 'package:budget_book_app/models/budget_item.dart';
import 'package:budget_book_app/screens/permissions_screen.dart';
import 'package:budget_book_app/screens/itemDataScreen.dart';
import 'package:budget_book_app/screens/theme_select_screeen.dart';
import 'package:budget_book_app/screens/top_expenses_screen.dart';
import 'package:budget_book_app/services/firestore_service.dart';
import 'package:budget_book_app/services/sync_service.dart';
import 'package:budget_book_app/widgets/account_settings_dialog.dart';
import 'package:budget_book_app/widgets/add_item_dialog_box.dart';
import 'package:budget_book_app/widgets/item_card.dart';
import 'package:budget_book_app/widgets/month_card.dart';
import 'package:budget_book_app/widgets/set_budget_dialog_box.dart';
import 'package:budget_book_app/widgets/top_card1.dart';
import 'package:budget_book_app/widgets/top_card2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_launcher_icons/xml_templates.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

/// ===============================================================
/// HOMESCREEN (Main Dashboard UI)
/// ---------------------------------------------------------------
/// This screen:
/// - Displays all budget items from Hive
/// - Shows total expense
/// - Provides edit & delete via Slidable
/// - Provides Add button (FAB)
/// - Periodically refreshes to update timestamps
/// - (Commented) Handles Android overlay → Flutter communication
/// ===============================================================
class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final Box settingsBox = Hive.box('appSettings');

  int monthlyBudget = 0;
  void openSetBudgetDialog() async {
    final int? newBudget = await showDialog<int>(
      context: context,
      builder: (_) => SetBudgetDialogBox(currentBudget: monthlyBudget),
    );
    log(newBudget.toString());

    if (newBudget != null) {
      settingsBox.put('monthlyBudget', newBudget); // ✅ SAVE
      setState(() {
        monthlyBudget = newBudget;
      });
    }
  }

  Color get backgroundColorOfCards {
    final theme = Theme.of(context);
    return isRight ? theme.colorScheme.surface : theme.scaffoldBackgroundColor;
  }

  //Page view controller
  final _pageViewController = PageController();

  //FORMMATTED MONTH AND YEAR FOR THE LISTVIEWBUILDER
  String formatMonth(String key) {
    final year = int.parse(key.split('-')[0]);
    final month = int.parse(key.split('-')[1]);

    const monthNames = [
      "", // index 0 unused
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return "${monthNames[month]} $year";
  }

  void _editItem(BudgetItem item) async {
    final BudgetItem? updated = await showDialog(
      context: context,
      builder: (_) => AddItemDialogBox(
        isEditing: true,
        existingItem: item,
        existingName: item.name,
        existingQuantity: item.quantity.toString(),
        existingPrice: item.price.toString(),
      ),
    );

    if (updated != null) {
      itemsBox.put(updated.id, updated); // local
      setState(() {});
    }

    try {
      final service = await FirestoreService.forCurrentUser();
      await service.updateItem(updated!);
    } catch (e) {
      log('Failed update: $e');
    }
  }

  void _handleDeepLink() {
    final uri = Uri.base;

    if (uri.scheme == "budgetbook" &&
        uri.host == "dialog" &&
        uri.path == "/addItem") {
      // Open the dialog
      showDialog(context: context, builder: (_) => const AddItemDialogBox());
    }
  }

  /// Hive box reference
  final itemsBox = Hive.box<BudgetItem>('itemsBox');

  /// Periodic UI update timer (for timestamp refresh)
  Timer? _timer;

  double mainContainerHeight = 0;
  double mainContainerWidth = 0;
  bool isRight = false;
  // bool isOpen = false;

  @override
  void initState() {
    super.initState();

    monthlyBudget = settingsBox.get('monthlyBudget', defaultValue: 0);

    log('Loaded monthly budget: $monthlyBudget');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        mainContainerHeight = MediaQuery.of(context).size.height;
        mainContainerWidth = MediaQuery.of(context).size.width;
        // backgroudColorofCards = Theme.of(context).scaffoldBackgroundColor;
      });
      _handleDeepLink();

      // NEW: start local-to-cloud sync listener
      if (FirebaseAuth.instance.currentUser != null) {
        listenForLocalChanges();
      }
    });

    // =============================================================
    // Periodic UI refresh
    // -------------------------------------------------------------
    // This triggers every minute to update timestamps like:
    // "Added 5 minutes ago", "Added 1 hour ago", etc.
    // =============================================================
    _timer = Timer.periodic(Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    // Cancel periodic refresh timer
    _timer?.cancel();
    _pageViewController.dispose();
    super.dispose();
  }

  /// =============================================================
  /// BUILD METHOD — MAIN UI
  /// =============================================================
  @override
  Widget build(BuildContext context) {
    final myThemeVar = Theme.of(context);
    int duration = 300;
    int colorDuration = duration + (duration * .2).toInt();

    return Stack(
      children: [
        // bottom layer
        Material(
          color: Colors.transparent,
          child: Container(
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //     colors: [
            //       myThemeVar.colorScheme.surface,
            //       myThemeVar.brightness == Brightness.dark
            //           ? MyAppTheme.scaffoldBackgroundColorSecondaryDark
            //           : MyAppTheme.scaffoldBackgroundColorSecondaryLight,
            //     ],
            //     begin: Alignment.topLeft,
            //     end: Alignment.bottomLeft,
            //   ),
            // ),
            // color: myThemeVar.colorScheme.surface,
            decoration: BoxDecoration(
              // image: DecorationImage(
              //   image: AssetImage("assets/bg/scaf_paper_bg.jpg"),
              //   fit: BoxFit.cover,
              // ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  myThemeVar.scaffoldBackgroundColor,
                  myThemeVar.scaffoldBackgroundColor,
                ],
              ),
            ),
            width: MediaQuery.of(context).size.width,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedScale(
                scale: 1,
                duration: Duration(milliseconds: duration),
                curve: Curves.linear,
                child: AnimatedSlide(
                  offset: isRight ? const Offset(0, 0) : Offset(-1, 0),
                  duration: Duration(milliseconds: duration),
                  curve: Curves.linear,

                  //CLoumn
                  child: Container(
                    margin: EdgeInsets.only(left: 20),
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: MediaQuery.of(context).size.height,
                    // color: Colors.purple,
                    child: SingleChildScrollView(
                      child: Column(
                        key: ValueKey(isRight),
                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.08,
                          ),
                          IconButton(
                            color: myThemeVar.iconTheme.color,
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                // if (backgroudColorofCards ==
                                //     myThemeVar.scaffoldBackgroundColor) {
                                //   backgroudColorofCards =
                                //       myThemeVar.colorScheme.surface;
                                // } else {
                                //   backgroudColorofCards =
                                //       myThemeVar.scaffoldBackgroundColor;
                                // }
                                // if (isRight) {
                                //   mainContainerHeight = MediaQuery.of(
                                //     context,
                                //   ).size.height;
                                //   mainContainerWidth = MediaQuery.of(
                                //     context,
                                //   ).size.width;
                                // } else {
                                //   mainContainerHeight =
                                //       MediaQuery.of(context).size.height * 0.7;
                                //   mainContainerWidth =
                                //       MediaQuery.of(context).size.width * 0.7;
                                // }

                                isRight = !isRight;
                                // isOpen = !isOpen;

                                // if (isRight) {
                                //   isRight = false;
                                // } else {
                                //   isRight = true;
                                // }
                              });
                            },
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),
                          //USER card CONTAINER
                          Material(
                            color: Colors.transparent,
                            child: StreamBuilder<User?>(
                              stream: FirebaseAuth.instance.userChanges(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 52,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }

                                final user = snapshot.data;
                                return Container(
                                  // width: double.infinity,
                                  width:
                                      MediaQuery.of(context).size.width * 0.55,
                                  // height: MediaQuery.of(context).size.height * .1,

                                  // height: double.infinity,
                                  // color: Colors.red,
                                  margin: EdgeInsets.only(left: 0, right: 0),

                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(7),
                                    onTap: () {
                                      // Navigator.pop(context);

                                      // Navigator.pop(context);
                                      user == null
                                          ? {
                                              handleLoginButtonClick(),
                                              isRight = !isRight,
                                            }
                                          : log("already logged");

                                      log("user name clicked");
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 26,
                                            backgroundColor: Colors.black
                                                .withOpacity(0.3),

                                            // backgroundImage:NetworkImage(currUser!.photoURL.toString()),
                                            // child:Icon(Icons.person),
                                            backgroundImage:
                                                user?.photoURL != null
                                                ? NetworkImage(user!.photoURL!)
                                                : null,
                                            child: user?.photoURL == null
                                                ? Icon(
                                                    Icons.person,
                                                    color: Colors.white,
                                                  )
                                                : null,
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                FittedBox(
                                                  child: Text(
                                                    user?.displayName ?? "",
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: myThemeVar
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                  ),
                                                ),
                                                FittedBox(
                                                  child: Text(
                                                    user?.email ?? "",
                                                    style: TextStyle(
                                                      color: myThemeVar
                                                          .colorScheme
                                                          .secondary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: 80),

                          //DRAWER BUTTONS
                          // ...[
                          //1st Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(7),
                              onTap: () {
                                setState(() {
                                  isRight = !isRight;
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ThemeSelectScreeen(),
                                  ),
                                );
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 5, right: 2),
                                height:
                                    MediaQuery.of(context).size.height * .05,
                                width: MediaQuery.of(context).size.width * .5,
                                // color: Colors.blue,
                                // color: Colors.red,
                                child: FittedBox(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        child: Icon(
                                          Icons.dark_mode_outlined,
                                          color: myThemeVar.colorScheme.primary,
                                          size:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.05,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      FittedBox(
                                        child: SingleChildScrollView(
                                          child: Text(
                                            "System Theme",
                                            maxLines: 1,
                                            // style: myThemeVar.textTheme.bodyLarge,
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.manrope()
                                                  .fontFamily,
                                              fontSize:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.05,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          //3rd button

                          // Material(
                          //   color: Colors.transparent,
                          //   child: InkWell(
                          //     borderRadius: BorderRadius.circular(7),
                          //     onTap: () {
                          //       setState(() {
                          //         isRight = !isRight;
                          //       });
                          //       Navigator.push(
                          //         context,
                          //         MaterialPageRoute(
                          //           builder: (_) => Activities(),
                          //         ),
                          //       );
                          //     },
                          //     child: Container(
                          //       alignment: Alignment.centerLeft,
                          //       padding: EdgeInsets.only(left: 5, right: 2),
                          //       // height:
                          //       //     MediaQuery.of(context).size.height *
                          //       //     .1,
                          //       width: MediaQuery.of(context).size.width * .5,
                          //       // color: Colors.blue,
                          //       child: FittedBox(
                          //         child: Row(
                          //           children: [
                          //             Icon(
                          //               Icons.format_list_bulleted_outlined,
                          //               color: myThemeVar.colorScheme.primary,
                          //               size: myThemeVar
                          //                   .textTheme
                          //                   .bodyLarge!
                          //                   .fontSize!
                          //                   .toDouble(),
                          //             ),
                          //             SizedBox(width: 10),
                          //             Text(
                          //               "Button 3",
                          //               style: myThemeVar.textTheme.bodyLarge,
                          //             ),
                          //           ],
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          SizedBox(height: 10),

                          //2nd button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(7),
                              onTap: () {
                                setState(() {
                                  isRight = !isRight;
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TopExpensesScreen(
                                      containerHeight: MediaQuery.of(
                                        context,
                                      ).size.height,
                                      containerWidth: MediaQuery.of(
                                        context,
                                      ).size.width,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 5, right: 2),
                                height:
                                    MediaQuery.of(context).size.height * .05,
                                width: MediaQuery.of(context).size.width * .5,
                                // color: Colors.blue,
                                // color: Colors.red,
                                child: FittedBox(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        child: Icon(
                                          Icons.trending_up,
                                          color: myThemeVar.colorScheme.primary,
                                          size:
                                              MediaQuery.of(
                                                context,
                                              ).size.width *
                                              0.05,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      FittedBox(
                                        child: SingleChildScrollView(
                                          child: Text(
                                            "Top Expense",
                                            maxLines: 1,
                                            // style: myThemeVar.textTheme.bodyLarge,
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.manrope()
                                                  .fontFamily,
                                              fontSize:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.05,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 10),

                          //3rd button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(7),
                              onTap: () {
                                setState(() {
                                  isRight = !isRight;
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PermissionsScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                alignment: Alignment.centerLeft,
                                padding: EdgeInsets.only(left: 5, right: 2),
                                height:
                                    MediaQuery.of(context).size.height * .05,
                                width: MediaQuery.of(context).size.width * .5,
                                // color: Colors.blue,
                                child: FittedBox(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        child: FittedBox(
                                          child: Icon(
                                            Icons.settings,
                                            color:
                                                myThemeVar.colorScheme.primary,
                                            size:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width *
                                                0.05,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      SizedBox(
                                        child: FittedBox(
                                          child: Text(
                                            "Settings",
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontFamily: GoogleFonts.manrope()
                                                  .fontFamily,
                                              fontSize:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.width *
                                                  0.05,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 10),

                          //3rd Button

                          //4th Button
                          FirebaseAuth.instance.currentUser != null
                              ? Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(7),
                                    onTap: () async {
                                      // Navigator.pop(context);

                                      setState(() {
                                        isRight = !isRight;
                                      });

                                      try {
                                        signOut();
                                        if (FirebaseAuth.instance.currentUser ==
                                            null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Already Logged out",
                                              ),
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text("Logged Out"),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text("error: $e")),
                                        );
                                      }

                                      // try {
                                      //   await signOut();

                                      //   ScaffoldMessenger.of(context).showSnackBar(
                                      //     const SnackBar(
                                      //       content: Text(
                                      //         "Logged Out",
                                      //         style: TextStyle(color: Colors.white),
                                      //       ),
                                      //       backgroundColor: Color.fromARGB(
                                      //         255,
                                      //         83,
                                      //         83,
                                      //         83,
                                      //       ),
                                      //     ),
                                      //   );
                                      // } catch (e) {
                                      //   ScaffoldMessenger.of(context).showSnackBar(
                                      //     SnackBar(
                                      //       content: Text(
                                      //         "Error: $e",
                                      //         style: TextStyle(color: Colors.red),
                                      //       ),
                                      //       backgroundColor: Color.fromARGB(
                                      //         255,
                                      //         83,
                                      //         83,
                                      //         83,
                                      //       ),
                                      //     ),
                                      //   );
                                      // }
                                      log("Sign out Clicked");

                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (_) => Activities(),
                                      //   ),
                                      // );
                                    },
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                        left: 5,
                                        right: 2,
                                      ),
                                      height:
                                          MediaQuery.of(context).size.height *
                                          .05,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          .5,
                                      // color: Colors.blue,
                                      child: FittedBox(
                                        child: Row(
                                          children: [
                                            FittedBox(
                                              child: Transform.rotate(
                                                angle: pi,
                                                child: Icon(
                                                  Icons.logout,
                                                  color: myThemeVar
                                                      .colorScheme
                                                      .primary,
                                                  size:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      .05,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            FittedBox(
                                              child: Text(
                                                "Log out",
                                                style: TextStyle(
                                                  fontFamily:
                                                      GoogleFonts.manrope()
                                                          .fontFamily,
                                                  fontSize:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.05,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(7),
                                    onTap: () async {
                                      // Navigator.pop(context);

                                      setState(() {
                                        isRight = !isRight;
                                      });

                                      handleLoginButtonClick();

                                      // try {
                                      //   signOut();
                                      //   if (FirebaseAuth.instance.currentUser ==
                                      //       null) {
                                      //     ScaffoldMessenger.of(
                                      //       context,
                                      //     ).showSnackBar(
                                      //       SnackBar(
                                      //         content: Text(
                                      //           "Already Logged out",
                                      //         ),
                                      //       ),
                                      //     );
                                      //   } else {
                                      //     ScaffoldMessenger.of(
                                      //       context,
                                      //     ).showSnackBar(
                                      //       SnackBar(
                                      //         content: Text("Logged Out"),
                                      //       ),
                                      //     );
                                      //   }
                                      // } catch (e) {
                                      //   ScaffoldMessenger.of(
                                      //     context,
                                      //   ).showSnackBar(
                                      //     SnackBar(content: Text("error: $e")),
                                      //   );
                                      // }

                                      // try {
                                      //   await signOut();

                                      //   ScaffoldMessenger.of(context).showSnackBar(
                                      //     const SnackBar(
                                      //       content: Text(
                                      //         "Logged Out",
                                      //         style: TextStyle(color: Colors.white),
                                      //       ),
                                      //       backgroundColor: Color.fromARGB(
                                      //         255,
                                      //         83,
                                      //         83,
                                      //         83,
                                      //       ),
                                      //     ),
                                      //   );
                                      // } catch (e) {
                                      //   ScaffoldMessenger.of(context).showSnackBar(
                                      //     SnackBar(
                                      //       content: Text(
                                      //         "Error: $e",
                                      //         style: TextStyle(color: Colors.red),
                                      //       ),
                                      //       backgroundColor: Color.fromARGB(
                                      //         255,
                                      //         83,
                                      //         83,
                                      //         83,
                                      //       ),
                                      //     ),
                                      //   );
                                      // }
                                      log("Sign out Clicked");

                                      // Navigator.push(
                                      //   context,
                                      //   MaterialPageRoute(
                                      //     builder: (_) => Activities(),
                                      //   ),
                                      // );
                                    },
                                    child: Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(
                                        left: 5,
                                        right: 2,
                                      ),
                                      height:
                                          MediaQuery.of(context).size.height *
                                          .05,
                                      width:
                                          MediaQuery.of(context).size.width *
                                          .5,
                                      // color: Colors.blue,
                                      child: FittedBox(
                                        child: Row(
                                          children: [
                                            FittedBox(
                                              child: Icon(
                                                Icons.logout,
                                                color: myThemeVar
                                                    .colorScheme
                                                    .primary,
                                                size:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.width *
                                                    .05,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            FittedBox(
                                              child: Text(
                                                "Log in",
                                                style: TextStyle(
                                                  fontFamily:
                                                      GoogleFonts.manrope()
                                                          .fontFamily,
                                                  fontSize:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.width *
                                                      0.05,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                          // ]
                          // .animate(
                          //   interval: (duration * 0.25).ms,
                          //   onPlay: (c) =>
                          //       isRight ? c.forward() : c.forward(),
                          // )
                          // .slideX(begin: -1, end: 0), //DRAWER ANIMATION
                          Container(
                            // color: Colors.red,
                            width: double.infinity,
                            // height:
                            //     (MediaQuery.of(context).size.height * .3) + 30,
                            child: Text(""),
                          ),
                        ],
                      ),
                    ),
                    // child: Text(""),
                  ),
                  // //
                ),
              ),
            ),
          ),
        ),
        // ),

        // SECOND LAYER BORDER CONTAINER
        AnimatedScale(
          scale: isRight ? 0.71 : 1.1,
          duration: Duration(milliseconds: duration),
          curve: Curves.linear,
          child: AnimatedSlide(
            offset: isRight ? const Offset(0.65, 0) : Offset.zero,
            duration: Duration(milliseconds: duration),
            curve: Curves.linear,
            child: Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: myThemeVar.dividerColor),
              ),
              child: Container(
                color: Colors.transparent,
                child: Center(child: Text("")),
              ),
            ),
          ),
        ),

        //MAIN SCAFFOLD
        AnimatedScale(
          scale: isRight ? 0.7 : 1.0,
          duration: Duration(milliseconds: duration),
          curve: Curves.linear,
          child: AnimatedSlide(
            offset: isRight ? const Offset(0.67, 0) : Offset.zero,
            duration: Duration(milliseconds: duration),
            curve: Curves.linear,
            child: AnimatedContainer(
              duration: Duration(milliseconds: colorDuration),
              curve: Curves.easeInOutCubic,

              decoration: BoxDecoration(
                borderRadius: isRight
                    ? BorderRadius.circular(15)
                    : BorderRadius.circular(0),
                //color: backgroundColorOfCards, //SMOOTH TRANSITION
                color: Colors.transparent,

                ///COLOR TRANSITION
                // color: Colors.white,
              ),
              // color: Colors.amber,
              child: ClipRRect(
                borderRadius: isRight
                    ? BorderRadius.circular(16)
                    : BorderRadius.circular(0),
                child: GestureDetector(
                  onTap: isRight
                      ? () {
                          setState(() {
                            isRight = !isRight;
                          });
                        }
                      : null,
                  onHorizontalDragUpdate: isRight
                      ? (details) {
                          if (details.delta.dx < -8) {
                            setState(() => isRight = !isRight);
                          }
                        }
                      : null,
                  child: Scaffold(
                    // backgroundColor: const Color.fromARGB(255, 44, 16, 16),
                    backgroundColor: isRight
                        ? Colors.transparent
                        : Colors.transparent,
                    // : myThemeVar.scaffoldBackgroundColor,

                    // =============================================================
                    // APP BAR (Custom Widget)
                    // =============================================================
                    // appBar: customAppBar(title: "Budget Book"),
                    appBar: PreferredSize(
                      preferredSize: const Size.fromHeight(kToolbarHeight),
                      child: StreamBuilder<User?>(
                        stream: FirebaseAuth.instance.userChanges(),
                        builder: (context, snapshot) {
                          final user = snapshot.data;

                          // if (isRight == false) {
                          return AppBar(
                            systemOverlayStyle: const SystemUiOverlayStyle(
                              systemNavigationBarColor: Colors.transparent,
                            ), //transparent system navigation bar
                            backgroundColor: myThemeVar.cardColor,
                            // backgroundColor: Colors.transparent,
                            surfaceTintColor: Colors.transparent,
                            flexibleSpace: Container(
                              // decoration: BoxDecoration(
                              //   image: DecorationImage(
                              //     image: AssetImage(
                              //       "assets/bg/card_paper_bg_light.jpg",
                              //     ),
                              //     fit: BoxFit.cover,
                              //   ),
                              // ),
                            ),
                            leading: IconButton(
                              color: myThemeVar.iconTheme.color,
                              icon: const Icon(Icons.menu),
                              onPressed: () {
                                setState(() {
                                  isRight = !isRight;
                                });
                              },
                            ),
                            // iconTheme: const IconThemeData(color: Colors.white70),
                            title: Text(
                              "Budget Book",
                              style: TextStyle(
                                color: myThemeVar.colorScheme.primary,
                                fontFamily: GoogleFonts.workSans().fontFamily,
                                fontWeight: FontWeight.w900,
                                fontSize: 24,
                              ),
                            ),
                            actions: [
                              GestureDetector(
                                onTap: () {
                                  log("photo url: ${user?.photoURL}");
                                  AccountSettingsDialog()
                                      .showAccountSettingDialog(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: user?.photoURL != null
                                        ? NetworkImage(user!.photoURL!)
                                        : null,
                                    child: user?.photoURL == null
                                        ? Icon(
                                            Icons.person,
                                            color: myThemeVar.iconTheme.color,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ],
                          );
                          // } else {
                          //   return AppBar(
                          //     backgroundColor: myThemeVar.cardColor,
                          //     surfaceTintColor: Colors.transparent,
                          //     title: Text(
                          //       "Budget Book",
                          //       style: TextStyle(
                          //         color: myThemeVar.colorScheme.primary,
                          //         fontFamily: GoogleFonts.workSans().fontFamily,
                          //         fontWeight: FontWeight.w900,
                          //         fontSize: 24,
                          //       ),
                          //     ),
                          //   );
                          // }
                        },
                      ),
                    ),

                    body: IgnorePointer(
                      ignoring: isRight,

                      // =============================================================
                      // BODY — Item List + Summary Card
                      // =============================================================
                      child: ValueListenableBuilder(
                        valueListenable: itemsBox
                            .listenable(), // Rebuild on Hive change
                        builder: (context, Box<BudgetItem> box, _) {
                          // ---------------------------------------------------------
                          // Empty State
                          // ---------------------------------------------------------

                          if (box.isEmpty) {
                            return SizedBox.expand(
                              child: Container(
                                // decoration: const BoxDecoration(
                                //   // color: Colors.transparent,
                                //   // image: DecorationImage(
                                //   //   image: AssetImage(
                                //   //     "assets/bg/card_paper_bg_light.jpg",
                                //   //   ),
                                //   //   fit: BoxFit.cover,
                                //   // ),
                                // ),
                                color: myThemeVar.cardColor,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.3,
                                    child: Column(
                                      children: [
                                        Flexible(
                                          child: Lottie.asset(
                                            "assets/lottie/cat_in_the_box.json",
                                          ),
                                        ),
                                        Text(
                                          "No Items found",
                                          style: TextStyle(
                                            fontFamily: GoogleFonts.workSans()
                                                .fontFamily,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(child: SizedBox(height: 0)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          
                          }

                          // ---------------------------------------------------------
                          // Convert Hive box to list & sort newest → oldest
                          // ---------------------------------------------------------
                          final items = box.values.toList()
                            ..sort((a, b) => b.dateTime.compareTo(a.dateTime));

                          final grouped = Api.groupItemsByMonth(items);

                          final List<dynamic> displayList = [];

                          final Map<String, int> monthlyTotal = {};

                          // grouped.forEach((monthKey, montItem){
                          //   montlyTotal.add(monthKey);
                          //   montlyTotal.addAll(montItem.price)
                          // });

                          grouped.forEach((monthKey, monthItem) {
                            int total = monthItem.fold(
                              0,
                              (sum, item) => sum + (item.price * item.quantity),
                            );
                            monthlyTotal[monthKey] = total;

                            displayList.add(monthKey);
                            displayList.addAll(monthItem);
                          });

                          // =========================================================
                          // MAIN COLUMN
                          // =========================================================

                          return Container(
                            margin: EdgeInsets.only(left: 0, right: 0, top: 0),
                            // No animated width/height → boosts FPS massively
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,

                            // color: const Color.fromARGB(255, 44, 16, 16),
                            // color: const Color.fromRGBO(34, 40, 49, 1.000),
                            child: Column(
                              children: [
                                // =======================================================
                                // TOP CARD
                                // =======================================================
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: myThemeVar.dividerColor,
                                      ),
                                    ),
                                    // image: DecorationImage(
                                    //   image: AssetImage(
                                    //     "assets/bg/card_paper_bg_light.jpg",
                                    //   ),
                                    //   fit: BoxFit.cover,
                                    // ),
                                    // color: Colors.red,
                                  ),
                                  height:
                                      MediaQuery.of(context).size.height * 0.27,
                                  width: double.infinity,
                                  child: Card(
                                    elevation: 0,
                                    margin: const EdgeInsets.only(
                                      bottom: 0,
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      // side: BorderSide(
                                      //   color: !isRight
                                      //       ? myThemeVar.dividerColor
                                      //       : Colors.transparent,
                                      // ),
                                      borderRadius: isRight
                                          ? BorderRadiusGeometry.only(
                                              bottomLeft: Radius.circular(0),
                                              bottomRight: Radius.circular(0),
                                            )
                                          : BorderRadiusGeometry.zero,
                                    ),
                                    color: myThemeVar.cardColor,
                                    // color: Colors.transparent,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: PageView(
                                            controller: _pageViewController,
                                            children: [
                                              TopCard1(
                                                containeHeight: 600,
                                                containeWidth: 250,
                                                monthBudget:
                                                    monthlyBudget, // ✅ int
                                                onEditBudget:
                                                    openSetBudgetDialog, // ✅ callback
                                              ),
                                              TopCard2(
                                                containerHeight: MediaQuery.of(
                                                  context,
                                                ).size.height,
                                                containerWidth: MediaQuery.of(
                                                  context,
                                                ).size.width,
                                              ),

                                              // OpenContainer(
                                              //   closedElevation:
                                              //       0, // remove shadow in closed state
                                              //   openElevation:
                                              //       0, // remove shadow when opening
                                              //   closedColor: Colors.transparent,
                                              //   transitionDuration:
                                              //       const Duration(
                                              //         milliseconds: 250,
                                              //       ),
                                              //   closedBuilder:
                                              //       (context, Action) {
                                              //         return TopCard2(
                                              //           containerHeight:
                                              //               MediaQuery.of(
                                              //                 context,
                                              //               ).size.height,
                                              //           containerWidth:
                                              //               MediaQuery.of(
                                              //                 context,
                                              //               ).size.width,
                                              //         );
                                              //       },
                                              //   openBuilder: (context, Action) {
                                              //     return TopExpensesScreen(
                                              //       containerHeight:
                                              //           MediaQuery.of(
                                              //             context,
                                              //           ).size.height,
                                              //       containerWidth:
                                              //           MediaQuery.of(
                                              //             context,
                                              //           ).size.width,
                                              //     );
                                              //   },
                                              // ),

                                              // TopCard2(
                                              //   containerHeight:
                                              //               MediaQuery.of(
                                              //                 context,
                                              //               ).size.height,
                                              //           containerWidth:
                                              //               MediaQuery.of(
                                              //                 context,
                                              //               ).size.width,
                                              // ),
                                            ],
                                          ),
                                        ),

                                        Padding(
                                          padding: EdgeInsets.only(bottom: 4),
                                          child: SmoothPageIndicator(
                                            controller: _pageViewController,
                                            count: 2,
                                            effect: WormEffect(
                                              dotHeight: 6,
                                              dotWidth: 6,
                                              spacing: 6,
                                              activeDotColor: myThemeVar
                                                  .colorScheme
                                                  .primary,
                                              dotColor: myThemeVar
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // =======================================================
                                // ITEM LIST
                                // =======================================================
                                Expanded(
                                  child: Container(
                                    // color: Colors.red,
                                    margin: EdgeInsets.only(left: 0, right: 0),
                                    child: ListView.builder(
                                      padding: const EdgeInsets.only(
                                        bottom: 80,
                                        top: 5,
                                      ),
                                      itemCount: displayList.length,
                                      itemBuilder: (context, index) {
                                        final entry = displayList[index];

                                        if (entry is String) {
                                          if (index == 0) {
                                            return const SizedBox.shrink();
                                          }

                                          return MonthCard(
                                            month: formatMonth(entry),
                                            total: monthlyTotal[entry] ?? 0,
                                            containerHeight: MediaQuery.of(
                                              context,
                                            ).size.height,
                                            containerWidth: MediaQuery.of(
                                              context,
                                            ).size.width,
                                            monthCardColor: Colors.transparent,
                                            colorDuration: colorDuration,
                                          );
                                        } else {
                                          final item = entry;

                                          return Slidable(
                                            key: ValueKey(item.id),

                                            endActionPane: ActionPane(
                                              motion: const DrawerMotion(),
                                              extentRatio: 0.25,
                                              children: [
                                                SlidableAction(
                                                  onPressed: (context) =>
                                                      _editItem(item),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  foregroundColor: myThemeVar
                                                      .colorScheme
                                                      .primary,
                                                  icon: Icons.edit,
                                                  label: 'Edit',
                                                ),
                                              ],
                                            ),

                                            startActionPane: ActionPane(
                                              motion: const DrawerMotion(),
                                              extentRatio: 0.25,
                                              children: [
                                                SlidableAction(
                                                  onPressed: (context) async {
                                                    final confirmed = await showDialog<bool>(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          // backgroundColor:
                                                          //     myThemeVar
                                                          //         .cardColor,
                                                          icon: const Icon(
                                                            Icons
                                                                .warning_amber_rounded,
                                                            // color: Colors.red,
                                                          ),
                                                          title: const Text(
                                                            'Delete Item?',
                                                          ),
                                                          content: const Text(
                                                            'This action cannot be undone.',
                                                          ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    false,
                                                                  ),
                                                              child: const Text(
                                                                'Cancel',
                                                              ),
                                                            ),
                                                            FilledButton.tonal(
                                                              style: FilledButton.styleFrom(
                                                                // backgroundColor:
                                                                //     myThemeVar
                                                                //         .scaffoldBackgroundColor,
                                                                // foregroundColor:
                                                                //     Colors
                                                                //         .red, // destructive
                                                              ),
                                                              onPressed: () =>
                                                                  Navigator.pop(
                                                                    context,
                                                                    true,
                                                                  ),
                                                              child: const Text(
                                                                'Delete',
                                                              ),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );

                                                    if (confirmed == true) {
                                                      // Navigator.pop(context);

                                                      itemsBox.delete(item.id);

                                                      try {
                                                        final service =
                                                            await FirestoreService.forCurrentUser();
                                                        await service
                                                            .deleteItem(
                                                              item.id,
                                                            );

                                                        Api.showAppSnack(
                                                          "Item Deleted",
                                                        );

                                                        log('deleted');
                                                      } catch (e) {
                                                        Api.showAppSnack(
                                                          "Item Deleted Locally",
                                                        );
                                                        log(
                                                          'Failed remote delete: $e',
                                                        );
                                                      }

                                                      // ✅ DO YOUR ACTION HERE
                                                      // syncLocalItemsToCloud();
                                                      // migrateKeysToId();

                                                      // try {
                                                      //   await syncLocalItemsToCloud();
                                                      //   ScaffoldMessenger.of(context).showSnackBar(
                                                      //     SnackBar(content: Text("Data Synced")),
                                                      //   );
                                                      // } catch (e) {
                                                      //   ScaffoldMessenger.of(context).showSnackBar(
                                                      //     SnackBar(content: Text("Error: $e")),
                                                      //   );
                                                      // }

                                                      // close AccountSettingsDialog AFTER confirm
                                                      // log("Sync confirmed");
                                                    } else {
                                                      log("Delete cancelled");
                                                    }
                                                  },
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  foregroundColor: myThemeVar
                                                      .colorScheme
                                                      .primary,
                                                  icon: Icons.delete,
                                                  label: 'Delete',
                                                ),
                                              ],
                                            ),

                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadiusGeometry.circular(
                                                    0,
                                                  ),
                                              child: OpenContainer(
                                                closedElevation:
                                                    0, // remove shadow in closed state
                                                openElevation:
                                                    0, // remove shadow when opening
                                                closedColor: Colors.transparent,
                                                transitionDuration:
                                                    const Duration(
                                                      milliseconds: 500,
                                                    ),
                                                closedBuilder:
                                                    (context, action) {
                                                      return ItemCard(
                                                        name: item.name,
                                                        date: item.dateTime,
                                                        quantity: item.quantity,
                                                        price: item.price,
                                                        onEdit: () =>
                                                            _editItem(item),
                                                        containerHeight:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.height,
                                                        containerWidth:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.width,
                                                        isRight: isRight,
                                                      );
                                                    },
                                                openBuilder: (context, action) {
                                                  return Itemdatascreen(
                                                    containerHeight:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.height,
                                                    containerWidth:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.width,
                                                    itemName: item.name ?? "",
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // =============================================================
                    // ➕ FLOATING ACTION BUTTON (Add New Item)
                    // =============================================================
                    floatingActionButton: SpeedDial(
                      icon: Icons.add,
                      activeIcon: Icons.close,
                      // animatedIcon: AnimatedIcons.add_event,
                      iconTheme: IconThemeData(size: 28.0),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.black,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      visible: true,
                      curve: Curves.bounceInOut,
                      children: [
                        SpeedDialChild(
                          child: Icon(
                            Icons.chrome_reader_mode,
                            color: Colors.black,
                          ),
                          backgroundColor: Colors.green,
                          onTap: () async {
                            openSetBudgetDialog();
                            log('Pressed Set Budget');
                          },
                          label: 'Set Budget',
                          labelStyle: myThemeVar.textTheme.bodySmall,
                          labelBackgroundColor: myThemeVar.cardColor,
                        ),

                        SpeedDialChild(
                          child: Icon(Icons.create, color: Colors.black),
                          backgroundColor: Colors.green,
                          onTap: () async {
                            final BudgetItem? item = await showDialog(
                              context: context,
                              builder: (_) =>
                                  AddItemDialogBox(isEditing: false),
                            );
                            if (item != null) {
                              // Save locally first
                              itemsBox.put(
                                item.id,
                                item,
                              ); // Save using ID as key
                              log('Saved item: ${item.id}');
                              setState(() {});

                              // Then upload in background
                              try {
                                final service =
                                    await FirestoreService.forCurrentUser();
                                await service.uploadItem(item);
                                log('Uploaded item ${item.id} to Firestore');
                              } catch (e) {
                                log('Failed upload: $e');
                                // optionally mark item as pending in Hive
                              }
                            }

                            log('Pressed Add Item');
                            // AddItemDialogBox();
                          },
                          label: 'Add Item',
                          labelStyle: myThemeVar.textTheme.bodySmall,
                          labelBackgroundColor: myThemeVar.cardColor,
                        ),
                        // SpeedDialChild(
                        //       child: Icon(Icons.laptop_chromebook, color: Colors.white),
                        //       backgroundColor: Colors.green,
                        //       onTap: () => log('Pressed Code'),
                        //       label: 'Code',
                        //       labelStyle:TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                        //       labelBackgroundColor: Colors.black,
                        // ),
                      ],
                    ),
                  ),
                
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
