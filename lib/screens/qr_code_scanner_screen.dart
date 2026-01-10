import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/screens/campaign_selection_screen.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:nurebo_admin/services/qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;

class QrCodeScanner extends StatefulWidget {
  const QrCodeScanner({super.key});

  @override
  State<StatefulWidget> createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> with SingleTickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  Future<String?>? httpRequest;
  late BusinessProvider businessProvider;
  AnimationController? animationController;


//   // In order to get hot reload to work we need to pause the camera if the platform
//   // is android, or resume the camera if the platform is iOS.
//   @override
//   void reassemble() {
//     super.reassemble();
//     if (Platform.isAndroid) {
//       controller!.pauseCamera();
//     } else if (Platform.isIOS) {
//       controller!.resumeCamera();
//     }
//   }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });

      if(scanData.code!.length == 36){
        // Effettua una chiamata HTTP con il valore del codice QR
        _validate(scanData.code!);
      }
      else{
        // print('Non un biglietto nurebo');
      }
    });
  }

  Future<void> _validate(String qrCodeValue) async {
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/validate");

    // var userProvider = Provider.of<UserProvider>(context);

    Map/*<String, String>*/ body = {
      // 'user_id': userProvider.user.id,
      'business_id': businessProvider.business!.id,
      'event_reservation_id': qrCodeValue,
    };

    var response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'Business-Mobile-App',
          HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
        }
    );

    if (response.statusCode >= 200 && response.statusCode < 400) {
      final jsonResponse = response.body;

      setState(() {
        httpRequest = Future.value(jsonResponse);
      });
    } else {
      setState(() {
        // httpRequest = Future.error('Errore nella chiamata HTTP');
        httpRequest = Future.value(response.statusCode.toString());
      });
    }
  }

  @override
  void initState() {
    super.initState();
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    httpRequest = Future.value(null);
    animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2700),);
  }

  @override
  void dispose() {
    controller?.dispose();
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);

    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                ? Text('Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                : Text('Scan a code'),
            ),
          ),
          Expanded(
            flex: 2,
            child: FutureBuilder<String?>(
              future: httpRequest,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(
                                      color: Colors.blue,
                                    ),);
                }
                else if (snapshot.hasError) {
                  return Text('Errore nella chiamata HTTP: ${snapshot.error}');
                }
                else if (snapshot.hasData) {
                  if(snapshot.data == 404.toString()){
                    animationController!.repeat();
                    return Lottie.asset(
                      'assets/animations/88708-email.json',
                      // 'assets/animations/58796-warning.json',
                      width: 50,
                      height: 50,
                      controller: animationController,
                      // repeat: true
                      onLoaded: (composition) {
                        // Esegui qui le operazioni desiderate quando l'animazione è stata caricata
                        animationController!.duration = composition.duration;

                        // // animationController!.repeat();
                        // setState(() {
                        //   animationController!.forward();
                        // });

                        Timer(const Duration(milliseconds: 2700)/*animationController!.duration!*/, () {
                          // animationController!.stop();
                          animationController!.reset();
                        });
                      },
                    );
                  }
                  else if(snapshot.data == 428.toString()){
                    // print('ddgbfhfhfhfhfnh');
                    animationController!.repeat();
                    // setState(() {
                    //   animationController!.forward();
                    // });
                    return Lottie.asset(
                      'assets/animations/58796-warning.json',
                      width: 50,
                      height: 50,
                      // repeat: true
                      controller: animationController,
                      onLoaded: (composition) {
                        // Esegui qui le operazioni desiderate quando l'animazione è stata caricata
                        animationController!.duration = composition.duration;

                        // animationController!.repeat();
                        // setState(() {
                        //   animationController!.forward();
                        // });

                        Timer(const Duration(milliseconds: 2700)/*animationController!.duration!*/, () {
                          // animationController!.stop();
                          animationController!.reset();
                        });
                      },
                    );
                  }
                  else if(snapshot.data == 200.toString()){
                    animationController!.repeat();
                    return Lottie.asset(
                      'assets/animations/75779-check.json',
                      width: 50,
                      height: 50,
                      controller: animationController,
                      // repeat: true
                      onLoaded: (composition) {
                        // Esegui qui le operazioni desiderate quando l'animazione è stata caricata
                        animationController!.duration = composition.duration;

                        // setState(() {
                        //   animationController!.forward();
                        //   // animationController!.repeat();
                        // });

                        Timer(const Duration(milliseconds: 2700)/*animationController!.duration!*/, () {
                          // animationController!.stop();
                          animationController!.reset();
                        });
                      },
                    );
                  }
                  else if(snapshot.data == 434.toString()){
                    animationController!.repeat();
                    return Lottie.asset(
                      'assets/animations/58796-warning.json',
                      width: 50,
                      height: 50,
                      controller: animationController,
                      // repeat: true
                      onLoaded: (composition) {
                        // Esegui qui le operazioni desiderate quando l'animazione è stata caricata
                        animationController!.duration = composition.duration;

                        // // animationController!.repeat();
                        // setState(() {
                        //   animationController!.forward();
                        // });

                        Timer(const Duration(milliseconds: 2700)/*animationController!.duration!*/, () {
                          // animationController!.stop();
                          animationController!.reset();
                        });
                      },
                    );
                  }
                  else {
                    // return Text('Risultato della chiamata HTTP: ${snapshot.data}');
                    animationController!.repeat();
                    return Lottie.asset(
                      'assets/animations/69164-marketing-campaign-creative-3d-animation.json',
                      width: 50,
                      height: 50,
                      controller: animationController,
                      repeat: true,
                      onLoaded: (composition) {
                        // Esegui qui le operazioni desiderate quando l'animazione è stata caricata
                        animationController!.duration = composition.duration;

                        // setState(() {
                        //   // animationController!.forward();
                        //   animationController!.repeat();
                        // });

                        // Timer(/*const Duration(milliseconds: 2500)*/animationController!.duration!, () {
                        //   // animationController!.stop();
                        //   animationController!.reset();
                        // });
                      },
                    );
                    // return Center(child: CircularProgressIndicator(color: Colors.red,));
                  }
                }
                else {
                  // return Text('Nessun risultato disponibile');
                  animationController!.repeat();
                  return Lottie.asset(
                    // 'assets/animations/48594-digital-media-3d.json',
                    'assets/animations/98288-loading.json',
                    width: 50,
                    height: 50,
                    controller: animationController,
                    repeat: true,
                    onLoaded: (composition) {
                      // Esegui qui le operazioni desiderate quando l'animazione è stata caricata
                      animationController!.duration = composition.duration;

                      // setState(() {
                      //   // animationController!.forward();
                      //   animationController!.repeat();
                      // });

                      // Timer(/*const Duration(milliseconds: 2500)*/animationController!.duration!, () {
                      //   // animationController!.stop();
                      //   animationController!.reset();
                      // });
                    },
                  );

                  // return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

