import 'dart:convert';
import 'dart:math';

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo_admin/models/selector_tile.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/selector_bottom_sheet.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;


class TimetableSettingsScreen extends StatefulWidget {

  const TimetableSettingsScreen({Key? key});

  @override
  _TimetableSettingsScreenState createState() => _TimetableSettingsScreenState();
}

class _TimetableSettingsScreenState extends State<TimetableSettingsScreen> {
  late BusinessProvider businessProvider;
  List bookingBusinessTimetable1 = [];
  List dsds4dsfdfs45 = [];
  late NumberFormat formatter;
  int? selectedId = -1;
  List<SelectorTile> dayList = [
    SelectorTile(title: 'Lunedì', /*subtitle: 'subtitle', datetime: 'datetime',*/ leadingWidget: Text('L', style: const TextStyle(color: Colors.blue),)),
    SelectorTile(title: 'Martedì', /*subtitle: 'subtitle', datetime: 'datetime',*/ leadingWidget: Text('L', style: const TextStyle(color: Colors.blue),)),
    SelectorTile(title: 'Mercoledì', /*subtitle: 'subtitle', datetime: 'datetime',*/ leadingWidget: Text('L', style: const TextStyle(color: Colors.blue),)),
    SelectorTile(title: 'Giovedì', /*subtitle: 'subtitle', datetime: 'datetime',*/ leadingWidget: Text('L', style: const TextStyle(color: Colors.blue),)),
    SelectorTile(title: 'Venerdì', /*subtitle: 'subtitle', datetime: 'datetime',*/ leadingWidget: Text('L', style: const TextStyle(color: Colors.blue),)),
    SelectorTile(title: 'Sabato', /*subtitle: 'subtitle', datetime: 'datetime',*/ leadingWidget: Text('L', style: const TextStyle(color: Colors.blue),)),
    SelectorTile(title: 'Domenica', /*subtitle: 'subtitle', datetime: 'datetime',*/ leadingWidget: Text('L', style: const TextStyle(color: Colors.blue),)),
  ];
  bool isSaved = false;

  updateDay(int index, int i) {
    setState(() {
      // selectedId = index;
      // selectedId = i;
      // selectedId = bookingBusinessTimetable[i]['weekday_id'];
      selectedId = i;
      /*businessProvider.business.*/bookingBusinessTimetable1[i]['weekday_id'] = index + 1;
    });
    // print(/*businessProvider.business.*/bookingBusinessTimetable1[i]['weekday_id']);
    // print(dayList[index].title);
    // print(selectedId);
    // print(index);
  }

