import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/geolocation_provider.dart';
// import 'package:nurebo_admin/screens/OTP_send_screen.dart';
import 'package:nurebo_admin/screens/login_otp_screen.dart';
import 'package:nurebo_admin/screens/splash_screen.dart';
// import 'package:nurebo_admin/screens/OTP_verify_screen-old.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:regexpattern/regexpattern.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:phone_numbers_parser/phone_numbers_parser.dart';



class LoginScreen extends StatefulWidget {

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController phoneController = TextEditingController(text: "");
  User? user;
  bool _isEmail = true;
  bool _isPhone = true;
  double? width;
  late double height;
  DateTime? currentBackPressTime;
  Business? business;
  // GeolocationProvider geolocationProvider;
  bool isSendClicked = false;
  bool isSendSMSClicked = false;
  bool showSplashScreen = false;


  bool isItalianMobileValid(String number) {
    RegExp regex = RegExp(r'^(\+39)?3\d{9}$');
    return regex.hasMatch(number);
  }

  Future sendEmail() async {
    // var url = Uri.parse(Utils.httpServerUrl + "business_authentication/send_email");
    var url = Uri.parse("${Utils.httpServerUrl}business/${business!.id}/authentication/send_email");

    Map/*<String, String>*/ body = {
      "email": business!.email,
      "business_id": business!.id,
    };

    var response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'Business-Mobile-App',
        }
    );
    // print("response.statusCode:");
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   chatMessageList = jsonData;
      // });
      // print("jsonData email");
      // print(jsonData);
      await Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            child: LoginOtpScreen(
              authId: jsonData,
              business: business,
              isEmailVerification: true,
            ),
            duration: const Duration(milliseconds: 500),
            type: PageTransitionType.fade,
          ),
          (route) => false
      );
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => VerifyOTPScreen(loginId: jsonData,))
      // );

      return jsonData;
    }
  }

  Future sendSMS() async {
    // var url = Uri.parse(Utils.httpServerUrl + "business_authentication/send_email");
    // var url = Uri.parse("${Utils.httpServerUrl}business/${business!.id}/authentication/send_sms");
    var url = Uri.parse("${Utils.httpServerUrl}business/authentication/send_sms");

    Map/*<String, String>*/ body = {
      // "phone": business!.phone_number,
      "phone": phoneController.text,
      // "business_id": business!.id,
    };

    var response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'Business-Mobile-App',
        }
    );
    // print("response.statusCode:");
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      //   chatMessageList = jsonData;
      // });
      print("jsonData7778857777");
      print(jsonData['business_authentication_id']);
      print(jsonData['business_id']);

      await Navigator.pushAndRemoveUntil(
          context,
          PageTransition(
            child: LoginOtpScreen(
              authId: jsonData['business_authentication_id'],
              business: Business(
                id: jsonData['business_id'],
                description: jsonData['business_description'],
                name: jsonData['business_name'],
                email: jsonData['business_email'],
                room_id: jsonData['business_room_id'],
                email_notification: jsonData['business_email_notification'],
                max_contemporary_appointments: jsonData['max_contemporary_appointments'],
                address: jsonData['business_address'],
                address_number: jsonData['business_address_number'],
                postal_code: jsonData['business_postal_code'],
                province: jsonData['business_province'],
                city: jsonData['business_city'],
                region: jsonData['business_region'],
                phone: jsonData['business_phone'],
                // is_booking_business: jsonData['is_booking_business'],
                profile_image: jsonData['business_profile_image'] ?? '',
                type_id: jsonData['business_type_id'],
                latitude: jsonData['business_latitude'],
                longitude: jsonData['business_longitude'],
                // category: Category(
                //   id: jsonData['category_id'],
                //   image: jsonData['category_image'],
                //   name: jsonData['category_name'],
                // )
              ),
              isEmailVerification: true,
            ),
            duration: const Duration(milliseconds: 500),
            type: PageTransitionType.fade,
          ),
          (route) => false
      );
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => VerifyOTPScreen(loginId: jsonData,))
      // );

      return jsonData;
    }
    else if(response.statusCode == 420){
      Fluttertoast.showToast(
        // msg: 'Email aggiornata a ${widget.user.email}',
        msg: 'Numero non registrato',
        backgroundColor: Colors.grey[700],
        // )..then((value) => Navigator.pop(context));
      )/*.then((value) => */;
    }
  }

  // Future verifyUser() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "business_authentication/business");
  //   // var url = Uri.parse("http://192.168.1.252/nurebo/getUser.php");
  //
  //   Map<String, String> body = {
  //     // "id": '12',
  //     "email": emailController.text,
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   print("response.statusCode:");
  //   print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var userData = json.decode(response.body);
  //
  //     print("jsonData username");
  //     print(userData[0]);
  //     // Map data = Map.from(userData[0]);
  //     Business business = new Business(
  //       id: userData[0]['id'],
  //       description: userData[0]['description'],
  //       phone_number: userData[0]['phone_number'],
  //       email: userData[0]['email'],
  //       profile_image: userData[0]['profile_image'],
  //       address: userData[0]['address'],
  //       name: userData[0]['name'],
  //       // registered_at: DateTime.tryParse(userData[0]['registered_at']),
  //       max_contemporary_appointments: userData[0]['max_contemporary_appointments'],
  //       is_booking_business: userData[0]['is_booking_business'],
  //       // last_login: userData[0]['last_login'],
  //       // payment_card: int.parse(userData[0]['payment_card']),
  //     );
  //
  //     // Provider.of<BusinessProvider>(context).user = user;
  //     // print('BusinessProvider:');
  //     // print(Provider.of<BusinessProvider>(context).user.toJson());
  //
  //     // setState(() {
  //     //   this.eventBusiness = eventBusiness;
  //     // });
  //
  //     Navigator.push(
  //         context,
  //         PageTransition(
  //           duration: const Duration(milliseconds: 500),
  //           alignment: Alignment.center,
  //           type: PageTransitionType.fade,
  //           // child: NotificationScreen(),
  //           child: SendOTPScreen(
  //             // username: userData[0]['username'],
  //             // userId: userData[0]['id'],
  //             business: business,
  //           ),
  //         )
  //     );
  //
  //     return userData[0];
  //   }
  // }

  Future existsEmail(String email) async {
    // print('coglio');

    // setState(() {
    //   // _isUsername = false;
    //   _isEmail = false;
    // });

    // var url = Uri.parse(Utils.httpServerUrl + "business/email");
    var url = Uri.parse("${Utils.httpServerUrl}business/email/$email");
    // User user1;

    // Map<String, String> body = {
    //   // "id": '12',
    //   "username": usernameController.text,
    // };

    // print(email);
    Map<String, String> body1 = {
      // "id": '12',
      "email": email,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body1),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'Business-Mobile-App',
        }
    );

    // print("response.statusCode:");
    // print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      // print('response');
      // print(response.headers);

      var userData = json.decode(response.body);

      // print("jsonData username");
      // print(userData[0]);
      // print("userData[0]['id']");
      // print(userData[0]['id']);
      // print("userData[0]['email']");
      // print(userData[0]['email']);
      // print("userData[0]['id']");
      // print(userData[0]['id']);
      // setState(() {
      //   _isUsername = false;
      // });
      if(userData[0] != null) {

        if(userData[0]['id'] != null) {
          setState(() {
            // usernameExists = true;
            // _isUsername = true;
            _isEmail = true;
          });

          Business business = Business(
            id: userData[0]['id'],
            description: userData[0]['description'],
            phone: userData[0]['phone'],
            email: userData[0]['email'],
            room_id: userData[0]['business_room_id'],
            email_notification: userData[0]['email_notification'],
            profile_image: userData[0]['profile_image'] ?? '',
            address: userData[0]['address'],
            name: userData[0]['name'],
            max_contemporary_appointments: userData[0]['max_contemporary_appointments'],
            // is_booking_business: userData[0]['is_booking_business'],
          );

          setState(() {
            // user = user1;
            this.business = business;
          });

          // print(user.id);

          // return user1;
        }
        else{
          // setState(() {
          //   // usernameExists = false;
          //   _isUsername = false;
          // });
        }
      }
      else{
        // setState(() {
        //   // usernameExists = false;
        //   _isUsername = false;
        // });
      }
      // return userData[0];
      return _isEmail;
    }
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: 'Premere due volte per uscire', );
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  void initState() {
    super.initState();
    // FlutterNativeSplash.remove();
    setState(() {
      showSplashScreen = false;
    });
    // geolocationProvider = Provider.of<GeolocationProvider>(context, listen: false);
    // geolocationProvider.getGeolocationPermission();

  }

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // geolocationProvider = Provider.of<GeolocationProvider>(context, listen: true);

    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    // print('height');
    // print(height);
    // print('width');
    // print(width);

    return showSplashScreen ? const SplashScreen() : Scaffold(
      resizeToAvoidBottomInset: true,
      body: WillPopScope(
        onWillPop: onWillPop,
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  // image: AssetImage('assets/images/bg_image.png'),
                  image: NetworkImage(
                    // 'https://images.pexels.com/photos/3059404/pexels-photo-3059404.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
                    // 'https://images.pexels.com/photos/784633/pexels-photo-784633.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'
                    'https://images.pexels.com/photos/1395967/pexels-photo-1395967.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'
                    // 'https://images.pexels.com/photos/4153618/pexels-photo-4153618.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  // begin: Alignment.topCenter,
                  begin: Alignment.bottomCenter,
                  // end: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.transparent, /*Color(0xFF111122).withOpacity(0.8),*/ Color(0xFF111122)],
                ),
              ),
            ),
            NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(
                        left: 0,
                        right: 0,
                        top: 0
                      ),
                      // shrinkWrap: true,
                      // physics: NeverScrollableScrollPhysics(),
                      // mainAxisAlignment: MainAxisAlignment.start,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // SizedBox(height: MediaQuery.of(context).size.height * 0.075),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(width: MediaQuery.of(context).size.width * 0.075),
                            RichText(
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.black,
                                    // color: Colors.white,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                        text: 'Bentornato da\n',
                                        // text: exhibitions[i].tipo,
                                        style: TextStyle(
                                            // fontWeight: FontWeight.w700,
                                            // fontSize: 16,
                                            // color: Colors.blue
                                            fontSize: MediaQuery.of(context).size.width * 0.05,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey[50],
                                        )
                                    ),
                                    TextSpan(
                                      text: 'nurebo',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        // color: Colors.blue[500],
                                        // color: Colors.blue[500],
                                        color: Colors.blue[500],
                                        fontFamily: 'Panton',
                                        letterSpacing: -5,
                                        fontSize: MediaQuery.of(context).size.width * 0.15,
                                      )
                                    ),
                                  ]
                              ),
                            ),
                            SizedBox(width: 1),
                            GradientText(
                                'Admin',
                                gradient: LinearGradient(
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                    colors: [
                                      // Color(0xff8921aa),
                                      // Color(0xffDA44bb),

                                      Colors.yellow,
                                      Colors.yellow,
                                      // Color(0xffDA44bb)
                                    ]
                                ),
                                style: TextStyle(
                                  fontSize: MediaQuery.of(context).size.width * 0.03,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[500],
                                  fontFamily: 'Panton',
                                  letterSpacing: -1,
                                )
                            ),
                          ],
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.025),

                        height > 700 ? Container(
                          height: MediaQuery.of(context).size.height * 0.33,
                          // width: MediaQuery.of(context).size.width * 0.97,
                          // child: Lottie.asset(
                          //   // 'assets/animations/69164-marketing-campaign-creative-3d-animation.json',
                          //   isSendClicked == false ? 'assets/animations/69164-marketing-campaign-creative-3d-animation.json' : 'assets/animations/88708-email.json',
                          //   // controller: animationController,
                          //   width: 200,
                          //   height: 200,
                          //   // repeat: true
                          // ),
                        ) : Container(height: MediaQuery.of(context).size.height * 0.07,),

                        // Visibility(
                        //   visible: false,
                        //   child: Padding(
                        //     padding: EdgeInsets.only(
                        //         left: MediaQuery.of(context).size.width * 0.09,
                        //         right: MediaQuery.of(context).size.width * 0.09,
                        //         // top: 30
                        //     ),
                        //     child: TextFormField(
                        //       // onChanged: (email) => existsEmail(email),
                        //       onChanged: (email) /*=>*/ async {
                        //         setState(() {
                        //           _isEmail = EmailValidator.validate(email) && email.isEmail();
                        //         });
                        //         // if(!EmailValidator.valibooking(email)){
                        //         // if(emailTextController.text.toString().isEmail()){
                        //         if(_isEmail == false){
                        //           // print('porcodio');
                        //           //
                        //           // setState(() {
                        //           //   _isEmail = true;
                        //           // });
                        //           // await existsEmail(email);
                        //         }
                        //         else{
                        //           // Fluttertoast.showToast(
                        //           //     msg: "Valid Email",
                        //           //     toastLength: Toast.LENGTH_SHORT,
                        //           //     gravity: ToastGravity.TOP,
                        //           //     timeInSecForIosWeb: 1,
                        //           //     fontSize: 16.0
                        //           // );
                        //         }
                        //       },
                        //       controller: emailController,
                        //       autofillHints: [AutofillHints.email],
                        //       // validator: (email) => email != null && !EmailValidator.valibooking(email)
                        //       //     ? 'Enter a valid email'
                        //       //     : null,
                        //       keyboardType: TextInputType.emailAddress,
                        //       // enabled: true,
                        //       enabled: isSendClicked ? false : true,
                        //       enableInteractiveSelection: true,
                        //       /*onChanged: (_) async {
                        //         // setState(() async {
                        //         await existsUser();
                        //         // });
                        //         print(usernameController.text);
                        //         print(usernameExists.toString());
                        //       },*/
                        //       // onChanged: (password) => onPasswordChanged(password),
                        //
                        //       decoration: InputDecoration(
                        //         filled: true,
                        //         fillColor: Colors.white,
                        //         prefixIcon: Padding(
                        //           padding: const EdgeInsets.only(bottom: 3.0),
                        //           child: Icon(
                        //             Icons.mail_outlined,
                        //             color: Colors.grey[700],
                        //             size: 21,
                        //           ),
                        //         ),
                        //         suffixIcon: Padding(
                        //           padding: const EdgeInsets.all(15.0),
                        //           child: AnimatedContainer(
                        //             duration: Duration(milliseconds: 0),
                        //             width: 20,
                        //             height: 20,
                        //             decoration: BoxDecoration(
                        //                 color: emailController.text == '' ? Colors.transparent :
                        //                 _isEmail
                        //                     ? Colors.green
                        //                     : Colors.red,
                        //   /*                              border: !_isEmail
                        //                       ? Border.all(color: Colors.transparent)
                        //                       : Border.all(color: Colors.grey.shade400),*/
                        //                 border: Border.all(color: Colors.transparent),
                        //                 // border: Border.all(color: Colors.grey.shade400),
                        //                 borderRadius: BorderRadius.circular(50)
                        //             ),
                        //             child: Center(
                        //               child: Icon(
                        //                 !_isEmail ? Icons.clear : Icons.check,
                        //                 color: emailController.text.isNotEmpty ? Colors.white : Colors.transparent,
                        //                 size: 15,
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //         border: OutlineInputBorder(
                        //             borderRadius: BorderRadius.circular(10),
                        //             borderSide: BorderSide(color: Colors.black)
                        //         ),
                        //         focusedBorder: OutlineInputBorder(
                        //             borderRadius: BorderRadius.circular(10),
                        //             borderSide: BorderSide(color: Colors.black)
                        //         ),
                        //         hintText: "Email",
                        //         contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                        //       ),
                        //     ),
                        //   ),
                        // ),


                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.09,
                              right: MediaQuery.of(context).size.width * 0.09,
                              // top: 30
                          ),
                          child: TextFormField(
                            // onChanged: (email) => existsEmail(email),
                            onChanged: (email) /*=>*/ async {

                              setState(() {
                                // _isPhone = PhoneNumber.parse(email, callerCountry: IsoCode.IT).isValid();
                                _isPhone = isItalianMobileValid(email);
                              });
                              // if(!EmailValidator.valibooking(email)){
                              // if(emailTextController.text.toString().isEmail()){
                              if(_isPhone == false){
                                // print('porcodio');
                                //
                                // setState(() {
                                //   _isEmail = true;
                                // });
                                // await existsEmail(email);
                              }
                              else{
                                // Fluttertoast.showToast(
                                //     msg: "Valid Email",
                                //     toastLength: Toast.LENGTH_SHORT,
                                //     gravity: ToastGravity.TOP,
                                //     timeInSecForIosWeb: 1,
                                //     fontSize: 16.0
                                // );
                              }
                            },
                            controller: phoneController,
                            autofillHints: [AutofillHints.telephoneNumber],
                            // validator: (email) => email != null && !EmailValidator.valibooking(email)
                            //     ? 'Enter a valid email'
                            //     : null,
                            keyboardType: TextInputType.phone,
                            // enabled: true,
                            enabled: isSendClicked ? false : true,
                            enableInteractiveSelection: true,
                            /*onChanged: (_) async {
                              // setState(() async {
                              await existsUser();
                              // });
                              print(usernameController.text);
                              print(usernameExists.toString());
                            },*/
                            // onChanged: (password) => onPasswordChanged(password),

                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Padding(
                                padding: const EdgeInsets.only(bottom: 3.0),
                                child: Icon(
                                  // Icons.phone,
                                  Icons.mail_outline,
                                  color: Colors.grey[700],
                                  size: 21,
                                ),
                              ),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 0),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                      color: phoneController.text == '' ? Colors.transparent :
                                      _isPhone
                                          ? Colors.green
                                          : Colors.red,
