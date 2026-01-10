import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

// //import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// //import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:nurebo_admin/widgets/image_cache_manager.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';


class FutureImage extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double? height;
  final bool? forceNetworkImage;

  const FutureImage(this.imageUrl, {super.key, required this.width, this.height, this.forceNetworkImage = false,});

  @override
  _FutureImageState createState() => _FutureImageState();
}

class _FutureImageState extends State<FutureImage>  {
  static final ImageCacheBusiness imageCacheBusiness = ImageCacheBusiness();
  // late Future<dynamic> imageFuture;
  late Future<dynamic> imageFuture = getImage/*getImageWithRetry*/();
  // late Future<dynamic> imageFuture = fetchImage();
  late Future<Uint8List?> cacheImageFuture;
  // final serverImageUrl = '${Utils.httpServerUrl}image?path=${widget.imageUrl}';
  late Uint8List? cacheImage;


  static void fetchImageIsolate(/*SendPort sendPort*/List<Object> arguments) async {
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

  /*void*/dynamic fetchImage() async {
    // Crea un ReceivePort per ricevere la risposta dall'isolate
    ReceivePort receivePort = ReceivePort();

    // Avvia l'isolate
    // await Isolate.spawn(fetchDataIsolate, receivePort.sendPort);
    await Isolate.spawn(fetchImageIsolate, [receivePort.sendPort, widget.imageUrl]);

    // Ascolta la risposta dall'isolate
    receivePort.listen((message) async {
      // if (message is String) {
        // final data = json.decode(message);
        // setState(() {
        //   jsonData = data.toString();
        // });
      try {
        /*await*/ imageCacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${widget.imageUrl}');
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

  Future<Uint8List?> getImageWithRetry(/*String url,*/ {int maxRetries = 30}) async {
    // print('ggghhfnnnn');
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      // print(url);
      try {
        Uint8List? imageData = await getImage();
        if (imageData != null) {
          if (imageData.lengthInBytes > 10000) {
            return imageData;
          }
        }
      } catch (e) {
        // Gestisci l'errore, se necessario
      }

      Future.delayed(const Duration(milliseconds: 100));
    }
    return null;  // Se tutti i tentativi falliscono, restituisci null
  }

  Future<dynamic/*Uint8List?*/> getImage(/*String imageUrl*/) async {
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

    if(response.statusCode >= 200 && response.statusCode < 400) {
      // dynamic jsonData = json.decode(response.body);
      // print('jsonData');
      // print(jsonData);
      // print(jsonData.toString());
      // return jsonData.toString();

      // final response1 = await http.get(
      //   Uri.parse(response.body),
      //   headers: {
      //     'Accept': '*/*',
      //     'Content-Type': 'application/json',
      //     'Accept-encoding': 'gzip, deflate',
      //     'connection': 'keep-alive',
      //   },
      // );
      //
      // Uint8List result = await FlutterImageCompress.compressWithList(
      //   response1.bodyBytes,
      //   // minHeight: 1920,
      //   // minWidth: 1080,
      //   quality: 60,
      //   // rotate: 180,
      // );
      // // print(list.length);
      // // print(result.length);
      // print('result.lengthInBytes');
      // print('${(result.lengthInBytes / (1024 * 1024)).toStringAsFixed(3)} MBBBBBBBBB');

      // if (response1.statusCode == 200) {
      //
      // }

      // Future.wait([
        /*await*/ imageCacheBusiness.addImageToCache(
          '${Utils.httpServerUrl}image?path=${widget.imageUrl}'
          // snapshot.data!
        );
      // ]);
      // print(DateTime.now());

      // setState(() {
      //
      // });

      return response.body;
      // return response1.bodyBytes;
      // return result;
    }

    return [];
    // return null;
  }

  @override
  void initState() {
    super.initState();
    // imageFuture = getImage();
    // cacheImageFuture = imageCacheBusiness.getImageFromCache('${Utils.httpServerUrl}image?path=${widget.imageUrl}');
    // imageCacheBusiness.getImageFromCache('${Utils.httpServerUrl}image?path=${widget.imageUrl}');
    // cacheImage = imageCacheBusiness.getImageFromCache('${Utils.httpServerUrl}image?path=${widget.imageUrl}')!;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (imageCacheBusiness.getImageFromCache('${Utils.httpServerUrl}image?path=${widget.imageUrl}') != null && widget.forceNetworkImage == false) {
      // print('77777snapshot.data');
      // print(widget.imageUrl);
      // print(snapshot.data);

      // L'immagine è presente nella cache
      return Image.memory(
        imageCacheBusiness.getImageFromCache('${Utils.httpServerUrl}image?path=${widget.imageUrl}')!,
        // cacheImage!,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        isAntiAlias: true,
        errorBuilder: (context, url, error) => SizedBox(
          width: widget.width,
          height: widget.height,
        ),
        width: widget.width,
        height: widget.height,
      );
    }
    else {

      // // L'immagine non è presente nella cache, esegui il download
      // return FutureBuilder<Uint8List>(
      //   future: imageCacheBusiness.downloadImage(widget.imageUrl),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.done) {
      //       if (snapshot.hasData && snapshot.data != null) {
      //         // Download completato, visualizza l'immagine
      //         return Image.memory(
      //           snapshot.data!,
      //           fit: BoxFit.cover,
      //         );
      //       } else {
      //         // Errore durante il download, visualizza un placeholder o un messaggio di errore
      //         return Placeholder();
      //       }
      //     } else {
      //       // In attesa del completamento del download, mostra uno spinner o un indicatore di caricamento
      //       return CircularProgressIndicator();
      //     }
      //   },
      // );
      //
      // imageCacheBusiness.downloadImage('${Utils.httpServerUrl}image?path=${widget.imageUrl}');

      // print('88888snapshot.data');
      // print(widget.imageUrl);

      // Future.wait([
      //   imageCacheBusiness.addImageToCache(
      //     '${Utils.httpServerUrl}image?path=${widget.imageUrl}',
      //     // snapshot.data!
      //   ),
      // ]);

      // var bbb = fetchImage();
      //
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
      //     bbb,
      //   ),
      // );

      return FutureBuilder<dynamic/*Uint8List?*/>(
        future: imageFuture,
        // future: fetchImage(),
        // future: getImage(),
        initialData: /*''*/null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // print('dfdgdgdg55');
            // print(snapshot);

            // return FutureImage(
            //   imageUrl: snapshot.data,
            //   cacheBusiness: CacheBusiness(
            //     Config(
            //       'customCacheKey',
            //       stalePeriod: const Duration(days: 7),
            //     ),
            //   ),
            //   fit: BoxFit.cover,
            //   width: MediaQuery.of(context).size.width,
            //   errorWidget: (context, url, error) => SizedBox(),
            // );
            return Image.network(
              snapshot.data.toString(),
              fit: BoxFit.cover,
              width: widget.width,
              height: widget.height,
              gaplessPlayback: true,
              isAntiAlias: true,
              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  width: widget.width,
                  height: widget.height,
                );
              },
              errorBuilder: (context, url, error) => SizedBox(
                width: widget.width,
                height: widget.height,
              ),
            );

            // return Image.memory(
            //   snapshot.data!,
            //   fit: BoxFit.cover,
            //   gaplessPlayback: true,
            //   isAntiAlias: true,
            //   errorBuilder: (context, url, error) => SizedBox(
            //     width: widget.width,
            //     height: widget.height,
            //   ),
            //   width: widget.width,
            //   height: widget.height,
            // );

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
            //     snapshot.data,
            //   ),
            // );
          } else {
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
}
