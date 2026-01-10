import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

// //import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// //import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:nurebo_admin/widgets/image_cache_manager.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:nurebo_admin/widgets/signed_image_manager.dart';


class SignedImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double? height;
  final bool? forceNetworkImage;

  const SignedImage(this.imageUrl, {Key? key, required this.width, this.height, this.forceNetworkImage = false,});

  @override
  _SignedImageState createState() => _SignedImageState();
}

class _SignedImageState extends State<SignedImage> {
  static final SignedImageBusiness signedImageBusiness = SignedImageBusiness();

  // late Future<dynamic> imageFuture;
  // late Future<dynamic> imageFuture = getImage();
  // late Future<dynamic> imageFuture = fetchImage();
  // late Future<String?> signedImageFuture;

  // final serverImageUrl = '${Utils.httpServerUrl}image?path=${widget.imageUrl}';


  static void fetchImageIsolate(/*SendPort sendPort*/
      List<Object> arguments) async {
    SendPort sendPort = arguments[0] as SendPort;

    // const url = "https://api.nurebo.com/business/post";
    var url = '${Utils.httpServerUrl}image?path=${arguments[1]}';

    try {
      final response = await http.get(
          Uri.parse(url),
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

      if (response.statusCode >= 200 && response.statusCode < 400) {
        final responseBody = response.body;

        // Invia la risposta all'isolate principale tramite il SendPort
        sendPort.send(responseBody);
      } else {
        // La chiamata HTTP ha restituito uno stato diverso da 200
        // print('Errore durante la chiamata HTTP: ${response.statusCode}');
      }
    } catch (e) {
      // Si è verificato un errore durante la chiamata HTTP
      // print('Errore durante la chiamata HTTP: $e');
    }
  }

  /*void*/
  dynamic fetchImage() async {
    // Crea un ReceivePort per ricevere la risposta dall'isolate
    ReceivePort receivePort = ReceivePort();

    // Avvia l'isolate
    // await Isolate.spawn(fetchDataIsolate, receivePort.sendPort);
    await Isolate.spawn(
        fetchImageIsolate, [receivePort.sendPort, widget.imageUrl]);

    // Ascolta la risposta dall'isolate
    receivePort.listen((message) async {
      // if (message is String) {
      // final data = json.decode(message);
      // setState(() {
      //   jsonData = data.toString();
      // });
      try {
        /*await*/ signedImageBusiness.addImage('${Utils.httpServerUrl}image?path=${widget.imageUrl}');
        // print('messagefgd5gf5fg5');
        // print(message);
        return message;
      } catch (error) {
        // Gestisci l'errore qui
        // print(error);
      }

      // return message;
      // }
    });
  }

  Future<String? /*Uint8List?*/> getImage(/*String imageUrl*/) async {
    // print("vvv5454cv5");

    // var url = Uri.parse(imageUrl);
    var url = Uri.parse('${Utils.httpServerUrl}image?path=${widget.imageUrl}');
    // var url = Uri.parse(widget.imageUrl);

    var response = await http.get(
        url,
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'Business-Mobile-App',
          'Accept-encoding': 'gzip, deflate',
          'Cache-Control': 'max-age=3600'
        }
    );

    // print("response");
    // print(response);

    // print('gg6dd6dd6');
    // print('${Utils.httpServerUrl}image?path=${widget.imageUrl}');

    if (response.statusCode >= 200 && response.statusCode < 400) {
      // dynamic jsonData = json.decode(response.body);
      // print('jsonData');
      // print(jsonData);

      await signedImageBusiness.addImage('${Utils.httpServerUrl}image?path=${widget.imageUrl}');

      return response.body;
      // return response1.bodyBytes;
      // return result;
    }

    // return [];
    return null;
  }

  @override
  void initState() {
    super.initState();
    // imageFuture = getImage();
    signedImageBusiness.getImage('${Utils.httpServerUrl}image?path=${widget.imageUrl}');
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print('99999snapshot.data');
    // print(widget.imageUrl);

    return FutureBuilder<String?/*dynamic*/ /*Uint8List?*/>(
      // future: imageFuture,
      // future: fetchImage(),
      future: getImage(),
      initialData: ''/*null*/,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // return Image(
          //   fit: BoxFit.cover,
          //   width: widget.width,
          //   height: widget.height,
          //   gaplessPlayback: true,
          //   isAntiAlias: true,
          //   loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          //     if (loadingProgress == null) return child;
          //     return SizedBox(
          //       width: widget.width,
          //       height: widget.height,
          //     );
          //   },
          //   errorBuilder: (context, url, error) => SizedBox(
          //     width: widget.width,
          //     height: widget.height,
          //   ),
          //   image: NetworkImage(
          //     snapshot.data!,
          //   ),
          // );
          // return Image.network(
          return CachedNetworkImage(
            imageUrl: snapshot.data!,
            fit: BoxFit.cover,
            width: widget.width,
            height: widget.height,
            // gaplessPlayback: true,
            // isAntiAlias: true,
            // loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            //   if (loadingProgress == null) return child;
            //   return SizedBox(
            //     width: widget.width,
            //     height: widget.height,
            //   );
            // },
            // errorBuilder: (context, url, error) => SizedBox(
            //   width: widget.width,
            //   height: widget.height,
            // ),
            errorWidget: (context, url, error) => SizedBox(
              width: widget.width,
              height: widget.height,
            ),
            cacheManager: CacheManager(
              Config(
                'customCacheKey',
                stalePeriod: const Duration(days: 7)
              )
            ),
          );
        }
        else {
          return SizedBox(
            width: widget.width,
            height: widget.height,
          );
        }
      },
    );
  }
}

