import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:recordify/provider/app_provider.dart';
import 'package:recordify/screens/home_screen.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({
    super.key,
    required this.verificationId,
  });
  final String verificationId;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String otpCode = "";
  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 230, 230, 230),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.sp),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SizedBox(
                    child: Image.asset(
                      'assets/images/blackCofferLogo.png',
                      width: ScreenUtil().screenWidth,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                SizedBox(
                  height: 40.h,
                ),
                Pinput(
                  length: 6,
                  showCursor: true,
                  autofocus: true,
                  defaultPinTheme: PinTheme(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.black,
                      ),
                    ),
                    textStyle: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      otpCode = value;
                    });
                  },
                ),
                SizedBox(
                  height: 40.h,
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(40.h),
                  width: ScreenUtil().screenWidth,
                  child: ElevatedButton(
                    onPressed: () async {
                      appProvider.toggleLoading();
                      try {
                        PhoneAuthCredential credential =
                            PhoneAuthProvider.credential(
                          verificationId: widget.verificationId,
                          smsCode: otpCode,
                        );
                        await FirebaseAuth.instance
                            .signInWithCredential(credential)
                            .then(
                          (value) {
                            appProvider.toggleLoading();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          },
                        );
                      } catch (ex) {
                        print(
                          "ERROR: $ex",
                        );
                      }
                    },
                    
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: Center(
                      child: Text(
                        'VERIFY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: appProvider.isLoading,
            child: Container(
              color: Colors.black.withOpacity(0.3),
              width: ScreenUtil().screenWidth,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
