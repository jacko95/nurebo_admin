import 'dart:async';
import 'dart:convert';

// import 'package:another_telephony/telephony.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nurebo_admin/main.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/screens/home_screen.dart';
// import 'package:nurebo_admin/screens/home_screen.dart';
import 'package:nurebo_admin/screens/login_screen.dart';
import 'package:nurebo_admin/services/telephony/telephony.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pin_code_text_field/pin_code_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:nurebo_admin/widgets/circular_countdown_timer/circular_countdown_timer.dart';


class LoginOtpScreen extends StatefulWidget {
  final String? authId;
  final Business? business;
  final bool? isEmailVerification;

  const LoginOtpScreen({super.key, this.authId, this.business, this.isEmailVerification});

  @override
  _LoginOtpScreenState createState() => _LoginOtpScreenState();
}

class _LoginOtpScreenState extends State<LoginOtpScreen> {
  int pinLength = 6;
  bool hasError = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textEditingController = TextEditingController();
  final Telephony telephony = Telephony.instance;

  String? smsOTP;
  final int startTime = 30;
  late Duration duration;
  late Timer timer;
  int _currentIndex = 0;

  bool _isResendAgain = false;
  late Timer _timer;
  // int _start = 60;
  int? _start;

  final CountDownController _controller = CountDownController();
  // int _duration = 60;
  late int _duration;
  late BusinessProvider businessProvider;


  verify() {
    const oneSec = Duration(milliseconds: 2000);
    _timer = Timer.periodic(oneSec, (timer) {});
  }

