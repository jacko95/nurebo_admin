import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nurebo_admin/main.dart';
import 'package:nurebo_admin/provider/download_provider.dart';
import 'package:provider/provider.dart';

Future<bool> onWillPop() {
  // DateTime? currentBackPressTime;
  // DateTime now = DateTime.now();
  // if (now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
  //   currentBackPressTime = now;
  //   Fluttertoast.showToast(
  //       msg: 'Premere due volte per uscire',
  //       backgroundColor: Colors.grey[700]
  //   );
    return Future.value(false);
  // }
  // return Future.value(true);
}

showDownloadProgressDialog(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (_) {
      return WillPopScope(
        onWillPop: onWillPop,
        child: CupertinoAlertDialog(
          key: scaffoldKey,
          content: Consumer<DownloadProvider>(
            builder: (context, provider, child) {
              if (provider.status == DownloadTaskStatus.STARTING) {
                return Center(child: Text("Starting Download..."));
              }
              else if (provider.status == DownloadTaskStatus.DOWNLOADING) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blue,),
                    Positioned(
                      right: 5,
                      child: Text("${provider.percent}%"),
                    ),
                  ],
                );
              }
              else if (provider.status == DownloadTaskStatus.FAILED) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red),
                    SizedBox(width: 16),
                    Expanded(child: Text('Failed to save: Permission denied')),
                  ],
                );
              }
              else {
                // print(provider.downloadedFile!.path);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 16),
                    Text('Done Downloading'),
                  ],
                );
              }
            },
          ),
        ),
      );
    },
  );
}