import 'register_ui.dart';
import 'forgot_ui.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class AuthUI extends StatefulWidget {
  const AuthUI({super.key});

  @override
  State<AuthUI> createState() => _AuthUIState();
}

class _AuthUIState extends State<AuthUI>
    with SingleTickerProviderStateMixin {
  bool isPlayer = true;
  bool hide = true;

  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final width = size.width;

    final mobile = width < 600;

    final cardWidth =
        mobile ? width * .92 : 440.0;

    final titleSize =
        mobile ? width * .085 : 38.0;

    final subtitleSize =
        mobile ? 11.0 : 14.0;

    final buttonHeight =
        mobile ? 58.0 : 62.0;

    return Scaffold(
      body: Stack(
        children: [

          /// ANIMATED BACKGROUND
          AnimatedBuilder(
            animation: controller,
            builder: (_, __) {
              return CustomPaint(
                size: Size.infinite,
                painter: UniversePainter(
                  controller.value,
                ),
              );
            },
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
                      sigmaX: 20,
                      sigmaY: 20,
                    ),

                    child: Container(
                      width: cardWidth,

                      padding:
                          EdgeInsets.all(
                        mobile ? 22 : 28,
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
                                    0xffA200FF),

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
                                        : 6,

                                color:
                                    Colors
                                        .white,
                              ),
                            ),
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 8
                                    : 12,
                          ),

                          /// SUBTITLE
                          Text(
                            "TOURNAMENT • SCRIMS • GLORY",

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

                              letterSpacing:
                                  mobile
                                      ? 1
                                      : 2,

                              fontSize:
                                  subtitleSize,
                            ),
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 30
                                    : 42,
                          ),

                          /// ROLE SWITCH
                          Container(
                            height:
                                mobile
                                    ? 60
                                    : 68,

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors
                                      .white10,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                24,
                              ),
                            ),

                            child: Row(
                              children: [

                                role(
                                  "PLAYER 🎮",
                                  isPlayer,
                                  true,
                                ),

                                role(
                                  "ADMIN 🛠",
                                  !isPlayer,
                                  false,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 26
                                    : 34,
                          ),

                          /// EMAIL FIELD
                          field(
                            isPlayer
                                ? "Username / Email"
                                : "Admin Username",

                            Icons.person,
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 16
                                    : 20,
                          ),

                          /// PASSWORD
                          password(),

                          if (isPlayer)
                            const SizedBox(
                              height: 12,
                            ),

                          /// FORGOT PASSWORD
                          if (isPlayer)
                            Align(
                              alignment:
                                  Alignment
                                      .centerRight,

                              child:
                                  GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              const ForgotPasswordUI(),
                                    ),
                                  );
                                },

                                child: Text(
                                  "Forgot Password?",

                                  style:
                                      TextStyle(
                                    fontSize:
                                        mobile
                                            ? 13
                                            : 14,

                                    color: Colors
                                        .cyanAccent
                                        .withOpacity(
                                            .85),
                                  ),
                                ),
                              ),
                            ),

                          SizedBox(
                            height:
                                mobile
                                    ? 26
                                    : 30,
                          ),

                          /// LOGIN BUTTON
                          SizedBox(
                            height:
                                buttonHeight,

                            width:
                                double.infinity,

                            child:
                                loginButton(),
                          ),

                          if (isPlayer)
                            SizedBox(
                              height:
                                  mobile
                                      ? 14
                                      : 18,
                            ),

                          if (isPlayer)
                            const Text(
                              "OR",

                              style:
                                  TextStyle(
                                color:
                                    Colors
                                        .white54,
                              ),
                            ),

                          if (isPlayer)
                            SizedBox(
                              height:
                                  mobile
                                      ? 14
                                      : 18,
                            ),

                          /// GOOGLE BUTTON
                          if (isPlayer)
                            google(),

                          if (isPlayer)
                            SizedBox(
                              height:
                                  mobile
                                      ? 22
                                      : 26,
                            ),

                          /// REGISTER
                          if (isPlayer)
                            Wrap(
                              alignment:
                                  WrapAlignment
                                      .center,

                              crossAxisAlignment:
                                  WrapCrossAlignment
                                      .center,

                              children: [

                                Text(
                                  "Don't have an account?",

                                  style:
                                      TextStyle(
                                    color: Colors
                                        .white
                                        .withOpacity(
                                            .72),

                                    fontSize:
                                        mobile
                                            ? 13
                                            : 14,
                                  ),
                                ),

                                const SizedBox(
                                  width: 8,
                                ),

                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) =>
                                                const RegisterUI(),
                                      ),
                                    );
                                  },

                                  child: Text(
                                    "Register",

                                    style:
                                        TextStyle(
                                      color:
                                          const Color(
                                              0xff00FFFF),

                                      fontWeight:
                                          FontWeight
                                              .bold,

                                      fontSize:
                                          mobile
                                              ? 14
                                              : 15,
                                    ),
                                  ),
                                ),
                              ],
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

  Widget role(
    String title,
    bool active,
    bool value,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            isPlayer = value;
          });
        },

        child: AnimatedContainer(
          duration: const Duration(
              milliseconds: 350),

          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [

                      Color(
                          0xff9D00FF),

                      Color(
                          0xff00FFFF),
                    ],
                  )
                : null,

            borderRadius:
                BorderRadius.circular(
                    26),
          ),

          child: Center(
            child: FittedBox(
              child: Padding(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 8,
                ),

                child: Text(
                  title,

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget field(
    String hint,
    IconData icon,
  ) {
    return TextField(
      style: const TextStyle(
        color: Colors.white,
      ),

      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: Colors.white,
        ),

        hintText: hint,

        hintStyle:
            const TextStyle(
          color: Colors.white54,
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

  Widget password() {
    return TextField(
      obscureText: hide,

      style: const TextStyle(
        color: Colors.white,
      ),

      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.lock,
          color: Colors.white,
        ),

        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              hide = !hide;
            });
          },

          icon: Icon(
            hide
                ? Icons.visibility
                : Icons.visibility_off,

            color: Colors.white,
          ),
        ),

        hintText: "Password",

        hintStyle:
            const TextStyle(
          color: Colors.white54,
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

  Widget loginButton() {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [

            Color(0xffA200FF),

            Color(0xff00FFFF),
          ],
        ),

        borderRadius:
            BorderRadius.circular(
                20),
      ),

      child: Center(
        child: Text(
          isPlayer
              ? "LOGIN"
              : "ADMIN LOGIN",

          style: const TextStyle(
            fontSize: 18,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget google() {
    return Container(
      width: double.infinity,

      height: 60,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
                20),
      ),

      child: const Center(
        child: Text(
          "Continue with Google",

          style: TextStyle(
            color: Colors.black,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class UniversePainter
    extends CustomPainter {
  final double t;

  UniversePainter(this.t);

  @override
  void paint(
      Canvas canvas,
      Size size) {
    final bg = Paint()

      ..shader =
          const LinearGradient(
        colors: [

          Color(0xff02010D),

          Color(0xff120028),

          Color(0xff020B25),
        ],
      ).createShader(
              Offset.zero & size);

    canvas.drawRect(
      Offset.zero & size,
      bg,
    );

    final random = Random(2);

    for (int i = 0;
        i < 250;
        i++) {
      canvas.drawCircle(
        Offset(
          random.nextDouble() *
              size.width,

          (random.nextDouble() *
                      size.height +
                  t * 180) %
              size.height,
        ),

        random.nextDouble() * 2,

        Paint()

          ..color = Colors.white
              .withOpacity(.75),
      );
    }
  }

  @override
  bool shouldRepaint(
          oldDelegate) =>
      true;
}