  Future updateOpenDatetime(int i) async {
    TimeOfDay initialTime = TimeOfDay(
        hour: int.tryParse(bookingBusinessTimetable1[i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours,
        minute: int.tryParse(bookingBusinessTimetable1[i]['open_at_minute'])!
    );

    var newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.input,
      // onEntryModeChanged: (timePickerEntryMode){
      //   print(timePickerEntryMode);
      // },
      // useRootNavigator: false

    );

    if (newTime == null) return;

    // print(newTime);

    setState(() {
      bookingBusinessTimetable1[i]['open_at_hour'] = (newTime.hour - DateTime.now().timeZoneOffset.inHours).toString();
      bookingBusinessTimetable1[i]['open_at_minute'] = newTime.minute.toString();
    });

    // if(bookingBusinessTimetable1.length == 0){
    //   await businessProvider.deleteTimetable();
    // }
    // else{
    //   List res = await businessProvider.updateTimetable(bookingBusinessTimetable1);
    //   // if(res == bookingBusinessTimetable){
    //   //   setState(() {
    //   //     businessProvider.business!.bookingBusinessTimetable = bookingBusinessTimetable;
    //   //   });
    //   // }
    // }
  }

  Future updateCloseDatetime(int i) async {
    TimeOfDay initialTime = TimeOfDay(
        hour: int.tryParse(bookingBusinessTimetable1[i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours,
        minute: int.tryParse(bookingBusinessTimetable1[i]['close_at_minute'])!
    );

    var newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      initialEntryMode: TimePickerEntryMode.input,
      // onEntryModeChanged: (timePickerEntryMode){
      //   print(timePickerEntryMode);
      // },
    );

    if (newTime == null) return;

    // print(newTime);

    setState(() {
      bookingBusinessTimetable1[i]['close_at_hour'] = (newTime.hour - DateTime.now().timeZoneOffset.inHours).toString();
      bookingBusinessTimetable1[i]['close_at_minute'] = newTime.minute.toString();
    });

    // if(bookingBusinessTimetable1.length == 0){
    //   await businessProvider.deleteTimetable();
    // }
    // else{
    //   List res = await businessProvider.updateTimetable(bookingBusinessTimetable1);
    //   // if(res == bookingBusinessTimetable){
    //   //   setState(() {
    //   //     businessProvider.business!.bookingBusinessTimetable = bookingBusinessTimetable;
    //   //   });
    //   // }
    // }
  }

  // Future updateTimetable() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "timetable");
  //
  //   // Map<String, dynamic> body = {
  //   //   'business_id': businessId,
  //   // };
  //
  //   var response = await http.put(
  //       url,
  //       // body: jsonEncode(body),
  //       body: jsonEncode(businessProvider.business.bookingBusinessTimetable),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   // print('response.statusCode');
  //   // print(response.statusCode);
  //
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     await Fluttertoast.showToast(
  //       msg: 'Orari di Apertura Aggiornati',
  //       backgroundColor: Colors.grey[700],
  //     );
  //
  //     return jsonData;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    initializeDateFormatting();
    timeAgo.setLocale('it', timeAgo.Italian());

    formatter = NumberFormat("00");

    // businessProvider.business!.bookingBusinessTimetable!.clear();

    // Future.wait([
    //   businessProvider.getDateBusinessTimetable(),
    // ]).then((value) {
      setState(() {
        bookingBusinessTimetable1.addAll(List.from(businessProvider.business!.bookingBusinessTimetable!));
      });
    // for(var e in businessProvider.business!.bookingBusinessTimetable!){
    //   bookingBusinessTimetable1.add(e);
    // }
      // dsds4dsfdfs45.addAll(List.from(businessProvider.business!.bookingBusinessTimetable!));
    // });

    // bookingBusinessTimetable = businessProvider.business.bookingBusinessTimetable;
    // bookingBusinessTimetable1.addAll(List.from(businessProvider.business!.bookingBusinessTimetable!));
    // bookingBusinessTimetable2.addAll(List.from(businessProvider.business!.bookingBusinessTimetable!));
  }

  @override
  void dispose() async {
    super.dispose();

    businessProvider.business!.bookingBusinessTimetable!.clear();
    // businessProvider.deleteLocalTimetable();
    // await Future.wait([
    //   businessProvider.getDateBusinessTimetable(),
    // ]).then((value) {
    //   // setState(() {
    //     bookingBusinessTimetable1.addAll(List.from(businessProvider.business!.bookingBusinessTimetable!));
    //   // });
    // });
    await businessProvider.getDateBusinessTimetable().then((value) {
      bookingBusinessTimetable1.addAll(List.from(businessProvider.business!.bookingBusinessTimetable!));
    });

  }

  @override
  Widget build(BuildContext context) {
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);

    return WillPopScope(
      onWillPop: () async {
        // Future.wait([
        //   businessProvider.getDateBusinessTimetable(),
        // ]);

        // setState(() {
          // businessProvider.business!.bookingBusinessTimetable = bookingBusinessTimetable1;
          // businessProvider.business!.bookingBusinessTimetable = bookingBusinessTimetable2;
          // businessProvider.business!.bookingBusinessTimetable!.clear();
          // businessProvider.deleteLocalTimetable();
        // });
        // await businessProvider.getDateBusinessTimetable();
        // await Future.delayed(Duration(milliseconds: 500), (){
        //   //mostrare un progress indicator in sovrimpressione
        // });

        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        // backgroundColor: Colors.grey[50],
        appBar: AppBar(
          titleSpacing: 0,
          // leadingWidth: 40,
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
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          title: Text(
            'Orari di Apertura',
            style: TextStyle(
                color: Colors.blue[500],
                // color: Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: 15
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: isSaved ? Transform.scale(scale: 0.8, child: const CircularProgressIndicator(color: Colors.blue,),) : OutlinedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  onPressed: () async {
                    setState(() {
                      isSaved = true;
                    });

                    if(bookingBusinessTimetable1.length == 0){
                      await businessProvider.deleteTimetable();
                    }
                    else{
                      List res = await businessProvider.updateTimetable(bookingBusinessTimetable1);
                      // if(res == bookingBusinessTimetable){
                      //   setState(() {
                      //     businessProvider.business!.bookingBusinessTimetable = bookingBusinessTimetable;
                      //   });
                      // }
                    }
                    // print('businessProvider.business.bookingBusinessTimetable.length');
                    // print(businessProvider.business!.bookingBusinessTimetable!.length);


                    Navigator.pop(context);
                  },
                  child: Text(
                    'Salva',
                    style: TextStyle(
                        color: Colors.blue
                    ),
                  )
                // child: Icon(
                //   Icons.add,
                //   color: Colors.blue,
                // ),
              ),
            )
          ],
        ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.start,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              // SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (overscroll) {
                  overscroll.disallowIndicator();
                  return true;
                },
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * .97,
                        // height: (bookingBusinessTimetable.length * 22 + (20)).toDouble(),
                        padding: EdgeInsets.only(
                            right: 15,
                            left: 15
                        ),
                        // margin: EdgeInsets.only(left: 33),
                        // color: Colors.red,
                        // clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListView.separated(
                                separatorBuilder: (context, i) {
                                  return SizedBox(height: 4,);
                                },
                                shrinkWrap: true,
                                itemCount: /*businessProvider.business.*/bookingBusinessTimetable1.length,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, i){
                                  if(/*businessProvider.business.*/bookingBusinessTimetable1[i]['weekday_id'] == 1){
                                    return Marquee(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          OutlinedButton(
                                            onPressed: () async {
                                              // print(
                                              //   bookingBusinessTimetable[i]['id']
                                              // );

                                              // print('dio');
                                              // print(bookingBusinessTimetable[i]['weekday_id']);
                                              // print(accountList[i].title);
                                              // print(selectedId);
                                              // print(i);

                                              setState(() {
                                                selectedId = /*businessProvider.business.*/bookingBusinessTimetable1[i]['weekday_id'] - 1;
                                                // selectedId = i;
                                              });

                                              showSelectorBottomSheet(
                                                context: context,
                                                accountList: dayList,
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
                                                selectedRadioColor: Colors.blue[500]!, //Optional
                                                // unselectedTextColor: Colors.white, //Optional
                                                unselectedTextColor: Colors.grey[900], //Optional
                                                // selectedTextColor: Colors.amber, //Optional
                                                unselectedSubtitleColor: Colors.grey[500],
                                                unselectedDatetimeColor: Colors.grey[700],
                                                selectedTextColor: Colors.blue[500]!, //Optional
                                                //Optional
                                                tapCallback: (index) {
                                                  updateDay(index, i);
                                                  Navigator.pop(context);
                                                },
                                                //Optional
                                                // addAccountTapCallback: () {
                                                //   setState(() {
                                                //     resultText = "Add account clicked";
                                                //   });
                                                //   print(resultText);
                                                // },
                                              );

                                            },
                                            child: Text(
                                              'Lunedì ',
                                              style: TextStyle(
                                                // color: Colors.blue[500],
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,
                                            ),
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width * .06),
                                          OutlinedButton(
                                            onPressed: () async {
                                              await updateOpenDatetime(i);
                                            },
                                            child: Text(
                                              formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours)
                                              + ':' + formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['open_at_minute'])),
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,
                                            ),
                                          ),
                                          Text(
                                            ' - ',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18
                                            ),
                                          ),
                                          OutlinedButton(
                                            onPressed: () async {
                                              await updateCloseDatetime(i);
                                            },
                                            child: Text(
                                              formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours)
                                                  + ':' + formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['close_at_minute'])),
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,

                                            ),
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width * .03),
                                          InkWell(
                                            onTap: () async {
                                              // print(bookingBusinessTimetable1.length);
                                              // for(int j = 0; j < bookingBusinessTimetable.length; j++){
                                              //   if(i == j){
                                              //     setState(() {
                                              //       bookingBusinessTimetable.remove(i);
                                              //     });
                                              //   }
                                              // }
                                              setState(() {
                                                bookingBusinessTimetable1.removeAt(i);
                                              });
                                              // print(bookingBusinessTimetable1.length);
                                            },
                                            child: Container(
                                              // width: 30,
                                              // height: 60,
                                              margin: EdgeInsets.only(
                                                  left: MediaQuery.of(context).size.width * .02,
                                                  right: MediaQuery.of(context).size.width * .005,
                                                  top: 10,
                                                  bottom: 10
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[500],
                                                // color: Colors.red[600],
                                                shape: BoxShape.circle,
                                                // border: Border.all(
                                                //   // color: Colors.red[500],
                                                // ),
                                                // borderRadius: BorderRadius.all(Radius.circular(20))
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Icon(
                                                  Icons.clear,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                  else if(/*businessProvider.business.*/bookingBusinessTimetable1[i]['weekday_id'] == 2){
                                    return Marquee(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          OutlinedButton(
                                            onPressed: () async {
                                              // print(
                                              //   bookingBusinessTimetable[i]['id']
                                              // );

                                              // print('dio');
                                              // print(bookingBusinessTimetable[i]['weekday_id']);
                                              // print(accountList[i].title);
                                              // print(selectedId);
                                              // print(i);

                                              setState(() {
                                                selectedId = /*businessProvider.business.*/bookingBusinessTimetable1[i]['weekday_id'] - 1;
                                                // selectedId = i;
                                              });

                                              showSelectorBottomSheet(
                                                context: context,
                                                accountList: dayList,
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
                                                selectedRadioColor: Colors.blue[500]!, //Optional
                                                // unselectedTextColor: Colors.white, //Optional
                                                unselectedTextColor: Colors.grey[900], //Optional
                                                // selectedTextColor: Colors.amber, //Optional
                                                unselectedSubtitleColor: Colors.grey[500],
                                                unselectedDatetimeColor: Colors.grey[700],
                                                selectedTextColor: Colors.blue[500]!, //Optional
                                                //Optional
                                                tapCallback: (index) {
                                                  updateDay(index, i);
                                                  Navigator.pop(context);
                                                },
                                                //Optional
                                                // addAccountTapCallback: () {
                                                //   setState(() {
                                                //     resultText = "Add account clicked";
                                                //   });
                                                //   print(resultText);
                                                // },
                                              );

                                            },
                                            child: Text(
                                              'Martedì ',
                                              style: TextStyle(
                                                // color: Colors.blue[500],
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,

                                            ),
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width * .06),
                                          OutlinedButton(
                                            onPressed: () async {
                                              await updateOpenDatetime(i);
                                            },
                                            child: Text(
                                              formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours)
                                                  + ':' + formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['open_at_minute'])),
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,
                                            ),
                                          ),
                                          Text(
                                            ' - ',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18
                                            ),
                                          ),
                                          OutlinedButton(
                                            onPressed: () async {
                                              await updateCloseDatetime(i);
                                            },
                                            child: Text(
                                              formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours)
                                                  + ':' + formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['close_at_minute'])),
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,

                                            ),
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width * .03),
                                          InkWell(
                                            onTap: () async {
                                              // print(bookingBusinessTimetable1.length);
                                              // for(int j = 0; j < bookingBusinessTimetable.length; j++){
                                              //   if(i == j){
                                              //     setState(() {
                                              //       bookingBusinessTimetable.remove(i);
                                              //     });
                                              //   }
                                              // }
                                              setState(() {
                                                bookingBusinessTimetable1.removeAt(i);
                                              });
                                              // print(bookingBusinessTimetable1.length);
                                            },
                                            child: Container(
                                              // width: 30,
                                              // height: 60,
                                              margin: EdgeInsets.only(
                                                  left: MediaQuery.of(context).size.width * .02,
                                                  right: MediaQuery.of(context).size.width * .005,
                                                  top: 10,
                                                  bottom: 10
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[500],
                                                // color: Colors.red[600],
                                                shape: BoxShape.circle,
                                                // border: Border.all(
                                                //   // color: Colors.red[500],
                                                // ),
                                                // borderRadius: BorderRadius.all(Radius.circular(20))
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Icon(
                                                  Icons.clear,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                  else if(/*businessProvider.business.*/bookingBusinessTimetable1[i]['weekday_id'] == 3){
                                    return Marquee(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          OutlinedButton(
                                            onPressed: () async {
                                              // print(
                                              //   bookingBusinessTimetable[i]['id']
                                              // );

                                              // print('dio');
                                              // print(bookingBusinessTimetable[i]['weekday_id']);
                                              // print(accountList[i].title);
                                              // print(selectedId);
                                              // print(i);

                                              setState(() {
                                                selectedId = /*businessProvider.business.*/bookingBusinessTimetable1[i]['weekday_id'] - 1;
                                                // selectedId = i;
                                              });

                                              showSelectorBottomSheet(
                                                context: context,
                                                accountList: dayList,
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
                                                selectedRadioColor: Colors.blue[500]!, //Optional
                                                // unselectedTextColor: Colors.white, //Optional
                                                unselectedTextColor: Colors.grey[900], //Optional
                                                // selectedTextColor: Colors.amber, //Optional
                                                unselectedSubtitleColor: Colors.grey[500],
                                                unselectedDatetimeColor: Colors.grey[700],
                                                selectedTextColor: Colors.blue[500]!, //Optional
                                                //Optional
                                                tapCallback: (index) {
                                                  updateDay(index, i);
                                                  Navigator.pop(context);
                                                },
                                                //Optional
                                                // addAccountTapCallback: () {
                                                //   setState(() {
                                                //     resultText = "Add account clicked";
                                                //   });
                                                //   print(resultText);
                                                // },
                                              );

                                            },
                                            child: Text(
                                              'Mercoledì ',
                                              style: TextStyle(
                                                // color: Colors.blue[500],
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,

                                            ),
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width * .06),
                                          OutlinedButton(
                                            onPressed: () async {
                                              await updateOpenDatetime(i);
                                            },
                                            child: Text(
                                              formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours)
                                                  + ':' + formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['open_at_minute'])),
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,
                                            ),
                                          ),
                                          Text(
                                            ' - ',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18
                                            ),
                                          ),
                                          OutlinedButton(
                                            onPressed: () async {
                                              await updateCloseDatetime(i);
                                            },
                                            child: Text(
                                              formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours)
                                                  + ':' + formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['close_at_minute'])),
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,

                                            ),
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width * .03),
                                          InkWell(
                                            onTap: () async {
                                              // print(bookingBusinessTimetable1.length);
                                              // for(int j = 0; j < bookingBusinessTimetable.length; j++){
                                              //   if(i == j){
                                              //     setState(() {
                                              //       bookingBusinessTimetable.remove(i);
                                              //     });
                                              //   }
                                              // }
                                              setState(() {
                                                bookingBusinessTimetable1.removeAt(i);
                                              });
                                              // print(bookingBusinessTimetable1.length);
                                            },
                                            child: Container(
                                              // width: 30,
                                              // height: 60,
                                              margin: EdgeInsets.only(
                                                  left: MediaQuery.of(context).size.width * .02,
                                                  right: MediaQuery.of(context).size.width * .005,
                                                  top: 10,
                                                  bottom: 10
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[500],
                                                // color: Colors.red[600],
                                                shape: BoxShape.circle,
                                                // border: Border.all(
                                                //   // color: Colors.red[500],
                                                // ),
                                                // borderRadius: BorderRadius.all(Radius.circular(20))
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Icon(
                                                  Icons.clear,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                  else if(/*businessProvider.business.*/bookingBusinessTimetable1[i]['weekday_id'] == 4){
                                    return Marquee(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          OutlinedButton(
                                            onPressed: () async {
                                              // print(
                                              //   bookingBusinessTimetable[i]['id']
                                              // );

                                              // print('dio');
                                              // print(bookingBusinessTimetable[i]['weekday_id']);
                                              // print(accountList[i].title);
                                              // print(selectedId);
                                              // print(i);

                                              setState(() {
                                                selectedId = /*businessProvider.business.*/bookingBusinessTimetable1[i]['weekday_id'] - 1;
                                                // selectedId = i;
                                              });

                                              showSelectorBottomSheet(
                                                context: context,
                                                accountList: dayList,
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
                                                selectedRadioColor: Colors.blue[500]!, //Optional
                                                // unselectedTextColor: Colors.white, //Optional
                                                unselectedTextColor: Colors.grey[900], //Optional
                                                // selectedTextColor: Colors.amber, //Optional
                                                unselectedSubtitleColor: Colors.grey[500],
                                                unselectedDatetimeColor: Colors.grey[700],
                                                selectedTextColor: Colors.blue[500]!, //Optional
                                                //Optional
                                                tapCallback: (index) {
                                                  updateDay(index, i);
                                                  Navigator.pop(context);
                                                },
                                                //Optional
                                                // addAccountTapCallback: () {
                                                //   setState(() {
                                                //     resultText = "Add account clicked";
                                                //   });
                                                //   print(resultText);
                                                // },
                                              );

                                            },
                                            child: Text(
                                              'Giovedì ',
                                              style: TextStyle(
                                                // color: Colors.blue[500],
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,

                                            ),
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width * .06),
                                          OutlinedButton(
                                            onPressed: () async {
                                              await updateOpenDatetime(i);
                                            },
                                            child: Text(
                                              formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours)
                                                  + ':' + formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['open_at_minute'])),
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,
                                            ),
                                          ),
                                          Text(
                                            ' - ',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18
                                            ),
                                          ),
                                          OutlinedButton(
                                            onPressed: () async {
                                              await updateCloseDatetime(i);
                                            },
                                            child: Text(
                                              formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours)
                                                  + ':' + formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['close_at_minute'])),
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,
                                            ),
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width * .03),
                                          InkWell(
                                            onTap: () async {
                                              // print(bookingBusinessTimetable1.length);
                                              // for(int j = 0; j < bookingBusinessTimetable.length; j++){
                                              //   if(i == j){
                                              //     setState(() {
                                              //       bookingBusinessTimetable.remove(i);
                                              //     });
                                              //   }
                                              // }
                                              setState(() {
                                                bookingBusinessTimetable1.removeAt(i);
                                              });
                                              // print(bookingBusinessTimetable1.length);
                                            },
                                            child: Container(
                                              // width: 30,
                                              // height: 60,
                                              margin: EdgeInsets.only(
                                                  left: MediaQuery.of(context).size.width * .02,
                                                  right: MediaQuery.of(context).size.width * .005,
                                                  top: 10,
                                                  bottom: 10
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[500],
                                                // color: Colors.red[600],
                                                shape: BoxShape.circle,
                                                // border: Border.all(
                                                //   // color: Colors.red[500],
                                                // ),
                                                // borderRadius: BorderRadius.all(Radius.circular(20))
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Icon(
                                                  Icons.clear,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                  else if(/*businessProvider.business.*/bookingBusinessTimetable1[i]['weekday_id'] == 5){
                                    return Marquee(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          OutlinedButton(
                                            onPressed: () async {
                                              // print(
                                              //   bookingBusinessTimetable[i]['id']
                                              // );

                                              // print('dio');
                                              // print(bookingBusinessTimetable[i]['weekday_id']);
                                              // print(accountList[i].title);
                                              // print(selectedId);
                                              // print(i);

                                              setState(() {
                                                selectedId = /*businessProvider.business.*/bookingBusinessTimetable1[i]['weekday_id'] - 1;
                                                // selectedId = i;
                                              });

                                              showSelectorBottomSheet(
                                                context: context,
                                                accountList: dayList,
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
                                                selectedRadioColor: Colors.blue[500]!, //Optional
                                                // unselectedTextColor: Colors.white, //Optional
                                                unselectedTextColor: Colors.grey[900], //Optional
                                                // selectedTextColor: Colors.amber, //Optional
                                                unselectedSubtitleColor: Colors.grey[500],
                                                unselectedDatetimeColor: Colors.grey[700],
                                                selectedTextColor: Colors.blue[500]!, //Optional
                                                //Optional
                                                tapCallback: (index) {
                                                  updateDay(index, i);
                                                  Navigator.pop(context);
                                                },
                                                //Optional
                                                // addAccountTapCallback: () {
                                                //   setState(() {
                                                //     resultText = "Add account clicked";
                                                //   });
                                                //   print(resultText);
                                                // },
                                              );

                                            },
                                            child: Text(
                                              'Venerdì ',
                                              style: TextStyle(
                                                // color: Colors.blue[500],
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,

                                            ),
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width * .06),
                                          OutlinedButton(
                                            onPressed: () async {
                                              await updateOpenDatetime(i);
                                            },
                                            child: Text(
                                              formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours)
                                                  + ':' + formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['open_at_minute'])),
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,
                                            ),
                                          ),
                                          Text(
                                            ' - ',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18
                                            ),
                                          ),
                                          OutlinedButton(
                                            onPressed: () async {
                                              await updateCloseDatetime(i);
                                            },
                                            child: Text(
                                              formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours)
                                                  + ':' + formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['close_at_minute'])),
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,

                                            ),
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width * .03),
                                          InkWell(
                                            onTap: () async {
                                              // print(bookingBusinessTimetable1.length);
                                              // for(int j = 0; j < bookingBusinessTimetable.length; j++){
                                              //   if(i == j){
                                              //     setState(() {
                                              //       bookingBusinessTimetable.remove(i);
                                              //     });
                                              //   }
                                              // }
                                              setState(() {
                                                bookingBusinessTimetable1.removeAt(i);
                                              });
                                              // print(bookingBusinessTimetable1.length);

                                            },
                                            child: Container(
                                              // width: 30,
                                              // height: 60,
                                              margin: EdgeInsets.only(
                                                  left: MediaQuery.of(context).size.width * .02,
                                                  right: MediaQuery.of(context).size.width * .005,
                                                  top: 10,
                                                  bottom: 10
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[500],
                                                // color: Colors.red[600],
                                                shape: BoxShape.circle,
                                                // border: Border.all(
                                                //   // color: Colors.red[500],
                                                // ),
                                                // borderRadius: BorderRadius.all(Radius.circular(20))
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Icon(
                                                  Icons.clear,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                  else if(/*businessProvider.business.*/bookingBusinessTimetable1[i]['weekday_id'] == 6){
                                    return Marquee(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          OutlinedButton(
                                            onPressed: () async {
                                              // print(
                                              //   bookingBusinessTimetable[i]['id']
                                              // );

                                              // print('dio');
                                              // print(bookingBusinessTimetable[i]['weekday_id']);
                                              // print(accountList[i].title);
                                              // print(selectedId);
                                              // print(i);

                                              setState(() {
                                                selectedId = /*businessProvider.business.*/bookingBusinessTimetable1[i]['weekday_id'] - 1;
                                                // selectedId = i;
                                              });

                                              showSelectorBottomSheet(
                                                context: context,
                                                accountList: dayList,
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
                                                selectedRadioColor: Colors.blue[500]!, //Optional
                                                // unselectedTextColor: Colors.white, //Optional
                                                unselectedTextColor: Colors.grey[900], //Optional
                                                // selectedTextColor: Colors.amber, //Optional
                                                unselectedSubtitleColor: Colors.grey[500],
                                                unselectedDatetimeColor: Colors.grey[700],
                                                selectedTextColor: Colors.blue[500]!, //Optional
                                                //Optional
                                                tapCallback: (index) {
                                                  updateDay(index, i);
                                                  Navigator.pop(context);
                                                },
                                                //Optional
                                                // addAccountTapCallback: () {
                                                //   setState(() {
                                                //     resultText = "Add account clicked";
                                                //   });
                                                //   print(resultText);
                                                // },
                                              );

                                            },
                                            child: Text(
                                              'Sabato ',
                                              style: TextStyle(
                                                // color: Colors.blue[500],
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,

                                            ),
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width * .06),
                                          OutlinedButton(
                                            onPressed: () async {
                                              await updateOpenDatetime(i);
                                            },
                                            child: Text(
                                              formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours)
                                                  + ':' + formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['open_at_minute'])),
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,
                                            ),
                                          ),
                                          Text(
                                            ' - ',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18
                                            ),
                                          ),
                                          OutlinedButton(
                                            onPressed: () async {
                                              await updateCloseDatetime(i);
                                            },
                                            child: Text(
                                              formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours)
                                                  + ':' + formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['close_at_minute'])),
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,

                                            ),
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width * .03),
                                          InkWell(
                                            onTap: () async {
                                              // print(bookingBusinessTimetable1.length);
                                              // for(int j = 0; j < bookingBusinessTimetable.length; j++){
                                              //   if(i == j){
                                              //     setState(() {
                                              //       bookingBusinessTimetable.remove(i);
                                              //     });
                                              //   }
                                              // }
                                              setState(() {
                                                bookingBusinessTimetable1.removeAt(i);
                                              });
                                              // print(bookingBusinessTimetable1.length);
                                            },
                                            child: Container(
                                              // width: 30,
                                              // height: 60,
                                              margin: EdgeInsets.only(
                                                  left: MediaQuery.of(context).size.width * .02,
                                                  right: MediaQuery.of(context).size.width * .005,
                                                  top: 10,
                                                  bottom: 10
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[500],
                                                // color: Colors.red[600],
                                                shape: BoxShape.circle,
                                                // border: Border.all(
                                                //   // color: Colors.red[500],
                                                // ),
                                                // borderRadius: BorderRadius.all(Radius.circular(20))
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Icon(
                                                  Icons.clear,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                  else if(/*businessProvider.business.*/bookingBusinessTimetable1[i]['weekday_id'] == 7){
                                    return Marquee(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          OutlinedButton(
                                            onPressed: () async {
                                              // print(
                                              //   bookingBusinessTimetable[i]['id']
                                              // );

                                              // print('dio');
                                              // print(bookingBusinessTimetable[i]['weekday_id']);
                                              // print(accountList[i].title);
                                              // print(selectedId);
                                              // print(i);

                                              setState(() {
                                                selectedId = /*businessProvider.business.*/bookingBusinessTimetable1[i]['weekday_id'] - 1;
                                                // selectedId = i;
                                              });

                                              showSelectorBottomSheet(
                                                context: context,
                                                accountList: dayList,
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
                                                selectedRadioColor: Colors.blue[500]!, //Optional
                                                // unselectedTextColor: Colors.white, //Optional
                                                unselectedTextColor: Colors.grey[900], //Optional
                                                // selectedTextColor: Colors.amber, //Optional
                                                unselectedSubtitleColor: Colors.grey[500],
                                                unselectedDatetimeColor: Colors.grey[700],
                                                selectedTextColor: Colors.blue[500]!, //Optional
                                                //Optional
                                                tapCallback: (index) {
                                                  updateDay(index, i);
                                                  Navigator.pop(context);
                                                },
                                                //Optional
                                                // addAccountTapCallback: () {
                                                //   setState(() {
                                                //     resultText = "Add account clicked";
                                                //   });
                                                //   print(resultText);
                                                // },
                                              );

                                            },
                                            child: Text(
                                              'Domenica ',
                                              style: TextStyle(
                                                // color: Colors.blue[500],
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,

                                            ),
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width * .06),
                                          OutlinedButton(
                                            onPressed: () async {
                                              await updateOpenDatetime(i);
                                            },
                                            child: Text(
                                              formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours)
                                                  + ':' + formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['open_at_minute'])),
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,
                                            ),
                                          ),
                                          Text(
                                            ' - ',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18
                                            ),
                                          ),
                                          OutlinedButton(
                                            onPressed: () async {
                                              await updateCloseDatetime(i);
                                            },
                                            child: Text(
                                              formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours)
                                                  + ':' + formatter.format(int.tryParse(/*businessProvider.business.*/bookingBusinessTimetable1[i]['close_at_minute'])),
                                              style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                              ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                              backgroundColor: Colors.white,
                                              // minimumSize: Size(50, 30),
                                              alignment: Alignment.center,
                                              elevation: 0,

                                            ),
                                          ),
                                          SizedBox(width: MediaQuery.of(context).size.width * .03),
                                          InkWell(
                                            onTap: () async {
                                              // print(bookingBusinessTimetable1.length);
                                              // for(int j = 0; j < bookingBusinessTimetable.length; j++){
                                              //   if(i == j){
                                              //     setState(() {
                                              //       bookingBusinessTimetable.remove(i);
                                              //     });
                                              //   }
                                              // }
                                              setState(() {
                                                bookingBusinessTimetable1.removeAt(i);
                                              });
                                              // print(bookingBusinessTimetable1.length);
                                            },
                                            child: Container(
                                              // width: 30,
                                              // height: 60,
                                              margin: EdgeInsets.only(
                                                  left: MediaQuery.of(context).size.width * .02,
                                                  right: MediaQuery.of(context).size.width * .005,
                                                  top: 10,
                                                  bottom: 10
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[500],
                                                // color: Colors.red[600],
                                                shape: BoxShape.circle,
                                                // border: Border.all(
                                                //   // color: Colors.red[500],
                                                // ),
                                                // borderRadius: BorderRadius.all(Radius.circular(20))
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(5.0),
                                                child: Icon(
                                                  Icons.clear,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                  else return null;
                                }
                            ),
                            SizedBox(height: 15,),
                            OutlinedButton(
                              onPressed: (){
                                // print(businessProvider.business.bookingBusinessTimetable);
                                // print(DateTime.now().weekday);
                                // print(DateTime.now().day);
                                // print(DateFormat('EEEE').format(DateTime.now()));

                                Map<String, dynamic> value = {
                                  'id': 'avfndvcnjvskvsdjk',
                                  'day': DateFormat('EEEE').format(DateTime.now()),
                                  'business_id': businessProvider.business!.id,
                                  'weekday_id': DateTime.now().weekday,
                                  'open_at_hour': DateTime.now().hour.toString(),
                                  'open_at_minute': DateTime.now().minute.toString(),
                                  'close_at_hour': DateTime.now().hour.toString(),
                                  'close_at_minute': DateTime.now().minute.toString(),
                                  'is_new': 1,
                                };

                                setState(() {
                                  /*businessProvider.business.*/bookingBusinessTimetable1.add(value);
                                });

                                // print(value);
                              },
                              child: Text(
                                'Aggiungi',
                                style: TextStyle(
                                    color: Colors.blue[500],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.only(left: 15, bottom: 10, right: 15, top: 10),
                                backgroundColor: Colors.white,
                                // minimumSize: Size(50, 30),
                                alignment: Alignment.center,
                                elevation: 0,

                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),

              SizedBox(
                height: 50,
              ),

            ],
          ),
        ),
      ),
    );
  }
}
