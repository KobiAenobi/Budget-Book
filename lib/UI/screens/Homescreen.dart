import 'dart:developer' show log;
import 'dart:math' hide log;

import 'package:animations/animations.dart';
import 'package:budget_book_app/UI/helper/api.dart';
import 'package:budget_book_app/UI/screens/itemDataScreen.dart';
import 'package:budget_book_app/UI/screens/permissions_screen.dart';
import 'package:budget_book_app/UI/screens/theme_select_screeen.dart';
import 'package:budget_book_app/UI/screens/top_expenses_screen.dart';
import 'package:budget_book_app/UI/screens/widgets/account_settings_dialog.dart';
import 'package:budget_book_app/UI/screens/widgets/add_item_dialog_box.dart';
import 'package:budget_book_app/UI/screens/widgets/item_card.dart';
import 'package:budget_book_app/UI/screens/widgets/month_card.dart';
import 'package:budget_book_app/UI/screens/widgets/set_budget_dialog_box.dart';
import 'package:budget_book_app/UI/screens/widgets/top_card1.dart';
import 'package:budget_book_app/UI/screens/widgets/top_card2.dart';
import 'package:budget_book_app/blocs/budgets/budget_bloc.dart';
import 'package:budget_book_app/blocs/budgets/budget_event.dart';
import 'package:budget_book_app/blocs/budgets/budget_state.dart';
import 'package:budget_book_app/blocs/budgets/models/budget_input.dart';
import 'package:budget_book_app/blocs/budgets/models/budget_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int monthlyBudget = 0;
  int weeklyBudget = 0;
  int dailyBudget = 0;
  //Page view controller
  final _pageViewController = PageController();
  //Menu Drawer
  bool isRight = false;

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final user = FirebaseAuth.instance.currentUser;

    final blocContext = context;
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

    final myThemeVar = Theme.of(context);
    int duration = 300;
    int colorDuration = duration + (duration * .2).toInt();

    // ---------------------------------------------------------
    // Convert Hive box to list & sort newest → oldest
    // ---------------------------------------------------------
    // final items = dummyItems..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // final grouped = groupItemsByMonth(items);

    // final List<dynamic> displayList = [];

    // final Map<String, int> monthlyTotal = {};

    // grouped.forEach((monthKey, monthItem) {
    //   int total = monthItem.fold(
    //     0,
    //     (sum, item) => sum + (item.price * item.quantity),
    //   );
    //   monthlyTotal[monthKey] = total;

    //   displayList.add(monthKey);
    //   displayList.addAll(monthItem);
    // });

    /////////////////////////////////////////////////////

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
                                              // handleLoginButtonClick(),
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
                                            "Top Expenses",
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
                                        context.read<BudgetBloc>().add(
                                          SignOutRequested(),
                                        );
                                        Api.showAppSnack("Logged out");
                                      } catch (e) {
                                        log(
                                          "From homeScreen.dart- logout button: Error: $e",
                                        );
                                      }

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
                                      log(
                                        "From homeScreen.dart- Log out Clicked",
                                      );

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

                                      try {
                                        context.read<BudgetBloc>().add(
                                          SignInToGoogleRequested(),
                                        );
                                      } catch (e) {
                                        log(
                                          "From homeScreen.dart- Log in button: Error: $e",
                                        );
                                      }

                                      // handleLoginButtonClick();

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
                                      log("Log in Clicked");

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
                    appBar: AppBar(
                      toolbarHeight: kToolbarHeight - 15,
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
                        "Budget BLoC",
                        style: TextStyle(
                          color: myThemeVar.colorScheme.primary,
                          fontFamily: GoogleFonts.workSans().fontFamily,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                      actions: [
                        StreamBuilder(
                          stream: FirebaseAuth.instance.authStateChanges(),
                          builder: (context, snapshot) {
                            final user = snapshot.data;
                            return GestureDetector(
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
                            );
                          },
                        ),
                      ],
                    ),

                    body: BlocConsumer<BudgetBloc, BudgetState>(
                      listener: (context, state) {
                        if (state is BudgetLoaded) {
                          monthlyBudget = state.budgetThisMonth;
                          weeklyBudget = state.budgetThisWeek;
                          dailyBudget = state.budgetThisDay;
                          log("from: HomeScreen.dart - Rebuilddddd");
                          // optional: Snackbar, animation, etc.
                        }
                      },
                      builder: (context, state) {
                        if (state is BudgetInitial || state is BudgetLoading) {
                          log("from: HomeScreen.dart - budget loading");
                          return Center(child: CircularProgressIndicator());
                        }

                        if (state is BudgetLoaded) {
                          log("from: HomeScreen.dart - budget loaded");
                          // setState(() {});
                          final displayList = state.displayList;
                          final monthlyTotal = state.monthlyTotal;
                          // final thisMonthTotal = state
                          //     .monthlyTotal['${DateTime.now().year}-${DateTime.now().month}'];
                          final thisMonthTotal = state.thisMonthTotal;
                          final thisWeekTotal = state.thisWeekTotal;
                          final thisDayTotal = state.thisDayTotal;

                          // final x = displayList[index];

                          // log(
                          //   "montly total: ${DateTime.now().year}-${DateTime.now().month}",
                          // );

                          if (displayList.isEmpty) {
                            log("from: HomeScreen.dart - displayList.isEmpty");
                            return SizedBox.expand(
                              child: Container(
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
                          } else {
                            return Container(
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
                                    ),
                                    height:
                                        MediaQuery.of(context).size.height *
                                        0.27,
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

                                                  onEditBudget: () async {
                                                    BudgetInput
                                                    bnudget = await showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          SetBudgetDialogBox(
                                                            currentMonthlyBudget:
                                                                monthlyBudget,
                                                            currentWeeklyBudget:
                                                                weeklyBudget,
                                                            currentDailyBudget:
                                                                dailyBudget,
                                                          ),
                                                    );

                                                    if (bnudget != null) {
                                                      context
                                                          .read<BudgetBloc>()
                                                          .add(
                                                            SetBudgets(
                                                              bnudget.month,
                                                              bnudget.week,
                                                              bnudget.day,
                                                            ),
                                                          );
                                                    }
                                                  },

                                                  //budgets
                                                  monthBudget:
                                                      state.budgetThisMonth,
                                                  weekBudget:
                                                      state.budgetThisWeek,
                                                  dayBudget:
                                                      state.budgetThisDay,

                                                  //total expenses
                                                  currMonthTotal: thisMonthTotal
                                                      .toInt(),
                                                  currWeekTotal: thisWeekTotal
                                                      .toInt(),
                                                  currDayTotal: thisDayTotal
                                                      .toInt(),
                                                ),
                                                TopCard2(
                                                  containerHeight:
                                                      MediaQuery.of(
                                                        context,
                                                      ).size.height,
                                                  containerWidth: MediaQuery.of(
                                                    context,
                                                  ).size.width,
                                                ),
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
                                      margin: EdgeInsets.only(
                                        left: 0,
                                        right: 0,
                                      ),
                                      child: ListView.builder(
                                        padding: const EdgeInsets.only(
                                          bottom: 80,
                                          top: 5,
                                        ),
                                        itemCount: displayList.length,
                                        itemBuilder: (context, index) {
                                          // log("index: $index");
                                          final entry = displayList[index];
                                          // log("entry: ${displayList[index]}");

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
                                              monthCardColor:
                                                  Colors.transparent,
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
                                                    onPressed: (_) async {
                                                      final BudgetItem?
                                                      uitem = await showDialog(
                                                        context: blocContext,
                                                        builder: (_) =>
                                                            AddItemDialogBox(
                                                              existingItem:
                                                                  item,
                                                              existingName:
                                                                  item.name,
                                                              existingPrice: item
                                                                  .price
                                                                  .toString(),
                                                              existingQuantity:
                                                                  item.quantity
                                                                      .toString(),
                                                              isEditing: true,
                                                            ),
                                                      );
                                                      if (uitem != null) {
                                                        // UpdateBudgetItem(item);
                                                        blocContext
                                                            .read<BudgetBloc>()
                                                            .add(
                                                              UpdateBudgetItem(
                                                                uitem,
                                                              ),
                                                            );
                                                      }
                                                    },

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
                                                    onPressed: (_) async {
                                                      final confirmed = await showDialog<bool>(
                                                        context: blocContext,
                                                        barrierDismissible:
                                                            false,
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
                                                                child:
                                                                    const Text(
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
                                                                child:
                                                                    const Text(
                                                                      'Delete',
                                                                    ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );

                                                      if (confirmed == true) {
                                                        blocContext
                                                            .read<BudgetBloc>()
                                                            .add(
                                                              DeleteBudgetItem(
                                                                item.id,
                                                              ),
                                                            );
                                                        log("Item Deleted");
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
                                                  closedColor:
                                                      Colors.transparent,
                                                  transitionDuration:
                                                      const Duration(
                                                        milliseconds: 500,
                                                      ),
                                                  closedBuilder:
                                                      (context, action) {
                                                        return ItemCard(
                                                          name: item.name,
                                                          date: item.dateTime,
                                                          quantity:
                                                              item.quantity,
                                                          price: item.price,
                                                          onEdit: () {},
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
                                                  openBuilder:
                                                      (context, action) {
                                                        return Itemdatascreen(
                                                          containerHeight:
                                                              MediaQuery.of(
                                                                context,
                                                              ).size.height,
                                                          containerWidth:
                                                              MediaQuery.of(
                                                                context,
                                                              ).size.width,
                                                          itemName:
                                                              item.name ?? "",
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
                          }
                          //
                        }

                        return Container(child: Center(child: Text("Oops")));
                      },
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
                            log("set budget Pressed");

                            BudgetInput? bnudget = await showDialog(
                              context: context,
                              builder: (_) => SetBudgetDialogBox(
                                currentMonthlyBudget: monthlyBudget,
                                currentWeeklyBudget: weeklyBudget,
                                currentDailyBudget: dailyBudget,
                              ),
                            );

                            if (bnudget != null) {
                              context.read<BudgetBloc>().add(
                                SetBudgets(
                                  bnudget.month,
                                  bnudget.week,
                                  bnudget.day,
                                ),
                              );
                            }
                          },
                          label: 'Set Budget',
                          labelStyle: myThemeVar.textTheme.bodySmall,
                          labelBackgroundColor: myThemeVar.cardColor,
                        ),

                        SpeedDialChild(
                          child: Icon(Icons.create, color: Colors.black),
                          backgroundColor: Colors.green,
                          onTap: () async {
                            log('Pressed Add Item');
                            // AddItemDialogBox();
                            final BudgetItem? item = await showDialog(
                              context: context,
                              builder: (_) =>
                                  AddItemDialogBox(isEditing: false),
                            );
                            if (item != null) {
                              blocContext.read<BudgetBloc>().add(
                                AddBudgetItem(item),
                              );
                            }
                          },
                          label: 'Add Item',
                          labelStyle: myThemeVar.textTheme.bodySmall,
                          labelBackgroundColor: myThemeVar.cardColor,
                        ),
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
