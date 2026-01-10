import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:nurebo_admin/screens/home_screen.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo_admin/models/booking.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/business_post.dart';
import 'package:nurebo_admin/models/post.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/post_provider.dart';
import 'package:nurebo_admin/provider/prestazione_provider.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/account.dart';
import 'package:nurebo_admin/widgets/account_selector.dart';
import 'package:nurebo_admin/widgets/custom_dialog.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:nurebo_admin/widgets/image_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;


class PostEditScreen extends StatefulWidget {
  // final Post? post;
  final BusinessPost? post;
  final bool? isNewPost;

  const PostEditScreen({super.key, this.post, /*this.eventBusiness,*/ this.isNewPost});

  @override
  _PostEditScreenState createState() => _PostEditScreenState();
}

class _PostEditScreenState extends State<PostEditScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  bool? editableDescription;
  File? _image;
  final picker = ImagePicker();
  bool isSelectedImage = false;
  late BusinessProvider businessProvider;
  late PrestazioneProvider prestazioneProvider;
  late SocketProvider socketProvider;
  late PostProvider postProvider;
  bool isSaved = false;
  List<Account> bottomsheetPrestazioneList = [];
  List<Account> bottomsheetPrenotazioneList = [];
  List<Account> bottomsheetUserList = [];
  String resultText = "";
  int prestazioneSelectedId = -1;
  int prenotazioneSelectedId = -1;
  int userSelectedId = -1;
  NumberFormat? formatter;
  List<User> userOrderList = [];
  Future a = Future((){});
  // static final ImageCacheBusiness imageCacheBusiness = ImageCacheBusiness();
  List<Booking> tempAppointments = [];


  Future choiceImage() async {
    // var pickedImage = await picker.getImage(source: ImageSource.gallery);
    var pickedImage = await picker.pickImage(source: ImageSource.gallery);
    // PickedFile pickedImage = await picker.getVideo(source: ImageSource.gallery);

    // _video = File(pickedFile.path);
    setState(() {
      _image = File(pickedImage!.path);
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
              int statusCode = await postProvider.deletePost(businessProvider.business!.id, widget.post!.id, context);
              if(statusCode == 200){
                Navigator.pop(context);
                Navigator.pop(context);
                // Fluttertoast.showToast(
                //   msg: 'Prestazione cancellata',
                //   backgroundColor: Colors.grey[700],
                // );
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Post cancellata',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                ));
              }
            },

            // image: 'https://images.pexels.com/photos/3268732/pexels-photo-3268732.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
            // cancelColor: Colors.red[400],
          );
        }
    );
  }

  Future getAllBuyers(String? businessId, BuildContext context) async {
    BusinessProvider businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione/business");
    var url = Uri.parse("${Utils.httpServerUrl}business/$businessId/order/user");

    Map<String, String?> body = {
      // 'event_business_id': widget.eventBusiness.id,
      'business_id': businessId,
    };

    // var response = await http.post(
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

    // print('response.statusCode');
    // print(response.statusCode);

    if(response.statusCode == 401 && BusinessPreferences.getIsLogged() == true) {
      // if (!mounted) return;
      await businessProvider.logout(context);
    }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      // print('jsonDatag5gfgf5gf5');
      // print(jsonData);

      // prestazioneList = jsonData;
      for(var e in jsonData){
        userOrderList.add(
          User(
            id: e['user_id'],
            email: e['user_email'],
            username: e['user_username'],
            name: e['user_name'],
            description: e['user_description'],
            phone: e['user_phone'],
            profile_image: e['user_profile_image'] ?? '',
            // description: appointments[i]['user_description'],
          ),
        );
      }

      // print('postList.length');
      // print(postList.length);

      bottomsheetUserList = List.generate(
        userOrderList.length,
        (index){
          return Account(
            title: userOrderList[index].name,
            datetime: /*userOrderList[index].email!*/'',
            // datetime: DateFormat.yMMMMd('it_IT').format(DateTime.tryParse(allEntities[index]['begin_at'])).toString()
            //     + ' alle ' + DateTime.tryParse(allEntities[index]['begin_at']).toString().substring(11, 16),
            // subtitle: '@${userOrderList[index].username!}',
            // subtitle: userOrderList[index].description!,
            accountImageWidget: /*userOrderList[index].profile_image != '' ?*/ FutureImage(
              userOrderList[index].profile_image,
              width: 200,
            )/* : Icon(
              Icons.account_circle_rounded,
              color: Colors.grey[300],
              size: 45,
            ),*/
          );
        }
      );

      // /*bottomsheetUserList*/userOrderList.sort((a, b) {
      //   return a./*title*/name.toString().toLowerCase().compareTo(b./*title*/name.toString().toLowerCase());
      // });

      // notifyListeners();
      return jsonData;
    }
  }

  @override
  void initState() {
    super.initState();
    postProvider = Provider.of<PostProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    prestazioneProvider = Provider.of<PrestazioneProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);

    initializeDateFormatting();
    timeAgo.setLocale('it', timeAgo.Italian());
    formatter = NumberFormat("00");

    if(widget.post!.description != null) {
      _descriptionController.text = widget.post!.description!;
    }

    Future.wait([
      a = getAllBuyers(businessProvider.business!.id, context),
    ]).then((value) {
      if(widget.isNewPost == false){
        // print('edId555555');
        // int prestazioneIndex = -1;
        // for(Prestazione prestazione in prestazioneProvider.prestazioneList){
        for(int i = 0; i < prestazioneProvider.prestazioneList.length; i++){
          // print(prestazioneProvider.prestazioneList[i].id);
          if(prestazioneProvider.prestazioneList[i].id == widget.post!.prestazione!.id!){
            // prestazioneIndex = i;
            prestazioneSelectedId = i;
            break;
          }
        }

        print('userOrderList.length');
        print(userOrderList.length);
        for(int i = 0; i < userOrderList.length; i++){
          print(userOrderList[i].id);
          if(userOrderList[i].id == widget.post!.user!.id!){
            setState(() {
              userSelectedId = i;
            });
            break;
          }
        }
        // selectedId = prestazioneIndex;

        print(userSelectedId);
        // print(prestazioneIndex);
        print(widget.post!.user!.id!);
      }
    });
    //
    bottomsheetPrestazioneList = List.generate(
      prestazioneProvider.prestazioneList.length,
      (index){
        return Account(
          title: prestazioneProvider.prestazioneList[index].title,
          datetime: !prestazioneProvider.prestazioneList[index].is_price_range ? '€ ${NumberFormat.currency(
            // customPattern: '#,##',
              decimalDigits: 2,
              symbol: '',
              locale: 'IT_it'
          ).format(prestazioneProvider.prestazioneList[index].price)}' : 'da € ${NumberFormat.currency(
            // customPattern: '#,##',
              decimalDigits: 2,
              symbol: '',
              locale: 'IT_it'
          ).format(prestazioneProvider.prestazioneList[index].price_min)}\na € ${NumberFormat.currency(
            // customPattern: '#,##',
              decimalDigits: 2,
              symbol: '',
              locale: 'IT_it'
          ).format(prestazioneProvider.prestazioneList[index].price_max)}',
          // datetime: DateFormat.yMMMMd('it_IT').format(DateTime.tryParse(allEntities[index]['begin_at'])).toString()
          //     + ' alle ' + DateTime.tryParse(allEntities[index]['begin_at']).toString().substring(11, 16),
          subtitle: "${prestazioneProvider.prestazioneList[index].duration} min",
          accountImageWidget: FutureImage(
            prestazioneProvider.prestazioneList[index].image != null
              ? prestazioneProvider.prestazioneList[index].image!
              : prestazioneProvider.prestazioneList[index].business!.profile_image!,
            width: 200,
          ),
        );
      },
      // growable: false
    );

    for(Booking obj in socketProvider.myAppointments) {
      if(obj.begin_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).isBefore(DateTime.now().add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))){
        tempAppointments.add(obj);
      }
    }

    tempAppointments.sort((b, a) {
      return a.begin_at!.compareTo(b.begin_at!);
    });

    // print(socketProvider.myAppointments.length);
    // print(tempAppointments.length);

    bottomsheetPrenotazioneList = List.generate(
      tempAppointments.length,
      (index){
        return Account(
          // title: "@${tempAppointments[index].user.username}",
          title: "${tempAppointments[index].user.name}",
          // datetime: ,
          datetime: DateFormat.yMMMMd('it_IT').format(tempAppointments[index].begin_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))).toString()
              + ' alle ' + tempAppointments[index].begin_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
          subtitle: "${tempAppointments[index].prestazione!.title}",
          accountImageWidget: FutureImage(
            tempAppointments[index].user.profile_image,
            width: 200,
          ),
        );
      }
    );

  }

  @override
  Widget build(BuildContext context) {
    postProvider = Provider.of<PostProvider>(context, listen: true);
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);
    prestazioneProvider = Provider.of<PrestazioneProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);

    return Scaffold(
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
        title: Text(
          widget.isNewPost! ? 'Inserimento post' : 'Modifica post',
          style: TextStyle(
              color: Colors.blue,
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
                  if(!widget.isNewPost! /*&& _priceController.text != '' && _durationController.text != ''*/) {
                    setState(() {
                      isSaved = true;
                    });

                    print('userSelectedId');
                    print(userSelectedId);

                    http.StreamedResponse response = await postProvider.updatePost(
                        postId: widget.post!.id!,
                        businessId: businessProvider.business!.id!,
                        // user: userOrderList[userSelectedId],
                        user: userSelectedId != -1
                          ? userOrderList[userSelectedId]
                          : widget.post!.user,
                        // // prestazione: prestazioneSelectedId == -1 ? Prestazione() : prestazioneProvider.prestazioneList[prestazioneSelectedId],
                        prestazione: prestazioneSelectedId != -1
                          ? prestazioneProvider.prestazioneList[prestazioneSelectedId]
                          // : bottomsheetPrestazioneList[prestazioneSelectedId],
                          : widget.post!.prestazione,
                        // booking: prenotazioneSelectedId == -1
                        //   ? widget.post!.booking
                        //   : tempAppointments[prenotazioneSelectedId],
                        // title: _titleController.text,
                        description: _descriptionController.text,
                        // duration: _durationController.text,
                        // price: _priceController.text.replaceAll(',', '.'),
                        image: widget.post!.image_url!,
                        uploadImage: _image,
                        /*NumberFormat.currency(
                          // customPattern: '#,##',
                        decimalDigits: 2,
                          locale: 'IT_it').format(double.tryParse(_priceController.text)),*/
                        context: this.context
                    );
                    if(response.statusCode >= 200 && response.statusCode < 400){
                      Navigator.pop(context);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          'Post aggiornato',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Colors.green,
                      ));
                    }
                    else {
                      setState(() {
                        isSaved = false;
                      });
                    }
                  }
                  else if(widget.isNewPost! /*&& _priceController.text != '' && _durationController.text != ''*/) {
                    // print('widget.isNewPost!');

                    // if(_image != null){
                    //   setState(() {
                    //     isSaved = true;
                    //   });
                    /*}
                    else*/ if(_image == null) {
                      Fluttertoast.showToast(
                        msg: 'Scegli un immagine',
                        backgroundColor: Colors.grey[800],
                      );
                    }
                    else {
                      setState(() {
                        isSaved = true;
                      });
                      int statusCode = await postProvider.createPost(
                          // title: _titleController.text,
                          // businessId: widget.eventBusiness.id,
                          user: userSelectedId == -1
                              ? User(profile_image: '')
                              : userOrderList[userSelectedId],
                          // user: tempAppointments[prenotazioneSelectedId].user,
                          prestazione: prestazioneSelectedId == -1
                              ? Prestazione(is_price_range: false)
                              : prestazioneProvider.prestazioneList[prestazioneSelectedId],
                          // prestazione: prenotazioneSelectedId == -1 ? Prestazione() : tempAppointments[prenotazioneSelectedId].prestazione,
                          businessId: businessProvider.business!.id!,
                          // booking: widget.post!.booking,
                          // booking: /*prenotazioneSelectedId == -1
                          //   ? widget.post!.booking
                          //   : */tempAppointments[prenotazioneSelectedId],
                          description: _descriptionController.text,
                          // duration: _durationController.text,
                          // price: _priceController.text,
                          uploadImage: _image,
                          /*NumberFormat.currency(
                          // customPattern: '#,##',
                          decimalDigits: 2,
                          locale: 'IT_it').format(double.tryParse(_priceController.text)),*/
                          context: this.context
                      );

                      // print(statusCode);

                      // Navigator.pop(context);
                      if (statusCode == 200) {
                        // Navigator.pop(context);
                        Get.offAll(() => const HomeScreen());

                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                            'Post inserito',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: Colors.green,
                        ));
                        // print('prestazioneProvider.prestazioneList');
                        // for(var e in postProvider.postList){
                        // print(e);
                        // }
                      }
                      else {
                        setState(() {
                          isSaved = false;
                        });
                      }
                    }
                  }
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
                      "Immagine del post",
                      // "Immagine di copertina",
                      // 'Immagini',
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
                      child: isSelectedImage == false && widget.post!.image_url != null && widget.post!.image_url != '' ? FutureImage(
                        widget.post!.image_url!,
                        // colorBlendMode: BlendMode.darken,
                        // colorBlendMode: BlendMode.hardLight,
                        // width: 45,
                        // height: 45,
                        // filterQuality: FilterQuality.high,
                        // placeholder: (context, url) => Center(
                        //     child: CircularProgressIndicator()
                        // ),

                        // width: 110,
                        // height: 100,
                        width: MediaQuery.of(context).size.width/3,
                        // margin: EdgeInsets.all(5),
                      ) : isSelectedImage == true ? Image.file(_image!) : Container(
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
          // Column(
          //   children: [
          //     EventImagesWidget(
          //       text: "Immagini dell'evento",
          //       // numImages: 5,
          //       images: [],
          //     ),
          //     Divider(
          //       color: Colors.grey[400],
          //       height: 1,
          //       // endIndent: 20,
          //       // indent: 20,
          //     ),
          //   ],
          // ),

          // Column(
          //   children: [
          //     Container(
          //       padding: const EdgeInsets.fromLTRB(15, 10, 10, 15),
          //       margin: EdgeInsets.all(0),
          //       // height: 58.0,
          //       color: Colors.white,
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Text(
          //             "Prenotazione",
          //             textAlign: TextAlign.center,
          //             style: TextStyle(
          //                 color: Colors.blue,
          //                 fontWeight: FontWeight.w600
          //             ),
          //           ),
          //           prenotazioneSelectedId == -1 && widget.isNewPost!/*widget.post!.prestazione == null*/ ? Container(
          //             width: MediaQuery.of(context).size.width * .48,
          //             // height: (businessProvider.business.bookingBusinessTimetable.length * 20 + (20)).toDouble(),
          //             padding: EdgeInsets.only(
          //                 right: 15,
          //                 left: 15
          //             ),
          //           ) : Container(
          //             width: MediaQuery.of(context).size.width * .48,
          //             // height: (businessProvider.business.bookingBusinessTimetable.length * 20 + (20)).toDouble(),
          //             padding: EdgeInsets.only(
          //                 right: 15,
          //                 left: 15,
          //                 top: 4
          //             ),
          //             // margin: EdgeInsets.only(left: 33),
          //             child: Row(
          //               children: [
          //                 Container(
          //                   height: 35,
          //                   width: 35,
          //                   child: Card(
          //                     semanticContainer: true,
          //                     clipBehavior: Clip.antiAliasWithSaveLayer,
          //                     elevation: 3,
          //                     shape: RoundedRectangleBorder(
          //                         borderRadius: BorderRadius.all(Radius.circular(5))
          //                     ),
          //                     // color: Colors.red,
          //                     // child: CircleAvatar(
          //                     child: FutureImage(
          //                       // widget.post!.prestazione!.image!,
          //                       !widget.isNewPost! && prenotazioneSelectedId == -1
          //                           ? widget.post!.user!.profile_image
          //                           : tempAppointments[prenotazioneSelectedId].user.profile_image,
          //                       width: MediaQuery.of(context).size.width,
          //                     ),
          //                   ),
          //                 ),
          //                 SizedBox(width: 5),
          //                 Column(
          //                   crossAxisAlignment: CrossAxisAlignment.start,
          //                   mainAxisAlignment: MainAxisAlignment.center,
          //                   children: [
          //                     // SizedBox(height: 5),
          //                     Container(
          //                       width: MediaQuery.of(context).size.width * .3,
          //                       child: Text(
          //                         // widget.post!.business!.name!,
          //                         // "@${tempAppointments[prenotazioneSelectedId].user.username}",
          //                         // "${tempAppointments[prenotazioneSelectedId].user.name}",
          //                         !widget.isNewPost! && prenotazioneSelectedId == -1 && widget.post!.user!.name != null
          //                           ? widget.post!.user!.name!
          //                           : !widget.isNewPost! && prenotazioneSelectedId == -1 && widget.post!.user!.name == null
          //                             ? widget.post!.user!.username!
          //                           : "${tempAppointments[prenotazioneSelectedId].user.name}",
          //                         maxLines: 1,
          //                         overflow: TextOverflow.ellipsis,
          //                         style: TextStyle(
          //                             color: Colors.grey[800],
          //                             fontWeight: FontWeight.w600,
          //                             fontSize: 12.5
          //                         ),
          //                         // textAlign: TextAlign.left,
          //                         // gradient: LinearGradient(
          //                         //     begin: Alignment.bottomLeft,
          //                         //     end: Alignment.topRight,
          //                         //     colors: [
          //                         //       Color(0xff8921aa),
          //                         //       Color(0xffDA44bb),
          //                         //       // Color(0xffDA44bb)
          //                         //     ]
          //                         // ),
          //                       ),
          //                     ),
          //                     SizedBox(height: 1.5,),
          //                     Container(
          //                       width: MediaQuery.of(context).size.width * .3,
          //                       child: Marquee(
          //                         child: GradientText(
          //                           // widget.post!.prestazione!.title!,
          //                           // tempAppointments[prenotazioneSelectedId].prestazione!.title!,
          //                           !widget.isNewPost! && prenotazioneSelectedId == -1
          //                             ? widget.post!.prestazione!.title!
          //                             : "${tempAppointments[prenotazioneSelectedId].prestazione!.title!}",
          //                           style: TextStyle(
          //                               color: Colors.blue,
          //                               fontWeight: FontWeight.w600,
          //                               fontSize: 14.5
          //                           ),
          //                           maxLines: 1,
          //                           overflow: TextOverflow.ellipsis,
          //                           // textAlign: TextAlign.left,
          //                           gradient: LinearGradient(
          //                               begin: Alignment.bottomLeft,
          //                               end: Alignment.topRight,
          //                               colors: [
          //                                 Color(0xff8921aa),
          //                                 Color(0xffDA44bb),
          //                                 // Colors.grey[900]!,
          //                                 // Colors.grey[900]!,
          //                               ]
          //                           ),
          //                         ),
          //                       ),
          //                     ),
          //                     SizedBox(height: 1.5,),
          //                     Container(
          //                       width: MediaQuery.of(context).size.width * .3,
          //                       child: Text(
          //                         // timeAgo.format(
          //                         //   tempAppointments[prenotazioneSelectedId].created_at!,
          //                         //   locale: 'it'
          //                         // )
          //                         !widget.isNewPost! && prenotazioneSelectedId == -1
          //                           ? timeAgo.format(
          //                             widget.post!.created_at!, //metter l orario del booking
          //                             locale: 'it'
          //                           ) : timeAgo.format(
          //                             tempAppointments[prenotazioneSelectedId].created_at!,
          //                             locale: 'it'
          //                         ),
          //                         maxLines: 1,
          //                         overflow: TextOverflow.ellipsis,
          //                         style: TextStyle(
          //                             color: Colors.grey[600],
          //                             fontWeight: FontWeight.w600,
          //                             fontSize: 12
          //                         ),
          //                         // textAlign: TextAlign.left,
          //                         // gradient: LinearGradient(
          //                         //     begin: Alignment.bottomLeft,
          //                         //     end: Alignment.topRight,
          //                         //     colors: [
          //                         //       Color(0xff8921aa),
          //                         //       Color(0xffDA44bb),
          //                         //       // Color(0xffDA44bb)
          //                         //     ]
          //                         // ),
          //                       ),
          //                     ),
          //                   ],
          //                 ),
          //               ],
          //             ),
          //           ),
          //           TextButton(
          //               onPressed: () async {
          //                 showAccountSelectorSheet(
          //                   context: context,
          //                   accountList: bottomsheetPrenotazioneList,
          //                   isSheetDismissible: true, //Optional
          //                   // initiallySelectedIndex: 2, //Optional
          //                   initiallySelectedIndex: prenotazioneSelectedId, //Optional
          //                   hideSheetOnItemTap: false, //Optional
          //                   // addAccountTitle: "Add User", //Optional
          //                   // showAddAccountOption: true, //Optional
          //                   // backgroundColor: Colors.blue[700], //Optional
          //                   backgroundColor: Colors.white, //Optional
          //                   // arrowColor: Colors.white, //Optional
          //                   arrowColor: Colors.grey, //Optional
          //                   // unselectedRadioColor: Colors.white, //Optional
          //                   unselectedRadioColor: Colors.grey, //Optional
          //                   // selectedRadioColor: Colors.amber, //Optional
          //                   selectedRadioColor: Colors.blue, //Optional
          //                   // unselectedTextColor: Colors.white, //Optional
          //                   unselectedTextColor: Colors.grey[900], //Optional
          //                   // selectedTextColor: Colors.amber, //Optional
          //                   unselectedSubtitleColor: Colors.grey[700],
          //                   unselectedDatetimeColor: Colors.green[600],
          //                   selectedTextColor: Colors.blue, //Optional
          //                   //Optional
          //                   tapCallback: (index) {
          //                     setState(() {
          //                       // resultText = "selected account is : ${not[index].title}";
          //                       prenotazioneSelectedId = index;
          //                     });
          //                     // print(resultText);
          //                   },
          //                   //Optional
          //                   addAccountTapCallback: () {
          //                     // setState(() {
          //                     //   resultText = "Add account clicked";
          //                     // });
          //                     // print(resultText);
          //                   },
          //                 );
          //               },
          //               child: const Text(
          //                 "Seleziona",
          //                 style: TextStyle(
          //                     color: Colors.blue
          //                 ),
          //               )
          //           )
          //           // SizedBox()
          //         ],
          //       ),
          //     ),
          //     Divider(
          //       color: Colors.grey[400],
          //       height: 1,
          //       // endIndent: 15,
          //       // indent: 15,
          //     ),
          //   ],
          // ),

          Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(15, 0, 10, 5),
                margin: EdgeInsets.all(0),
                // height: 58.0,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Prestazione",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.blue[500],
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    prestazioneSelectedId == -1/*widget.post!.prestazione == null*/ ? Container(
                      width: MediaQuery.of(context).size.width * .48,
                      // height: (businessProvider.business.bookingBusinessTimetable.length * 20 + (20)).toDouble(),
                      padding: EdgeInsets.only(
                          right: 15,
                          left: 15
                      ),
                    ) : Container(
                      width: MediaQuery.of(context).size.width * .48,
                      // height: (businessProvider.business.bookingBusinessTimetable.length * 20 + (20)).toDouble(),
                      padding: EdgeInsets.only(
                          right: 15,
                          left: 15,
                          top: 4
                      ),
                      // margin: EdgeInsets.only(left: 33),
                      child: Row(
                        children: [
                          Container(
                            height: 35,
                            width: 35,
                            child: Card(
                              semanticContainer: true,
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              // color: Colors.red,
                              // child: CircleAvatar(
                              child: FutureImage(
                                // widget.post!.prestazione!.image!,
                                prestazioneProvider.prestazioneList[prestazioneSelectedId].image != null
                                    ? prestazioneProvider.prestazioneList[prestazioneSelectedId].image!
                                    : prestazioneProvider.prestazioneList[prestazioneSelectedId].business!.profile_image!,
                                width: MediaQuery.of(context).size.width,
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // SizedBox(height: 5),
                              Container(
                                width: MediaQuery.of(context).size.width * .3,
                                child: Marquee(
                                  child: GradientText(
                                    // widget.post!.prestazione!.title!,
                                    prestazioneProvider.prestazioneList[prestazioneSelectedId].title!,
                                    style: TextStyle(
                                        color: Colors.blue[500],
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13.5
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    // textAlign: TextAlign.left,
                                    gradient: LinearGradient(
                                        begin: Alignment.bottomLeft,
                                        end: Alignment.topRight,
                                        colors: [
                                          // Color(0xff8921aa),
                                          // Color(0xffDA44bb),
                                          Colors.grey[900]!,
                                          Colors.grey[900]!,
                                        ]
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 0.5,),
                              Container(
                                width: MediaQuery.of(context).size.width * .3,
                                child: Text(
                                 // widget.post!.business!.name!,
                                  prestazioneProvider.prestazioneList[prestazioneSelectedId].duration.toString() + ' min',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.5
                                  ),
                                  // textAlign: TextAlign.left,
                                  // gradient: LinearGradient(
                                  //     begin: Alignment.bottomLeft,
                                  //     end: Alignment.topRight,
                                  //     colors: [
                                  //       Color(0xff8921aa),
                                  //       Color(0xffDA44bb),
                                  //       // Color(0xffDA44bb)
                                  //     ]
                                  // ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                        onPressed: () async {
                          showAccountSelectorSheet(
                            context: context,
                            accountList: bottomsheetPrestazioneList,
                            isSheetDismissible: true, //Optional
                            // initiallySelectedIndex: 2, //Optional
                            initiallySelectedIndex: prestazioneSelectedId, //Optional
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
                            unselectedSubtitleColor: Colors.grey[700],
                            unselectedDatetimeColor: Colors.green[600],
                            selectedTextColor: Colors.blue[500]!, //Optional
                            //Optional
                            tapCallback: (index) {
                              setState(() {
                                resultText = "selected account is : ${bottomsheetPrestazioneList[index].title}";
                                prestazioneSelectedId = index;
                              });
                              // print(resultText);
                            },
                            //Optional
                            addAccountTapCallback: () {
                              setState(() {
                                resultText = "Add account clicked";
                              });
                              // print(resultText);
                            },
                          );
                        },
                        child: const Text(
                          "Seleziona",
                          style: TextStyle(
                              color: Colors.blue
                          ),
                        )
                    )
                    // SizedBox()
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
                padding: const EdgeInsets.fromLTRB(15, 0, 10, 5),
                margin: EdgeInsets.all(0),
                // height: 58.0,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Utente",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.blue[500],
                          fontWeight: FontWeight.w600
                      ),
                    ),

                    FutureBuilder(
                      // future: Future.wait([a]),
                      future: a,
                      builder: (context, snapshot) {
                        if(snapshot.connectionState == ConnectionState.done){
                          return userSelectedId == -1/*widget.post!.user == null*/ ? Container(
                            width: MediaQuery.of(context).size.width * .48,
                            // height: (businessProvider.business.bookingBusinessTimetable.length * 20 + (20)).toDouble(),
                            padding: EdgeInsets.only(
                                right: 15,
                                left: 15
                            ),
                          ) : Container(
                            width: MediaQuery.of(context).size.width * .48,
                            // height: (businessProvider.business.bookingBusinessTimetable.length * 20 + (20)).toDouble(),
                            padding: EdgeInsets.only(
                                right: 15,
                                left: 15,
                                top: 4
                            ),
                            // margin: EdgeInsets.only(left: 33),
                            child: Row(
                              children: [
                                Container(
                                  height: 35,
                                  width: 35,
                                  child: userOrderList[userSelectedId].profile_image != '' ? Card(
                                    semanticContainer: true,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(20))
                                    ),
                                    // color: Colors.red,
                                    // child: CircleAvatar(
                                    child: userOrderList[userSelectedId].profile_image != '' ? FutureImage(
                                      // widget.post!.user!.profile_image!,
                                      userOrderList[userSelectedId].profile_image,
                                      width: MediaQuery.of(context).size.width,
                                    ) : Icon(
                                      Icons.account_circle_rounded,
                                      color: Colors.grey[300],
                                      size: 35,
                                    ),
                                  ) : Icon(
                                    Icons.account_circle_rounded,
                                    color: Colors.grey[300],
                                    size: 35,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // SizedBox(height: 5),
                                    Container(
                                      width: MediaQuery.of(context).size.width * .3,
                                      child: Marquee(
                                        child: GradientText(
                                          // widget.post!.user!.name!,
                                          userOrderList[userSelectedId].name != null ? userOrderList[userSelectedId].name! : '',
                                          style: TextStyle(
                                              color: Colors.blue[500],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13.5
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          // textAlign: TextAlign.left,
                                          gradient: LinearGradient(
                                              begin: Alignment.bottomLeft,
                                              end: Alignment.topRight,
                                              colors: [
                                                // Color(0xff8921aa),
                                                // Color(0xffDA44bb),
                                                Colors.grey[900]!,
                                                Colors.grey[900]!,
                                              ]
                                          ),
                                        ),
                                      ),
                                    ),
                                    // SizedBox(height: 0.5,),
                                    // Container(
                                    //   width: MediaQuery.of(context).size.width * .3,
                                    //   child: Text(
                                    //     // '@' + widget.post!.user!.username!,
                                    //     '@' + userOrderList[userSelectedId].username!,
                                    //     maxLines: 1,
                                    //     overflow: TextOverflow.ellipsis,
                                    //     style: TextStyle(
                                    //         color: Colors.grey[600],
                                    //         fontWeight: FontWeight.w600,
                                    //         fontSize: 12.5
                                    //     ),
                                    //     // textAlign: TextAlign.left,
                                    //     // gradient: LinearGradient(
                                    //     //     begin: Alignment.bottomLeft,
                                    //     //     end: Alignment.topRight,
                                    //     //     colors: [
                                    //     //       Color(0xff8921aa),
                                    //     //       Color(0xffDA44bb),
                                    //     //       // Color(0xffDA44bb)
                                    //     //     ]
                                    //     // ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }
                        else {
                          return SizedBox();
                        }
                      }
                    ),
                    TextButton(
                        onPressed: () async {
                          showAccountSelectorSheet(
                            context: context,
                            accountList: bottomsheetUserList,
                            isSheetDismissible: true, //Optional
                            // initiallySelectedIndex: 2, //Optional
                            initiallySelectedIndex: userSelectedId, //Optional
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
                            unselectedSubtitleColor: Colors.grey[700],
                            unselectedDatetimeColor: Colors.green[600],
                            selectedTextColor: Colors.blue[500]!, //Optional
                            //Optional
                            tapCallback: (index) {
                              setState(() {
                                resultText = "selected account is : ${bottomsheetUserList[index].title}";
                                userSelectedId = index;
                              });
                              // print(resultText);
                            },
                            //Optional
                            addAccountTapCallback: () {
                              setState(() {
                                resultText = "Add account clicked";
                              });
                              // print(resultText);
                            },
                          );
                        },
                        child: const Text(
                          "Seleziona",
                          style: TextStyle(
                              color: Colors.blue
                          ),
                        )
                    )
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
                      'Descrizione',
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
                        controller: _descriptionController,
                        clearButtonMode: _descriptionController.text != ''
                            ? OverlayVisibilityMode.always
                            : OverlayVisibilityMode.never,
                        enabled: true,

                        decoration: BoxDecoration(color: Colors.white),
                        textAlign: /*row.textAlign ??*/ TextAlign.left,
                        placeholder: /*row.placeholder ??*/ "Inserire la descrizione",
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
                          if(_descriptionController.text == ''){
                            setState(() {
                              editableDescription = false;
                            });
                          }
                          else{
                            setState(() {
                              editableDescription = true;
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

          Visibility(
            visible: !widget.isNewPost!,
            child: Container(
              // height: MediaQuery.of(context).size.width * 0.1,
              // width: MediaQuery.of(context).size.width * 0.4,
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.2,
                  right: MediaQuery.of(context).size.width * 0.2,
                  top: 45,
                  bottom: 35
              ),
              child: ElevatedButton(
              // child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.red[500],
                      // backgroundColor: Colors.white,
                      // minimumSize: Size(50, 30),
                      alignment: Alignment.center
                  ),
                  onPressed: () async {
                    _showDeletingDialog(
                        "Premere su 'Cancella' se si vuole cancellare definitivamente la prestazione"
                    );
                  },
                  child: Text(
                    'Cancella',
                    style: TextStyle(
                      // color: Colors.blue[500],
                      // color: Colors.red[500],
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  )
              ),
            ),
          )
        ],
      ),

    );
  }
}
