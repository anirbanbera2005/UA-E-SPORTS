import 'new_pass_ui.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class OtpUI extends StatefulWidget {
  const OtpUI({super.key});

  @override
  State<OtpUI> createState() =>
      _OtpUIState();
}

class _OtpUIState
    extends State<OtpUI>
    with SingleTickerProviderStateMixin {
  late AnimationController c;

  final controllers =
      List.generate(
    6,
    (_) =>
        TextEditingController(),
  );

  final focusNodes =
      List.generate(
    6,
    (_) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();

    c = AnimationController(
      vsync: this,
      duration:
          const Duration(
        seconds: 18,
      ),
    )..repeat();
  }

  @override
  void dispose() {
    for (var x
        in controllers) {
      x.dispose();
    }

    for (var x
        in focusNodes) {
      x.dispose();
    }

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

    final otpSize =
        mobile ? 44.0 : 46.0;

    return Scaffold(
      body: Stack(
        children: [

          /// ANIMATED BACKGROUND
          AnimatedBuilder(
            animation: c,

            builder: (_, __) =>
                CustomPaint(
              size: Size.infinite,

              painter:
                  SpacePainter(
                c.value,
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
                        context);
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
                            "VERIFY OTP",

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
                            "Enter the 6 digit verification code",

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

                              height: 1.5,
                            ),
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 28
                                    : 34,
                          ),

                          /// OTP BOXES
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,

                            children:
                                List.generate(
                              6,

                              (i) => otpBox(
                                i,
                                otpSize,
                              ),
                            ),
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 22
                                    : 24,
                          ),

                          /// RESEND
                          Text(
                            "Resend OTP in 00:30",

                            style:
                                TextStyle(
                              color:
                                  Colors
                                      .cyanAccent,

                              fontSize:
                                  mobile
                                      ? 13
                                      : 14,
                            ),
                          ),

                          SizedBox(
                            height:
                                mobile
                                    ? 28
                                    : 30,
                          ),

                          /// VERIFY BUTTON
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const CreatePasswordUI(),
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
                                  "VERIFY",

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

  Widget otpBox(
    int index,
    double size,
  ) {
    return SizedBox(
      width: size,

      child: TextField(
        controller:
            controllers[index],

        focusNode:
            focusNodes[index],

        maxLength: 1,

        textAlign:
            TextAlign.center,

        keyboardType:
            TextInputType.number,

        style:
            TextStyle(
          color: Colors.white,

          fontSize:
              size * .48,
        ),

        decoration:
            InputDecoration(
          counterText: "",

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

        onChanged:
            (value) {
          if (value
                  .isNotEmpty &&
              index < 5) {
            FocusScope.of(context)
                .requestFocus(
              focusNodes[
                  index + 1],
            );
          }

          if (value.isEmpty &&
              index > 0) {
            FocusScope.of(context)
                .requestFocus(
              focusNodes[
                  index - 1],
            );
          }
        },
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
      Size s) {
    canvas.drawRect(
      Offset.zero & s,

      Paint()

        ..shader =
            const LinearGradient(
          colors: [

            Color(
                0xff02010D),

            Color(
                0xff180035),

            Color(
                0xff040C25),
          ],
        ).createShader(
                Offset.zero &
                    s),
    );

    final r = Random(2);

    for (int i = 0;
        i < 260;
        i++) {
      canvas.drawCircle(
        Offset(
          r.nextDouble() *
              s.width,

          (r.nextDouble() *
                      s.height +
                  t * 180) %
              s.height,
        ),

        r.nextDouble() * 2,

        Paint()

          ..color = Colors.white
              .withOpacity(.8),
      );
    }
  }

  @override
  bool shouldRepaint(
          oldDelegate) =>
      true;
}