/*                              border: !_isEmail
                                            ? Border.all(color: Colors.transparent)
                                            : Border.all(color: Colors.grey.shade400),*/
                                      border: Border.all(color: Colors.transparent),
                                      // border: Border.all(color: Colors.grey.shade400),
                                      borderRadius: BorderRadius.circular(50)
                                  ),
                                  child: Center(
                                    child: Icon(
                                      !_isPhone ? Icons.clear : Icons.check,
                                      color: phoneController.text.isNotEmpty ? Colors.white : Colors.transparent,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.black)
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: Colors.black)
                              ),
                              hintText: "Inserisci il tuo numero",
                              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 20),
                            ),
                          ),
                        ),

                        // Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //
                        //   children: <Widget>[
                        //     Text(
                        //         // 'Hello',
                        //         'Kad',
                        //         softWrap: true,
                        //         style: TextStyle(
                        //             fontSize: 80.0, fontWeight: FontWeight.bold,
                        //           // height: 0
                        //           wordSpacing: 0
                        //         )
                        //     ),
                        //     Row(
                        //       crossAxisAlignment: CrossAxisAlignment.start,
                        //       mainAxisAlignment: MainAxisAlignment.start,
                        //
                        //       children: [
                        //         Text(
                        //           // 'There',
                        //             'ingira',
                        //             softWrap: true,
                        //
                        //             style: TextStyle(
                        //                 fontSize: 80.0,
                        //                 fontWeight: FontWeight.bold,
                        //                 wordSpacing: 0,
                        //               height: 0.75
                        //             )
                        //         ),
                        //         Text(
                        //             '.',
                        //             softWrap: true,
                        //
                        //             style: TextStyle(
                        //                 fontSize: 80.0,
                        //                 fontWeight: FontWeight.bold,
                        //                 color: Colors.green,
                        //                 wordSpacing: 0,
                        //               height: 0.75
                        //             )
                        //         )
                        //       ],
                        //     ),
                        //   ],
                        // ),
                        // TextField(
                        //   controller: usernameController,
                        //   keyboardType: TextInputType.name,
                        //   enabled: true,
                        //   enableInteractiveSelection: true,
                        //   onChanged: (_) async {
                        //     // setState(() async {
                        //       await existsUser();
                        //     // });
                        //     // await existsUser();
                        //     print(usernameController.text);
                        //     print(usernameExists.toString());
                        //   },
                        // ),
                        // Center(
                        //   child: ElevatedButton(
                        //     onPressed: () async {
                        //       await verifyUser();
                        //
                        //       // await sendSms();
                        //       // Navigator.push(
                        //       //   context,
                        //       //   MaterialPageRoute(builder: (context) => AuthScreen())
                        //       // );
                        //     },
                        //     // color: Colors.redAccent,
                        //     child: Text('Accedi'),
                        //   ),
                        // ),
                        // Container(
                        //   width: MediaQuery.of(context).size.width * .7,
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: ElevatedButton(
                        //       style: ButtonStyle(
                        //         backgroundColor: MaterialStateProperty.all<Color>(Colors.grey[500]),
                        //         // foregroundColor: Colors.grey,
                        //       ),
                        //       onPressed: (){
                        //         Navigator.pushAndRemoveUntil(
                        //           context,
                        //           MaterialPageRoute(
                        //               // builder: (context) => RegisterScreen(),
                        //               builder: (context) => RegisterScreen1(),
                        //           ),
                        //           (route) => false
                        //         );
                        //         // debugPrint("CLicckk");
                        //       },
                        //       child: Text(
                        //         "Iscriviti",
                        //         style: TextStyle(
                        //           color: Colors.white,
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(
                          height: 30,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Visibility(
                            //   visible: !isSendClicked,
                            //   child: Center(
                            //     child: Container(
                            //       // height: MediaQuery.of(context).size.height * 0.075,
                            //       width: MediaQuery.of(context).size.width * 0.75,
                            //       child: MaterialButton(
                            //         onPressed: () async {
                            //           // if(_isUsername && usernameController.text != ''){
                            //           if(_isEmail && emailController.text != ''){
                            //             if((await existsEmail(emailController.text)) == true){
                            //               setState(() {
                            //                 isSendClicked = true;
                            //               });
                            //               await sendEmail();
                            //             }
                            //           }
                            //           else{
                            //             Fluttertoast.showToast(
                            //               // msg: 'Email aggiornata a ${widget.user.email}',
                            //               msg: 'Email non valida',
                            //               backgroundColor: Colors.grey[700],
                            //               // )..then((value) => Navigator.pop(context));
                            //             )/*.then((value) => */;
                            //           }
                            //         },
                            //         // minWidth: MediaQuery.of(context).size.width * 0.6,
                            //         elevation: 0,
                            //         // color: Colors.blue[500],
                            //         color: Colors.blue[500],
                            //         padding: EdgeInsets.fromLTRB(50, 18, 50, 18),
                            //         shape: RoundedRectangleBorder(
                            //             borderRadius: BorderRadius.circular(8)
                            //         ),
                            //         // elevation: 0,
                            //         // padding: EdgeInsets.all(18),
                            //         // shape: RoundedRectangleBorder(
                            //         //     borderRadius: BorderRadius.circular(20)
                            //         // ),
                            //         child: Center(
                            //           child: Text(
                            //             "Accedi tramite Email",
                            //             style: TextStyle(
                            //               fontWeight: FontWeight.bold,
                            //               color: Colors.white
                            //             ),
                            //           )
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            Visibility(
                              visible: !isSendSMSClicked,
                              child: Center(
                                child: Container(
                                  // height: MediaQuery.of(context).size.height * 0.075,
                                  width: MediaQuery.of(context).size.width * 0.75,
                                  child: MaterialButton(
                                    onPressed: () async {
                                      if(/*_isEmail &&*/isItalianMobileValid(phoneController.text)){
                                        //   setState(() {
                                        //     isSendSMSClicked = true;
                                        //   });
                                        await sendSMS();
                                      }
                                      else {
                                        Fluttertoast.showToast(
                                          // msg: 'Email aggiornata a ${widget.user.email}',
                                          msg: 'Numero non valido',
                                          backgroundColor: Colors.grey[700],
                                          // )..then((value) => Navigator.pop(context));
                                        )/*.then((value) => */;
                                      }
                                    },
                                    // minWidth: MediaQuery.of(context).size.width * 0.6,
                                    elevation: 0,
                                    // color: Colors.blue[500],
                                    color: Colors.blue[500],
                                    padding: EdgeInsets.fromLTRB(50, 18, 50, 18),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)
                                    ),
                                    // elevation: 0,
                                    // padding: EdgeInsets.all(18),
                                    // shape: RoundedRectangleBorder(
                                    //     borderRadius: BorderRadius.circular(20)
                                    // ),
                                    child: Center(
                                      child: Text(
                                        // "Accedi tramite SMS",
                                        "Invia",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white
                                        ),
                                      )
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            // Center(
                            //   child: Container(
                            //     width: MediaQuery.of(context).size.width * 0.75,
                            //     child: MaterialButton(
                            //       onPressed: () async {
                            //         // await verifyUser();
                            //         // if(_isUsername && usernameController.text != ''){
                            //         if(_isEmail && emailController.text != ''){
                            //           await sendSms();
                            //         }
                            //         else{
                            //           Fluttertoast.showToast(
                            //             // msg: 'Email aggiornata a ${widget.user.email}',
                            //             msg: 'Username non valido',
                            //             backgroundColor: Colors.grey[700],
                            //             // )..then((value) => Navigator.pop(context));
                            //           )/*.then((value) => */;
                            //         }
                            //       },
                            //       // minWidth: MediaQuery.of(context).size.width * 0.6,
                            //       elevation: 0,
                            //       color: Colors.blue[500],
                            //       padding: EdgeInsets.fromLTRB(50, 18, 50, 18),
                            //       shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(20)
                            //       ),
                            //       // elevation: 0,
                            //       // padding: EdgeInsets.all(18),
                            //       // shape: RoundedRectangleBorder(
                            //       //     borderRadius: BorderRadius.circular(20)
                            //       // ),
                            //       child: Center(
                            //           child: Text(
                            //             "Accedi tramite SMS",
                            //             style: TextStyle(
                            //                 fontWeight: FontWeight.bold,
                            //                 color: Colors.white
                            //             ),
                            //           )
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: 15,
                            // ),
                            // Center(
                            //   child: Container(
                            //     width: MediaQuery.of(context).size.width * 0.75,
                            //     child: MaterialButton(
                            //       onPressed: () async {
                            //         // Navigator.pushAndRemoveUntil(
                            //         //   context,
                            //         //   PageTransition(
                            //         //     // child: RegisterScreen1(),
                            //         //     child: RegisterScreen(),
                            //         //     duration: const Duration(milliseconds: 500),
                            //         //     type: PageTransitionType.fade,
                            //         //   ),
                            //         //   (route) => false
                            //         // );
                            //       },
                            //       // minWidth: MediaQuery.of(context).size.width * 0.6,
                            //       elevation: 0,
                            //       color: Colors.grey[500],
                            //       // color: Colors.lightBlue[200],
                            //       // color: Colors.purple[300],
                            //       padding: EdgeInsets.fromLTRB(50, 18, 50, 18),
                            //       shape: RoundedRectangleBorder(
                            //           borderRadius: BorderRadius.circular(20)
                            //       ),
                            //       // elevation: 0,
                            //       // padding: EdgeInsets.all(18),
                            //       // shape: RoundedRectangleBorder(
                            //       //     borderRadius: BorderRadius.circular(20)
                            //       // ),
                            //       child: Center(
                            //           child: Text(
                            //             "Registrati",
                            //             style: TextStyle(
                            //                 fontWeight: FontWeight.bold,
                            //                 color: Colors.white
                            //             ),
                            //           )
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(height: 30,),
                            SizedBox(
                              height: height > 700
                                ? MediaQuery.of(context).size.height * 0.075
                                : MediaQuery.of(context).size.height * 0.085,
                            ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     Text(
                            //       'Non hai un account?',
                            //       style: TextStyle(
                            //         color: Colors.grey.shade600,
                            //         fontSize: 14.0, fontWeight:
                            //         FontWeight.w400
                            //       ),
                            //     ),
                            //     SizedBox(width: 5,),
                            //     InkWell(
                            //       onTap: (){
                            //         Navigator.pushAndRemoveUntil(
                            //           context,
                            //           PageTransition(
                            //             child: RegisterScreen1(),
                            //             duration: const Duration(milliseconds: 1),
                            //             type: PageTransitionType.fade,
                            //
                            //           ),
                            //           (route) => false
                            //         );
                            //       },
                            //       highlightColor: Colors.transparent,
                            //       splashColor: Colors.transparent,
                            //       child: Padding(
                            //         padding: const EdgeInsets.symmetric(vertical: 20.0),
                            //         child: Text(
                            //           'Registrati',
                            //           style: TextStyle(
                            //               color: Colors.blue,
                            //               fontSize: 14.0,
                            //               fontWeight: FontWeight.w500
                            //           ),
                            //         ),
                            //       ),
                            //     )
                            //   ],
                            // ),
                            // Row(
                            //   mainAxisAlignment: MainAxisAlignment.center,
                            //   children: [
                            //     Text(
                            //       // "Non ti ricordi l'username?",
                            //       // "Non ti ricordi l'email del tuo account?",
                            //       "Non ti ricordi la tua E-mail?",
                            //       style: TextStyle(
                            //           // color: Colors.grey.shade600,
                            //           color: Colors.grey.shade50,
                            //           fontSize: 14.0,
                            //           fontWeight: FontWeight.w400
                            //       ),
                            //     ),
                            //     SizedBox(width: 5,),
                            //     InkWell(
                            //       onTap: (){
                            //
                            //       },
                            //       highlightColor: Colors.transparent,
                            //       splashColor: Colors.transparent,
                            //       child: Padding(
                            //         padding: const EdgeInsets.symmetric(vertical: 20.0),
                            //         child: Text(
                            //           'Clicca qui',
                            //           // 'Contattaci',
                            //           style: TextStyle(
                            //               color: Colors.blue,
                            //               fontSize: 14.0,
                            //               fontWeight: FontWeight.w500
                            //           ),
                            //         ),
                            //       ),
                            //     )
                            //   ],
                            // ),

                          ],
                        ),
                        /*usernameExists == true ? Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                // await verifyUser();
                                await sendEmail();
                              },
                              // color: Colors.redAccent,
                              child: Text('Accedi tramite Email'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await sendSms();
                                // await verifyUser();
                              },
                              // color: Colors.redAccent,
                              child: Text('Accedi tramite SMS'),
                            ),
                          ],
                        )
                            : Text("")*/
                        // SizedBox(height: 30,),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
