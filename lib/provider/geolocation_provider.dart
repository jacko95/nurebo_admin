import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';

class GeolocationProvider extends ChangeNotifier {
  Position? position;
  LocationPermission? locationPermission;

  Future<Position?> getGeolocationPermission() async {
    locationPermission = await Geolocator.checkPermission();
    // locationPermission = await Geolocator.requestPermission();
    // print('locationPermission.toString() 2');
    // print(locationPermission.toString());

    if(locationPermission == LocationPermission.always || locationPermission == LocationPermission.whileInUse) {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        // forceAndroidLocationBusiness: true,
      );
    }
    else if(locationPermission == LocationPermission.deniedForever){

      //mostrare un dialog con questa scritta
      // print("Abilitare la localizzazione dalle impostazioni o cancellare i dati oppure disinstallare e reinstallare l'app");
      await Geolocator.openAppSettings();
    }
    else if(locationPermission == LocationPermission.denied){
      //mostrare un dialog con questa scritta
      // print("Abilitare la localizzazione dalle impostazioni o cancellare i dati oppure disinstallare e reinstallare l'app");
      await Geolocator.requestPermission();
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        // forceAndroidLocationBusiness: true,
      );
    }

    notifyListeners();
    return position;
  }

  Future<Position?> checkGeolocationPermission() async {
    locationPermission = await Geolocator.checkPermission();
    // locationPermission = await Geolocator.requestPermission();
    // print('locationPermission.toString() 1');
    // print(locationPermission.toString());

    if(locationPermission == LocationPermission.always || locationPermission == LocationPermission.whileInUse) {
      position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        // forceAndroidLocationBusiness: true,
      );
    }
    // else if(locationPermission == LocationPermission.deniedForever){
    //
    //   //mostrare un dialog con questa scritta
    //   print("Abilitare la localizzazione dalle impostazioni o cancellare i dati oppure disinstallare e reinstallare l'app");
    //   await Geolocator.openAppSettings();
    // }
    // else if(locationPermission == LocationPermission.denied){
    //   //mostrare un dialog con questa scritta
    //   print("Abilitare la localizzazione dalle impostazioni o cancellare i dati oppure disinstallare e reinstallare l'app");
    //   await Geolocator.requestPermission();
    //
    // }

    notifyListeners();
    return position;
  }


}
