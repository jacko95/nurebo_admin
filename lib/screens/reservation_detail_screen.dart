import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

// //import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nurebo_admin/models/reservation.dart';
import 'package:nurebo_admin/models/reservation_proposal_datetime.dart';
import 'package:nurebo_admin/screens/user_profile_screen.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/widgets/account.dart';
import 'package:nurebo_admin/widgets/account_selector.dart';
import 'package:nurebo_admin/widgets/booking_dialog.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:nurebo_admin/models/booking.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/provider/booking_provider.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/screens/booking_edit_screen2.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/custom_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:nurebo_admin/widgets/popover.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:nurebo_admin/main.dart';
import 'package:url_launcher/url_launcher.dart';

class ReservationDetailScreen extends StatefulWidget {
  final Reservation? reservation;

  const ReservationDetailScreen({super.key, this.reservation});

  @override
  _ReservationDetailScreenState createState() => _ReservationDetailScreenState();
}

class _ReservationDetailScreenState extends State<ReservationDetailScreen> /*with WidgetsBindingObserver, RouteAware*/ {
  late SocketProvider socketProvider;
  // Reservation? reservation;
  late BusinessProvider businessProvider;
  BookingProvider? bookingProvider;
  List<ReservationProposalDatetime> reservationProposalDatetimeList = [];
  List<Account> proposals = [];
  String resultText = "";
  int selectedId = -1;
  Future a = Future.value(null);


