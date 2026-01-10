import 'dart:convert';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:nurebo_admin/models/event.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/provider/event_provider.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/prestazione_provider.dart';
import 'package:nurebo_admin/screens/event_detail_screen.dart';
import 'package:nurebo_admin/screens/prestazione_detail_screen.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:get/get_utils/get_utils.dart';

class BusinessEventsScreen extends StatefulWidget {

  const BusinessEventsScreen({Key? key,});

  @override
  _BusinessEventsScreenState createState() => _BusinessEventsScreenState();
}

class _BusinessEventsScreenState extends State<BusinessEventsScreen> {
  // final formatter =  NumberFormat.decimalPattern().format(1234); // formatted number will be: 1,234
  List eventsList = [];
  late EventProvider eventProvider;
  late BusinessProvider businessProvider;
  // List prestazioneCategories = [];

  // Future getAllEventCategories(int singleEventId) async {
  //   var url = Uri.parse(Constants.httpServerUrl + "single_event_ticket/single_event");
  //   // var ticketCategoryProvider = Provider.of<TicketProvider>(context/*, listen: false*/);
  //
  //   Map/*<String, String>*/ body = {
  //     'single_event_id': singleEventId,
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   print('response.statusCode');
  //   print(response.statusCode);
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     setState(() {
  //       prestazioneCategories = jsonData.toList();
  //     });
  //
  //     print(jsonData);
  //     print(prestazioneCategories);
  //     return jsonData;
  //   }
  // }

  // Future getAllDateBusinessPrestazioni() async {
  //   var url = Uri.parse(Constants.httpServerUrl + "prestazione/booking_business");
  //
  //   Map<String, String> body = {
  //     // 'event_business_id': widget.eventBusiness.id,
  //     'business_id': '11',
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   print('response.statusCode');
  //   print(response.statusCode);
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     setState(() {
  //       prestazioneList = jsonData;
  //     });
  //     print(jsonData);
  //     return jsonData;
  //   }
  // }
  //
  // Future deletePrestazione(String prestazioneId) async {
  //   var url = Uri.parse(Constants.httpServerUrl + "event_business/single_event/delete");
  //
  //   Map/*<String, String>*/ body = {
  //     'business_id': '11',
  //     'prestazione_id': prestazioneId,
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   print('response.statusCode');
  //   print(response.statusCode);
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     // setState(() {
  //     //   eventBusinessEventsList = jsonData;
  //     // });
  //     print(jsonData);
  //     return jsonData;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    eventProvider = Provider.of<EventProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    eventProvider = Provider.of<EventProvider>(context, listen: true);
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);

    return RefreshIndicator(
      edgeOffset: 60,
      // strokeWidth: 5,
      // displacement: 200,
      // triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: () async {
        eventProvider.deleteAll();
        await eventProvider.getAllBusinessEvents(businessProvider.business!.id, context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
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
          backgroundColor: Colors.white,
          // centerTitle: true,
          title: Text(
            'Eventi',
            style: TextStyle(
                // color: Colors.blue,
                color: Colors.grey[500],
                // fontWeight: FontWeight.w600,
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
            //       // Navigator.push(
            //       //   context,
            //       //   PageTransition(
            //       //     duration: const Duration(milliseconds: 500),
            //       //     alignment: Alignment.center,
            //       //     type: PageTransitionType.fade,
            //       //     // child: NotificationScreen(),
            //       //     child: PrestazioneDetailScreen(
            //       //       prestazione: Event(
            //       //         title: '',
            //       //         description: '',
            //       //       ),
            //       //       // eventBusiness: widget.bookingBusiness,
            //       //       isNewPrestazione: true,
            //       //     ),
            //       //   )
            //       // );
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
            child: ListView.separated(
                padding: EdgeInsets.only(top: 15, bottom: 10),
                separatorBuilder: (context, index) => Divider(
                  // color: Colors.black,
                  height: 10,
                  thickness: 1,
                  indent: 15,
                  endIndent: 15,
                ),
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                // physics: NeverScrollableScrollPhysics(),
                itemCount: eventProvider.eventList.length,
                itemBuilder: (context, i){
                  return InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onTap: () async {
                      // ticketCategoryProvider.deleteAll();

                      // Prestazione prestazione = new Prestazione(
                      //   id: prestazioneList[i]['id'],
                      //   description: prestazioneList[i]['description'],
                      //   business_id: prestazioneList[i]['business_id'],
                      //   title: prestazioneList[i]['title'],
                      //   image: prestazioneList[i]['image'],
                      //   price: prestazioneList[i]['price'].toDouble(),
                      //   duration: prestazioneList[i]['duration'],
                      // );
                      // Prestazione prestazione = new Prestazione(
                      //   id: prestazioneProvider.prestazioneList[i]['id'],
                      //   description: prestazioneProvider.prestazioneList[i]['description'],
                      //   business_id: prestazioneProvider.prestazioneList[i]['business_id'],
                      //   title: prestazioneProvider.prestazioneList[i]['title'],
                      //   image: prestazioneProvider.prestazioneList[i]['image'],
                      //   price: prestazioneProvider.prestazioneList[i]['price'].toDouble(),
                      //   duration: prestazioneProvider.prestazioneList[i]['duration'],
                      // );

                      Event event = Event(
                        id: eventProvider.eventList[i].id,
                        description: eventProvider.eventList[i].description,
                        business_id: eventProvider.eventList[i].business_id,
                        title: eventProvider.eventList[i].title,
                        image: eventProvider.eventList[i].image,
                        begin_at: eventProvider.eventList[i].begin_at,
                        end_at: eventProvider.eventList[i].end_at,
                        is_valid: eventProvider.eventList[i].is_valid,
                        previous: eventProvider.eventList[i].previous,
                        created_at: eventProvider.eventList[i].created_at,
                      );

                      // prestazioneCategories.clear();
                      // await getAllEventCategories(singleEvent.id);

                      // ticketCategoryProvider.createNewCategories(ticketCategories.length);
                      // print('ticketCategoryProvider.ticketCategories.length');
                      // print(ticketCategoryProvider.ticketCategories.length);
                      // for(int i = 0; i < ticketCategoryProvider.ticketCategories.length; i++){
                      //   ticketCategoryProvider.setTitle(i, ticketCategories[i]['title']);
                      //   // ticketCategoryProvider.setPrice(i, double.tryParse(ticketCategories[i]['price']));
                      //   ticketCategoryProvider.setAdditional(i, ticketCategories[i]['additional']);
                      // }
                      // print(ticketCategoryProvider.ticketCategories);
                      // print('ticketCategoryProvider.ticketCategories.length1');
                      // print(ticketCategoryProvider.ticketCategories.length);
                      // print('prestazioneCategories.length1');
                      // print(prestazioneCategories.length);

                      Navigator.push(
                        context,
                        PageTransition(
                          duration: const Duration(milliseconds: 500),
                          alignment: Alignment.center,
                          type: PageTransitionType.fade,
                          child: EventDetailScreen(
                            event: event,
                            // eventBusiness: widget.bookingBusiness,
                            // ticketCategories: prestazioneCategories,
                            isNewEvent: false,
                          ),
                        ),
                      );
                    },

                    //   child: Padding(
                    //     padding: EdgeInsets.only(top: 5, bottom: 5),
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //       children: [
                    //         Container(
                    //           child: Padding(
                    //             padding: EdgeInsets.only(left: 10, top: 2.5, bottom: 2.5),
                    //             child: Container(
                    //               width: 90,
                    //               height: 60,
                    //               child: Card(
                    //                 semanticContainer: true,
                    //                 clipBehavior: Clip.antiAliasWithSaveLayer,
                    //                 child: Image.network(
                    //                   // prestazioneList[i]['image'] ?? '',
                    //                   // prestazioneList[i].image ?? '',
                    //                   prestazioneProvider.prestazioneList[i]['image'] ?? '',
                    //                   fit: BoxFit.cover,
                    //                 ),
                    //                 shape: RoundedRectangleBorder(
                    //                   borderRadius: BorderRadius.circular(5.0),
                    //                 ),
                    //                 elevation: 15,
                    //                 //margin: EdgeInsets.all(10),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //         Expanded(
                    //           //alignment: Alignment.topLeft,
                    //           child: Padding(
                    //             padding: EdgeInsets.only(left: 15),
                    //             child: Column(
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               children: [
                    //                 Row(
                    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //                   children: [
                    //                     Padding(
                    //                       padding: EdgeInsets.only(top: 0),
                    //                       child: Text(
                    //                         // prestazioneList[i]['title'].toString().capitalizeFirst,
                    //                         prestazioneProvider.prestazioneList[i]['title'].toString().capitalizeFirst,
                    //                         style: TextStyle(
                    //                             fontWeight: FontWeight.w700,
                    //                             fontSize: 18.0,
                    //                             color: Colors.blue
                    //                         ),
                    //                       ),
                    //                     ),
                    //                     // Padding(
                    //                     //   padding: EdgeInsets.only(top: 5, right: 15),
                    //                     //   child: Text(
                    //                     //     "3:35 pm",
                    //                     //     // DateTime.tryParse(chatMessageList[i]['sent_at']).hour.toString() + ":"
                    //                     //     //     + DateTime.tryParse(chatMessageList[i]['sent_at']).minute.toString() + ":"
                    //                     //     //     + DateTime.tryParse(chatMessageList[i]['sent_at']).second.toString(),
                    //                     //     style: TextStyle(
                    //                     //         color: Colors.grey[600],
                    //                     //         fontWeight: FontWeight.w700,
                    //                     //         fontSize: 12
                    //                     //     ),
                    //                     //   ),
                    //                     // )
                    //                   ],
                    //                 ),
                    //                 SizedBox(height: 4),
                    //                 Container(
                    //                   child: Row(
                    //                     children: [
                    //                       Text(
                    //                         '€' ,
                    //                         maxLines: 2,
                    //                         overflow: TextOverflow.ellipsis,
                    //                         // softWrap: true,
                    //                         style: TextStyle(
                    //                           color: Colors.grey[800],
                    //                           fontWeight: FontWeight.w700
                    //                         ),
                    //                       ),
                    //                       SizedBox(width: 2,),
                    //                       Text(
                    //                         // NumberFormat.currency(customPattern: '#,##', locale: 'IT_it').format(prestazioneList[i]['price'].toDouble())/*prestazioneList[i]['price'].toString()*/
                    //                         NumberFormat.currency(customPattern: '#,##', locale: 'IT_it').format(prestazioneProvider.prestazioneList[i]['price'].toDouble()),
                    //                         maxLines: 2,
                    //                         overflow: TextOverflow.ellipsis,
                    //                         // softWrap: true,
                    //                         style: TextStyle(
                    //                           color: Colors.grey[800],
                    //                           fontWeight: FontWeight.w700
                    //                         ),
                    //                       ),
                    //                       Text(
                    //                         ' • '
                    //                       ),
                    //                       Text(
                    //                         // prestazioneList[i]['duration'].toString() + ' min',
                    //                         prestazioneProvider.prestazioneList[i]['duration'].toString() + ' min',
                    //                         maxLines: 2,
                    //                         overflow: TextOverflow.ellipsis,
                    //                         // softWrap: true,
                    //                         style: TextStyle(
                    //                             color: Colors.grey[800],
                    //                             fontWeight: FontWeight.w700
                    //                         ),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //                 // Row(
                    //                 //   mainAxisAlignment: MainAxisAlignment.end,
                    //                 //   // crossAxisAlignment: CrossAxisAlignment.center,
                    //                 //   children: [
                    //                 //     Padding(
                    //                 //       padding: EdgeInsets.only(top: 5, right: 15),
                    //                 //       child: Text(
                    //                 //         "3:35 pm",
                    //                 //         style: TextStyle(
                    //                 //           color: Colors.grey[900],
                    //                 //         ),
                    //                 //       ),
                    //                 //     )
                    //                 //   ],
                    //                 // ),
                    //                 // SizedBox(height: 4),
                    //                 // Marquee(
                    //                 //   child: Row(
                    //                 //     children: [
                    //                 //       Text(
                    //                 //         prestazioneList[i]['description'].toString(),
                    //                 //         maxLines: 4,
                    //                 //         overflow: TextOverflow.ellipsis,
                    //                 //         // softWrap: true,
                    //                 //         style: TextStyle(
                    //                 //           color: Colors.grey[800],
                    //                 //         ),
                    //                 //       ),
                    //                 //     ],
                    //                 //   ),
                    //                 // ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //         // Padding(
                    //         //   padding: EdgeInsets.only(right: 15),
                    //         //   // mainAxisAlignment: MainAxisAlignment.center,
                    //         //   child:
                    //         //     Text(
                    //         //         "5:35 pm"
                    //         //     )
                    //         // ),
                    //         Padding(
                    //           padding: EdgeInsets.only(right: 5, left: 20, ),
                    //           child: IconButton(
                    //             onPressed: () {
                    //
                    //               // prestazioneProvider.deletePrestazione(prestazioneList[i]['id']);
                    //               prestazioneProvider.deletePrestazione(businessProvider.business.id, prestazioneProvider.prestazioneList[i]['id']);
                    //               // setState(() {
                    //               //   getAllDateBusinessPrestazioni();
                    //               // });
                    //             },
                    //             icon: Icon(
                    //               Icons.delete_outline,
                    //               color: Colors.grey[500],
                    //               // color: Colors.redAccent,
                    //             ),
                    //           ),
                    //           // child: Container(
                    //           //   width: 12,
                    //           //   height: 12,
                    //           //   decoration: BoxDecoration(
                    //           //     color: Colors.blue[300],
                    //           //     shape: BoxShape.circle,
                    //           //   ),
                    //           // ),
                    //         ),
                    //         Divider(height: 5, thickness: 5,),
                    //       ],
                    //     ),
                    // ),
                    child: Container(
                      margin: EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.only(
                        top: 8,
                        bottom: 8,
                        left: 20,
                        right: 15
                      ),
                      child: Row(
                        children: [
                          // prestazioneProvider.prestazioneList[i]['image'] == '' || prestazioneProvider.prestazioneList[i]['image'] == null ? ClipRRect(
                          eventProvider.eventList[i].image == '' || eventProvider.eventList[i].image == null ? ClipRRect(
                            // borderRadius: BorderRadius.circular(40),
                            borderRadius: BorderRadius.circular(4),
                            // child: Image.asset(
                            // child: Image.network(
                            //   businessProvider.business.profile_image,
                            //   // height: 38,
                            //   height: 45,
                            //   // width: 38,
                            //   width: 45,
                            //   fit: BoxFit.cover,
                            // ),
                            child: FutureImage(
                              businessProvider.business!.profile_image!,
                              // colorBlendMode: BlendMode.darken,
                              // colorBlendMode: BlendMode.hardLight,
                              width: 60,
                              height: 45,
                              // filterQuality: FilterQuality.high,
                              // placeholder: (context, url) => Center(
                              //     child: CircularProgressIndicator()
                              // ),
                            ),
                          ) : ClipRRect(
                            // borderRadius: BorderRadius.circular(40),
                            borderRadius: BorderRadius.circular(4),
                            // child: Image.asset(
                            child: FutureImage(
                              eventProvider.eventList[i].image!,
                              // colorBlendMode: BlendMode.darken,
                              // colorBlendMode: BlendMode.hardLight,
                              width: 60,
                              height: 45,
                              // filterQuality: FilterQuality.high,
                              // placeholder: (context, url) => Center(
                              //     child: CircularProgressIndicator()
                              // ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Marquee(
                                    child: GradientText(
                                      eventProvider.eventList[i].title ?? '',
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
                                        //   color: Colors.black,
                                          color: Colors.green[600],
                                          fontWeight: FontWeight.w600,
                                        fontSize: 15.5
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 3,),
                                  Text(
                                    // discussionData[index].booking,
                                    // timeAgo.format(
                                    //     DateTime.tryParse(bookingList[index]['created_at']),
                                    //     locale: 'it'
                                    // ),
                                    // DateFormat.MMMMd('it_IT').format(DateTime.tryParse(bookingList[index]['created_at']))
                                    //   + ' alle ' +
                                    //   bookingList[index]['created_at'].toString().substring(11, 16),
                                    eventProvider.eventList[i].description.toString() /*?? ''*/,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        // color: Colors.black.withOpacity(0.8),
                                        color: Colors.grey[700],
                                        // color: Colors.blue[600],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  SizedBox(height: 1,),
                                  // prestazioneProvider.prestazioneList[i]['price'] != null && prestazioneProvider.prestazioneList[i]['price'] != '' ? Text(
                                  //   // timeAgo.format(
                                  //   //     DateTime.tryParse(bookingList[index]['begin_at']),
                                  //   //     locale: 'it'
                                  //   // ),
                                  //   // DateFormat.MMMMd('it_IT').format(DateTime.tryParse(bookingList[index]['begin_at']))
                                  //   //     + ' alle ' +
                                  //   //     bookingList[index]['begin_at'].toString().substring(11, 16),
                                  //   '€ ' + NumberFormat.currency(
                                  //     // customPattern: '#,##',
                                  //     decimalDigits: 2,
                                  //     symbol: '',
                                  //     locale: 'IT_it',
                                  //     // symbol: '€'
                                  //   ).format(prestazioneProvider.prestazioneList[i]['price'].toDouble()),
                                  //   // bookingList[index]['prestazione_title'],
                                  //   style: TextStyle(
                                  //     // color: Colors.black.withOpacity(0.5),
                                  //       color: Colors.green[700],
                                  //       fontSize: 13,
                                  //       fontWeight: FontWeight.w500
                                  //   ),
                                  // ) : SizedBox(),
                                ],
                              ),
                            ),
                          ),
                          // Icon(
                          //   Icons.more_vert_rounded,
                          //   color: Colors.black.withOpacity(0.5),
                          //   size: 18,
                          // )

                          eventProvider.eventList[i].begin_at != null && eventProvider.eventList[i].begin_at.toString() != '' ? Text(
                            // timeAgo.format(
                            //     DateTime.tryParse(bookingList[index]['begin_at']),
                            //     locale: 'it'
                            // ),
                            DateFormat.yMMMEd('it_IT').format(eventProvider.eventList[i].begin_at!).substring(0, 3).toLowerCase().capitalize!
                                + '\n' +
                            DateFormat.yMMMEd('it_IT').format(eventProvider.eventList[i].begin_at!).substring(4).toLowerCase().capitalize!
                                + '\n' +
                                eventProvider.eventList[i].begin_at.toString().substring(11, 16),
                            // '€ ' + NumberFormat.currency(
                            //   // customPattern: '#,##',
                            //   decimalDigits: 2,
                            //   symbol: '',
                            //   locale: 'IT_it',
                            //   // symbol: '€'
                            // ).format(32.2),
                            // bookingList[index]['prestazione_title'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              // color: Colors.black.withOpacity(0.8),
                              // color: Colors.green[800],
                              color: Colors.blue[500],
                              fontSize: 13,
                              fontWeight: FontWeight.w500
                            ),
                          ) : SizedBox(),
                          // Padding(
                          //   padding: EdgeInsets.only(right: 0, left: 0, ),
                          //   child: IconButton(
                          //     onPressed: () async {
                          //       // prestazioneProvider.deletePrestazione(prestazioneList[i]['id']);
                          //       await prestazioneProvider.deletePrestazione(businessProvider.business.id, prestazioneProvider.prestazioneList[i]['id']);
                          //       // setState(() {
                          //       //   getAllDateBusinessPrestazioni();
                          //       // });
                          //     },
                          //     icon: Icon(
                          //       Icons.delete_outline,
                          //       color: Colors.grey[500],
                          //       size: 22,
                          //       // color: Colors.redAccent,
                          //     ),
                          //   ),
                          //   // child: Container(
                          //   //   width: 12,
                          //   //   height: 12,
                          //   //   decoration: BoxDecoration(
                          //   //     color: Colors.blue[300],
                          //   //     shape: BoxShape.circle,
                          //   //   ),
                          //   // ),
                          // ),
                          Divider(height: 5, thickness: 5,),
                        ],
                      ),
                    ),
                  );
                }
              ),
          ),
          // ),
        ),
      ),
    );
  }
}
