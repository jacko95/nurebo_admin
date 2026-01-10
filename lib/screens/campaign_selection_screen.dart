import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/business_campaign_type.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/campaign_provider.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/screens/campaign_notification_screen.dart';
import 'package:nurebo_admin/screens/campaign_user_preview_list_screen.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/future_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';


class CampaignSelectionScreen extends StatefulWidget {

  const CampaignSelectionScreen({super.key});

  @override
  _CampaignSelectionScreenState createState() => _CampaignSelectionScreenState();
}

class _CampaignSelectionScreenState extends State<CampaignSelectionScreen> {
  // bool? isEnabled;
  // bool? isBackground;
  // bool? isVibrate;
  // bool? isSilent;
  // bool? isEmailNotification;
  SocketProvider? socketProvider;
  late BusinessProvider businessProvider;
  late CampaignProvider campaignProvider;
  int _selectedItemIndex = 0;
  List itemList = [
    [Icons.people_outline_outlined, "Tutti gli utenti", "Tutti gli utenti iscritti"],
    [Icons.person_outlined, "Nuovi utenti", "Utenti che non hanno mai aquistato una prestazione"],
    [Icons.event, "Utenti con prenotazioni", "Utenti che hanno già effettuato almeno una prenotazione"],
    [Icons.tag, "Utenti taggati", "Utenti che sono stati taggati in almeno un post"],
    [Icons.favorite_border_rounded, "Utenti con preferiti", "Utenti che hanno tra i preferiti almeno una prestazione"],
    // [Icons.add, "Utenti per prestazione", "Utenti che hanno aquistato una specifica prestazione"],
    // [Icons.add, "Utenti per salvati", "Utenti che hanno salvato il tuo locale nei locali salvati"],
    // [Icons.add, "Utenti per like", "Utenti che hanno messo like ad una tua specifica prestazione"],
  ];
  // List<BusinessCampaignType> campaignTypeList = [];
  // List businessCampaignList = [];
  Future a = Future(() {}), b = Future(() {});
  // int maxCampaignPerWeek = 2;


  @override
  void initState() {
    super.initState();

    // BusinessPreferences.init();

    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    campaignProvider = Provider.of<CampaignProvider>(context, listen: false);

    Future.wait([
      a = campaignProvider.getAllBusinessCampaignTypes(context),
      b = campaignProvider.getAllBusinessCampaign(context),
    ]);

    // /*await*/ Future.delayed(
    //     const Duration(milliseconds: 2500),
    //         () async {
    //       if(mounted) {
    //         // Navigator.pop(context);
    //         await Navigator.push(
    //           context,
    //           PageTransition(
    //             child: const CampaignsScreen(),
    //             duration: const Duration(milliseconds: 500),
    //             type: PageTransitionType.fade,
    //           ),
    //         );
    //       }
    //     }
    // );
  }

