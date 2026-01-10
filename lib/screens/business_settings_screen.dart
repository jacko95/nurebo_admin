import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:mime/mime.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/prestazione_provider.dart';
import 'package:nurebo_admin/screens/timetable_settings_screen.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:nurebo_admin/widgets/image_cache_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:http_parser/src/media_type.dart';


class BusinessSettingsScreen extends StatefulWidget {

  const BusinessSettingsScreen({Key? key});

  @override
  _BusinessSettingsScreenState createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  bool? editableName;
  bool? editableEmail;
  bool? editableLimit;
  bool? editablePhone;
  bool? editableDescription;
  File _image = File('');
  final picker = ImagePicker();
  bool isSelectedImage = false;
  late BusinessProvider businessProvider;
  PrestazioneProvider? prestazioneProvider;
  // List? bookingBusinessTimetable = [];
  late NumberFormat formatter;
  ImageCacheBusiness cacheBusiness = ImageCacheBusiness();
  bool isSaved = false;


  // Future getDateBusinessTimetable() async {
  //   // var url = Uri.parse(Utils.httpServerUrl + "timetable/business");
  //   var url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}/timetable");
  //
  //   Map/*<String, String>*/ body = {
  //     'business_id': businessProvider.business!.id,
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
  //       }
  //   );
  //
  //   print('response.statusCode');
  //   print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     setState(() {
  //       bookingBusinessTimetable = jsonData;
  //     });
  //
  //     print('bookingBusinessTimetable0');
  //     print(bookingBusinessTimetable);
  //
  //     // bookingBusinessTimetable.sort((a, b) {
  //     //   if(a['weekday_id'] == b['weekday_id']) {
  //     //     if(int.tryParse(a['open_at_hour']) == int.tryParse(b['open_at_hour'])) {
  //     //       return int.tryParse(a['close_at_hour']).compareTo(int.tryParse(b['close_at_hour']));
  //     //     }
  //     //     return int.tryParse(a['open_at_hour']).compareTo(int.tryParse(b['open_at_hour']));
  //     //   }
  //     //   return a['weekday_id'].compareTo(b['weekday_id']);
  //     // });
  //     bookingBusinessTimetable!.sort((a, b) {
  //       if(a['weekday_id'] == b['weekday_id']) {
  //         if(int.tryParse(a['open_at_hour']) == int.tryParse(b['open_at_hour'])) {
  //           if(int.tryParse(a['open_at_minute']) == int.tryParse(b['open_at_minute'])) {
  //             if(int.tryParse(a['close_at_hour']) == int.tryParse(b['close_at_hour'])) {
  //               return int.tryParse(a['close_at_minute'])!.compareTo(int.tryParse(b['close_at_minute'])!);
  //             }
  //             return int.tryParse(a['close_at_hour'])!.compareTo(int.tryParse(b['close_at_hour'])!);
  //           }
  //           return int.tryParse(a['open_at_minute'])!.compareTo(int.tryParse(b['open_at_minute'])!);
  //         }
  //         return int.tryParse(a['open_at_hour'])!.compareTo(int.tryParse(b['open_at_hour'])!);
  //       }
  //       return a['weekday_id'].compareTo(b['weekday_id']);
  //     });
  //
  //     print('bookingBusinessTimetable1');
  //     print(bookingBusinessTimetable);
  //
  //     return jsonData;
  //   }
  // }

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

  Future updateBusiness1(/*XFile _image*/) async {
    cacheBusiness.removeImageFromCache('${Utils.httpServerUrl}image?path=${businessProvider.business!.profile_image}');

    // XFile _image = await choiceImage();

    String imageName = _image.path.split('/').last;
    // List<int> imageBytes = File(filePath.path).readAsBytesSync();

    var request = http.MultipartRequest(
        'PUT',
        Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}")
    );

