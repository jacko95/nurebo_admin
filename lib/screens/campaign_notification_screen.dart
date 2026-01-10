import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:mime/mime.dart';
import 'package:nurebo_admin/models/booking.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/business_campaign_type.dart';
import 'package:nurebo_admin/models/post.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/campaign_provider.dart';
import 'package:nurebo_admin/provider/post_provider.dart';
import 'package:nurebo_admin/provider/prestazione_provider.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/screens/campaign_user_preview_list_screen.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/account.dart';
import 'package:nurebo_admin/widgets/account_selector.dart';
import 'package:nurebo_admin/widgets/custom_dialog.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:nurebo_admin/widgets/image_cache_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;
import 'package:mime/mime.dart';
import 'package:http_parser/src/media_type.dart';


class CampaignNotificationScreen extends StatefulWidget {
  // final Post? post;
  // final int? campaignType;
  final BusinessCampaignType campaignType;

  const CampaignNotificationScreen({super.key, required this.campaignType});

  @override
  _CampaignNotificationScreenState createState() => _CampaignNotificationScreenState();
}

class _CampaignNotificationScreenState extends State<CampaignNotificationScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  bool? editableBody;
  bool? editableTitle;
  File? image;
  final picker = ImagePicker();
  bool isSelectedImage = false;
  late BusinessProvider businessProvider;
  late PrestazioneProvider prestazioneProvider;
  late CampaignProvider campaignProvider;
  late SocketProvider socketProvider;
  late PostProvider postProvider;
  // bool isSaved = false;
  // List<Account> bottomsheetPrestazioneList = [];
  // List<Account> bottomsheetPrenotazioneList = [];
  // List<Account> bottomsheetUserList = [];
  // String resultText = "";
  // int prestazioneSelectedId = -1;
  // int prenotazioneSelectedId = -1;
  // int userSelectedId = -1;
  NumberFormat? formatter;
  // List<User> userOrderList = [];
  // Future a = Future((){});
  // static final ImageCacheBusiness imageCacheBusiness = ImageCacheBusiness();
  // List<Booking> tempAppointments = [];


  Future choiceImage() async {
    // var pickedImage = await picker.getImage(source: ImageSource.gallery);
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);
    // PickedFile pickedImage = await picker.getVideo(source: ImageSource.gallery);

    // _video = File(pickedFile.path);
    setState(() {
      image = File(pickedImage!.path);
      isSelectedImage = true;
    });
  }

  // Future getAllEventCategories() async {
  //   var url = Uri.parse(Constants.httpServerUrl + "single_event_ticket/single_event");
  //   // var ticketCategoryProvider = Provider.of<TicketProvider>(context/*, listen: false*/);
  //
  //   Map/*<String, String>*/ body = {
  //     'single_event_id': widget.singleEvent.id,
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
  //       ticketCategories = jsonData.toList();
  //     });
  //
  //     print(jsonData);
  //     print(ticketCategories);
  //     return jsonData;
  //   }
  // }

  void _showDeletingDialog(String module) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return CustomDialog(
            title: 'Cancellare post',
            content: module,
            confirmColor: Colors.red[400],
            isCancel: true,
            confirmContent: 'Cancella',
            confirmCallback: () async {
              // int statusCode = await postProvider.deletePost(businessProvider.business!.id, widget.post!.id, context);
              // if(statusCode == 200){
              //   Navigator.pop(context);
              //   // Fluttertoast.showToast(
              //   //   msg: 'Prestazione cancellata',
              //   //   backgroundColor: Colors.grey[700],
              //   // );
              //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              //     content: Row(
              //       children: [
              //         Icon(
              //           Icons.delete_outline,
              //           color: Colors.white,
              //         ),
              //         SizedBox(width: 10),
              //         Text(
              //           'Prestazione cancellata',
              //           style: TextStyle(
              //             fontWeight: FontWeight.w600,
              //             color: Colors.white,
              //           ),
              //         ),
              //       ],
              //     ),
              //     backgroundColor: Colors.green,
              //   ));
              // }
            },

            // image: 'https://images.pexels.com/photos/3268732/pexels-photo-3268732.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
            // cancelColor: Colors.red[400],
          );
        }
    );
  }

  // Future getAllBuyers(String? businessId, BuildContext context) async {
  //   BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
  //   // var url = Uri.parse(Utils.httpServerUrl + "prestazione/business");
  //   var url = Uri.parse("${Utils.httpServerUrl}business/$businessId/order/user");
  //
  //   Map<String, String?> body = {
  //     // 'event_business_id': widget.eventBusiness.id,
  //     'business_id': businessId,
  //   };
  //
  //   // var response = await http.post(
  //   var response = await http.get(
  //       url,
  //       // body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //         'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
  //         'X-App-Version-Name': Utils.version_name,
  //         'X-App-Version-Number': Utils.version_id.toString(),
  //         'X-Client-Type': 'Business-Mobile-App',
  //         HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!
  //       }
  //   );
  //
  //   // print('response.statusCode');
  //   // print(response.statusCode);
  //
  //   if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
  //     // if (!mounted) return;
  //     await businessProvider.logout(context);
  //   }
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     // print('jsonDatag5gfgf5gf5');
  //     // print(jsonData);
  //
  //     // prestazioneList = jsonData;
  //     for(var e in jsonData){
  //       userOrderList.add(
  //         User(
  //           id: e['user_id'],
  //           email: e['user_email'],
  //           username: e['user_username'],
  //           name: e['user_name'],
  //           phone_number: e['user_phone_number'],
  //           profile_image: e['user_profile_image'] ?? '',
  //           // description: appointments[i]['user_description'],
  //         ),
  //       );
  //     }
  //
  //     // print('postList.length');
  //     // print(postList.length);
  //
  //     bottomsheetUserList = List.generate(
  //       userOrderList.length,
  //       (index){
  //         return Account(
  //           title: userOrderList[index].name,
  //           datetime: /*userOrderList[index].email!*/'',
  //           // datetime: DateFormat.yMMMMd('it_IT').format(DateTime.tryParse(allEntities[index]['begin_at'])).toString()
  //           //     + ' alle ' + DateTime.tryParse(allEntities[index]['begin_at']).toString().substring(11, 16),
  //           subtitle: '@' + userOrderList[index].username!,
  //           accountImageWidget: FutureImage(
  //             userOrderList[index].profile_image,
  //             width: 200,
  //           ),
  //         );
  //       }
  //     );
  //
  //     // bottomsheetUserList.sort((a, b) {
  //     //   return a.subtitle.toString().toLowerCase().compareTo(b.subtitle.toString().toLowerCase());
  //     // });
  //
  //
  //     // notifyListeners();
  //     return jsonData;
  //   }
  // }

  @override
  void initState() {
    super.initState();
    postProvider = Provider.of<PostProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    prestazioneProvider = Provider.of<PrestazioneProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    campaignProvider = Provider.of<CampaignProvider>(context, listen: false);

    initializeDateFormatting();
    timeAgo.setLocale('it', timeAgo.Italian());
    formatter = NumberFormat("00");

    campaignProvider.businessCampaignType = widget.campaignType;

    print('widget.campaignType');
    print(widget.campaignType);

    // if(widget.post!.description != null) {
    //   _descriptionController.text = widget.post!.description!;
    // }

    // Future.wait([
    //   a = getAllBuyers(businessProvider.business!.id, context),
    // ]).then((value) {
    //   if(widget.isNewPost == false){
    //     // print('edId555555');
    //     // int prestazioneIndex = -1;
    //     // for(Prestazione prestazione in prestazioneProvider.prestazioneList){
    //     for(int i = 0; i < prestazioneProvider.prestazioneList.length; i++){
    //       // print(prestazioneProvider.prestazioneList[i].id);
    //       if(prestazioneProvider.prestazioneList[i].id == widget.post!.prestazione!.id!){
    //         // prestazioneIndex = i;
    //         prestazioneSelectedId = i;
    //         break;
    //       }
    //     }
    //
    //     print('userOrderList.length');
    //     print(userOrderList.length);
    //     for(int i = 0; i < userOrderList.length; i++){
    //       print(userOrderList[i].id);
    //       if(userOrderList[i].id == widget.post!.user!.id!){
    //         setState(() {
    //           userSelectedId = i;
    //         });
    //         break;
    //       }
    //     }
    //     // selectedId = prestazioneIndex;
    //
    //     print(userSelectedId);
    //     // print(prestazioneIndex);
    //     print(widget.post!.user!.id!);
    //   }
    // });
    // bottomsheetPrestazioneList = List.generate(
    //     prestazioneProvider.prestazioneList.length,
    //     (index){
    //       return Account(
    //         title: prestazioneProvider.prestazioneList[index].title,
    //         datetime: '€ ${NumberFormat.currency(
    //           // customPattern: '#,##',
    //             decimalDigits: 2,
    //             symbol: '',
    //             locale: 'IT_it'
    //         ).format(prestazioneProvider.prestazioneList[index].price)}',
    //         // datetime: DateFormat.yMMMMd('it_IT').format(DateTime.tryParse(allEntities[index]['begin_at'])).toString()
    //         //     + ' alle ' + DateTime.tryParse(allEntities[index]['begin_at']).toString().substring(11, 16),
    //         subtitle: "${prestazioneProvider.prestazioneList[index].duration} min",
    //         accountImageWidget: FutureImage(
    //           prestazioneProvider.prestazioneList[index].image != null
    //             ? prestazioneProvider.prestazioneList[index].image!
    //             : prestazioneProvider.prestazioneList[index].business!.profile_image!,
    //           width: 200,
    //         ),
    //       );
    //     }
    // );

    // for(Booking obj in socketProvider.myAppointments) {
    //   if(obj.begin_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).isBefore(DateTime.now().add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))){
    //     tempAppointments.add(obj);
    //   }
    // }
    //
    // tempAppointments.sort((b, a) {
    //   return a.begin_at!.compareTo(b.begin_at!);
    // });

    // print(socketProvider.myAppointments.length);
    // print(tempAppointments.length);

    // bottomsheetPrenotazioneList = List.generate(
    //   tempAppointments.length,
    //   (index){
    //     return Account(
    //       title: "@${tempAppointments[index].user.username}",
    //       // datetime: ,
    //       datetime: DateFormat.yMMMMd('it_IT').format(tempAppointments[index].begin_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))).toString()
    //           + ' alle ' + tempAppointments[index].begin_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
    //       subtitle: "${tempAppointments[index].prestazione!.title}",
    //       accountImageWidget: FutureImage(
    //         tempAppointments[index].user.profile_image,
    //         width: 200,
    //       ),
    //     );
    //   }
    // );
  }

  @override
  Widget build(BuildContext context) {
    postProvider = Provider.of<PostProvider>(context, listen: true);
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);
    prestazioneProvider = Provider.of<PrestazioneProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    campaignProvider = Provider.of<CampaignProvider>(context, listen: true);

    return Scaffold(
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
            // "Invia",
            // "Avvia campagna",
            // 'Continua',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700
            ),
          ),
          onPressed: () async {
            campaignProvider.setNotificationCampaign(
              title: _titleController.text,
              body: _bodyController.text,
              file: image,
            );

            Navigator.push(
              context,
              PageTransition(
                duration: const Duration(milliseconds: 500),
                alignment: Alignment.center,
                type: PageTransitionType.fade,
                child: CampaignUserPreviewListScreen()
              )
            );
            // campaignProvider.sendCampaignNotification(
            //   businessCampaignType: widget.campaignType,
            //   notificationTitle: _titleController.text,
            //   notificationBody: _bodyController.text,
            //   uploadImage: image,
            //   context: context,
            // );
          },
        ),
      ),
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
        title: Text(
          // 'Notifica',
          widget.campaignType.title!,
          // 'Dettagli notifica',
          style: TextStyle(
              color: Colors.blue[500],
              // color: Colors.grey[800],
              fontWeight: FontWeight.w600,
              fontSize: 15
          ),
        ),
        centerTitle: true,
        elevation: 0,
        // foregroundColor: Colors.blue,
        backgroundColor: Colors.white,
        // centerTitle: true,
        // title: Text(
        //   'Prestazioni',
        //   style: TextStyle(
        //       color: Colors.blue,
        //       // color: Colors.grey[800],
        //       fontWeight: FontWeight.w600,
        //       fontSize: 15
        //   ),
        // ),
        actions: [

        ],
      ),
      body: ListView(
        physics: ClampingScrollPhysics(),
        children: [
          // Column(
          //   children: [
          //     Container(
          //       padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          //       margin: EdgeInsets.all(0),
          //       height: 58.0,
          //       color: Colors.white,
          //       child: Row(
          //         children: [
          //           Text(
          //             'Titolo',
          //             style: TextStyle(
          //               color: Colors.blue,
          //               fontWeight: FontWeight.w600
          //             ),
          //           ),
          //           SizedBox(
          //             width: 15,
          //           ),
          //           Expanded(
          //             child: CupertinoTextField(
          //               // suffix: Icon(
          //               //     Icons.keyboard_arrow_right
          //               // ),
          //               obscureText: false,
          //               controller: _titleController,
          //               clearButtonMode: _titleController.text != ''
          //                   ? OverlayVisibilityMode.always
          //                   : OverlayVisibilityMode.never,
          //               enabled: true,
          //               decoration: BoxDecoration(color: Colors.white),
          //               textAlign: /*row.textAlign ??*/ TextAlign.left,
          //               placeholder: /*row.placeholder ??*/ "Inserire il titolo",
          //               placeholderStyle: TextStyle(
          //                   fontSize: 15,
          //                   color: CupertinoColors.placeholderText
          //               ),
          //               keyboardType: TextInputType.text,
          //               // maxLength: 15,
          //               style: TextStyle(
          //                   fontSize: 15,
          //                   color: Colors.grey[700],
          //               ),
          //               readOnly: false,
          //               onChanged: (value) {
          //                 if(_titleController.text == ''){
          //                   setState(() {
          //                     editableTitle = false;
          //                   });
          //                 }
          //                 else{
          //                   setState(() {
          //                     editableTitle = true;
          //                   });
          //                 }
          //               },
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //     Divider(
          //       color: Colors.grey[400],
          //       height: 1,
          //       // endIndent: 20,
          //       // indent: 20,
          //     ),
          //   ],
          // ),
          Container(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0, bottom: 10),
                    child: Text(
                      // "Immagine della notifica",
                      'Immagine',
                      style: TextStyle(
                          fontSize: 15,
                          color: Colors.blue[500],
                          fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                  Container(
                    // height: 100,
                    height: MediaQuery.of(context).size.width/2,
                    //wrapparlo con futurebuilder per creare l image file dall' image network
                    child: InkWell(
                      onTap: () async {
                        // print('ciao');
                        await choiceImage();
                        // print('_image.path');
                        // print(_image!.path);
                        // return SelectImageView(
                        //   selected: (image /*= FileImage().images[index]*/) async {
                        //     // images[index];
                        //     //实际情况是上传照片 返回图片URL，这里模拟数据使用路径
                        //     // row.state[index]["picurl"] = image.path;
                        //   },
                        // );
                      },
                      child: isSelectedImage == true ? Image.file(image!) : Container(
                        // width: 110,
                        // height: 100,
                        width: MediaQuery.of(context).size.width/3,
                        // margin: EdgeInsets.all(5),
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            color: Colors.grey[700],
                            size: 25,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15,),
                ],
              ),
            ),
          ),
          // Column(
          //   children: [
          //     EventImagesWidget(
          //       text: "Immagine di copertina dell'evento",
          //       numImages: 1,
          //       images: [
          //         widget.singleEvent.image
          //       ],
          //     ),
          //     Divider(
          //       color: Colors.grey[400],
          //       height: 1,
          //       // endIndent: 20,
          //       // indent: 20,
          //     ),
          //   ],
          // ),
          Divider(
            color: Colors.grey[400],
            height: 1,
            // endIndent: 20,
            // indent: 20,
          ),

          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                margin: EdgeInsets.all(0),
                height: 58.0,
                color: Colors.white,
                child: Row(
                  children: [
                    Text(
                      'Titolo',
                      style: TextStyle(
                          color: Colors.blue[500],
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: CupertinoTextField(
                        // suffix: Icon(
                        //     Icons.keyboard_arrow_right
                        // ),
                        obscureText: false,
                        controller: _titleController,
                        clearButtonMode: _titleController.text != ''
                            ? OverlayVisibilityMode.always
                            : OverlayVisibilityMode.never,
                        enabled: true,
                        decoration: BoxDecoration(color: Colors.white),
                        textAlign: /*row.textAlign ??*/ TextAlign.left,
                        placeholder: /*row.placeholder ??*/ "Inserire il titolo della notifica",
                        placeholderStyle: TextStyle(
                            fontSize: 15,
                            color: CupertinoColors.placeholderText
                        ),
                        keyboardType: TextInputType.text,
                        // maxLength: 15,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                        ),
                        readOnly: false,
                        onChanged: (value) {
                          if(_titleController.text == ''){
                            setState(() {
                              editableTitle = false;
                            });
                          }
                          else{
                            setState(() {
                              editableTitle = true;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.grey[400],
                height: 1,
                // endIndent: 15,
                // indent: 15,
              ),
            ],
          ),

          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                margin: EdgeInsets.all(0),
                // height: 58.0,
                color: Colors.white,
                child: Row(
                  children: [
                    Text(
                      'Testo',
                      style: TextStyle(
                          color: Colors.blue[500],
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: CupertinoTextField(
                        // suffix: Icon(
                        //     Icons.keyboard_arrow_right
                        // ),
                        obscureText: false,
                        controller: _bodyController,
                        clearButtonMode: _bodyController.text != ''
                            ? OverlayVisibilityMode.always
                            : OverlayVisibilityMode.never,
                        enabled: true,
                        decoration: BoxDecoration(color: Colors.white),
                        textAlign: /*row.textAlign ??*/ TextAlign.left,
                        placeholder: /*row.placeholder ??*/ "Inserire il testo della notifica",
                        placeholderStyle: TextStyle(
                            fontSize: 15,
                            color: CupertinoColors.placeholderText
                        ),
                        keyboardType: TextInputType.text,
                        minLines: 1,
                        maxLines: 8,
                        // expands: true,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                        ),
                        readOnly: false,
                        onChanged: (value) {
                          if(_bodyController.text == ''){
                            setState(() {
                              editableBody = false;
                            });
                          }
                          else{
                            setState(() {
                              editableBody = true;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.grey[400],
                height: 1,
                // endIndent: 20,
                // indent: 20,
              ),
            ],
          ),

          // Visibility(
          //   visible: !widget.isNewPost!,
          //   child: Container(
          //     // height: MediaQuery.of(context).size.width * 0.1,
          //     // width: MediaQuery.of(context).size.width * 0.4,
          //     margin: EdgeInsets.only(
          //         left: MediaQuery.of(context).size.width * 0.2,
          //         right: MediaQuery.of(context).size.width * 0.2,
          //         top: 45,
          //         bottom: 35
          //     ),
          //     child: ElevatedButton(
          //     // child: OutlinedButton(
          //         style: OutlinedButton.styleFrom(
          //             padding: EdgeInsets.zero,
          //             backgroundColor: Colors.red[500],
          //             // backgroundColor: Colors.white,
          //             // minimumSize: Size(50, 30),
          //             alignment: Alignment.center
          //         ),
          //         onPressed: () async {
          //           _showDeletingDialog(
          //               "Premere su 'Cancella' se si vuole cancellare definitivamente la prestazione"
          //           );
          //         },
          //         child: Text(
          //           'Cancella',
          //           style: TextStyle(
          //             // color: Colors.blue[500],
          //             // color: Colors.red[500],
          //             color: Colors.white,
          //             fontWeight: FontWeight.w800,
          //             fontSize: 12,
          //           ),
          //         )
          //     ),
          //   ),
          // )

          SizedBox(height: 100,)
        ],
      ),

    );
  }
}