  @override
  Widget build(BuildContext context) {
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    campaignProvider = Provider.of<CampaignProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 10),
        width: MediaQuery.of(context).size.width * 0.9,
        height: 50,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.blue[500])
          ),
          child: Text(
            // "Prosegui  (2 disponibili)",
            "Prosegui",
            // "Avvia campagna",
            // 'Continua',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700
            ),
          ),
          onPressed: () async {
            Navigator.push(
                context,
                PageTransition(
                  duration: const Duration(milliseconds: 500),
                  alignment: Alignment.center,
                  type: PageTransitionType.fade,
                  child: CampaignNotificationScreen(
                    // campaignType: _selectedItemIndex,
                    campaignType: campaignProvider.campaignTypeList[_selectedItemIndex],
                  )
                  // child: CampaignUserListScreen()
                )
            );
            // campaignProvider.businessCampaignType = campaignTypeList[_selectedItemIndex];
            // await campaignProvider.getAllCampaignUsers(context);
          },
        ),
      ),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: AppBar(
          iconTheme: IconThemeData(
            color: Colors.blue[500], //change your color here
          ),
          leading: IconButton(
            icon: Icon(
              // Icons.arrow_back,
              Icons.arrow_back_ios_new,
              // "${Icons.arrow_back_ios_new}" as IconData?,
              // size: 22,
              size: 16,
              color: Colors.grey[500],
            ),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          elevation: 0,
          // foregroundColor: Colors.blue,
          backgroundColor: Colors.white,
          // centerTitle: true,
          // title: Text(
          //   // 'Campagne',
          //   // '1 Campagna disponibile',
          //   '1 Campagna rimanente',
          //   style: TextStyle(
          //       color: Colors.blue,
          //       // color: Colors.grey[800],
          //       fontWeight: FontWeight.w600,
          //       fontSize: 15
          //   ),
          // ),
          title: Padding(
            padding: EdgeInsets.only(
              right: MediaQuery.of(context).size.width * .1
            ),
            child: FutureBuilder(
              future: b,
              builder: (context, snapshot) {
                if(snapshot.connectionState == ConnectionState.done){
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        // backgroundColor: Colors.grey[300],
                        // maxRadius: 11,
                        backgroundColor: Colors.blue[400],
                        maxRadius: 15,
                        child: Center(
                          child: Text(
                            // "2",
                            (Utils.maxCampaignPerWeek - campaignProvider.campaignThisWeek).toString(),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                                fontSize: 13.0,
                                color: Colors.white,
                                fontWeight: FontWeight.w700
                            )
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        // 'Campagne',
                        // '1 Campagna disponibile',
                        'Campagn${(Utils.maxCampaignPerWeek - campaignProvider.campaignThisWeek) < 2 ? "a" : "e"} rimanent${(Utils.maxCampaignPerWeek - campaignProvider.campaignThisWeek) < 2 ? "e" : "i"}',
                        style: TextStyle(
                          // color: Colors.blue,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                            fontSize: 15
                        ),
                      ),
                    ],
                  );
                }
                else {
                  return SizedBox();
                }

              }
            ),
          ),
          actions: [
            // Padding(
            //   padding: const EdgeInsets.all(10.0),
            //   child: Text(
            //     '0/1',
            //     style: TextStyle(
            //       // color: Colors.grey[600],
            //       color: Colors.green[600],
            //       fontWeight: FontWeight.w800,
            //       fontSize: 20
            //     ),
            //   ),
            // )
          ],
        ),
      ),
      // body: buildSettingsList(),
      body: FutureBuilder(
        // future: Future.wait([a]),
        future: a,
        builder: (context, snapshot) {
          if(ConnectionState.done == snapshot.connectionState){
            return NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: ListView(
                children: [
                  SizedBox(height: 15),
                  ListView.separated(
                    // backgroundColor: Colors.white,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    // itemCount: itemList.length,
                    itemCount: campaignProvider.campaignTypeList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Theme(
                        data: ThemeData(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: GestureDetector(
                          onTap: (){
                            // print(campaignTypeList[index].id);
                            // print(index);
                            // print('');
                            setState(() {
                              _selectedItemIndex = index;
                              // Esegui l'azione desiderata quando il radio button viene selezionato
                            });
                          },
                          child: ListTile(
                            // isThreeLine: true,
                            hoverColor: Colors.transparent,
                            // focusNode: FocusNode(),
                            // enableFeedback: false,
                            selectedTileColor: Colors.transparent,
                            // activeColor: Colors.transparent,
                            // activeTrackColor: Colors.transparent,
                            // tileColor: Colors.transparent,
                            title: Container(
                              width: MediaQuery.of(context).size.width * .5,
                              child: Row(
                                children: [
                                  SizedBox(width: 5,),
                                  // Icon(
                                  //   itemList[index][0],
                                  //   // Icons.notifications,
                                  //   color: Colors.grey[500],
                                  //   size: 27,
                                  // ),
                                  FutureSvg(
                                    campaignProvider.campaignTypeList[index].icon ?? '',
                                    color: Colors.grey[500],
                                    width: campaignProvider.campaignTypeList[index].icon_size ?? 30.0,
                                    height: campaignProvider.campaignTypeList[index].icon_size ?? 30.0,
                                  ),
                                  SizedBox(width: 30,),
                                  Container(
                                    width: MediaQuery.of(context).size.width * .53,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(bottom: .0),
                                          child: Text(
                                            // itemList[index][1],
                                            campaignProvider.campaignTypeList[index].title ?? '',
                                            // style: GoogleFonts.roboto(
                                            style: TextStyle(
                                              // color: Colors.grey[800],
                                                color: Colors.blue[500],
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 2,),
                                        Text(
                                          // itemList[index][2],
                                          campaignProvider.campaignTypeList[index].description ?? '',
                                          // style: GoogleFonts.roboto(
                                          style: TextStyle(
                                            // fontWeight: FontWeight.w500,
                                            // color: Colors.blue,
                                              color: Colors.grey[600],
                                              fontSize: 14
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            ),
                            // subtitle: Text(
                            //   "Attiva la vibrazione per le notifiche",
                            //   // style: GoogleFonts.roboto(
                            //   style: TextStyle(
                            //     // fontWeight: FontWeight.w500,
                            //     // color: Colors.blue,
                            //       color: Colors.grey[600],
                            //       fontSize: 13
                            //   ),
                            // ),
                            trailing: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              // child: Icon(
                              //   // Icons.navigate_next_rounded,
                              //   Icons.arrow_forward_ios_rounded,
                              //   // color: Colors.black,
                              //   color: Colors.grey[500],
                              //   size: 30,
                              // ),
                              child: Radio(
                                  value: index,
                                  groupValue: _selectedItemIndex,
                                  onChanged: (value){
                                    setState(() {
                                      _selectedItemIndex = value!;
                                      // Esegui l'azione desiderata quando il radio button viene selezionato
                                    });
                                  }
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return SizedBox(height: 10,);
                    },
                  ),
                  SizedBox(
                    height: 95,
                  )
                ],
              ),
            );
          }
          else {
            return const SizedBox();
          }
        }
      ),
    );
  }

}