import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpScreen extends StatefulWidget {
  OtpScreen(
      {super.key,
      required this.number,
      this.startCountdown = false,
      required this.verificationid});

  final String number;
  final bool startCountdown;
  final String verificationid;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height * 0.44,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: mainCard(widget: widget))
            ],
          ),
        ),
      ),
    );
  }
}

class mainCard extends StatefulWidget {
  const mainCard({
    super.key,
    required this.widget,
  });

  final OtpScreen widget;

  @override
  State<mainCard> createState() => _mainCardState();
}

class _mainCardState extends State<mainCard> {
  List<bool> flag = [
    false,
    false,
    false,
    false,
  ];

  var firstController = TextEditingController();
  var secondController = TextEditingController();
  var thirdController = TextEditingController();
  var fourthController = TextEditingController();

  FocusNode firstFocus = FocusNode();
  FocusNode secondFocus = FocusNode();
  FocusNode thirdFocus = FocusNode();
  FocusNode fourthFocus = FocusNode();

  int secondsRemaining = 60;
  bool enableResend = false;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    if (widget.widget.startCountdown) {
      startCountdown();
    }
  }

  void startCountdown() {
    setState(() {
      secondsRemaining = 60;
      enableResend = false;
    });
    countdownTimer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
      }
    });
  }

  void resendOtp() {
    if (enableResend) {
      // Add your OTP resend logic here
      startCountdown(); // Restart countdown after OTP is resent
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.grey,
      color: Colors.white,
      elevation: 7,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            "Verify Your OTP",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Enter OTP sent on +91${widget.widget.number}",
            style: const TextStyle(
                fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              otpTextField(
                controller: firstController,
                focusNode: firstFocus,
                nextFocusNode: secondFocus,
                flagIndex: 0,
              ),
              otpTextField(
                controller: secondController,
                focusNode: secondFocus,
                nextFocusNode: thirdFocus,
                prevFocusNode: firstFocus,
                flagIndex: 1,
              ),
              otpTextField(
                controller: thirdController,
                focusNode: thirdFocus,
                nextFocusNode: fourthFocus,
                prevFocusNode: secondFocus,
                flagIndex: 2,
              ),
              otpTextField(
                controller: fourthController,
                focusNode: fourthFocus,
                prevFocusNode: thirdFocus,
                flagIndex: 3,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      )),
                  onPressed: () async {
                    String otpCode = firstController.text +
                        secondController.text +
                        thirdController.text +
                        fourthController.text;
                    if (otpCode.length == 4) {
                      try {
                        PhoneAuthCredential credential =
                            await PhoneAuthProvider.credential(
                                verificationId: widget.widget.verificationid,
                                smsCode: otpCode);
                        UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
                        if(userCredential != null){
                          print("Otp verification succefully");
                        }
                      } catch (ex) {
                        print("otp verification error $ex");
                      }
                    }
                  },
                  child: const Text(
                    "Verify",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white),
                  )),
            ),
          ),
          Text("Didn't receive OTP? Resend OTP in $secondsRemaining "),
          TextButton(
              onPressed: () {},
              child: Text(
                "Resend OTP",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: enableResend ? Colors.deepPurple : Colors.grey),
              ))
        ],
      ),
    );
  }

  Widget otpTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocusNode,
    FocusNode? prevFocusNode,
    required int flagIndex,
  }) {
    return SizedBox(
      height: 65,
      width: 60,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: (value) {
          if (value.length == 1) {
            flag[flagIndex] = true;
            if (nextFocusNode != null)
              FocusScope.of(context).requestFocus(nextFocusNode);
          } else if (value.length == 0) {
            flag[flagIndex] = false;
            if (prevFocusNode != null)
              FocusScope.of(context).requestFocus(prevFocusNode);
          }
          setState(() {});
        },
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 20),
        cursorColor: Colors.black,
        decoration: InputDecoration(
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: flag[flagIndex]
                ? const BorderSide(color: Colors.deepPurple, width: 3)
                : const BorderSide(color: Colors.deepPurple, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: flag[flagIndex]
                ? BorderSide(
                    color: const Color(0xff32357C).withOpacity(0.8), width: 0)
                : BorderSide(
                    color: Colors.deepPurple.withOpacity(0.8), width: 3),
          ),
        ),
      ),
    );
  }
}