  Future<void> bottomSheetNotLogged(BuildContext context) async {
    await showModalBottomSheet<int>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Popover(
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: Container(
              height: 400,
              margin: EdgeInsets.only(top: 20),
              child: ListView.builder(
                itemCount: reservationProposalDatetimeList.length,
                itemBuilder: (context, i){
                  return ListTile(
                    leading: Icon(Icons.access_time_outlined, color: Colors.grey[700], size: 30,),
                    title: Text(
                      '${DateFormat.yMMMMd('it_IT').format(reservationProposalDatetimeList[i].datetime!)} alle ${reservationProposalDatetimeList[i].datetime.toString().substring(11, 16)}',
                      // textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    // subtitle: Text(reservationProposalDatetimeList[i].reservationProposal!.user!.email!),
                  );
                }
              ),
            ),
          )
        );
      },
    );
  }

  void _showDeletingDialog(String module, BuildContext context) {
    // BookingProvider? bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return CustomDialog(
            title: 'Cancellare prenotazione',
            content: module,
            confirmColor: Colors.red[400],
            isCancel: true,
            confirmContent: 'Cancella',
            confirmCallback: () async {
              socketProvider.deleteReservation(
                widget.reservation!,
                  // reservationProposalDatetimeList[selectedId].reservationProposal!,
                  // reservationProposalDatetimeList[selectedId],
              );
            },
            // image: 'https://images.pexels.com/photos/3268732/pexels-photo-3268732.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
            // cancelColor: Colors.red[400],
          );
        }
    );
  }

  void _showConfirmProposalDialog(String module, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return CustomDialog(
          title: 'Confermare proposta',
          content: module,
          confirmColor: Colors.green[600],
          isCancel: true,
          confirmContent: 'Conferma',
          confirmCallback: () async {
            print('object');
            /*await*/ socketProvider.confirmReservationProposal(
              widget.reservation!,
              reservationProposalDatetimeList[selectedId].reservationProposal!,
              reservationProposalDatetimeList[selectedId]
            ).then((value) async {
              if(value >= 200 && value < 400){
                // print('diocawwww');
                // print(widget.reservation?.proposal != null && reservationProposalDatetimeList.isNotEmpty && widget.reservation!.is_canceled == false);
                // setState(() {
                //   reservationProposalDatetimeList.clear();
                // });
                // Navigator.of(context).pop();

                socketProvider.businessReservationList.clear();
                /*await*/ Future.wait([
                  socketProvider.getBusinessReservations(),
                  // a = loadData(),
                ]);

                // print(widget.reservation?.proposal != null && reservationProposalDatetimeList.isNotEmpty && widget.reservation!.is_canceled == false);
              }
            });
          },
        );
      }
    );
  }

  Future getBusinessReservationProposals() async {
    // print('reservationProposalDatetimeList.isNotEmpty555');
    // print(reservationProposalDatetimeList.isNotEmpty);
    // print(widget.reservation?.proposal?.user_type_id!);
    // print(reservationProposalDatetimeList[0].reservationProposal?.user_type_id == 1);
    // var url = Uri.parse("${Utils.httpServerUrl}reservation/${widget.reservation?.id}/proposal/latest");
    var url = Uri.parse("${Utils.httpServerUrl}reservation/${widget.reservation?.id}/proposal/${widget.reservation?.proposal?.id}/latest");
    // var url = Uri.parse("${Utils.httpServerUrl}reservation/${widget.reservation?.id}/proposal");

    // Map/*<String, String>*/ body = {
    //   // 'business_id': business.id,
    //   'business_id': BusinessPreferences.getBusinessId(),
    // };

    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'Business-Mobile-App',
          // 'Authorization': BusinessPreferences.getUserToken()
          HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
        }
    );

    // print("ooooooooooo response.statusCode:");
    // print(response.statusCode);

    reservationProposalDatetimeList.clear();
    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      Fluttertoast.showToast(
        msg: 'Autenticazione scaduta',
        backgroundColor: Colors.grey[700],
      );
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      print('ff5f5f5gg5');
      print(jsonData);
      print(jsonData.length);

      for(var e in jsonData){
        reservationProposalDatetimeList.add(
          ReservationProposalDatetime.fromJson(e)
        );
      }

      setState(() {});

      // print(reservationProposalDatetimeList);

      return jsonData;
    }
  }

  Future loadData() async {
    await getBusinessReservationProposals();
    // await Future.wait([
    //   /*a = *//*socketProvider.*/getBusinessReservationProposals(/*widget.reservation!*/),
    // ]).then((value) {
      reservationProposalDatetimeList.sort((a, b) {
        // if(a.priority != null && b.priority != null) {
        //   return a.priority!.compareTo(b.priority!);
        // }
        if(a.datetime != null && b.datetime != null) {
          return a.datetime!.compareTo(b.datetime!);
        }
        return 0;
      });

      proposals = List.generate(
          reservationProposalDatetimeList.length,
              (index){
            return Account(
                title: '${DateFormat.yMMMMd('it_IT').format(reservationProposalDatetimeList[index].datetime!)} alle ${reservationProposalDatetimeList[index].datetime?./*add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).*/toString().substring(11, 16)}',
                // subtitle: allEntities[index]['business_name'],
                datetime: '${DateFormat.yMMMMd('it_IT').format(reservationProposalDatetimeList[index].datetime!)} alle ${reservationProposalDatetimeList[index].datetime?./*add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).*/toString().substring(11, 16)}',
                // accountImageWidget: FutureImage(
                //   allEntities[index]['image'],
                //   width: MediaQuery.of(context).size.width,
                // )
                accountImageWidget: Container()
            );
          }
      );

      print("widget.reservation?.proposal");
      print("");
      print(widget.reservation?.proposal != null);
      print(reservationProposalDatetimeList.length > 0);
      print(widget.reservation!.is_canceled == false);
      // print(widget.reservation?.proposal != null && reservationProposalDatetimeList.isNotEmpty && widget.reservation!.is_canceled == false);
    // });
  }

  @override
  void initState() {
    super.initState();
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // bookingProvider = Provider.of<BookingProvider>(context, listen: false);
    // reservation = widget.reservation;
    // print('reservation456985');
    a = loadData();
  }

  // void _initializeProviders() {
  //   socketProvider = Provider.of<SocketProvider>(context, listen: false);
  //   businessProvider = Provider.of<BusinessProvider>(context, listen: false);
  //   bookingProvider = Provider.of<BookingProvider>(context, listen: false);
  //   // reservation = widget.reservation;
  // }
  //
  // Future<void> _loadData() async {
  //   _initializeProviders();
  //
  //   print('reservation456985');
  //   // print(widget.reservation?.toJson());
  //   print(widget.reservation?.is_canceled);
  //   print(widget.reservation?.proposal != null);
  //
  //   await socketProvider.getBusinessReservationProposals(widget.reservation!);
  //
  //   // setState(() {
  //     reservationProposalDatetimeList.sort((a, b) {
  //       if (a.datetime != null && b.datetime != null) {
  //         return a.datetime!.compareTo(b.datetime!);
  //       }
  //       return 0;
  //     });
  //
  //     proposals = List.generate(
  //       reservationProposalDatetimeList.length,
  //           (index) => Account(
  //         title: '${DateFormat.yMMMMd('it_IT').format(reservationProposalDatetimeList[index].datetime!)} alle ${reservationProposalDatetimeList[index].datetime.toString().substring(11, 16)}',
  //         datetime: '${DateFormat.yMMMMd('it_IT').format(reservationProposalDatetimeList[index].datetime!)} alle ${reservationProposalDatetimeList[index].datetime.toString().substring(11, 16)}',
  //         accountImageWidget: Container(),
  //       ),
  //     );
  //   // });
  // }
  //
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addObserver(this);
  //   _initializeProviders();
  //   _loadData();
  // }
  //
  // @override
  // Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
  //   if (state == AppLifecycleState.resumed) {
  //     await _loadData(); // Ricarica i dati quando l'app rientra in primo piano
  //   }
  // }
  //
  // @override
  // Future<void> didChangeDependencies() async {
  //   super.didChangeDependencies();
  //   // routeObserver.subscribe(this, ModalRoute.of(context));
  //   final route = ModalRoute.of(context);
  //   // if (route != null) {
  //   if (route is PageRoute) { // Controlla se è una PageRoute
  //     routeObserver.subscribe(this, route); // Usa route direttamente (è ModalRoute)
  //   }
  //   // Richiama _loadData() se necessario quando cambiano le dipendenze
  //   await _loadData();
  // }

  @override
  void dispose() {
    // WidgetsBinding.instance.removeObserver(this);
    // routeObserver.unsubscribe(this);
    super.dispose();
  }

  // @override
  // void didPushNext() {
  //   // Chiamato quando si naviga via da questa schermata
  // }
  //
  // @override
  // Future<void> didPopNext() async {
  //   // Chiamato quando si torna a questa schermata (es. da una notifica)
  //   await _loadData();
  // }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);
    // bookingProvider = Provider.of<BookingProvider>(context, listen: true);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Color(0xFFF6F7F9),
        // statusBarColor: MaterialColors.blue,
        // systemNavigationBarColor: MaterialColors.blue
      ),
      child: Scaffold(
        // backgroundColor: Color(0xFFF6F7F9),
        backgroundColor: Colors.grey[100],
        // appBar: AppBar(
        //   iconTheme: IconThemeData(
        //     color: Colors.blue[500], //change your color here
        //   ),
        //   leading: Padding(
        //     padding: const EdgeInsets.only(top: 0),
        //     child: InkWell(
        //       onTap: (){
        //         Navigator.pop(context);
        //       },
        //       child: Container(
        //         height: 40,
        //         width: 40,
        //         margin: EdgeInsets.only(top: 20, left: 20),
        //           padding: EdgeInsets.all(0),
        //           decoration: BoxDecoration(
        //               shape: BoxShape.circle,
        //               color: Colors.white
        //           ),
        //           child: Center(
        //             child: Icon(
        //               // Icons.star_rounded,
        //               // Icons.star_half_rounded,
        //               // Icons.star_border_rounded,
        //               Icons.arrow_back_ios,
        //               // color: _isAppBarExpanded ? Colors.grey[500] : Colors.red,
        //               // color: _theme,
        //               color: Colors.grey[700],
        //               // color: _scrollController.offset > (200 - kToolbarHeight) ? Colors.white : Colors.grey[500],
        //               size: 18,
        //             ),
        //           )
        //       ),
        //     ),
        //   ),
        //   centerTitle: true,
        //   elevation: 0,
        //   // foregroundColor: Colors.blue,
        //   // backgroundColor: Colors.white,
        //   // backgroundColor: Color(0xFFF6F7F9),
        //   backgroundColor: Colors.transparent,
        //   // centerTitle: true,
        //   // title: Text(
        //   //   'Prenotazioni',
        //   //   style: TextStyle(
        //   //       color: Colors.blue,
        //   //       // color: Colors.grey[800],
        //   //       fontWeight: FontWeight.w600,
        //   //       fontSize: 16
        //   //   ),
        //   // ),
        //   actions: [
        //     Visibility(
        //       // visible: widget.reservation!.is_guest == 1,
        //       visible: false,
        //       child: Container(
        //         // height: MediaQuery.of(context).size.width * 0.1,
        //         // width: MediaQuery.of(context).size.width * 0.4,
        //         margin: EdgeInsets.only(
        //             // left: MediaQuery.of(context).size.width * 0.2,
        //             right: 10,
        //             // right: MediaQuery.of(context).size.width * 0.2,
        //             top: 10,
        //             bottom: 10
        //         ),
        //         child: ElevatedButton(
        //         // child: OutlinedButton(
        //             style: OutlinedButton.styleFrom(
        //                 padding: EdgeInsets.zero,
        //                 backgroundColor: Colors.blue[500],
        //                 // backgroundColor: Colors.white,
        //                 // backgroundColor: Colors.grey[300],
        //                 minimumSize: Size(
        //                     MediaQuery.of(context).size.width * .25,
        //                     MediaQuery.of(context).size.width * .05
        //                 ),
        //                 alignment: Alignment.center
        //             ),
        //             onPressed: (){
        //               // Navigator.push(
        //               //   context,
        //               //   PageTransition(
        //               //     duration: const Duration(milliseconds: 500),
        //               //     alignment: Alignment.center,
        //               //     type: PageTransitionType.fade,
        //               //     child: BookingEditScreen2(
        //               //       booking: reservation!,
        //               //     )
        //               //   )
        //               // );
        //             },
        //             child: Text(
        //               'Modifica',
        //               style: TextStyle(
        //                 // color: Colors.blue[500],
        //                 color: Colors.white,
        //                 fontWeight: FontWeight.w700,
        //                 fontSize: 13,
        //               ),
        //             )
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: ListView(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Container(
                          // height: 40,
                          // width: 40,
                          margin: EdgeInsets.only(top: 20, left: 20),
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white
                          ),
                          child: Center(
                            child: Icon(
                              // Icons.star_rounded,
                              // Icons.star_half_rounded,
                              // Icons.star_border_rounded,
                              Icons.arrow_back,
                              // color: _isAppBarExpanded ? Colors.grey[500] : Colors.red,
                              // color: _theme,
                              color: Colors.grey[800],
                              // color: _scrollController.offset > (200 - kToolbarHeight) ? Colors.white : Colors.grey[500],
                              size: 22,
                            ),
                          )
                      ),
                    ),
                    FutureBuilder(
                      // future: a,
                      future: Future.wait([a]),
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.done){
                          return Visibility(
                            // visible: reservation!.validated_at == null && (reservation?.is_canceled == false || reservation?.is_canceled == null),
                            // visible: widget.reservation?.proposal != null && widget.reservation!.is_canceled == false,
                            visible: widget.reservation?.proposal != null && reservationProposalDatetimeList.isNotEmpty && widget.reservation!.is_canceled == false,
                            child: Container(
                              margin: EdgeInsets.only(right: 20, top: 15),
                              // child: ElevatedButton(
                              child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    // style: ElevatedButton.styleFrom(
                                    // padding: EdgeInsets.zero,
                                    elevation: 2,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 20
                                    ),
                                    // backgroundColor: Colors.orange[600],
                                    backgroundColor: Colors.white,
                                    // minimumSize: Size(80, 30),
                                    alignment: Alignment.center,
                                    shape: const StadiumBorder(),
                                    side: const BorderSide(width: 2, color: Colors.orange/*green*/),
                                  ),
                                  onPressed: () async {
                                    // if(widget.reservation?.proposal?.user_type_id == 1) {
                                    if(reservationProposalDatetimeList[0].reservationProposal?.user_type_id == 1) {
                                      print('reservationProposalDatetimeList.length12223');
                                      print(reservationProposalDatetimeList.length);
                                      bottomSheetNotLogged(context);
                                    }
                                    // else if(widget.reservation?.proposal?.user_type_id == 2) {
                                    else if(reservationProposalDatetimeList[0].reservationProposal?.user_type_id == 2) {
                                      showAccountSelectorSheet(
                                        context: context,
                                        accountList: proposals,
                                        isSheetDismissible: true, //Optional
                                        // initiallySelectedIndex: 2, //Optional
                                        initiallySelectedIndex: selectedId, //Optional
                                        hideSheetOnItemTap: false, //Optional
                                        // addAccountTitle: "Add User", //Optional
                                        // showAddAccountOption: true, //Optional
                                        // backgroundColor: Colors.blue[700], //Optional
                                        backgroundColor: Colors.white, //Optional
                                        // arrowColor: Colors.white, //Optional
                                        arrowColor: Colors.grey, //Optional
                                        // unselectedRadioColor: Colors.white, //Optional
                                        unselectedRadioColor: Colors.grey, //Optional
                                        // selectedRadioColor: Colors.amber, //Optional
                                        selectedRadioColor: Colors.blue, //Optional
                                        // unselectedTextColor: Colors.white, //Optional
                                        unselectedTextColor: Colors.grey[900], //Optional
                                        // selectedTextColor: Colors.amber, //Optional
                                        unselectedSubtitleColor: Colors.grey[500],
                                        unselectedDatetimeColor: Colors.grey[700],
                                        selectedTextColor: Colors.blue,
                                        tapCallback: (index) {
                                          setState(() {
                                            resultText = "selected account is : ${proposals[index].title}";
                                            selectedId = index;
                                          });
                                          // print(resultText);
                                          print(reservationProposalDatetimeList[selectedId].id);
                                          print(reservationProposalDatetimeList[selectedId].reservationProposal?.id);
                                          Navigator.pop(context);
                                          _showConfirmProposalDialog(
                                              "Confermare l'invio di ${'${DateFormat.yMMMMd('it_IT').format(reservationProposalDatetimeList[selectedId].datetime!)} alle ${reservationProposalDatetimeList[selectedId].datetime.toString().substring(11, 16)}'} come proposta selezionata",
                                              context
                                          );
                                        },
                                        //Optional
                                        addAccountTapCallback: () {
                                          setState(() {
                                            resultText = "Add account clicked";
                                          });
                                          // print(resultText);

                                        },
                                      );
                                    }

                                  },
                                  child: Text(
                                    // widget.reservation?.proposal?.user_type_id == 1 ? 'Proposte in Attesa di Convalida' : 'Proposte da Convalidare',
                                    reservationProposalDatetimeList.isNotEmpty && reservationProposalDatetimeList[0].reservationProposal?.user_type_id == 1 ? 'Proposte in Attesa di Convalida' : 'Proposte da Convalidare',
                                    style: TextStyle(
                                      // color: Colors.blue[500],
                                      // color: Colors.red[500],
                                      // color: Colors.orange[100],
                                      color: Colors.orange[600],
                                      // color: Colors.green[600],
                                      // color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  )
                              ),
                            ),
                          );
                        }
                        else {
                          return Container();
                        }
                      }
                    ),
                  ],
                ),

                // Container(
                //   color: Color(0xFFF6F7F9),
                //   child: Padding(
                //     padding: const EdgeInsets.only(left: 10, top: 10),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.start,
                //       children: [
                //         ClipRRect(
                //           borderRadius: BorderRadius.all(Radius.circular(10)),
                //           child: Container(
                //             color: Colors.transparent,
                //             // color: Colors.grey[300],
                //
                //             child: IconButton(
                //               onPressed: (){
                //                 Navigator.pop(context);
                //               },
                //               padding: EdgeInsets.all(0),
                //
                //               icon: Icon(
                //                 // Icons.arrow_back,
                //                 // Icons.clear,
                //                 Icons.arrow_back_ios_outlined,
                //                 size: 24,
                //                 // color: CupertinoColors.black,
                //                 color: Colors.grey[600],
                //               ),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
                Container(
                  padding: EdgeInsets.fromLTRB(40, 10, 40, 0),
                  // color: Color(0xFFF6F7F9),
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();
                      return true;
                    },
                    child: ListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            // SizedBox(
                            //   height: 0,
                            // ),

                            /*Container(
                              margin: EdgeInsets.only(top: 20),
                              height: 170,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[100],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                image: DecorationImage(
                                  image: widget.booking!.prestazione!.image != null && widget.booking!.prestazione!.image != '' ? CachedNetworkImageProvider(
                                    widget.booking!.prestazione!.image!,
                                    errorListener: () => const SizedBox(),
                                  ) : CachedNetworkImageProvider(
                                      businessProvider.business!.profile_image!,
                                    errorListener: () => const SizedBox(),
                                  ),
                                  fit: BoxFit.cover
                                ),
                              ),
                            ),*/
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              height: 170,
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: FutureImage(
                                  widget.reservation!.business!.profile_image!,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                            ),

                            ClipPath(
                              clipper: TicketTopClipper(),
                              child: Container(
                                width: double.infinity,
                                color: Colors.white,
                                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // GradientText(
                                    //   businessProvider.business!.name != null ? businessProvider.business!.name! : '',
                                    //   // 'A partire da € 60,00',
                                    //   maxLines: 1,
                                    //   // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                                    //   // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                                    //   gradient: LinearGradient(
                                    //     begin: Alignment.bottomLeft,
                                    //     end: Alignment.topRight,
                                    //     colors: [
                                    //       Color(0xff8921aa),
                                    //       Color(0xffDA44bb),
                                    //       // Color(0xffDA44bb)
                                    //     ]
                                    //   ),
                                    //   // gradient: LinearGradient(
                                    //   //     begin: Alignment.bottomLeft,
                                    //   //     end: Alignment.topRight,
                                    //   //     colors: [
                                    //   //       Colors.blue[500],
                                    //   //       Color(0xffDA44bb),
                                    //   //
                                    //   //       Color(0xff8921aa),
                                    //   //     ]
                                    //   // ),
                                    //   style: TextStyle(
                                    //       color: Colors.blue[500],
                                    //       fontWeight: FontWeight.w800,
                                    //       fontSize: 12
                                    //   ),
                                    //   textAlign: TextAlign.left,
                                    // ),
                                    SizedBox(height: 10,),
                                    Marquee(
                                      child: Text(
                                        businessProvider.business!.name != null ? businessProvider.business!.name! : '',
                                        // widget.appointment.business.name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 20,
                                          // color: Colors.grey[600]
                                          color: Colors.blue[500]
                                        ),
                                      ),
                                    ),
                                    // SizedBox(height: 4,),
                                    // Text(
                                    //   // widget.appointment.prestazione.title,
                                    //   '@' + widget.appointment.user.username,
                                    //   style: TextStyle(
                                    //       fontWeight: FontWeight.w800,
                                    //       fontSize: 14,
                                    //       color: Colors.grey[700]
                                    //   ),
                                    // ),
                                    // SizedBox(height: 6,),
                                    // Text(
                                    //   widget.appointment.business.address ?? ' ',
                                    //   style: TextStyle(
                                    //       fontWeight: FontWeight.w800,
                                    //       fontSize: 11,
                                    //       color: Colors.grey[500]
                                    //   ),
                                    // ),
                                    SizedBox(height: 30,),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.reservation!.datetime != null ? DateFormat.yMMMMEEEEd('it_IT').format(widget.reservation!.datetime!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/).toUpperCase() : '',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 17,
                                              color: Colors.grey[900]
                                          ),
                                        ),
                                        SizedBox(height: 4,),
                                        widget.reservation!.datetime != null ? Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              color: Colors.grey[700],
                                              size: 18,
                                            ),
                                            SizedBox(width: 3,),
                                            Text(
                                              widget.reservation!.datetime != null ? widget.reservation!.datetime!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16) : '',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 15,
                                                  color: Colors.grey[700]
                                              ),
                                            ),
                                          ],
                                        ) : SizedBox(),
                                      ],
                                    ),

                                    SizedBox(
                                      height: 30,
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 20.0),
                                          child: Text(
                                            'ID:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: Colors.grey[500]
                                            ),
                                          ),
                                        ),
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.5,
                                          child: Marquee(
                                            child: Row(
                                              children: [
                                                Text(
                                                  widget.reservation!.id ?? '',
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 14,
                                                      color: Colors.grey[800]
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),

                                    //TODO: INSERIRE ANCHE LE INFORMAZIONI SUL PAGAMENTO: TIPO IL METODO E QUANDO è STATO EFFETTUATO
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Text(
                                    //       'Utente:',
                                    //       style: TextStyle(
                                    //           fontWeight: FontWeight.w700,
                                    //           fontSize: 12,
                                    //           color: Colors.grey[500]
                                    //       ),
                                    //     ),
                                    //     Text(
                                    //       widget.booking!.user!.username != null
                                    //         ? '@' + widget.booking!.user!.username!
                                    //         : '-',
                                    //       style: TextStyle(
                                    //           fontWeight: FontWeight.w800,
                                    //           fontSize: 14,
                                    //           color: Colors.grey[600]
                                    //           // color: Colors.blue[500]
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    // SizedBox(
                                    //   height: 10,
                                    // ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Nome:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.grey[500]
                                          ),
                                        ),
                                        InkWell(
                                          onTap: (){
                                            // Navigator.push(
                                            //   context,
                                            //   PageTransition(
                                            //       duration: const Duration(milliseconds: 500),
                                            //       alignment: Alignment.center,
                                            //       type: PageTransitionType.fade,
                                            //       child: UserProfileScreen(
                                            //         userId: widget.reservation!.user.id!,
                                            //         // isTab: false,
                                            //       )
                                            //   ),
                                            // );
                                          },
                                          child: Text(
                                            widget.reservation!.name != null && widget.reservation!.validated_at != null ? widget.reservation!.name! : widget.reservation!.validated_at == null ? '********' : '-',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                                // color: Colors.grey[800]
                                                color: Colors.blue[500]
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),

                                    // widget.reservation!.guestPhone != null ? Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Text(
                                    //       'Telefono:',
                                    //       style: TextStyle(
                                    //           fontWeight: FontWeight.w700,
                                    //           fontSize: 12,
                                    //           color: Colors.grey[500]
                                    //       ),
                                    //     ),
                                    //     Text(
                                    //       widget.reservation!.guestPhone!,
                                    //       style: TextStyle(
                                    //           fontWeight: FontWeight.w800,
                                    //           fontSize: 14,
                                    //           color: Colors.grey[800]
                                    //         // color: Colors.blue[500]
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ) : SizedBox(),
                                    // widget.reservation!.guestPhone != null ? SizedBox(
                                    //   height: 10,
                                    // ) : SizedBox(),
                                    //
                                    // widget.reservation!.guestEmail != null ? Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Text(
                                    //       'Email:',
                                    //       style: TextStyle(
                                    //           fontWeight: FontWeight.w700,
                                    //           fontSize: 12,
                                    //           color: Colors.grey[500]
                                    //       ),
                                    //     ),
                                    //     Text(
                                    //       widget.reservation!.guestEmail!,
                                    //       style: TextStyle(
                                    //           fontWeight: FontWeight.w800,
                                    //           fontSize: 14,
                                    //           color: Colors.grey[800]
                                    //         // color: Colors.blue[500]
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ) : SizedBox(),
                                    // widget.reservation!.guestEmail != null ? SizedBox(
                                    //   height: 10,
                                    // ) : SizedBox(),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Coperti:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.grey[500]
                                          ),
                                        ),
                                        Text(
                                            widget.reservation!.quantity.toString(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                              // color: Colors.grey[800]
                                              color: Colors.green[500]
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Link:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.grey[500]
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async => {
                                            await launchUrl(
                                              Uri.parse("https://www.nurebo.com/${widget.reservation!.business_url}"),
                                              mode: LaunchMode.externalApplication
                                            )
                                          },
                                          style: ButtonStyle(
                                            // padding: WidgetStateProperty.all(EdgeInsets.zero),
                                            padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 15)),
                                            minimumSize: WidgetStateProperty.all(Size.zero),
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            visualDensity: VisualDensity.compact,
                                            overlayColor: WidgetStateProperty.all(Colors.transparent),
                                            splashFactory: NoSplash.splashFactory,
                                          ),
                                          child: Text(
                                            "https://www.nurebo.com/${widget.reservation!.business_url}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                                // color: Colors.grey[800]
                                                color: Colors.grey[600]
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Text(
                                    //       'Durata:',
                                    //       style: TextStyle(
                                    //           fontWeight: FontWeight.w700,
                                    //           fontSize: 12,
                                    //           color: Colors.grey[500]
                                    //       ),
                                    //     ),
                                    //     // Text(
                                    //     //   widget.reservation!.prestazione!.duration.toString()
                                    //     //   + ' minuti',
                                    //     //   style: TextStyle(
                                    //     //       fontWeight: FontWeight.w800,
                                    //     //       fontSize: 14,
                                    //     //       color: Colors.grey[800]
                                    //     //       // color: Colors.blue[500]
                                    //     //   ),
                                    //     // ),
                                    //   ],
                                    // ),
                                    // SizedBox(
                                    //   height: 10,
                                    // ),
                                    // widget.reservation!.is_guest == 1 ? Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Padding(
                                    //       padding: const EdgeInsets.only(right: 20),
                                    //       child: Text(
                                    //         'Creato il:',
                                    //         style: TextStyle(
                                    //             fontWeight: FontWeight.w700,
                                    //             fontSize: 12,
                                    //             color: Colors.grey[500]
                                    //         ),
                                    //       ),
                                    //     ),
                                    //     Container(
                                    //       width: MediaQuery.of(context).size.width * 0.4,
                                    //       child: Marquee(
                                    //         child: Text(
                                    //           DateFormat.yMMMMd('it_IT').format(widget.reservation!.created_at!/*.toLocal()*//*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/)
                                    //           + ' alle ' + widget.reservation!.created_at!/*.toLocal()*//*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                                    //           style: TextStyle(
                                    //               fontWeight: FontWeight.w800,
                                    //               fontSize: 14,
                                    //               color: Colors.grey[800]
                                    //           ),
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ) : Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     Padding(
                                    //       padding: const EdgeInsets.only(right: 20),
                                    //       child: Text(
                                    //         'Acquistato il:',
                                    //         style: TextStyle(
                                    //             fontWeight: FontWeight.w700,
                                    //             fontSize: 12,
                                    //             color: Colors.grey[500]
                                    //         ),
                                    //       ),
                                    //     ),
                                    //     Text(
                                    //       DateFormat.yMMMMd('it_IT').format(widget.reservation!.created_at!/*.toLocal()*/.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))
                                    //       + ' alle ' + widget.reservation!.created_at!/*.toLocal()*/.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                    //       style: TextStyle(
                                    //           fontWeight: FontWeight.w800,
                                    //           fontSize: 14,
                                    //           color: Colors.grey[800]
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                    // SizedBox(
                                    //   height: 10,
                                    // ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 20.0),
                                          child: Text(
                                            'Effettuato il:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: Colors.grey[500]
                                            ),
                                          ),
                                        ),
                                        Text(
                                          DateFormat.yMMMMd('it_IT').format(widget.reservation!.created_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/)
                                              + ' alle ' + widget.reservation!.created_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: Colors.grey[800]
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(
                                      height: 10,
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 20.0),
                                          child: Text(
                                            'Convalidato il:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: Colors.grey[500]
                                            ),
                                          ),
                                        ),
                                        Text(
                                          widget.reservation!.validated_at != null ? DateFormat.yMMMMd('it_IT').format(widget.reservation!.validated_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/) + ' alle ' + widget.reservation!.validated_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16) : '-',
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: Colors.grey[800]
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(
                                      height: 10,
                                    ),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 20.0),
                                          child: Text(
                                            'Annullato il:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12,
                                                color: Colors.grey[500]
                                            ),
                                          ),
                                        ),
                                        Text(
                                          widget.reservation!.is_canceled_at != null ? DateFormat.yMMMMd('it_IT').format(widget.reservation!.is_canceled_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/) + ' alle ' + widget.reservation!.is_canceled_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16) : '-',
                                          maxLines: 1,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 14,
                                              color: Colors.grey[800]
                                          ),
                                        ),
                                      ],
                                    ),

                                    // SizedBox(
                                    //   height: 30,
                                    // ),

                                    SizedBox(
                                      height: 30,
                                    ),
                                    generateDashedDivider(
                                        MediaQuery.of(context).size.width * 0.68
                                    )
                                    // Image.network(
                                    //     widget.singleEventTicket.qr_code
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                            ClipPath(
                              clipper: TicketBottomClipper(),
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30,),
                // widget.reservation!.isCanceled == 1 ? Center(
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 40.0),
                //     child: Text(
                //       'Questa prenotazione è stata cancellata',
                //       textAlign: TextAlign.center,
                //       style: TextStyle(
                //         // color: Colors.blue[500],
                //         color: Colors.red[500],
                //         // color: Colors.white,
                //         fontWeight: FontWeight.w800,
                //         fontSize: 20,
                //       ),
                //     ),
                //   ),
                // ) : DateTime.now().isBefore(widget.reservation!.begin_at!) ?

                // Column(
                //   children: [
                //     Container(
                //       // height: MediaQuery.of(context).size.width * 0.1,
                //       // width: MediaQuery.of(context).size.width * 0.4,
                //       margin: EdgeInsets.only(
                //           left: MediaQuery.of(context).size.width * 0.2,
                //           right: MediaQuery.of(context).size.width * 0.2,
                //           top: 5,
                //           bottom: 5
                //       ),
                //       child: ElevatedButton(
                //           style: OutlinedButton.styleFrom(
                //               padding: EdgeInsets.zero,
                //               backgroundColor: Colors.blue[500],
                //               // backgroundColor: Colors.white,
                //               minimumSize: Size(
                //                   MediaQuery.of(context).size.width * .5,
                //                   MediaQuery.of(context).size.width * .1
                //               ),
                //               alignment: Alignment.center
                //           ),
                //           onPressed: (){
                //
                //           },
                //           child: Text(
                //             'Modifica',
                //             style: TextStyle(
                //               // color: Colors.blue[500],
                //               // color: Colors.red[500],
                //               color: Colors.white,
                //               fontWeight: FontWeight.w800,
                //               fontSize: 13,
                //             ),
                //           )
                //       ),
                //     ),
                //     Container(
                //       // height: MediaQuery.of(context).size.width * 0.1,
                //       // width: MediaQuery.of(context).size.width * 0.4,
                //       margin: EdgeInsets.only(
                //           left: MediaQuery.of(context).size.width * 0.2,
                //           right: MediaQuery.of(context).size.width * 0.2,
                //           top: 5,
                //           bottom: 5
                //       ),
                //       child: ElevatedButton(
                //           style: OutlinedButton.styleFrom(
                //               padding: EdgeInsets.zero,
                //               backgroundColor: Colors.red[500],
                //               // backgroundColor: Colors.white,
                //               minimumSize: Size(
                //                 MediaQuery.of(context).size.width * .5,
                //                 MediaQuery.of(context).size.width * .1
                //               ),
                //               alignment: Alignment.center
                //           ),
                //           onPressed: (){
                //             _showDeletingDialog(
                //               // "Premere su 'Cancella' se si vuole cancellare definitivamente l'appuntamento e rimborsare il cliente"
                //               "Premere su 'Cancella' se si vuole cancellare definitivamente l'appuntamento",
                //               context
                //             );
                //           },
                //           child: Text(
                //             'Cancella',
                //             style: TextStyle(
                //               // color: Colors.blue[500],
                //               // color: Colors.red[500],
                //               color: Colors.white,
                //               fontWeight: FontWeight.w800,
                //               fontSize: 13,
                //             ),
                //           )
                //       ),
                //     ),
                //   ],
                // )


                // if(widget.reservation!.is_canceled == true){
                //
                // }
                Visibility(
                  visible: (widget.reservation!.datetime == null || widget.reservation!.datetime!.isAfter(DateTime.now().add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))) && widget.reservation!.is_canceled == false,
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceAround,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.width * 0.18,
                        width: MediaQuery.of(context).size.width * 0.18,
                        // margin: EdgeInsets.only(
                        //     left: MediaQuery.of(context).size.width * 0.2,
                        //     right: MediaQuery.of(context).size.width * 0.2,
                        //     top: 5,
                        //     bottom: 5
                        // ),
                        child: ElevatedButton(
                            style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                // backgroundColor: Colors.blue[500],
                                backgroundColor: Colors.grey[500],
                                // backgroundColor: Colors.white,
                                minimumSize: Size(
                                    MediaQuery.of(context).size.width * .5,
                                    MediaQuery.of(context).size.width * .1
                                ),
                                alignment: Alignment.center
                            ),
                            onPressed: () async {
                              final result = await showDialog(
                                context: context,
                                builder: (context) => const BookingDialog(),
                              );

                              if (result != null /*&& result['prenotazioni'] != null*/) {
                                // final prenotazioni = result['prenotazioni'] as Map<DateTime, List<TimeOfDay>>;
                                print('🎯 Prenotazione confermata:');
                                print(result);
                                // print(prenotazioni);
                                // prenotazioni.forEach((date, times) {
                                //   for (final time in times) {
                                //     // print('📅 ${DateFormat('dd/MM/yyyy').format(date)} - ⏰ ${time.format(context)}');
                                //     // print(date);
                                //     print(time);
                                //   }
                                // });
                                socketProvider.sendReservationProposal(
                                  widget.reservation!,
                                  result
                                );

                                await Future.wait([
                                  // a = loadData(),
                                  getBusinessReservationProposals()
                                ]);

                                setState(() {
                                });
                              }
                            },
                            // child: Text(
                            //   'Modifica',
                            //   style: TextStyle(
                            //     // color: Colors.blue[500],
                            //     // color: Colors.red[500],
                            //     color: Colors.white,
                            //     fontWeight: FontWeight.w800,
                            //     fontSize: 13,
                            //   ),
                            // )
                          child: Icon(
                            Icons.edit_calendar_outlined,
                            size: 25,
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.2),
                      Container(
                        height: MediaQuery.of(context).size.width * 0.18,
                        width: MediaQuery.of(context).size.width * 0.18,
                        // margin: EdgeInsets.only(
                        //     left: MediaQuery.of(context).size.width * 0.2,
                        //     right: MediaQuery.of(context).size.width * 0.2,
                        //     top: 5,
                        //     bottom: 5
                        // ),
                        child: ElevatedButton(
                            style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                // backgroundColor: Colors.red[600],
                                backgroundColor: Colors.grey[500],
                                // backgroundColor: Colors.white,
                                minimumSize: Size(
                                  MediaQuery.of(context).size.width * .5,
                                  MediaQuery.of(context).size.width * .1
                                ),
                                alignment: Alignment.center
                            ),
                            onPressed: (){
                              _showDeletingDialog(
                                // "Premere su 'Cancella' se si vuole cancellare definitivamente l'appuntamento e rimborsare il cliente"
                                "Sei sicuro di voler annullare definitivamente la prenotazione",
                                context
                              );
                            },
                            // child: Text(
                            //   'Cancella',
                            //   style: TextStyle(
                            //     // color: Colors.blue[500],
                            //     // color: Colors.red[500],
                            //     color: Colors.white,
                            //     fontWeight: FontWeight.w800,
                            //     fontSize: 13,
                            //   ),
                            // )
                          child: Icon(
                            Icons.delete_outline,
                            size: 25,
                          ),
                        ),
                      ),
                      // Container(
                      //   height: MediaQuery.of(context).size.width * 0.18,
                      //   width: MediaQuery.of(context).size.width * 0.18,
                      //   // margin: EdgeInsets.only(
                      //   //     left: MediaQuery.of(context).size.width * 0.2,
                      //   //     right: MediaQuery.of(context).size.width * 0.2,
                      //   //     top: 5,
                      //   //     bottom: 5
                      //   // ),
                      //   child: ElevatedButton(
                      //       style: OutlinedButton.styleFrom(
                      //           padding: EdgeInsets.zero,
                      //           backgroundColor: Colors.green[600],
                      //           // backgroundColor: Colors.white,
                      //           minimumSize: Size(
                      //             MediaQuery.of(context).size.width * .5,
                      //             MediaQuery.of(context).size.width * .1
                      //           ),
                      //           alignment: Alignment.center
                      //       ),
                      //       onPressed: (){
                      //         _showDeletingDialog(
                      //           // "Premere su 'Cancella' se si vuole cancellare definitivamente l'appuntamento e rimborsare il cliente"
                      //           "Premere su 'Cancella' se si vuole cancellare definitivamente l'appuntamento",
                      //           context
                      //         );
                      //       },
                      //       // child: Text(
                      //       //   'Cancella',
                      //       //   style: TextStyle(
                      //       //     // color: Colors.blue[500],
                      //       //     // color: Colors.red[500],
                      //       //     color: Colors.white,
                      //       //     fontWeight: FontWeight.w800,
                      //       //     fontSize: 13,
                      //       //   ),
                      //       // )
                      //     child: Icon(
                      //       Icons.upload_outlined,
                      //       size: 25,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                )
                  // : DateTime.now().isAfter(widget.reservation!.begin_at!) ? Center(
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 40.0),
                //     child: Text(
                //       'Questa prenotazione è già stata effettuata',
                //       textAlign: TextAlign.center,
                //       style: TextStyle(
                //         color: Colors.blue[500],
                //         // color: Colors.red[500],
                //         // color: Colors.white,
                //         fontWeight: FontWeight.w800,
                //         fontSize: 20,
                //       ),
                //     ),
                //   ),
                // ) : SizedBox(),
                // SizedBox(height: 50,),
              ],
            ),
        ),
      )
    );
  }
}

class TicketTopClipper extends CustomClipper<Path> {
  double radius = 15;

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - radius);
    path.quadraticBezierTo(radius, size.height - radius, radius, size.height);
    path.lineTo(size.width - radius, size.height);
    path.quadraticBezierTo(size.width - radius, size.height - radius,
        size.width, size.height - radius);
    path.lineTo(size.width, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Widget generateDashedDivider(double width) {
  int n = width ~/ 5;
  return Marquee(
    child: Row(
      children: List.generate(
          n,
              (index) => (index % 2 == 0)
              ? Container(
            height: 2,
            width: width / n,
            color: Color(0xFFE4E4E4),
          )
              : SizedBox(
            width: width / n,
          )),
    ),
  );
}

class TicketBottomClipper extends CustomClipper<Path> {
  double radius = 15;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, radius);
    path.quadraticBezierTo(size.width - radius, radius, size.width - radius, 0);
    path.lineTo(radius, 0);
    path.quadraticBezierTo(radius, radius, 0, radius);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
