import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:otp_authentication/views/otp_screen.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text("Otp Verification"),
        centerTitle: true,
        backgroundColor: Colors.grey[200],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                width: MediaQuery.of(context).size.width * 0.9,
                child: const MainCard(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MainCard extends StatelessWidget {
  const MainCard({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController numberController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return Card(
      shadowColor: Colors.grey,
      color: Colors.white,
      elevation: 7,
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text(
              "Enter Your Mobile Number",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Enter Mobile Number linked with PAN &\nAdhaar",
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: TextFormField(
                  controller: numberController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                      hintText: "Mobile Number*",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.deepPurple)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.deepPurple))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    } else if (!RegExp(r'^\+?[0-9]{10,12}$').hasMatch(value)) {
                      return 'Enter a valid mobile number';
                    }
                    return null;
                  },
                ),
              ),
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
                      if (_formKey.currentState!.validate()) {
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          phoneNumber: numberController.text.trim(),
                          verificationCompleted: (PhoneAuthCredential credential) {},
                          verificationFailed: (FirebaseAuthException ex) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(ex.message!)));
                          },
                          codeSent: (String verificationId, int? resendToken) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OtpScreen(
                                    verificationid: verificationId,
                                    number: numberController.text,
                                    startCountdown: true,
                                  ),
                                ));
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {},
                        );
                      }
                    },
                    child: const Text(
                      "Get Started",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.white),
                    )),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
                child: const NoteCard(),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class NoteCard extends StatelessWidget {
  const NoteCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "NOTE",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.deepOrange),
            ),
            Text(
              "By clicking Get Started, you are agreeing to the Terms of Use and Privacy Policy",
              style: TextStyle(
                  fontWeight: FontWeight.w400, color: Colors.grey[700]),
            ),
            Text(
              "If Signing up as a firm, enter the mobile number of the Authorised Partner/Director.",
              style: TextStyle(
                  fontWeight: FontWeight.w400, color: Colors.grey[700]),
            )
          ],
        ),
      ),
    );
  }
}
