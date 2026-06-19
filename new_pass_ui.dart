import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'login_ui.dart';

class CreatePasswordUI extends StatefulWidget {
  const CreatePasswordUI({super.key});

  @override
  State<CreatePasswordUI> createState() =>
      _CreatePasswordUIState();
}

class _CreatePasswordUIState
    extends State<CreatePasswordUI>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  bool hide1 = true;
  bool hide2 = true;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration:
          const Duration(
        seconds: 18,
      ),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(
      BuildContext context) {
    final size =
        MediaQuery.of(context).size;

    final width = size.width;

    final mobile = width < 600;

    final cardWidth =
        mobile ? width * .92 : 440.0;

    final titleSize =
        mobile ? width * .08 : 34.0;

    return Scaffold(
      body: Stack(
        children: [

          /// ANIMATED BACKGROUND
          AnimatedBuilder(
            animation: controller,

            builder: (_, __) =>
                CustomPaint(
              size: Size.infinite,

              painter:
                  UniversePainter(
                controller.value,
              ),
            ),
          ),

          /// BACK BUTTON
          SafeArea(
            child: Align(
              alignment:
                  Alignment.topLeft,

              child: Padding(
                padding:
                    const EdgeInsets.only(
                  left: 10,
                  top: 5,
                ),

                child: IconButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                    );
                  },

                  icon: const Icon(
                    Icons
                        .arrow_back_ios_new,

                    color:
                        Colors.white,

                    size: 26,
                  ),
                ),
              ),
            ),
          ),

          /// CONTENT
          SafeArea(
            child: Center(
              child:
                  SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),

                padding:
                    EdgeInsets.symmetric(
                  horizontal:
                      mobile ? 16 : 22,

                  vertical: 20,
                ),

                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    mobile ? 28 : 35,
                  ),

                  child: BackdropFilter(
                    filter:
                        ImageFilter.blur(
                      sigmaX: 18,
                      sigmaY: 18,
                    ),

                    child: Container(
                      width: cardWidth,

                      padding:
                          EdgeInsets.all(
                        mobile ? 22 : 30,
                      ),

                      decoration:
                          BoxDecoration(
                        color: Colors.white
                            .withOpacity(
                                .08),

                        border: Border.all(
                          color:
                              Colors.white24,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          mobile ? 28 : 35,
                        ),
                      ),

                      child: Column(
                        children: [

                          /// LOGO
                          ShaderMask(
                            shaderCallback:
                                (r) =>
                                    const LinearGradient(
                              colors: [

                                Color(
                                    0xff00FFFF),

                                Color(
                                    0xffA000FF),

                                Color(
                                    0xff00FFB7),
                              ],
                            ).createShader(
                                        r),

                            child: Text(
                              "UA ESPORTS",

                              textAlign:
                                  TextAlign
                                      .center,

                              style:
                                  TextStyle(
                                fontSize:
                                    titleSize,

                                fontWeight:
                                    FontWeight
                                        .w900,

                                letterSpacing:
                                    mobile
                                        ? 3
                                        : 5,

                                color:
                                    Colors
                                        .white,
                              ),
                            ),
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 10
                                    : 14,
                          ),

                          /// TITLE
                          Text(
                            "CREATE NEW PASSWORD",

                            textAlign:
                                TextAlign
                                    .center,

                            style:
                                TextStyle(
                              color:
                                  Colors
                                      .white70,

                              fontSize:
                                  mobile
                                      ? 16
                                      : 18,

                              letterSpacing:
                                  mobile
                                      ? 2
                                      : 3,
                            ),
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 22
                                    : 26,
                          ),

                          /// DESCRIPTION
                          Text(
                            "Your new password must be different from previous passwords",

                            textAlign:
                                TextAlign
                                    .center,

                            style:
                                TextStyle(
                              color:
                                  Colors
                                      .white
                                      .withOpacity(
                                          .72),

                              fontSize:
                                  mobile
                                      ? 14
                                      : 15,

                              height: 1.6,
                            ),
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 28
                                    : 34,
                          ),

                          /// PASSWORD FIELD
                          passwordField(
                            "New Password",
                            true,
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 16
                                    : 18,
                          ),

                          /// CONFIRM PASSWORD
                          passwordField(
                            "Confirm Password",
                            false,
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 28
                                    : 32,
                          ),

                          /// BUTTON
                          GestureDetector(
                            onTap: () {
                              Navigator
                                  .pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          const AuthUI(),
                                ),
                              );
                            },

                            child: Container(
                              width:
                                  double.infinity,

                              height:
                                  mobile
                                      ? 58
                                      : 62,

                              decoration:
                                  BoxDecoration(
                                gradient:
                                    const LinearGradient(
                                  colors: [

                                    Color(
                                        0xffA000FF),

                                    Color(
                                        0xff00FFFF),
                                  ],
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                        22),
                              ),

                              child:
                                  Center(
                                child: Text(
                                  "RESET PASSWORD",

                                  style:
                                      TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,

                                    fontSize:
                                        mobile
                                            ? 16
                                            : 18,
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget passwordField(
      String hint,
      bool first) {
    return TextField(
      obscureText:
          first ? hide1 : hide2,

      style:
          const TextStyle(
        color: Colors.white,
      ),

      decoration:
          InputDecoration(
        prefixIcon:
            const Icon(
          Icons.lock,

          color:
              Colors.white,
        ),

        suffixIcon:
            IconButton(
          onPressed: () {
            setState(() {
              if (first) {
                hide1 = !hide1;
              } else {
                hide2 = !hide2;
              }
            });
          },

          icon: Icon(
            first
                ? hide1
                    ? Icons.visibility
                    : Icons
                        .visibility_off
                : hide2
                    ? Icons.visibility
                    : Icons
                        .visibility_off,

            color:
                Colors.white,
          ),
        ),

        hintText: hint,

        hintStyle:
            const TextStyle(
          color:
              Colors.white54,
        ),

        filled: true,

        fillColor:
            Colors.white10,

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
                  20),

          borderSide:
              BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
                  20),

          borderSide:
              BorderSide.none,
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
                  20),

          borderSide:
              const BorderSide(
            color:
                Colors.cyanAccent,
          ),
        ),
      ),
    );
  }
}

class UniversePainter
    extends CustomPainter {
  final double t;

  UniversePainter(
      this.t);

  @override
  void paint(
      Canvas canvas,
      Size size) {
    canvas.drawRect(
      Offset.zero & size,

      Paint()

        ..shader =
            const LinearGradient(
          colors: [

            Color(
                0xff02010D),

            Color(
                0xff160033),

            Color(
                0xff040C25),
          ],
        ).createShader(
                Offset.zero &
                    size),
    );

    final r = Random(2);

    for (int i = 0;
        i < 260;
        i++) {
      canvas.drawCircle(
        Offset(
          r.nextDouble() *
              size.width,

          (r.nextDouble() *
                      size.height +
                  t * 160) %
              size.height,
        ),

        r.nextDouble() * 2,

        Paint()

          ..color = Colors.white
              .withOpacity(.78),
      );
    }
  }

  @override
  bool shouldRepaint(
          oldDelegate) =>
      true;
}