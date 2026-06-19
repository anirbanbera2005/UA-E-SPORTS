import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterUI(),
    );
  }
}

class RegisterUI extends StatefulWidget {
  const RegisterUI({super.key});

  @override
  State<RegisterUI> createState() =>
      _RegisterUIState();
}

class _RegisterUIState
    extends State<RegisterUI>
    with SingleTickerProviderStateMixin {
  late AnimationController c;

  bool hide1 = true;
  bool hide2 = true;
  bool accept = false;

  @override
  void initState() {
    super.initState();

    c = AnimationController(
      vsync: this,
      duration:
          const Duration(
              seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    c.dispose();
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
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,

        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Stack(
        children: [

          /// BACKGROUND
          AnimatedBuilder(
            animation: c,

            builder:
                (_, __) =>
                    CustomPaint(
              painter:
                  SpacePainter(
                c.value,
              ),

              size:
                  Size.infinite,
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
                                    : 12,
                          ),

                          /// TITLE
                          Text(
                            "CREATE ACCOUNT",

                            textAlign:
                                TextAlign
                                    .center,

                            style:
                                TextStyle(
                              fontSize:
                                  mobile
                                      ? 16
                                      : 18,

                              letterSpacing:
                                  mobile
                                      ? 2
                                      : 3,

                              color:
                                  Colors
                                      .white70,
                            ),
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 28
                                    : 36,
                          ),

                          /// USERNAME
                          field(
                            "Username",
                            Icons.person,
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 16
                                    : 18,
                          ),

                          /// EMAIL
                          field(
                            "Email (Optional)",
                            Icons.email,
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 16
                                    : 18,
                          ),

                          /// PHONE
                          field(
                            "Phone Number",
                            Icons.phone,
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 16
                                    : 18,
                          ),

                          /// PASSWORD
                          password(
                            "Password",
                            true,
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 16
                                    : 18,
                          ),

                          /// CONFIRM PASSWORD
                          password(
                            "Confirm Password",
                            false,
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 10
                                    : 12,
                          ),

                          /// TERMS
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .center,

                            children: [

                              Checkbox(
                                value: accept,

                                activeColor:
                                    Colors.cyan,

                                onChanged:
                                    (v) {
                                  setState(() {
                                    accept =
                                        v!;
                                  });
                                },
                              ),

                              Expanded(
                                child: Text(
                                  "Accept Terms & Conditions",

                                  style:
                                      TextStyle(
                                    color:
                                        Colors
                                            .white70,

                                    fontSize:
                                        mobile
                                            ? 13
                                            : 14,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 22
                                    : 26,
                          ),

                          /// REGISTER BUTTON
                          register(
                              mobile),

                          SizedBox(
                            height:
                                mobile
                                    ? 18
                                    : 20,
                          ),

                          const Text(
                            "OR",

                            style:
                                TextStyle(
                              color:
                                  Colors
                                      .white54,
                            ),
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 16
                                    : 18,
                          ),

                          /// GOOGLE
                          google(mobile),

                          SizedBox(
                            height:
                                mobile
                                    ? 22
                                    : 24,
                          ),

                          /// LOGIN
                          Wrap(
                            alignment:
                                WrapAlignment
                                    .center,

                            crossAxisAlignment:
                                WrapCrossAlignment
                                    .center,

                            children: [

                              Text(
                                "Already have an account?",

                                style:
                                    TextStyle(
                                  color: Colors
                                      .white
                                      .withOpacity(
                                          .7),

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
                                  Navigator.pop(
                                    context,
                                  );
                                },

                                child: Text(
                                  "LOGIN",

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

  Widget field(
    String hint,
    IconData icon,
  ) {
    return TextField(
      style:
          const TextStyle(
        color: Colors.white,
      ),

      decoration:
          InputDecoration(
        prefixIcon:
            Icon(
          icon,
          color:
              Colors.white,
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
                  18),

          borderSide:
              BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
                  18),

          borderSide:
              BorderSide.none,
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
                  18),

          borderSide:
              const BorderSide(
            color:
                Colors.cyanAccent,
          ),
        ),
      ),
    );
  }

  Widget password(
    String hint,
    bool first,
  ) {
    return TextField(
      obscureText:
          first
              ? hide1
              : hide2,

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
          onPressed:
              () {
            setState(() {
              first
                  ? hide1 =
                      !hide1
                  : hide2 =
                      !hide2;
            });
          },

          icon:
              Icon(
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
                  18),

          borderSide:
              BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
                  18),

          borderSide:
              BorderSide.none,
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
                  18),

          borderSide:
              const BorderSide(
            color:
                Colors.cyanAccent,
          ),
        ),
      ),
    );
  }

  Widget register(
      bool mobile) {
    return Container(
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
                0xff9D00FF),

            Color(
                0xff00FFFF),
          ],
        ),

        borderRadius:
            BorderRadius.circular(
                20),
      ),

      child:
          Center(
        child: Text(
          "REGISTER",

          style:
              TextStyle(
            fontSize:
                mobile
                    ? 16
                    : 18,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget google(
      bool mobile) {
    return Container(
      width:
          double.infinity,

      height:
          mobile
              ? 56
              : 60,

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
                20),
      ),

      child:
          Center(
        child: Text(
          "Continue with Google",

          style:
              TextStyle(
            color:
                Colors.black,

            fontSize:
                mobile
                    ? 14
                    : 15,

            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class SpacePainter
    extends CustomPainter {
  final double t;

  SpacePainter(
      this.t);

  @override
  void paint(
      Canvas canvas,
      Size size) {
    canvas.drawRect(
      Offset.zero &
          size,

      Paint()

        ..shader =
            const LinearGradient(
          colors: [

            Color(
                0xff030112),

            Color(
                0xff170033),

            Color(
                0xff040C25),
          ],
        ).createShader(
                Offset.zero &
                    size),
    );

    final r =
        Random(4);

    for (int i = 0;
        i < 240;
        i++) {
      canvas.drawCircle(
        Offset(
          r.nextDouble() *
              size.width,

          (r.nextDouble() *
                      size.height +
                  t * 180) %
              size.height,
        ),

        r.nextDouble() *
            2,

        Paint()

          ..color = Colors.white
              .withOpacity(
                  .8),
      );
    }
  }

  @override
  bool shouldRepaint(
          oldDelegate) =>
      true;
}