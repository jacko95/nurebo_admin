import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_native_splash/flutter_native_splash.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:path_provider/path_provider.dart';


class SignedImageBusiness {
  static final SignedImageBusiness _instance = SignedImageBusiness._internal();

  factory SignedImageBusiness() {
    return _instance;
  }

  SignedImageBusiness._internal();

  final Map<String, String> signedImageCache = {};


  String? getImage(String url) {
    // print('urlsffd');
    // print(url);

    if (signedImageCache.containsKey(url)) {
      return signedImageCache[url];
    }
    // await downloadImage(url);
    return null;
    // return _imageCache[url];
  }

  // void addImageToCache(String url, Uint8List imageData) async {
  //   _imageCache[url] = imageData;
  // }

  // Future<void> addImageToCache(String url) async {
  //   if(_imageCache.keys.contains(url)){
  //     print('return');
  //     return;
  //   }
  //
  //   // print('_imageCache');
  //   // for(var e in _imageCache.keys){
  //   //   print(e);
  //   // }
  //
  //   // Effettua la richiesta GET al link firmato per ottenere i dati dell'immagine
  //   final response = await http.get(
  //       Uri.parse(url),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   // print('urldfgg');
  //   // print(url);
  //
  //   if (response.statusCode >= 200 && response.statusCode < 400) {
  //     // print('response.body');
  //     // print(response.body);
  //     // final imageData = response.bodyBytes;
  //     // final imageData = response.body;
  //     // _imageCache[url] = imageData as Uint8List;
  //     // _imageCache[url] = imageData;
  //
  //     final response1 = await http.get(
  //       Uri.parse(response.body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //     );
  //
  //     if (response1.statusCode == 200) {
  //       // print('response1.body');
  //       // print(response1.body);
  //       final imageData1 = response1.bodyBytes;
  //       // final imageData = response.body;
  //
  //       _imageCache[url] = imageData1;
  //       // _imageCache.putIfAbsent(url, () => _imageCache[url] = imageData1);
  //
  //       // print('sfddggddg');
  //       // for(var e in _imageCache.keys){
  //       //   print(e);
  //       // }
  //
  //     } else {
  //       throw Exception('Failed to download image');
  //     }
  //   } else {
  //     throw Exception('Failed to download image');
  //   }
  // }

  void removeImage(String url) async {
    if (signedImageCache.keys.contains(url)) {
      signedImageCache.remove(url);
      // print('hit');
      // for (var element in imageCache.keys) {print(element);}
      // print(imageCache.containsKey(url));
      return;
    }
    // print('not hit');
  }

  Future<void> addImage(String url) async {
    if (signedImageCache.keys.contains(url)) {
      // print('return');
      return;
    }

    final receivePort = ReceivePort();

    await Isolate.spawn(fetchImageIsolate, [receivePort.sendPort, url]);

    receivePort.listen((message) async {
      if (message is String) {

        signedImageCache[url] = message;
        // _imageCache[url] = result;
        // FlutterNativeSplash.remove();

        receivePort.close();
      } else {
        // print('Failed to download image');
      }
    });
  }

  static void fetchImageIsolate(List<Object> arguments) async {
    SendPort sendPort = arguments[0] as SendPort;
    String url = arguments[1] as String;

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
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 400) {
      sendPort.send(response.body);
    }
    else {
      // print('Failed to download image');
    }
  }

  // Future<Uint8List> compressImage(Uint8List list) async {
  //   Uint8List result = await FlutterImageCompress.compressWithList(
  //     list,
  //     // minHeight: 1920,
  //     // minWidth: 1080,
  //     quality: 10,
  //     // rotate: 180,
  //   );
  //   // print(list.length);
  //   // print(result.length);
  //   // print('result.lengthInBytes');
  //   // print((result.lengthInBytes / (1024 * 1024)).toStringAsFixed(3));
  //
  //   return result;
  // }

  // Future<Uint8List> downloadImage(String url) async {
  //   // Effettua il download dell'immagine e restituisci un Uint8List con i dati binari
  //
  //   // Esempio di utilizzo del pacchetto http per il download dell'immagine
  //   final response = await http.get(Uri.parse(url));
  //   if (response.statusCode >= 200 && response.statusCode < 400) {
  //     final imageData = response.bodyBytes;
  //     _imageCache[url] = imageData;
  //     return imageData;
  //   } else {
  //     // print(url);
  //     throw Exception('Failed to download image');
  //   }
  // }
}