//
// import 'dart:async';
// import 'dart:isolate';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:nurebo/utils/utils.dart';
// import 'package:nurebo/widgets/image_cache_business.dart';
//
// class FutureImage extends StatefulWidget {
//   final String imageUrl;
//   final double width;
//   final double? height;
//
//   const FutureImage(this.imageUrl, {Key? key, required this.width, this.height}) : super(key: key);
//
//   @override
//   _FutureImageState createState() => _FutureImageState();
// }
//
// class _FutureImageState extends State<FutureImage> {
//   final ImageCacheBusiness imageCacheBusiness = ImageCacheBusiness();
//   late Future<dynamic> imageFuture;
//   late Future<Uint8List?> cacheImageFuture;
//
//   static void fetchImageIsolate(List<Object> arguments) async {
//     SendPort sendPort = arguments[0] as SendPort;
//     var url = '${Utils.httpServerUrl}image?path=${arguments[1]}';
//
//     try {
//       final response = await http.get(Uri.parse(url), headers: {
//         'Accept': '*/*',
//         'Content-Type': 'application/json',
//         'Accept-encoding': 'gzip, deflate',
//         'connection': 'keep-alive',
//       });
//
//       if (response.statusCode >= 200 && response.statusCode < 400) {
//         final responseBody = response.body;
//
//         sendPort.send(responseBody);
//       } else {
//         print('Errore durante la chiamata HTTP: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Errore durante la chiamata HTTP: $e');
//     }
//   }
//
//   // Future<dynamic> fetchImage() async {
//   //   ReceivePort receivePort = ReceivePort();
//   //   await Isolate.spawn(fetchImageIsolate, [receivePort.sendPort, widget.imageUrl]);
//   //   /*await*/ imageCacheBusiness.addImageToCache(
//   //       '${Utils.httpServerUrl}image?path=${widget.imageUrl}'
//   //     // snapshot.data!
//   //   );
//   //   return receivePort.first;
//   // }
//
//   Future<dynamic> fetchImage() async {
//     Completer<dynamic> completer = Completer<dynamic>();
//     ReceivePort receivePort = ReceivePort();
//
//     receivePort.listen((message) async {
//       /*await*/ imageCacheBusiness.addImageToCache(
//           '${Utils.httpServerUrl}image?path=${widget.imageUrl}'
//       );
//       completer.complete(message);
//       receivePort.close();
//     });
//
//     await Isolate.spawn(fetchImageIsolate, [receivePort.sendPort, widget.imageUrl]);
//
//     return completer.future;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     // imageFuture = fetchImage();
//     cacheImageFuture = imageCacheBusiness.getImageFromCache('${Utils.httpServerUrl}image?path=${widget.imageUrl}');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Uint8List?>(
//       future: cacheImageFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           if (snapshot.hasData && snapshot.data != null) {
//             return Image.memory(
//               snapshot.data!,
//               fit: BoxFit.cover,
//               gaplessPlayback: true,
//               isAntiAlias: true,
//               errorBuilder: (context, url, error) => SizedBox(
//                 width: widget.width,
//                 height: widget.height,
//               ),
//               width: widget.width,
//               height: widget.height,
//             );
//           } else {
//             return FutureBuilder<dynamic>(
//               // future: imageFuture,
//               future: fetchImage(),
//               initialData: '',
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   if (snapshot.hasData && snapshot.data != null) {
//                     return Image.network(
//                       snapshot.data,
//                       fit: BoxFit.cover,
//                       gaplessPlayback: true,
//                       isAntiAlias: true,
//                       errorBuilder: (context, url, error) => SizedBox(
//                         width: widget.width,
//                         height: widget.height,
//                       ),
//                       width: widget.width,
//                       height: widget.height,
//                     );
//                   } else {
//                     return SizedBox(
//                       width: widget.width,
//                       height: widget.height,
//                     );
//                   }
//                 } else {
//                   return SizedBox(
//                     width: widget.width,
//                     height: widget.height,
//                   );
//                 }
//               },
//             );
//           }
//         } else {
//           return SizedBox(
//             width: widget.width,
//             height: widget.height,
//           );
//         }
//       },
//     );
//   }
// }