    String imageMimeType = lookupMimeType(_image.path)!;
    // print('imageMimeType');
    // print(imageMimeType);

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        // imageFilePath,
        _image.path,
        filename: '${imageName.split('image_picker').last}',
        // contentType: new MediaType('image', 'jpeg')
        // contentType: new MediaType('image', 'png')
        contentType: MediaType(
          imageMimeType.split('/').first,
          imageMimeType.split('/').last
        )
      )
    );

    // request.files.add(
    //   http.MultipartFile.fromBytes(
    //     'image',
    //     _imageFile.readAsBytesSync(),
    //     filename: '$imageName',
    //     // contentType: new MediaType('image', 'jpeg')
    //     contentType: new MediaType('image', 'png')
    //     // contentType: new MediaType('image', 'jpg')
    //   )
    // );

    // http.MultipartFile.fromString(
    //   'image',
    //   _imageFile.path,
    //   filename: '$imageName',
    // );

    request.headers.addAll({
      'Accept': '*/*',
      'Content-Type': 'multipart/form-data',
      'Accept-encoding': 'gzip, deflate',
      HttpHeaders.authorizationHeader: BusinessPreferences.getBusinessToken()!,
    });
    // request.headers['Content-Type'] = 'multipart/form-data';
    // request.headers['Accept'] = '*/*';
    // request.headers['Accept-encoding'] = 'gzip, deflate';
    // request.fields['file'] = name;

    request.fields['business_id'] = businessProvider.business!.id!;
    request.fields['name'] = _nameController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['phone'] = _phoneController.text;
    request.fields['email'] = _emailController.text;
    request.fields['max_contemporary_appointments'] = /*_limitController.text.contains('.')
        ? int.tryParse(_limitController.text.split('.')[0]).toString()
        : _limitController.text.contains(',') ? int.tryParse(_limitController.text.split(',')[0]).toString()
        : */int.tryParse(_limitController.text).toString();

    http.StreamedResponse res = await request.send();

    if(res.statusCode == 200){
      var jsonData = jsonDecode(await res.stream.transform(utf8.decoder).join());
      // print('resfv5vc5cb5');
      // print(jsonData);
      // business!.profile_image = 'http://192.168.1.225/nurebo-server/posts/${imageName.split('image_picker').last}';

      businessProvider.setDescription(_descriptionController.text);
      businessProvider.setEmail(_emailController.text);
      businessProvider.setName(_nameController.text);
      businessProvider.setphone(_phoneController.text);
      businessProvider.setMaxContemporaryAppointments(
        /*_limitController.text.contains('.') ? int.tryParse(_limitController.text.split('.')[0])
        : _limitController.text.contains(',') ? int.tryParse(_limitController.text.split(',')[0])
        :*/ int.tryParse(_limitController.text)
      );
      businessProvider.setProfileImage(jsonData['image']);

      await cacheBusiness.addImageToCache('${Utils.httpServerUrl}image?path=${jsonData['image']}');
      // for (var element in cacheBusiness.imageCache.keys) {print(element);}

      // Navigator.pop(context);

      Fluttertoast.showToast(
        msg: 'Immagine Profilo aggiornata',
        backgroundColor: Colors.grey[700],
      );
    }

    return res.statusCode;
  }

  Future updateBusiness() async {
    // var url = Uri.parse(Utils.httpServerUrl + "business");
    var url = Uri.parse("${Utils.httpServerUrl}business/${businessProvider.business!.id}");

    Map/*<String, String>*/ body = {
      'name': _nameController.text,
      'business_id': businessProvider.business!.id,
      // 'address': businessProvider.business.address,
      'description': _descriptionController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'max_contemporary_appointments': int.tryParse(_limitController.text),
    };

    var response = await http.put(
        url,
        body: jsonEncode(body),
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

    // print('response.business update');
    // print(response.statusCode);

    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      businessProvider.setDescription(_descriptionController.text);
      businessProvider.setEmail(_emailController.text);
      businessProvider.setName(_nameController.text);
      businessProvider.setphone(_phoneController.text);
      businessProvider.setMaxContemporaryAppointments(int.tryParse(_limitController.text));

      // return jsonData;
      return response.statusCode;
    }
    return response.statusCode;
  }

  @override
  void initState() {
    super.initState();
    prestazioneProvider = Provider.of<PrestazioneProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    initializeDateFormatting();
    formatter = NumberFormat("00");

    if(businessProvider.business!.name != null)
      _nameController.text = businessProvider.business!.name!;
    if(businessProvider.business!.address != null)
      _addressController.text = businessProvider.business!.address!;
    if(businessProvider.business!.description != null)
      _descriptionController.text = businessProvider.business!.description!;
    if(businessProvider.business!.phone != null)
      _phoneController.text = businessProvider.business!.phone.toString();
    if(businessProvider.business!.email != null)
      _emailController.text = businessProvider.business!.email!;
    if(businessProvider.business!.max_contemporary_appointments != null)
      _limitController.text = businessProvider.business!.max_contemporary_appointments.toString();

    // Future.wait([
    //   getDateBusinessTimetable(),
    // ]);
  }

  @override
  Widget build(BuildContext context) {
    prestazioneProvider = Provider.of<PrestazioneProvider>(context, listen: true);
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);

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
          child: isSaved ? Transform.scale(scale: 0.6, child: const CircularProgressIndicator(color: Colors.white),) : Text(
            "Salva",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700
            ),
          ),
          onPressed: () async {
            setState(() {
              isSaved = true;
            });

            int res;
            if(_image.path == ''){
              // print('65dgvb5bc56');
              res = await updateBusiness();
            }
            else{
              // print('c5cvv5v5');
              res = await updateBusiness1();
              Navigator.pop(context);
            }

            if(res == 200){
              Navigator.pop(context);
              // Fluttertoast.showToast(
              //   msg: 'Modifiche applicate',
              //   backgroundColor: Colors.grey[700],
              // );
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Profilo aggiornato',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.green,
              ));
            }
            else{
              Navigator.pop(context);
              Fluttertoast.showToast(
                msg: 'Errore',
                backgroundColor: Colors.grey[700],

              );
            }
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
        centerTitle: true,
        elevation: 0,
        // foregroundColor: Colors.blue,
        backgroundColor: Colors.white,
        // centerTitle: true,
        // title: Text(
        //   // 'I miei dati',
        //   // 'Business',
        //   // 'Info',
        //   'Informazioni',
        //   style: TextStyle(
        //       color: Colors.blue,
        //       // color: Colors.grey[800],
        //       fontWeight: FontWeight.w600,
        //       fontSize: 16
        //   ),
        // ),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.all(10.0),
          //   child: isSaved ? Transform.scale(scale: 0.8, child: const CircularProgressIndicator(),) : OutlinedButton(
          //       style: ButtonStyle(
          //         backgroundColor: MaterialStateProperty.all(Colors.white),
          //       ),
          //       onPressed: () async {
          //         setState(() {
          //           isSaved = true;
          //         });
          //
          //         int res;
          //         if(_image.path == ''){
          //           // print('65dgvb5bc56');
          //           res = await updateBusiness();
          //         }
          //         else{
          //           // print('c5cvv5v5');
          //           res = await updateBusiness1();
          //           Navigator.pop(context);
          //         }
          //
          //         if(res == 200){
          //           Navigator.pop(context);
          //           // Fluttertoast.showToast(
          //           //   msg: 'Modifiche applicate',
          //           //   backgroundColor: Colors.grey[700],
          //           // );
          //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          //             content: Text(
          //               'Profilo aggiornato',
          //               style: TextStyle(
          //                 fontWeight: FontWeight.w600,
          //                 color: Colors.white,
          //               ),
          //             ),
          //             backgroundColor: Colors.green,
          //           ));
          //         }
          //         else{
          //           Navigator.pop(context);
          //           Fluttertoast.showToast(
          //             msg: 'Errore',
          //             backgroundColor: Colors.grey[700],
          //
          //           );
          //         }
          //       },
          //       child: Text(
          //         'Salva',
          //         style: TextStyle(
          //             color: Colors.blue
          //         ),
          //       )
          //     // child: Icon(
          //     //   Icons.add,
          //     //   color: Colors.blue,
          //     // ),
          //   ),
          // )
        ],
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ListView(
          physics: ClampingScrollPhysics(),
          // padding: EdgeInsets.only(bottom: 15),
          children: [
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
                        'Nome',
                        style: TextStyle(
                          color: Colors.blue[500],
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      // Expanded(
                      //   child: CupertinoTextField(
                      //     // suffix: Icon(
                      //     //     Icons.keyboard_arrow_right
                      //     // ),
                      //     obscureText: false,
                      //     controller: _nameController,
                      //     clearButtonMode: _nameController.text != ''
                      //         ? OverlayVisibilityMode.always
                      //         : OverlayVisibilityMode.never,
                      //     enabled: true,
                      //     decoration: BoxDecoration(color: Colors.white),
                      //     textAlign: /*row.textAlign ??*/ TextAlign.left,
                      //     placeholder: /*row.placeholder ??*/ "Inserire il nome del locale",
                      //     placeholderStyle: TextStyle(
                      //         fontSize: 15,
                      //         color: CupertinoColors.placeholderText
                      //     ),
                      //     keyboardType: TextInputType.text,
                      //     // maxLength: 15,
                      //     style: TextStyle(
                      //         fontSize: 15,
                      //         color: Colors.grey[700],
                      //     ),
                      //     readOnly: false,
                      //     onChanged: (value) {
                      //       if(_nameController.text == ''){
                      //         setState(() {
                      //           editableName = false;
                      //         });
                      //       }
                      //       else{
                      //         setState(() {
                      //           editableName = true;
                      //         });
                      //       }
                      //     },
                      //   ),
                      // ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.71,
                        padding: EdgeInsets.only(left: 10),
                        child: Marquee(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _nameController.text,
                                style: GoogleFonts.roboto(
                                    color: CupertinoColors.label.withOpacity(0.775),
                                    fontWeight: FontWeight.w400
                                ),
                              ),
                            ],
                          ),
                        ),
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
                            "Immagine di copertina del locale",
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
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            // itemCount: (row.state as List).length,
                            // itemCount: widget.numImages,
                            // itemCount: widget.images.length,
                            itemCount: 1,
                            itemBuilder: (BuildContext context, int index) {
                              // _image = images[index];
                              // print(widget.images.length);
                              return InkWell(
                                onTap: () async {
                                  // print('ciao');
                                  await choiceImage();
                                  // print('_image.path');
                                  // print(_image.path);
                                  // return SelectImageView(
                                  //   selected: (image /*= FileImage().images[index]*/) async {
                                  //     // images[index];
                                  //     //实际情况是上传照片 返回图片URL，这里模拟数据使用路径
                                  //     // row.state[index]["picurl"] = image.path;
                                  //   },
                                  // );
                                },
                                child: isSelectedImage == false && businessProvider.business!.profile_image != null ? FutureImage(
                                  businessProvider.business!.profile_image!,
                                  // width: 100,
                                  width: MediaQuery.of(context).size.width,
                                  // height: 100,
                                  // height: MediaQuery.of(context).size.width/2,
                                ) : isSelectedImage == true ? Image.file(_image) : Container(
                                  // width: 110,
                                  width: MediaQuery.of(context).size.width,
                                  // height: 100,
                                  // margin: EdgeInsets.all(5),
                                  color: Colors.grey[200],
                                ),
                              );

                              // return SelectImageView(
                              //   selected: (image) async {
                              //     final response = await http.get(images[index]);
                              //     final documentDirectory = await getApplicationDocumentsDirectory();
                              //     final file = File(join(documentDirectory.path, images[index].toString().substring(15)));
                              //     file.writeAsBytesSync(response.bodyBytes);
                              //     image = file;
                              //     // Directory dir = await getApplicationDocumentsDirectory();
                              //     // String pathName = p.join(dir.path, filename);
                              //     // var myImageFile = File(pathName);
                              //     // images[index];
                              //     //实际情况是上传照片 返回图片URL，这里模拟数据使用路径
                              //     // row.state[index]["picurl"] = image.path;
                              //   },
                              // );
                            },
                          ),
                        ),
                        SizedBox(height: 15,),
                      ],
                    ),
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
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  margin: EdgeInsets.all(0),
                  height: 58.0,
                  color: Colors.white,
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Indirizzo',
                        style: TextStyle(
                            color: Colors.blue[500],
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      // Expanded(
                      //   child: CupertinoTextField(
                      //     // suffix: Icon(
                      //     //     Icons.keyboard_arrow_right
                      //     // ),
                      //     obscureText: false,
                      //     controller: _addressController,
                      //     clearButtonMode: /*_phoneNumberController.text != ''
                      //         ? OverlayVisibilityMode.always
                      //         : */OverlayVisibilityMode.never,
                      //     enabled: true,
                      //     decoration: BoxDecoration(color: Colors.white),
                      //     textAlign: /*row.textAlign ??*/ TextAlign.left,
                      //     placeholder: /*row.placeholder ??*/ "Inserire l'address del locale",
                      //     placeholderStyle: TextStyle(
                      //         fontSize: 15,
                      //         color: CupertinoColors.placeholderText
                      //     ),
                      //     // keyboardType: TextInputType.streetAddress,
                      //     // maxLength: 15,
                      //     style: TextStyle(
                      //       fontSize: 15,
                      //       color: Colors.grey[700],
                      //     ),
                      //     readOnly: true,
                      //     // onChanged: (value) {
                      //       // if(_phoneNumberController.text == ''){
                      //       //   setState(() {
                      //       //     editablePhone = false;
                      //       //   });
                      //       // }
                      //       // else{
                      //       //   setState(() {
                      //       //     editablePhone = true;
                      //       //   });
                      //       // }
                      //     // },
                      //   ),
                      // ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.71,
                        child: Marquee(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _addressController.text,
                                style: GoogleFonts.roboto(
                                    color: CupertinoColors.label.withOpacity(0.775),
                                  fontWeight: FontWeight.w400
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
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
                        'Email',
                        style: TextStyle(
                            color: Colors.blue[500],
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      // Expanded(
                      //   child: CupertinoTextField(
                      //     // suffix: Icon(
                      //     //     Icons.keyboard_arrow_right
                      //     // ),
                      //     obscureText: false,
                      //     controller: _emailController,
                      //     clearButtonMode: _emailController.text != ''
                      //         ? OverlayVisibilityMode.always
                      //         : OverlayVisibilityMode.never,
                      //     enabled: true,
                      //     decoration: BoxDecoration(color: Colors.white),
                      //     textAlign: /*row.textAlign ??*/ TextAlign.left,
                      //     placeholder: /*row.placeholder ??*/ "Inserire l'email",
                      //     placeholderStyle: TextStyle(
                      //         fontSize: 15,
                      //         color: CupertinoColors.placeholderText
                      //     ),
                      //     keyboardType: TextInputType.emailAddress,
                      //     // maxLength: 15,
                      //     style: TextStyle(
                      //       fontSize: 15,
                      //       color: Colors.grey[700],
                      //     ),
                      //     readOnly: false,
                      //     onChanged: (value) {
                      //       if(_emailController.text == ''){
                      //         setState(() {
                      //           editableEmail = false;
                      //         });
                      //       }
                      //       else{
                      //         setState(() {
                      //           editableEmail = true;
                      //         });
                      //       }
                      //     },
                      //   ),
                      // ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.71,
                        padding: EdgeInsets.only(left: 10),
                        child: Marquee(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _emailController.text,
                                style: GoogleFonts.roboto(
                                    color: CupertinoColors.label.withOpacity(0.775),
                                    fontWeight: FontWeight.w400
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
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
                        'Telefono',
                        style: TextStyle(
                            color: Colors.blue[500],
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      // Expanded(
                      //   child: CupertinoTextField(
                      //     // suffix: Icon(
                      //     //     Icons.keyboard_arrow_right
                      //     // ),
                      //     obscureText: false,
                      //     controller: _phoneNumberController,
                      //     clearButtonMode: _phoneNumberController.text != ''
                      //       ? OverlayVisibilityMode.always
                      //       : OverlayVisibilityMode.never,
                      //     enabled: true,
                      //     decoration: BoxDecoration(color: Colors.white),
                      //     textAlign: /*row.textAlign ??*/ TextAlign.left,
                      //     placeholder: /*row.placeholder ??*/ "Inserire il numero di telefono del locale",
                      //     placeholderStyle: TextStyle(
                      //         fontSize: 15,
                      //         color: CupertinoColors.placeholderText
                      //     ),
                      //     keyboardType: TextInputType.number,
                      //     // maxLength: 15,
                      //     style: TextStyle(
                      //       fontSize: 15,
                      //       color: Colors.grey[700],
                      //     ),
                      //     readOnly: false,
                      //     onChanged: (value) {
                      //       if(_phoneNumberController.text == ''){
                      //         setState(() {
                      //           editablePhone = false;
                      //         });
                      //       }
                      //       else{
                      //         setState(() {
                      //           editablePhone = true;
                      //         });
                      //       }
                      //     },
                      //   ),
                      // ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.71,
                        padding: EdgeInsets.only(left: 10),
                        child: Marquee(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                _phoneController.text,
                                style: GoogleFonts.roboto(
                                    color: CupertinoColors.label.withOpacity(0.775),
                                    fontWeight: FontWeight.w400
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
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
                        // 'Orari di Apertura',
                        'Orari',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.blue[500],
                            fontWeight: FontWeight.w600
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * .48,
                        height: (businessProvider.business!.bookingBusinessTimetable!.length * 20 + (20)).toDouble(),
                        padding: EdgeInsets.only(
                            right: 15,
                            left: 15
                        ),
                        margin: EdgeInsets.only(left: 33),
                        // color: Colors.red,
                        // clipBehavior: Clip.antiAliasWithSaveLayer,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ListView.separated(
                                separatorBuilder: (context, i) {
                                  return SizedBox(height: 4,);
                                },
                                shrinkWrap: true,
                                itemCount: businessProvider.business!.bookingBusinessTimetable!.length,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, i){
                                  if(businessProvider.business!.bookingBusinessTimetable![i]['weekday_id'] == 1){
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Lunedì ',
                                          style: TextStyle(
                                            // color: Colors.blue[500],
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13
                                          ),
                                        ),
                                        Text(
                                          '${formatter.format((int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24)}:${formatter.format(int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['open_at_minute']))} - ${formatter.format((int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24)}:${formatter.format(int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['close_at_minute']))}',
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  else if(businessProvider.business!.bookingBusinessTimetable![i]['weekday_id'] == 2){
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Martedì ',
                                          style: TextStyle(
                                            // color: Colors.blue[500],
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13
                                          ),
                                        ),
                                        Text(
                                          formatter.format((int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':' +
                                              formatter.format(int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['open_at_minute']))
                                              + ' - '
                                              + formatter.format((int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':'
                                              + formatter.format(int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['close_at_minute'])),
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  else if(businessProvider.business!.bookingBusinessTimetable![i]['weekday_id'] == 3){
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Mercoledì ',
                                          style: TextStyle(
                                            // color: Colors.blue[500],
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13
                                          ),
                                        ),
                                        Text(
                                          formatter.format((int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':' +
                                            formatter.format(int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['open_at_minute']))
                                            + ' - '
                                            + formatter.format((int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':'
                                            + formatter.format(int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['close_at_minute'])),
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  else if(businessProvider.business!.bookingBusinessTimetable![i]['weekday_id'] == 4){
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Giovedì ',
                                          style: TextStyle(
                                            // color: Colors.blue[500],
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13
                                          ),
                                        ),
                                        Text(
                                          formatter.format((int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':' +
                                              formatter.format(int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['open_at_minute']))
                                              + ' - '
                                              + formatter.format((int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':'
                                              + formatter.format(int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['close_at_minute'])),
                                          style: TextStyle(
                                            // color: Colors.blue[500],
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  else if(businessProvider.business!.bookingBusinessTimetable![i]['weekday_id'] == 5){
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Venerdì ',
                                          style: TextStyle(
                                            // color: Colors.blue[500],
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13
                                          ),
                                        ),
                                        Text(
                                          formatter.format((int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':' +
                                              formatter.format(int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['open_at_minute']))
                                              + ' - '
                                              + formatter.format((int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':'
                                              + formatter.format(int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['close_at_minute'])),
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  else if(businessProvider.business!.bookingBusinessTimetable![i]['weekday_id'] == 6){
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Sabato ',
                                          style: TextStyle(
                                            // color: Colors.blue[500],
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13
                                          ),
                                        ),
                                        Text(
                                          formatter.format((int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':' +
                                              formatter.format(int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['open_at_minute']))
                                              + ' - '
                                              + formatter.format((int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':'
                                              + formatter.format(int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['close_at_minute'])),
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  else if(businessProvider.business!.bookingBusinessTimetable![i]['weekday_id'] == 7){
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Domenica ',
                                          style: TextStyle(
                                            // color: Colors.blue[500],
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13
                                          ),
                                        ),
                                        Text(
                                          formatter.format((int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':' +
                                              formatter.format(int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['open_at_minute']))
                                              + ' - '
                                              + formatter.format((int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours) % 24) + ':'
                                              + formatter.format(int.tryParse(businessProvider.business!.bookingBusinessTimetable![i]['close_at_minute'])),
                                          style: TextStyle(
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 13
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  else return null;
                                }
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    duration: const Duration(milliseconds: 500),
                                    alignment: Alignment.center,
                                    type: PageTransitionType.fade,
                                    child: TimetableSettingsScreen()
                                )
                            );
                          },
                          child: Text(
                            "Modifica",
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

            Visibility(
              visible: businessProvider.business!.type_id == 1,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    margin: EdgeInsets.all(0),
                    height: 58.0,
                    color: Colors.white,
                    child: Row(
                      children: [
                        Text(
                          'Limite di\nAppuntamenti',
                          // textAlign: TextAlign.center,
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
                            controller: _limitController,
                            clearButtonMode: _limitController.text != ''
                                ? OverlayVisibilityMode.always
                                : OverlayVisibilityMode.never,
                            enabled: true,
                            decoration: BoxDecoration(color: Colors.white),
                            textAlign: /*row.textAlign ??*/ TextAlign.left,
                            placeholder: /*row.placeholder ??*/ "Limite di appuntamenti in contemporanea",
                            placeholderStyle: TextStyle(
                                fontSize: 15,
                                color: CupertinoColors.placeholderText
                            ),
                            keyboardType: TextInputType.number,
                            // maxLength: 15,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                            ),
                            readOnly: false,
                            onChanged: (value) {
                              if(_limitController.text == ''){
                                setState(() {
                                  editableLimit = false;
                                });
                              }
                              else{
                                setState(() {
                                  editableLimit = true;
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
                          placeholder: /*row.placeholder ??*/ "Inserire la descrizione dell'evento",
                          placeholderStyle: TextStyle(
                              fontSize: 15,
                              color: CupertinoColors.placeholderText
                          ),
                          keyboardType: TextInputType.text,
                          minLines: 1,
                          maxLines: 80,
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
                  // endIndent: 15,
                  // indent: 15,
                ),
              ],
            ),

            SizedBox(height: 100,)
          ],
        ),
      ),

    );
  }
}
