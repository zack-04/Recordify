import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:recordify/provider/app_provider.dart';
import 'package:recordify/screens/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  
  final FocusNode _focusNode = FocusNode();
  
   void _checkInputLength() {
    if (phoneController.text.length >= 10) {
      _focusNode.unfocus();
    }
  }

  @override
  void initState() {
    super.initState();
    phoneController.addListener(_checkInputLength);
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Country selectedCountry = CountryParser.parseCountryCode('IN');

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(
        offset: phoneController.text.length,
      ),
    );
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      height: 51.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black),
                      ),
                      margin: EdgeInsets.only(right: 5.sp),
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            countryListTheme: CountryListThemeData(
                              bottomSheetHeight: 600.h,
                              textStyle: const TextStyle(
                                color: Colors.black,
                              ),
                              searchTextStyle: const TextStyle(
                                color: Colors.black,
                              ),
                              flagSize: 20.sp,
                            ),
                            onSelect: (Country country) {
                              setState(() {
                                selectedCountry = country;
                              });
                            },
                          );
                        },
                        child: Text(
                          "${selectedCountry.flagEmoji} +${selectedCountry.phoneCode}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        focusNode: _focusNode,
                        textInputAction: TextInputAction.done,
                        onChanged: (value) {
                          phoneController.text = value;
                        },
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Enter mobile number',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w400,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Colors.black),
                          ),
                          suffixIcon: phoneController.text.length > 9
                              ? Container(
                                  height: 30.h,
                                  width: 30.w,
                                  margin: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.green,
                                  ),
                                  child: const Icon(
                                    Icons.done,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
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
                      print("Verifying...");
                      await FirebaseAuth.instance.verifyPhoneNumber(
                        verificationCompleted:
                            (PhoneAuthCredential credential) {},
                        verificationFailed: (FirebaseAuthException ex) {
                          print(ex);
                        },
                        codeSent: (String verificationId, int? resendToken) {
                          appProvider.toggleLoading();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OTPScreen(
                                verificationId: verificationId,
                              ),
                            ),
                          );
                        },
                        codeAutoRetrievalTimeout: (String verificationId) {},
                        phoneNumber:
                            "+${selectedCountry.phoneCode}${phoneController.text.toString()}",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: Center(
                      child: Text(
                        'NEXT',
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
