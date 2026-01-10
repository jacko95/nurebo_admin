import 'dart:convert';
import 'dart:io';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/screens/booking_detail_screen.dart';
import 'package:nurebo_admin/screens/notifications_screen.dart';
import 'package:nurebo_admin/screens/prestazione_slots_screen.dart';
//import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/business_campaign.dart';
import 'package:nurebo_admin/models/business_campaign_type.dart';
import 'package:nurebo_admin/models/category.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/campaign_provider.dart';
import 'package:nurebo_admin/provider/prestazione_provider.dart';
import 'package:nurebo_admin/screens/booking_screen.dart';
import 'package:nurebo_admin/screens/campaign_selection_screen.dart';
import 'package:nurebo_admin/screens/campaign_user_list_screen.dart';
import 'package:nurebo_admin/screens/prestazione_detail_screen.dart';
import 'package:nurebo_admin/screens/prestazione_list_screen.dart';
import 'package:nurebo_admin/screens/user_profile_screen.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:nurebo_admin/widgets/future_svg.dart';
import 'package:nurebo_admin/widgets/signed_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart' as gw;

import '../models/booking.dart';
import '../utils/business_preferences.dart';



class StatisticsListScreen extends StatefulWidget {

  const StatisticsListScreen({super.key,});

  @override
  _StatisticsListScreenState createState() => _StatisticsListScreenState();
}

class _StatisticsListScreenState extends State<StatisticsListScreen> {
  // final formatter =  NumberFormat.decimalPattern().format(1234); // formatted number will be: 1,234
  late BusinessProvider businessProvider;
  late SocketProvider socketProvider;
  Future a = Future((){}), b = Future((){}), hu = Future(() {});
  List? prestazioneRankingList = [];
  List? usersRankingList = [];



  Future getUsersRanking() async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking/user_ranking?business_id=${businessProvider.business.id}");

    // final queryParameters = {
    //   'param1': 'one',
    //   'param2': 'two',
    // };

    // final uri = Uri.http('www.myurl.com', '/api/v1/test/${widget.pk}', queryParameters);
    // final url = Uri.http(Utils.httpServerUrl/* + "booking/user_ranking"*/, '/booking/user_ranking', queryParameters);
    // final url = Uri.parse(Utils.httpServerUrl + "booking/user_ranking").replace(query: 'param1=one');