  void resend() {
    setState(() {
      _isResendAgain = true;
    });

    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      setState(() {
        if (_start == 0) {
          if(widget.isEmailVerification!)
            _start = 300;
          else
            _start = 60;
          _isResendAgain = false;
          _timer.cancel();
        } else {
          _start = _start! - 1;
        }
      });
    });
  }

  Future verifyOtp() async {
    // var url = Uri.parse(Utils.httpServerUrl + "business_authentication/verify");
    var url = Uri.parse("${Utils.httpServerUrl}business/${widget.business!.id.toString()}/authentication/${widget.authId.toString()}/verify");

    Map<String, String> body = {
      "id": widget.authId.toString(),
      "inserted_otp": _textEditingController.text,
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
      // print(jsonData);
      // if(/*valore ricevuto dal server == "corretto"*/jsonData == 1) {
      if(/*valore ricevuto dal server == "corretto"*/jsonData['success'] == 1) {
        // Navigator. pushReplacement(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => HomePage(),
        //   ),
        // );
        await BusinessPreferences.setBusinessId(widget.business!.id!);
        await BusinessPreferences.setIsLogged(true);
        await BusinessPreferences.setBusinessToken(jsonData['token']);
        businessProvider.setBusiness(widget.business);

        // await socketProvider.startSession(businessProvider.business!, (await getIp()) ?? <String, dynamic>{});

    // await socketProvider.getDateNotifications();

        // print("jsonData['token']");
        // print(jsonData['token']);

        await Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              // child: Main(user: widget.user,),
              child: HomeScreen(
                // business: widget.business,
              ),
              type: PageTransitionType.fade,
              duration: Duration(milliseconds: 500),
            ),
                (route) => false
        );

      }
      // else if(jsonData == 0) {
      else if(jsonData['success'] == 0) {
        // BusinessPreferences.setUser(widget.user.id.toString());
        await BusinessPreferences.setBusinessId('');
        await BusinessPreferences.setIsLogged(false);

        // print("jsonData['token']");
        // print(jsonData['token']);

        Fluttertoast.showToast(
          msg: 'Autenticazione fallita',
          backgroundColor: Colors.grey[800],
        )/*..then((value) => Navigator.pop(context))..then((value) => Phoenix.rebirth(context))*/;


        Navigator.pushAndRemoveUntil(
            context,
            PageTransition(
              child: LoginScreen(),
              type: PageTransitionType.fade,
              duration: Duration(milliseconds: 500),
            ),
            (route) => false
        );
      }
      // _timer.cancel();
      //else
      //push to view in cui mostra che l'otp è sbagliato
      //con un botton per riprovare l'autenticazione

      return jsonData;
    }
  }

  Widget buildTime() {
    return Text(
      "${duration.inSeconds}",
      style: const TextStyle(
          fontSize: 45
      ),
    );
  }

  void startTimer() {
    timer = Timer.periodic(
        Duration(
          seconds: 1,
        ),
        (_) => addTime()
    );
  }

  addTime() {
    final addSeconds = 1;
    final seconds = duration.inSeconds - addSeconds;
    setState(() {
      // final seconds = duration.inSeconds + addSeconds;
      duration = Duration(seconds: seconds);
    });
    if(seconds == 0) {
      // print("Countdown terminato!");
      timer.cancel();
      // reset();
      // startTimer();
      /*Navigator. pushReplacement(
        context,
        MaterialPageRoute(
          // builder: (context) => SendOTPScreen(),
          builder: (context) => UsernameScreen(),
        ),
      );*/
    }
  }

  void reset(){
    // setState(() {
    //   duration = Duration(seconds: startTime);
    // });
    setState(() => duration = Duration(seconds: startTime));
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
    // _controller.pause();
  }

  @override
  void initState() {
    super.initState();
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // socketProvider = Provider.of<SocketProvider>(context, listen: false);

    _start = !widget.isEmailVerification! ? 60 : 300;
    _duration = !widget.isEmailVerification! ? 60 : 300;
    // print("widget.loginId:");
    // print(widget.loginId);

    // BusinessPreferences.init();//???

    // duration = Duration(seconds: startTime);
    // startTimer();
    if(!widget.isEmailVerification!){

    }

    // telephony.listenIncomingSms(
    //   onNewMessage: (SmsMessage message) {
    //     // Handle message
    //     // //print('message.body6');
    //     // //print(message.body);
    //     smsOTP = message.body!.replaceAll(RegExp(r'[^0-9]'), '');
    //     _textEditingController.text = message.body!.replaceAll(RegExp(r'[^0-9]'), '');
    //     // Vibration.vibrate(duration: 500);
    //   },
    //   // onBackgroundMessage: backgroundMessageHandler,
    //   // listenInBackground: true,
    //   listenInBackground: false,
    // );
  }

  @override
  Widget build(BuildContext context) {
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,

        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20,),
                Visibility(
                  visible: _controller.isPaused,
                  child: CircularProgressIndicator(
                                      color: Colors.blue,
                                    ),
                ),
                Visibility(
                  visible: !_controller.isPaused,
                  child: CircularCountDownTimer(
                    // Countdown duration in Seconds.
                    duration: _duration,

                    // Countdown initial elapsed Duration in Seconds.
                    initialDuration: 0,

                    // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
                    controller: _controller,

                    // Width of the Countdown Widget.
                    width: MediaQuery.of(context).size.width * 0.3,

                    // Height of the Countdown Widget.
                    height: MediaQuery.of(context).size.height * 0.2,

                    // Ring Color for Countdown Widget.
                    ringColor: Colors.grey[300]!,

                    // Ring Gradient for Countdown Widget.
                    ringGradient: null,

                    // Filling Color for Countdown Widget.
                    // fillColor: Colors.blue[500]!,
                    fillColor: Colors.blue[500]!,

                    // Filling Gradient for Countdown Widget.
                    fillGradient: null,

                    // Background Color for Countdown Widget.
                    // backgroundColor: Colors.blue[300],
                    backgroundColor: Colors.blue[300],

                    // Background Gradient for Countdown Widget.
                    backgroundGradient: null,

                    // Border Thickness of the Countdown Ring.
                    strokeWidth: 15.0,

                    // Begin and end contours with a flat edge and no extension.
                    strokeCap: StrokeCap.round,
                    // strokeCap: StrokeCap.square,

                    // Text Style for Countdown Text.
                    textStyle: TextStyle(
                        fontSize: 25.0,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),

                    // Format for the Countdown Text.
                    textFormat: CountdownTextFormat.S,

                    // Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
                    isReverse: true,

                    // Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
                    isReverseAnimation: true,

                    // Handles visibility of the Countdown Text.
                    isTimerTextShown: true,

                    // Handles the timer start.
                    autoStart: true,

                    // This Callback will execute when the Countdown Starts.
                    onStart: () {
                      // Here, do whatever you want
                      // print('Countdown Started');
                    },

                    // This Callback will execute when the Countdown Ends.
                    onComplete: () {
                      // print('Countdown Ended');
                      Navigator.pushReplacement(
                        context,
                        PageTransition(
                          duration: const Duration(milliseconds: 200),
                          type: PageTransitionType.fade,
                          child: LoginScreen(),
                        )
                      );
                    },
                  ),
                ),
                // Center(child: buildTime()),
                // Center(
                //   child: Text(
                //     "Verification",
                //     style: TextStyle(
                //         fontSize: 30,
                //         fontWeight: FontWeight.bold
                //     ),
                //   ),
                // ),
                SizedBox(height: 30,),
                Container(
                  width: MediaQuery.of(context).size.width * .85,
                  child: Text(
                    /*!widget.isEmailVerification ? */"Inserire il codice inviato da Nurebo"
                      /*: "Inserire il codice a 6 cifre inviato da\ninfo.funnydragon@gmail.com"*/,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade500, height: 1.5),),
                ),
                SizedBox(height: 20,),
                Visibility(
                  visible: !_controller.isPaused,
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                          child: PinCodeTextField(
                            highlightColor: Colors.grey,
                            defaultBorderColor: Colors.grey,
                            hasTextBorderColor: Colors.grey,
                            autofocus: false,
                            hideCharacter: false,
                            highlight: true,
                            pinBoxHeight: 40,
                            pinBoxWidth: 40,
                            controller: _textEditingController,
                            maxLength: pinLength,
                            hasError: hasError,
                            pinBoxRadius: 5,
                            // maskCharacter: '*',
                            // onTextChanged: (/*text*/_) async {
                            //   // if (text.length == 6) {
                            //   if (_textEditingController.text.length == pinLength) {
                            //     // setState(() {
                            //     //   receiver.onSmsReceived.listen((SmsMessage smsMessage) async{
                            //     //     this.smsOTP = smsMessage.body.replaceAll(new RegExp(r'[^0-9]'),'');
                            //     //   });
                            //     // });
                            //     // if(widget.isEmailVerification){
                            //     //
                            //     // }
                            //     /*var ret = */await verifyOtp();
                            //     // if(ret == 1){
                            //     //   Navigator.push(
                            //     //       context,
                            //     //       MaterialPageRoute(builder: (context) => DashBoard())
                            //     //   );
                            //     // }
                            //     // otpData = text;
                            //     // smsOTP = text;
                            //     print(_textEditingController.text);
                            //   }
                            // },
                            // onDone: (text) {
                            //
                            // },
                            wrapAlignment: WrapAlignment.start,
                            pinBoxDecoration: ProvidedPinBoxDecoration.underlinedPinBoxDecoration,
                            pinTextStyle: TextStyle(fontSize: 18.0, color: Colors.black),
                            // pinTextAnimatedSwitcherTransition:
                            //     ProvidedPinBoxTextAnimation.scalingTransition,
                            // pinTextAnimatedSwitcherDuration:
                            //     const Duration(milliseconds: 300),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Text("Non hai ricevuto il messaggio?", style: TextStyle(fontSize: 14, color: Colors.grey.shade500),),
                      //     TextButton(
                      //         onPressed: () {
                      //           if (_isResendAgain) return;
                      //           resend();
                      //         },
                      //         child: Text(
                      //           _isResendAgain
                      //               ? "Riprova tra " + _start.toString()
                      //               : "Riprova",
                      //           style: TextStyle(
                      //               color: Colors.blueAccent
                      //           ),
                      //         )
                      //     )
                      //   ],
                      // ),
                    ],
                  ),
                ),

                SizedBox(height: 50,),
                Visibility(
                  visible: !_controller.isPaused,
                  child: Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.75,
                      child: MaterialButton(
                        onPressed: () async {
                          // await verifyUser();
                          // await sendSms();
                          // _timer.cancel();

                          _controller.pause();
                          await verifyOtp();
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
                              "Accedi",
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
                SizedBox(height: 50,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  showAlertDialogFailed(BuildContext context,String title, String description,String buttonName) {
    // Create button
    Widget okButton = TextButton(
      child: Text(buttonName),
      onPressed: () {
       Navigator.pop(context);
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}
