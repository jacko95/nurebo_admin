import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:http/http.dart' as http;
import 'package:nurebo_admin/widgets/download_dialog.dart';
// import 'package:open_file_plus/open_file_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';


enum DownloadTaskStatus {
  STARTING,
  DOWNLOADING,
  DONE,
  FAILED,
}

class DownloadProvider extends ChangeNotifier {
  int percent = 0;
  DownloadTaskStatus status = DownloadTaskStatus.STARTING;
  File? downloadedFile;
  String folderName = 'My HTTP Folder';


  Future<void> downloadFile({
    required BuildContext context,
    required String url,
    required String filename,
    required String fileExtension,
    bool openAfterDownload = true,
  }) async {
    // Reset the vars from previous task.
    int downloaded = 0;
    status = DownloadTaskStatus.STARTING;
    percent = 0;
    downloadedFile = null;

    showDownloadProgressDialog(context);

    var httpClient = http.Client();
    var request = http.Request('GET', Uri.parse(url));
    var response = httpClient.send(request);
    // This will only work on Android.
    // Use path_provider when platform is iOS.
    // Directory directory = Directory("/storage/emulated/0/$folderName");
    // final dir = Platform.isAndroid
    //   ? await getExternalStorageDirectory()
    //   : await getApplicationDocumentsDirectory();
    Directory directory = await getTemporaryDirectory();
    //Non salvare l'apk per sicurezza!!
    // anzi cancellarlo appena finita l'installazione

    List<List<int>> chunks = [];

    response.asStream().listen((http.StreamedResponse r) {
      r.stream.listen((List<int> chunk) {
        // Stream has started emitting
        // Download task has began
        status = DownloadTaskStatus.DOWNLOADING;

        // Display percentage of completion
        // debugPrint('downloadPercentage: ${downloaded / r.contentLength * 100}');

        chunks.add(chunk);
        downloaded += chunk.length;
        percent = (downloaded / r.contentLength! * 100).ceil();

        notifyListeners();
      }, onDone: () async {
        // Display percentage of completion
        // debugPrint('downloadPercentage: ${downloaded / r.contentLength * 100}');
        directory.createSync();

        File file = File('${directory.path}/$filename$fileExtension');
        final Uint8List bytes = Uint8List(r.contentLength!);
        int offset = 0;
        for (List<int> chunk in chunks) {
          bytes.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }

        try {
          await file.writeAsBytes(bytes);
        } on FileSystemException catch (e) {
          status = DownloadTaskStatus.FAILED;
          notifyListeners();
          // print(e.message);
          return;
        }

        // Set status to done
        status = DownloadTaskStatus.DONE;
        downloadedFile = file;

        notifyListeners();

        if(openAfterDownload) {
          await Future.delayed(const Duration(milliseconds: 500), () async {
            // Dismiss the dialog
            // Navigator.pop(context);
            // Navigator.of(context, rootNavigator: false).pop(context);
            // Phoenix.rebirth(context);

            print('downloadedFile!.path');
            print(downloadedFile!.path);
            // Open the file
            OpenResult openResult = await OpenFile.open(downloadedFile!.path);
            print(openResult.type);
            print(openResult.message);

            // Phoenix.rebirth(context);
            // Navigator.pop(context);
            await SystemChannels.platform.invokeMethod('SystemNavigator.pop');

            // exit(0);
          });
        }
      });
    });
  }

  Future<bool> checkPermission() async {
    var storageStatus = await Permission.storage.status;
    var manageExternalStorageStatus = await Permission.manageExternalStorage.status;
    var requestInstallPackagesStatus = await Permission.requestInstallPackages.status;
    // final status = await Permission.storage.request();

    // if (/*status.isUndetermined*/status.isPermanentlyDenied || status.isDenied) {
    //   // Don't have permission yet
    //   if (await Permission.storage.shouldShowRequestRationale) {
    //     return await Permission.storage.request().isGranted;
    //   } else {
    //     return await Permission.storage.request().isGranted;
    //   }
    // } else {
    //   return status.isGranted;
    // }
    if (/*status.isUndetermined*/storageStatus.isPermanentlyDenied || storageStatus.isDenied || manageExternalStorageStatus.isPermanentlyDenied ||
        manageExternalStorageStatus.isDenied || requestInstallPackagesStatus.isPermanentlyDenied || requestInstallPackagesStatus.isDenied) {
      // Don't have permission yet
      if (await Permission.storage.shouldShowRequestRationale && await Permission.manageExternalStorage.shouldShowRequestRationale) {
        return await Permission.storage.request().isGranted && await Permission.storage.request().isGranted && await Permission.requestInstallPackages.request().isGranted;
      } else {
        return await Permission.storage.request().isGranted && await Permission.manageExternalStorage.request().isGranted && await Permission.requestInstallPackages.request().isGranted;
      }
    } else {
      return storageStatus.isGranted && manageExternalStorageStatus.isGranted && requestInstallPackagesStatus.isGranted;
    }
  }
}