    // final url = Uri.parse(Utils.httpServerUrl + "booking/user_ranking").replace(queryParameters: {
    //   'business_id': businessProvider.business!.id,
    // });
    final url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/order/user/grouped-by-order").replace(queryParameters: {
      'business_id': businessProvider.business!.id,
    });

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
          HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
        }
    );

    // print('user_ranking');
    // print(response.statusCode);

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print("booking/user_ranking");
      // print(jsonData);

      usersRankingList = jsonData;

      return jsonData;
    }
  }

  Future getPrestazioneRanking() async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking/user_ranking?business_id=${businessProvider.business.id}");

    // final queryParameters = {
    //   'param1': 'one',
    //   'param2': 'two',
    // };

    // final uri = Uri.http('www.myurl.com', '/api/v1/test/${widget.pk}', queryParameters);
    // final url = Uri.http(Utils.httpServerUrl/* + "booking/user_ranking"*/, '/booking/user_ranking', queryParameters);
    // final url = Uri.parse(Utils.httpServerUrl + "booking/user_ranking").replace(query: 'param1=one');

    // final url = Uri.parse(Utils.httpServerUrl + "booking/prestazione_ranking").replace(queryParameters: {
    //   'business_id': businessProvider.business!.id,
    // });
    final url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/order/user/grouped-by-prestazione").replace(queryParameters: {
      'business_id': businessProvider.business!.id,
    });

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
          HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
        }
    );

    // print('user_ranking');
    // print(response.statusCode);

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print("booking/prestazione_ranking");
      // print(jsonData);

      prestazioneRankingList = jsonData;

      return jsonData;
    }
  }

  @override
  void initState() {
    super.initState();
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);


    initializeDateFormatting();
    timeAgo.setLocale('it', timeAgo.Italian());

    Future.wait([
      a = getUsersRanking(),
      b = getPrestazioneRanking(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    double chartBarWidth = MediaQuery.of(context).size.width * 0.0565;


    return Scaffold(
      backgroundColor: Color.fromRGBO(247, 251, 254, 1),

      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: Container(
      //   margin: EdgeInsets.only(bottom: 10),
      //   width: MediaQuery.of(context).size.width * 0.9,
      //   height: 50,
      //   child: ElevatedButton(
      //     style: ButtonStyle(
      //         backgroundColor: MaterialStateProperty.all(Colors.blue[500])
      //     ),
      //     child: Text(
      //       // "Aggiungi",
      //       "Nuova campagna",
      //       // 'Continua',
      //       style: TextStyle(
      //           fontSize: 16,
      //           fontWeight: FontWeight.w700
      //       ),
      //     ),
      //     onPressed: () async {
      //       Navigator.push(
      //           context,
      //           PageTransition(
      //             duration: const Duration(milliseconds: 500),
      //             alignment: Alignment.center,
      //             type: PageTransitionType.fade,
      //             // child: NotificationScreen(),
      //             child: CampaignSelectionScreen()
      //           )
      //       );
      //     },
      //   ),
      // ),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.blue[500], //change your color here
        ),
        leading: IconButton(
          icon: Icon(
            // Icons.arrow_back,
            Icons.arrow_back_ios_new,
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
        // backgroundColor: Color.fromRGBO(247, 251, 254, 1),
        backgroundColor: Colors.white,
        // centerTitle: true,
        title: Text(
          // 'Prestazioni',
          // 'Listino Prezzi',
          'Statistiche',
          style: TextStyle(
              color: Colors.blue[500],
              // color: Colors.grey[500],
              fontWeight: FontWeight.w600,
              fontSize: 16
          ),
        ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.all(10.0),
          //   child: OutlinedButton(
          //     style: ButtonStyle(
          //       backgroundColor: MaterialStateProperty.all(Colors.white),
          //     ),
          //     onPressed: () {
          //       // ticketCategoryProvider.deleteAll();
          //       Navigator.push(
          //         context,
          //         PageTransition(
          //           duration: const Duration(milliseconds: 500),
          //           alignment: Alignment.center,
          //           type: PageTransitionType.fade,
          //           // child: NotificationScreen(),
          //           child: PrestazioneDetailScreen(
          //             prestazione: Prestazione(
          //               title: '',
          //               description: '',
          //             ),
          //             // eventBusiness: widget.bookingBusiness,
          //             isNewPrestazione: true,
          //           ),
          //         )
          //       );
          //     },
          //     child: Text(
          //       'Aggiungi',
          //       style: TextStyle(
          //         color: Colors.blue
          //       ),
          //     )
          //     // child: Icon(
          //     //   Icons.add,
          //     //   color: Colors.blue,
          //     // ),
          //   ),
          // )
        ],
      ),
      body: SafeArea(
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),

            child: Column(
              children: [
                Visibility(
                  visible: businessProvider.business?.type_id == 1,
                  child: Container(
                    height: 400,
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: MediaQuery.of(context).size.width * 0.03
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Prenotazioni ricevute nell'ultimo periodo",
                          // "Prenotazioni effettuate nell'ultimo periodo",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 40,),
                        FutureBuilder(
                          // future: Future.wait([e, f, b]),
                            future: hu,
                            // future: Future.wait([callFutureMethods1()]),
                            builder: (context, snapshot) {
                              if(snapshot.connectionState == ConnectionState.done /*&& snapshot.hasData*/
                                  && socketProvider.bookingFrequencyList.isNotEmpty){
                                return Expanded(
                                  child: BarChart(
                                    BarChartData(
                                        borderData: FlBorderData(
                                            border: Border.all(width: 0),
                                            show: false
                                        ),
                                        groupsSpace: 15,
                                        // minfromY: 0,
                                        // maxfromY: 10,
                                        barTouchData: BarTouchData(
                                          // touchCallback: (flTouchEvent, barTouchResponse){
                                          //   print('ciao');
                                          // },
                                          // enabled: true
                                        ),
                                        titlesData: FlTitlesData(
                                          show: true,
                                          rightTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                                showTitles: false
                                            ),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                                showTitles: false
                                            ),
                                          ),
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              reservedSize: 30,
                                              interval: 15,
                                              getTitlesWidget: (double value, TitleMeta meta) {
                                                TextStyle style = const TextStyle(
                                                  color: Colors.black26,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 9.5,
                                                );

                                                double margin = MediaQuery.of(context).size.width * 0.015;

                                                Widget textWidget(String text) => Padding(
                                                  padding: EdgeInsets.only(/*bottom: margin,*/ top: 8),
                                                  child: Text(
                                                    text,
                                                    textAlign: TextAlign.center,
                                                    style: style,
                                                  ),
                                                );

                                                String formattedDate(int daysAgo) {
                                                  DateTime date = DateTime.now().subtract(Duration(days: daysAgo));
                                                  String day = date.day.toString();
                                                  String? month = DateFormat.MMMM('it_IT').format(date).substring(0, 3).capitalizeFirst;
                                                  return '$day\n$month';
                                                }

                                                switch (value.toInt()) {
                                                  case 1:
                                                    return textWidget(formattedDate(12));
                                                  case 3:
                                                    return textWidget(formattedDate(10));
                                                  case 5:
                                                    return textWidget(formattedDate(8));
                                                  case 7:
                                                    return textWidget(formattedDate(6));
                                                  case 9:
                                                    return textWidget(formattedDate(4));
                                                  case 11:
                                                    return textWidget(formattedDate(2));
                                                  case 13:
                                                    return textWidget(formattedDate(0));
                                                  default:
                                                    return textWidget('');
                                                }
                                              },
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                              sideTitles: SideTitles(
                                                showTitles: true,
                                                interval: 4.toDouble(),
                                                // getTextStyles: (value, h) => const TextStyle(
                                                //   color: Colors.black26,
                                                //   fontWeight: FontWeight.bold,
                                                //   fontSize: 11,
                                                // ),
                                                // // margin: 16,
                                                // margin: MediaQuery.of(context).size.width * 0.015,
                                                getTitlesWidget: (double value, TitleMeta meta) {
                                                  TextStyle style = const TextStyle(
                                                    color: Colors.black26,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 11,
                                                  );

                                                  double margin = MediaQuery.of(context).size.width * 0.015;

                                                  Widget textWidget(String text) => Padding(
                                                    padding: EdgeInsets.only(bottom: margin),
                                                    child: Text(
                                                      text,
                                                      style: style,
                                                    ),
                                                  );

                                                  // switch (value.toInt()) {
                                                  //   case 4:
                                                  //     return textWidget('4');
                                                  //   case 8:
                                                  //     return textWidget('8');
                                                  //   case 12:
                                                  //     return textWidget('12');
                                                  //   case 16:
                                                  //     return textWidget('16');
                                                  //   case 20:
                                                  //     return textWidget('20');
                                                  //   default:
                                                  //     return textWidget('');
                                                  // }
                                                  if(value > 0){
                                                    return textWidget(value.toInt().toString());
                                                  }
                                                  else {
                                                    return textWidget('');
                                                  }
                                                },
                                              )
                                          ),
                                        ),
                                        gridData: FlGridData(
                                          show: true,
                                          drawHorizontalLine: false,
                                          // getDrawingHorizontalLine: (value) {
                                          //   return FlLine(
                                          //     color: Colors.grey[400],
                                          //     strokeWidth: .5,
                                          //   );
                                          // },
                                          drawVerticalLine: false,
                                          getDrawingVerticalLine: (value) {
                                            return FlLine(
                                              color: Colors.grey[400],
                                              strokeWidth: 1,
                                            );
                                          },
                                        ),
                                        barGroups: [
                                          BarChartGroupData(
                                              x: 1,
                                              barRods: [
                                                BarChartRodData(
                                                    fromY: 0,
                                                    toY: /*bookingFrequencyList.length > 0 ? */socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-1].toDouble()
                                                    /*: bookingFrequencyList[bookingFrequencyList.length].toDouble()*/,
                                                    // fromY: bookingFrequencyList[8].toDouble(),
                                                    width: chartBarWidth,
                                                    color: const Color.fromRGBO(17, 159, 250, 1),
                                                    borderRadius: BorderRadius.circular(5)
                                                )
                                              ]
                                          ),
                                          BarChartGroupData(
                                              x: 2,
                                              barRods: [
                                                BarChartRodData(
                                                  fromY: 0,
                                                  toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-2].toDouble(),
                                                  // fromY: bookingFrequencyList[8].toDouble(),
                                                  width: chartBarWidth,
                                                  color: Color.fromRGBO(17, 159, 250, 1),
                                                  borderRadius: BorderRadius.circular(5),
                                                )
                                              ]
                                          ),
                                          BarChartGroupData(
                                              x: 3,
                                              barRods: [
                                                BarChartRodData(
                                                  // fromY: 12,
                                                    toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-3].toDouble(),
                                                    fromY: 0,
                                                    // fromY: bookingFrequencyList[8].toDouble(),
                                                    width: chartBarWidth,
                                                    color: Color.fromRGBO(17, 159, 250, 1),
                                                    borderRadius: BorderRadius.circular(5)
                                                )
                                              ]
                                          ),
                                          BarChartGroupData(
                                              x: 4,
                                              barRods: [
                                                BarChartRodData(
                                                    fromY: 0,
                                                    toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-4].toDouble(),
                                                    // fromY: bookingFrequencyList[8].toDouble(),
                                                    width: chartBarWidth,
                                                    color: Color.fromRGBO(17, 159, 250, 1),
                                                    borderRadius: BorderRadius.circular(5)
                                                )
                                              ]
                                          ),
                                          BarChartGroupData(
                                              x: 5,
                                              barRods: [
                                                BarChartRodData(
                                                    fromY: 0,
                                                    toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-5].toDouble(),
                                                    // fromY: bookingFrequencyList[8].toDouble(),
                                                    width: chartBarWidth,
                                                    color: Color.fromRGBO(17, 159, 250, 1),
                                                    borderRadius: BorderRadius.circular(5)
                                                )
                                              ]
                                          ),
                                          BarChartGroupData(
                                              x: 6,
                                              barRods: [
                                                BarChartRodData(
                                                    fromY: 0,
                                                    toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-6].toDouble(),
                                                    // fromY: bookingFrequencyList[8].toDouble(),
                                                    width: chartBarWidth,
                                                    color: Color.fromRGBO(17, 159, 250, 1),
                                                    borderRadius: BorderRadius.circular(5)
                                                )
                                              ]
                                          ),
                                          BarChartGroupData(
                                              x: 7,
                                              barRods: [
                                                BarChartRodData(
                                                    fromY: 0,
                                                    toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-7].toDouble(),
                                                    // fromY: bookingFrequencyList[8].toDouble(),
                                                    width: chartBarWidth,
                                                    color: Color.fromRGBO(17, 159, 250, 1),
                                                    borderRadius: BorderRadius.circular(5)
                                                )
                                              ]
                                          ),
                                          BarChartGroupData(
                                              x: 8,
                                              barRods: [
                                                BarChartRodData(
                                                  fromY: 0,
                                                  toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-8].toDouble(),
                                                  // fromY: bookingFrequencyList[9].toDouble(),
                                                  width: chartBarWidth,
                                                  color: Color.fromRGBO(17, 159, 250, 1),
                                                  borderRadius: BorderRadius.circular(5),
                                                )
                                              ]
                                          ),
                                          BarChartGroupData(
                                              x: 9,
                                              barRods: [
                                                BarChartRodData(
                                                    fromY: 0,
                                                    toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-9].toDouble(),
                                                    // fromY: bookingFrequencyList[10].toDouble(),
                                                    width: chartBarWidth,
                                                    color: Color.fromRGBO(17, 159, 250, 1),
                                                    borderRadius: BorderRadius.circular(5)
                                                )
                                              ]
                                          ),
                                          BarChartGroupData(
                                              x: 10,
                                              barRods: [
                                                BarChartRodData(
                                                    fromY: 0,
                                                    toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-10].toDouble(),
                                                    // fromY: bookingFrequencyList[11].toDouble(),
                                                    width: chartBarWidth,
                                                    color: Color.fromRGBO(17, 159, 250, 1),
                                                    borderRadius: BorderRadius.circular(5)
                                                )
                                              ]
                                          ),
                                          BarChartGroupData(
                                              x: 11,
                                              barRods: [
                                                BarChartRodData(
                                                    fromY: 0,
                                                    toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-11].toDouble(),
                                                    // fromY: bookingFrequencyList[12].toDouble(),
                                                    width: chartBarWidth,
                                                    color: Color.fromRGBO(17, 159, 250, 1),
                                                    borderRadius: BorderRadius.circular(5)
                                                )
                                              ]
                                          ),
                                          BarChartGroupData(
                                              x: 12,
                                              barRods: [
                                                BarChartRodData(
                                                    fromY: 0,
                                                    toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-12].toDouble(),
                                                    // fromY: bookingFrequencyList[12].toDouble(),
                                                    width: chartBarWidth,
                                                    color: Color.fromRGBO(17, 159, 250, 1),
                                                    borderRadius: BorderRadius.circular(5)
                                                )
                                              ]
                                          ),
                                          BarChartGroupData(
                                              x: 13,
                                              // barsSpace: 10,
                                              barRods: [
                                                BarChartRodData(
                                                    fromY: 0,
                                                    toY: socketProvider.bookingFrequencyList[socketProvider.bookingFrequencyList.length-13].toDouble(),
                                                    // fromY: bookingFrequencyList[12].toDouble(),
                                                    width: chartBarWidth,
                                                    color: Color.fromRGBO(17, 159, 250, 1),
                                                    borderRadius: BorderRadius.circular(5)
                                                )
                                              ]
                                          ),
                                          // BarChartGroupData(
                                          //     x: 14,
                                          //     barRods: [
                                          //       BarChartRodData(
                                          //         fromY: 9,
                                          //         width: chartBarWidth,
                                          //         color: Color.fromRGBO(17, 159, 250, 1),
                                          //         borderRadius: BorderRadius.circular(5),
                                          //
                                          //       )
                                          //     ]
                                          // ),
                                          // BarChartGroupData(
                                          //     x: 15,
                                          //     barRods: [
                                          //       BarChartRodData(
                                          //         // fromY: 20,
                                          //           fromY: bookingFrequencyList[1].toDouble(),
                                          //           width: 15,
                                          //           color: Color.fromRGBO(17, 159, 250, 1),
                                          //           borderRadius: BorderRadius.circular(5)
                                          //       )
                                          //     ]
                                          // ),
                                        ]
                                    ),
                                  ),
                                );
                              }
                              else if (snapshot.connectionState != ConnectionState.done){
                                return Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height * 0.18
                                  ),
                                  child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.blue,
                                      )
                                  ),
                                );
                              }
                              else if(snapshot.connectionState == ConnectionState.done /*&& snapshot.hasData*/
                                  && socketProvider.bookingFrequencyList.isEmpty){
                                return Padding(
                                  padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height * 0.18
                                  ),
                                  child: const Center(
                                    child: Text(
                                        "Nessuna prenotazione"
                                    ),
                                  ),
                                );
                              }
                              else {
                                return const SizedBox();
                              }
                            }
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),

                Container(
                  height: 530,
                  // padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                            child: Text(
                              'Ultime notifiche',
                              style: TextStyle(
                                color: Colors.black,
                                // color: Colors.green[600],
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: (){
                              Navigator.push(
                                  context,
                                  PageTransition(
                                      duration: const Duration(milliseconds: 500),
                                      alignment: Alignment.center,
                                      type: PageTransitionType.fade,
                                      child: NotificationsScreen()
                                    // child: TicketDetailScreen(
                                    //   user: widget.user,
                                    //   singleEventTicket: singleEventTicket,
                                    // ),
                                  )
                              );
                            },
                            child: Padding(
                              // padding: const EdgeInsets.only(
                              //     left: 8.0,
                              //   bottom: 0,
                              //   top: 0,
                              //   right: 8
                              // ),
                              padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                              child: Text(
                                // 'Show All',
                                'Mostra',
                                style: TextStyle(
                                  // color: Colors.black.withOpacity(0.5),
                                  color: Colors.blue[500],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // SizedBox(
                      //   height: 16,
                      // ),

                      Expanded(
                        child: ListView.builder(
                            padding: EdgeInsets.all(16),
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: socketProvider.notificationList.length < 6 ? socketProvider.notificationList.length : 6,
                            itemBuilder: (context, index) {
                              Booking? appun;
                              for(Booking e in socketProvider.myAppointments){
                                if(e.id == socketProvider.notificationList[index]['booking_id']){
                                  appun = e;
                                }
                              }

                              // Appointment appointment = new Appointment(
                              //   id: socketProvider.notificationList[index].id,
                              //   isCanceled: socketProvider.notificationList[index].isCanceled,
                              //   prestazione: new Prestazione(
                              //     id: socketProvider.notificationList[index].prestazione.id,
                              //     duration: socketProvider.notificationList[index].prestazione.duration,
                              //     image: socketProvider.notificationList[index].prestazione.image,
                              //     price: socketProvider.notificationList[index].prestazione.price,
                              //     title: socketProvider.notificationList[index].prestazione.title,
                              //     description: socketProvider.notificationList[index].prestazione.description,
                              //     business_id: socketProvider.notificationList[index].prestazione.business_id,
                              //   ),
                              //   user: new User(
                              //     email: socketProvider.notificationList[index].user.email,
                              //     username: socketProvider.notificationList[index].user.username,
                              //     name: socketProvider.notificationList[index].user.name,
                              //     phone_number: socketProvider.notificationList[index].user.phone_number,
                              //     profile_image: socketProvider.notificationList[index].user.profile_image,
                              //     description: socketProvider.notificationList[index].user.description,
                              //     id: socketProvider.notificationList[index].user.id,
                              //   ),
                              //   // business: new Business(
                              //   //   image: myAppointments[index]['profile_image'],
                              //   //   id: myAppointments[index]['business_id'],
                              //   //   // is_booking_business: 1,
                              //   //   name: myAppointments[index]['name'],
                              //   //   address: myAppointments[index]['address'],
                              //   //   phone_number: myAppointments[index]['phone_number'],
                              //   //   // max_contemporary_appointments: myAppointments[index]['max_contemporary_appointments'],
                              //   //
                              //   // ),
                              //   // begin_at: DateTime.tryParse(bookingList[index]['begin_at']),
                              //   begin_at: socketProvider.notificationList[index].begin_at,
                              //   // end_at: DateTime.tryParse(bookingList[index]['begin_at']).add(
                              //   //   Duration(
                              //   //       minutes: bookingList[index]['prestazione_duration'].toInt()
                              //   //   )
                              //   // ),
                              //   end_at: socketProvider.notificationList[index].begin_at.add(
                              //     Duration(
                              //         minutes: socketProvider.notificationList[index].prestazione.duration.toInt()
                              //     )
                              //   ),
                              //   // created_at: DateTime.tryParse(bookingList[index]['created_at']),
                              //   created_at: socketProvider.notificationList[index].created_at
                              // );

                              print('socketProvider.notificationList[index]');
                              print(socketProvider.notificationList[index]);

                              return InkWell(
                                onTap: (){
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          duration: const Duration(milliseconds: 500),
                                          alignment: Alignment.center,
                                          type: PageTransitionType.fade,
                                          child: BookingDetailScreen(
                                            booking: appun,
                                          )
                                        // child: TicketDetailScreen(
                                        //   user: widget.user,
                                        //   singleEventTicket: singleEventTicket,
                                        // ),
                                      )
                                  );

                                  print(socketProvider.notificationList[index]);
                                },
                                child: Container(
                                  margin: EdgeInsets.only(top: 16),
                                  padding: const EdgeInsets.all(16 / 2),
                                  child: Row(
                                    children: [
                                      InkWell(
                                        onTap: (){
                                          Navigator.push(
                                              context,
                                              PageTransition(
                                                  duration: const Duration(milliseconds: 500),
                                                  alignment: Alignment.center,
                                                  type: PageTransitionType.fade,
                                                  child: UserProfileScreen(
                                                    userId: socketProvider.notificationList[index]['user_id'],
                                                  )
                                                // child: TicketDetailScreen(
                                                //   user: widget.user,
                                                //   singleEventTicket: singleEventTicket,
                                                // ),
                                              )
                                          );

                                          // print(socketProvider.notificationList[index]);
                                          print('fg5gfgf5gf5gfgf5gf5gg5g5g');
                                          print(socketProvider.notificationList[index]['user_profile_image']);
                                          print(socketProvider.notificationList[index]['user_profile_image'] != 'null');
                                          print(socketProvider.notificationList[index]['user_profile_image'] != null);
                                          print(socketProvider.notificationList[index]['user_profile_image'] != '');
                                        },
                                        child: socketProvider.notificationList[index]['user_profile_image'] != null && socketProvider.notificationList[index]['user_profile_image'] != 'null' ? ClipRRect(
                                          borderRadius: BorderRadius.circular(40),
                                          // child: Image.asset(
                                          child: FutureImage(
                                            // imageUrl: appointment.user.profile_image,
                                            socketProvider.notificationList[index]['user_profile_image'] ?? '',
                                            height: 45,
                                            width: 45,
                                          ),
                                        ) : Icon(
                                          Icons.account_circle_rounded,
                                          color: Colors.grey[300],
                                          size: 55,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              gw.GradientText(
                                                // appointment.user.name,
                                                // socketProvider.notificationList[index]['user_name'] ?? '',
                                                socketProvider.notificationList[index]['user_name'] ?? "@${socketProvider.notificationList[index]['user_username']}",
                                                // gradient: appointment.isCanceled == 0 ? LinearGradient(
                                                gradient: socketProvider.notificationList[index]['is_canceled'] == 0 ? LinearGradient(
                                                    begin: Alignment.bottomLeft,
                                                    end: Alignment.topRight,
                                                    colors: [
                                                      // Color(0xff8921aa),
                                                      // Color(0xffDA44bb),
                                                      Colors.green[600]!,
                                                      Colors.green[600]!,
                                                    ]
                                                ) : LinearGradient(
                                                    begin: Alignment.bottomLeft,
                                                    end: Alignment.topRight,
                                                    colors: [
                                                      // Colors.red[600],
                                                      // Colors.red[600],
                                                      Colors.red[900]!,
                                                      Colors.red[600]!,
                                                    ]
                                                ),
                                                style: TextStyle(
                                                  //   color: Colors.black,
                                                    color: Colors.green[600],
                                                    fontWeight: FontWeight.w600
                                                ),
                                              ),
                                              Text(
                                                // appointment.prestazione.title,
                                                socketProvider.notificationList[index]['prestazione_title'],
                                                style: TextStyle(
                                                    color: Colors.black.withOpacity(0.8),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500
                                                ),
                                              ),
                                              Text(
                                                DateFormat.MMMMd('it_IT').format(DateTime.tryParse(socketProvider.notificationList[index]['booking_begin_at'])!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/)
                                                    + ' alle ' +
                                                    // socketProvider.notificationList[index]['booking_begin_at'].toString().substring(11, 16),
                                                    DateTime.tryParse(socketProvider.notificationList[index]['booking_begin_at'])!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                                                style: TextStyle(
                                                    color: Colors.black.withOpacity(0.5),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Icon(
                                      //   Icons.more_vert_rounded,
                                      //   color: Colors.black.withOpacity(0.5),
                                      //   size: 18,
                                      // )
                                      Text(
                                        // discussionData[index].booking,
                                        timeAgo.format(
                                          // appointment.created_at,
                                          // DateTime.tryParse(socketProvider.notificationList[index]['sent_at']),
                                          DateTime.tryParse(socketProvider.notificationList[index]['sent_at'])!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/,
                                          locale: 'it',
                                        ),
                                        // DateFormat.MMMMd('it_IT').format(DateTime.tryParse(bookingList[index]['created_at']))
                                        //     + ' alle ' +
                                        //     bookingList[index]['created_at'].toString().substring(11, 16),
                                        style: TextStyle(
                                            color: Colors.black.withOpacity(0.5),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),

                FutureBuilder(
                    future: a,
                    builder: (context, snapshot) {
                      return Container(
                        height: 530,
                        // padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                                  child: Text(
                                    // 'Clienti ',
                                    // 'Top 10 Clienti',
                                    'Clienti più frequenti',
                                    style: TextStyle(
                                      color: Colors.black,
                                      // color: Colors.green[600],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: false,
                                  child: InkWell(
                                    onTap: (){
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              duration: const Duration(milliseconds: 500),
                                              alignment: Alignment.center,
                                              type: PageTransitionType.fade,
                                              child: BookingScreen()
                                          )
                                      );
                                    },
                                    child: Padding(
                                      // padding: const EdgeInsets.only(
                                      //     left: 8.0,
                                      //   bottom: 0,
                                      //   top: 0,
                                      //   right: 8
                                      // ),
                                      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                                      child: Text(
                                        // 'Show All',
                                        'Mostra',
                                        style: TextStyle(
                                          // color: Colors.black.withOpacity(0.5),
                                          color: Colors.blue[500],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // SizedBox(
                            //   height: 16,
                            // ),

                            Expanded(
                              child: ListView.builder(
                                  padding: EdgeInsets.all(16),
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: usersRankingList!.length < 6 ? usersRankingList!.length : 6,
                                  // itemBuilder: (context, index) => DiscussionInfoDetail(
                                  //   info: discussionData[index],
                                  // ),
                                  itemBuilder: (context, index) {
                                    User user = User(
                                      email: usersRankingList![index]['user_email'],
                                      username: usersRankingList![index]['user_username'],
                                      name: usersRankingList![index]['user_name'],
                                      phone: usersRankingList![index]['user_phone'],
                                      profile_image: usersRankingList![index]['user_profile_image'] ?? '',
                                      description: usersRankingList![index]['user_description'],
                                      id: usersRankingList![index]['user_id'],
                                    );

                                    return InkWell(
                                      onTap: (){

                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                duration: const Duration(milliseconds: 500),
                                                alignment: Alignment.center,
                                                type: PageTransitionType.fade,
                                                child: UserProfileScreen(
                                                  userId: user.id!,
                                                )
                                              // child: TicketDetailScreen(
                                              //   user: widget.user,
                                              //   singleEventTicket: singleEventTicket,
                                              // ),
                                            )
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 16),
                                        padding: const EdgeInsets.all(16 / 2),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(40),
                                              clipBehavior: Clip.antiAliasWithSaveLayer,
                                              // child: Image.asset(
                                              child: user.profile_image != '' ? FutureImage(
                                                // discussionData[index].imageSrc,
                                                // bookingList[index]['user_profile_image'],
                                                user.profile_image,
                                                height: 49,
                                                width: 49,
                                              ) : Icon(
                                                Icons.account_circle_rounded,
                                                color: Colors.grey[300],
                                                size: 60,
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    gw.GradientText(
                                                      // user.username!,
                                                      user.name!,
                                                      // gradient: LinearGradient(
                                                      //     begin: Alignment.bottomLeft,
                                                      //     end: Alignment.topRight,
                                                      //     colors: [
                                                      //       Color(0xff8921aa),
                                                      //       Color(0xffDA44bb),
                                                      //     ]
                                                      // ),
                                                      style: TextStyle(
                                                        color: Colors.blue[600],
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 15
                                                      ),
                                                    ),
                                                    // SizedBox(height: 2.5,),
                                                    // Text(
                                                    //   // user.name ?? '',
                                                    //   user.description ?? '',
                                                    //   maxLines: 2,
                                                    //   overflow: TextOverflow.ellipsis,
                                                    //   style: TextStyle(
                                                    //       color: Colors.grey[500],
                                                    //       fontWeight: FontWeight.w600,
                                                    //       fontSize: 12
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Icon(
                                            //   Icons.more_vert_rounded,
                                            //   color: Colors.black.withOpacity(0.5),
                                            //   size: 18,
                                            // )
                                            Text(
                                              int.tryParse(usersRankingList![index]['ranking'].toString()).toString(),
                                              style: TextStyle(
                                                  color: Colors.black.withOpacity(0.6),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                              ),
                            )
                          ],
                        ),
                      );
                    }
                ),
                SizedBox(
                  height: 16,
                ),

                FutureBuilder(
                    future: b,
                    builder: (context, snapshot) {
                      return Container(
                        height: 560,
                        // padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                                  child: Text(
                                    // 'Clienti ',
                                    // 'Top 10 Clienti',
                                    'Prestazioni più acquistate',
                                    style: TextStyle(
                                      color: Colors.black,
                                      // color: Colors.green[600],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: false,
                                  child: InkWell(
                                    onTap: (){
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              duration: const Duration(milliseconds: 500),
                                              alignment: Alignment.center,
                                              type: PageTransitionType.fade,
                                              child: PrestazioneListScreen()
                                          )
                                      );
                                    },
                                    child: Padding(
                                      // padding: const EdgeInsets.only(
                                      //     left: 8.0,
                                      //   bottom: 0,
                                      //   top: 0,
                                      //   right: 8
                                      // ),
                                      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                                      child: Text(
                                        // 'Show All',
                                        'Mostra',
                                        style: TextStyle(
                                          // color: Colors.black.withOpacity(0.5),
                                          color: Colors.blue[500],
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // SizedBox(
                            //   height: 16,
                            // ),

                            Expanded(
                              child: ListView.builder(
                                  padding: EdgeInsets.all(16),
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: prestazioneRankingList!.length < 6 ? prestazioneRankingList!.length : 6,
                                  // itemBuilder: (context, index) => DiscussionInfoDetail(
                                  //   info: discussionData[index],
                                  // ),
                                  itemBuilder: (context, index) {
                                    Prestazione prestazione = Prestazione(
                                      id: prestazioneRankingList![index]['prestazione_id'],
                                      duration: prestazioneRankingList![index]['prestazione_duration'],
                                      image: prestazioneRankingList![index]['prestazione_image'],
                                      is_price_range: (prestazioneRankingList![index]['prestazione_is_price_range']?.toInt() ?? 0) == 1 ? true : false,
                                      price: prestazioneRankingList![index]['prestazione_price']?.toDouble(),
                                      price_min: prestazioneRankingList![index]['prestazione_price_min']?.toDouble(),
                                      price_max: prestazioneRankingList![index]['prestazione_price_max']?.toDouble(),
                                      title: prestazioneRankingList![index]['prestazione_title'],
                                      description: prestazioneRankingList![index]['prestazione_description'],
                                      business: Business(
                                          id: prestazioneRankingList![index]['business_id'],
                                          description: prestazioneRankingList![index]['business_description'],
                                          name: prestazioneRankingList![index]['business_name'],
                                          room_id: prestazioneRankingList![index]['business_room_id'],
                                          email: prestazioneRankingList![index]['business_email'],
                                          email_notification: prestazioneRankingList![index]['business_email_notification'],
                                          max_contemporary_appointments: prestazioneRankingList![index]['max_contemporary_appointments'],
                                          address: prestazioneRankingList![index]['business_address'],
                                          phone: prestazioneRankingList![index]['business_phone'],
                                          // is_booking_business: prestazioneRankingList![index]['is_booking_business'],
                                          profile_image: prestazioneRankingList![index]['business_profile_image'] ?? '',
                                          latitude: prestazioneRankingList![index]['business_latitude'],
                                          longitude: prestazioneRankingList![index]['business_longitude'],
                                          category: Category(
                                            id: prestazioneRankingList![index]['category_id'],
                                            image: prestazioneRankingList![index]['category_image'],
                                            name: prestazioneRankingList![index]['category_name'],
                                          )
                                      ),
                                    );

                                    return InkWell(
                                      onTap: (){
                                        Navigator.push(
                                            context,
                                            PageTransition(
                                                duration: const Duration(milliseconds: 500),
                                                alignment: Alignment.center,
                                                type: PageTransitionType.fade,
                                                child: PrestazioneSlotsScreen(
                                                  prestazione: prestazione,
                                                )
                                            )
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(top: 16),
                                        padding: const EdgeInsets.all(16 / 2),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: FutureImage(
                                                prestazione.image != null && prestazione.image != '' ? prestazione.image! : prestazione.business!.profile_image!,
                                                width: 50,
                                                height: 50,
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    gw.GradientText(
                                                      prestazione.title!,
                                                      gradient: LinearGradient(
                                                          begin: Alignment.bottomLeft,
                                                          end: Alignment.topRight,
                                                          colors: [
                                                            Color(0xff8921aa),
                                                            Color(0xffDA44bb),
                                                            // Color(0xffDA44bb)
                                                          ]
                                                      ),
                                                      style: TextStyle(
                                                          color: Colors.green[600],
                                                          fontWeight: FontWeight.w600
                                                      ),
                                                    ),
                                                    SizedBox(height: 2.5),
                                                    Text(
                                                      !prestazione.is_price_range ? '€ ${NumberFormat.currency(
                                                        // customPattern: '#,##',
                                                        decimalDigits: 2,
                                                        symbol: '',
                                                        locale: 'IT_it',
                                                        // symbol: '€'
                                                      ).format(prestazione.price)}' : 'da € ${NumberFormat.currency(
                                                        // customPattern: '#,##',
                                                        decimalDigits: 2,
                                                        symbol: '',
                                                        locale: 'IT_it',
                                                        // symbol: '€'
                                                      ).format(prestazione.price_min)}\na € ${NumberFormat.currency(
                                                        // customPattern: '#,##',
                                                        decimalDigits: 2,
                                                        symbol: '',
                                                        locale: 'IT_it',
                                                        // symbol: '€'
                                                      ).format(prestazione.price_max)}',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          color: Colors.green[600],
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 12
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Icon(
                                            //   Icons.more_vert_rounded,
                                            //   color: Colors.black.withOpacity(0.5),
                                            //   size: 18,
                                            // )
                                            Text(
                                              int.tryParse(prestazioneRankingList![index]['ranking'].toString()).toString(),
                                              style: TextStyle(
                                                  color: Colors.black.withOpacity(0.6),
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                              ),
                            )
                          ],
                        ),
                      );
                    }
                ),
                SizedBox(
                  height: 32,
                ),

              ],
            )
          ),
        ),
      ),
    );
  }
}
