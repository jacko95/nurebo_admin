import 'dart:convert';
import 'dart:math';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_cache_business/flutter_cache_business.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo_admin/main.dart';
import 'package:nurebo_admin/models/post.dart';
import 'package:nurebo_admin/models/prestazione.dart';
import 'package:nurebo_admin/models/user.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/post_provider.dart';
import 'package:nurebo_admin/provider/prestazione_provider.dart';
import 'package:nurebo_admin/provider/vetrina_provider.dart';
import 'package:nurebo_admin/screens/post_edit_screen.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/account.dart';
import 'package:nurebo_admin/widgets/account_selector.dart';
import 'package:nurebo_admin/widgets/custom_dialog.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:nurebo_admin/widgets/popover.dart';
import 'package:page_transition/page_transition.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class VetrinaListScreen extends StatefulWidget {
  // final SingleEventReservation ticket;
  // final User? user;

  VetrinaListScreen({Key? key,/* this.user*/});

  @override
  _VetrinaListScreenState createState() => _VetrinaListScreenState();
}

class _VetrinaListScreenState extends State<VetrinaListScreen> {
  // List myPrestazione = [];
  // var results;
  late BusinessProvider businessProvider;
  late PostProvider postProvider;
  late PrestazioneProvider prestazioneProvider;
  late VetrinaProvider vetrinaProvider;
  List<Account> bottomsheetPrestazioneList = [];
  int prestazioneSelectedId = -1;

  // Future getUserPrestazioneLiked() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "prestazione_favorite/user_id");
  //
  //   Map<String, dynamic> body = {
  //     // 'user_id': widget.user.id,
  //     'user_id': userProvider.user.id,
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
  //   //print("ticketUsers response.statusCode:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     setState(() {
  //       myPrestazione = jsonData;
  //       // results.addAll(jsonData);
  //       // results.shuffle();
  //     });
  //     // //print("singleEventReservationCategories: ");
  //     // //print(singleEventReservationCategories);
  //     // //print('searchUserByUsername results.toString()');
  //     // //print(results.toString());
  //     //print(jsonData);
  //     return jsonData;
  //   }
  // }

  void showDeletingDialog(String module, Prestazione prestazione) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return CustomDialog(
            title: 'Rimuovere prestazione In vetrina',
            content: module,
            confirmColor: Colors.red[400],
            isCancel: true,
            confirmContent: 'Rimuovi',
            confirmCallback: () async {
              int statusCode = await vetrinaProvider.deleteRecommendedPrestazione(
                businessProvider.business!.id,
                prestazione.id,
                context
              );
              if(statusCode == 200){
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
                        'Prestazione rimosssa',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  // backgroundColor: Colors.red,
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

  Future<void> bottomSheetRecommended(BuildContext context, Prestazione prestazione) async {
    await showModalBottomSheet<int>(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Popover(
          child: Column(
            children: [
              InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                onTap: () async {
                  showDeletingDialog("Sei sicuro di voler rimuovere questa prestazione?", prestazione);
                },
                child: Container(
                  child: ListTile(
                    title: Text(
                      'Elimina',
                      style: TextStyle(
                        // color: Colors.grey[800]
                        color: Colors.red[600],
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    leading: Icon(
                      // Icons.person,
                        Icons.delete_forever_outlined,
                        color: Colors.red[600]
                      // color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,)
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    postProvider = Provider.of<PostProvider>(context, listen: false);
    prestazioneProvider = Provider.of<PrestazioneProvider>(context, listen: false);
    vetrinaProvider = Provider.of<VetrinaProvider>(context, listen: false);

    // getUserPrestazioneLiked();
    // print('g5f45fhhddh');
    // print(postProvider.postList.length);

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
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);
    postProvider = Provider.of<PostProvider>(context, listen: true);
    prestazioneProvider = Provider.of<PrestazioneProvider>(context, listen: true);
    vetrinaProvider = Provider.of<VetrinaProvider>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
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
          'Vetrina',
          // 'Le mie prestazioni',
          style: TextStyle(
              color: Colors.blue[500],
              // color: Colors.grey[600],
              fontWeight: FontWeight.w600,
              fontSize: 15
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
          //           child: VetrinaCreateScreen(),
          //         )
          //       );
          //     },
          //     // child: Text(
          //     //   'Aggiungi',
          //     //   style: TextStyle(
          //     //       color: Colors.blue
          //     //   ),
          //     // )
          //     child: Icon(
          //       Icons.library_add_outlined,
          //       color: Colors.blue,
          //     ),
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
          children: [
            SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20, top: 0, bottom: 10),
                  child: Text(
                    "In evidenza",
                    // "Eventi",
                    style: TextStyle(
                      fontSize: 20,
                      //fontFamily: GoogleFonts.abhayaLibre(),
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w700,

                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(right: 10, bottom: 10),
                  child: OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                    onPressed: () {
                      // ticketCategoryProvider.deleteAll();
                      // Navigator.push(
                      //     context,
                      //     PageTransition(
                      //       duration: const Duration(milliseconds: 500),
                      //       alignment: Alignment.center,
                      //       type: PageTransitionType.fade,
                      //       // child: NotificationScreen(),
                      //       child: VetrinaCreateScreen(),
                      //     )
                      // );
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
                        tapCallback: (index) async {
                          if(vetrinaProvider.recommendedList.length > 4){
                            SnackBar snackBar = SnackBar(
                              content: Text(
                                'Hai raggiunto il massimo numero di prestazioni In vetrina',
                                // '${prestazioneProvider.prestazioneList[prestazioneSelectedId].title} aggiunta',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              backgroundColor: Colors.red,
                            );
                            snackbarKey.currentState?.showSnackBar(snackBar);
                            // return;
                          }
                          else {
                            setState(() {
                              // resultText = "selected account is : ${bottomsheetPrestazioneList[index].title}";
                              prestazioneSelectedId = index;
                            });
                            // print(resultText);
                            int statusCode = await vetrinaProvider.insertRecommendedPrestazione(
                              businessProvider.business!.id,
                              prestazioneProvider.prestazioneList[prestazioneSelectedId],
                              context
                            );
                            // await Future.delayed(const Duration(milliseconds: 250));
                            // Navigator.pop(context);
                            if (statusCode == 200) {
                              SnackBar snackBar = SnackBar(
                                content: Text(
                                  'Prestazione aggiunta',
                                  // '${prestazioneProvider.prestazioneList[prestazioneSelectedId].title} aggiunta',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.green,
                              );
                              snackbarKey.currentState?.showSnackBar(snackBar);
                            }
                            else {
                              SnackBar snackBar = SnackBar(
                                content: Text(
                                  'Riprova più tardi',
                                  // '${prestazioneProvider.prestazioneList[prestazioneSelectedId].title} aggiunta',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: Colors.red,
                              );
                              snackbarKey.currentState?.showSnackBar(snackBar);
                            }
                          }
                          Navigator.pop(context);
                          // setState(() {
                            // resultText = "selected account is : ${bottomsheetPrestazioneList[index].title}";
                            prestazioneSelectedId = -1;
                          // });

                        },
                        //Optional
                        addAccountTapCallback: () {
                          setState(() {
                            // resultText = "Add account clicked";
                          });
                          // print(resultText);
                        },
                      );
                    },
                    // child: Text(
                    //   'Aggiungi',
                    //   style: TextStyle(
                    //       color: Colors.blue
                    //   ),
                    // )
                    child: Icon(
                      Icons.library_add_outlined,
                      color: Colors.blue[500],
                      size: 20,
                    ),
                  ),
                )
              ],
            ),
            StaggeredGridView.countBuilder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                    top: 5,
                    left: 10,
                    right: 10,
                    bottom: 10
                ),
                crossAxisCount: 2,
                staggeredTileBuilder: (i) => const StaggeredTile.count(1, 0.5),
                //shrinkWrap: true,
                mainAxisSpacing: 0,
                // physics: NeverScrollableScrollPhysics(),
                crossAxisSpacing: 0,
                itemCount: vetrinaProvider.recommendedList.length,
                itemBuilder: (context, i) {
                  // //print('favoriteProvider.myFavoritesList');
                  // for(var e in postProvider.postList){
                  // //print(e);
                  // }
                  // //print('favoriteProvider.myFavoritesList.length');
                  // //print(favoriteProvider.favoritesList.length);

                  Prestazione prestazioneRecommended = vetrinaProvider.recommendedList[i];
                  // Post post = Post(
                  // id: postProvider.postList[i]['prestazione_id'],
                  // duration: favoriteProvider.favoritesList[i]['prestazione_duration'],
                  // isValid: favoriteProvider.favoritesList[i]['is_valid'],
                  // image: favoriteProvider.favoritesList[i]['prestazione_image'],
                  // price: favoriteProvider.favoritesList[i]['prestazione_price'].toDouble(),
                  // title: postProvider.postList[i]['prestazione_title'],
                  // description: postProvider.postList[i]['prestazione_description'] ?? '',
                  // created_at: DateTime.tryParse(postProvider.postList[i]['created_at']),

                  // business_id: favoriteProvider.myFavoritesList[i]['business_id'],

                  // business: Business(
                  //     profile_image: favoriteProvider.favoritesList[i]e['business_profile_image'] ?? '',
                  //     id: favoriteProvider.favoritesList[i]['business_id'],
                  //     type_id: 1,
                  //     longitude: favoriteProvider.favoritesList[i]['business_longitude'],
                  //     latitude: favoriteProvider.favoritesList[i]['business_latitude'],
                  //     name: favoriteProvider.favoritesList[i]['business_name'],
                  //     email: favoriteProvider.favoritesList[i]['business_email'],
                  //     description: favoriteProvider.favoritesList[i]['business_description'],
                  //     address: favoriteProvider.favoritesList[i]['business_address'],
                  //     room_id: favoriteProvider.favoritesList[i]['business_room_id'],
                  //     phone_number: favoriteProvider.favoritesList[i]['business_phone_number'],
                  //     max_contemporary_appointments: favoriteProvider.favoritesList[i]['max_contemporary_appointments'],
                  //     category: Category(
                  //       id: favoriteProvider.favoritesList[i]['category_id'],
                  //       image: favoriteProvider.favoritesList[i]['category_image'],
                  //       name: favoriteProvider.favoritesList[i]['category_name'],
                  //     )
                  // ),
                  // );

                  return InkWell(
                    onTap: (){
                      // Navigator.push(
                      //     context,
                      //     PageTransition(
                      //       duration: const Duration(milliseconds: 500),
                      //       alignment: Alignment.center,
                      //       type: PageTransitionType.fade,
                      //       child: PostCreateScreen(
                      //         post: post,
                      //         isNewPost: false,
                      //         // bookingBusiness: prestazione.business,
                      //         // user: widget.user,
                      //       ),
                      //     )
                      // );

                      bottomSheetRecommended(context, prestazioneRecommended);
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      elevation: 8,
                      child: Stack(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        fit: StackFit.expand,
                        children: [
                          FutureImage(
                            prestazioneRecommended.image != null && prestazioneRecommended.image != '' ? prestazioneRecommended.image! : prestazioneRecommended.business!.profile_image!,
                            width: MediaQuery.of(context).size.width,
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              // backgroundBlendMode: BlendMode.darken,
                              gradient: LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Colors.black,
                                  // Colors.transparent,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Center(
                            child: GradientText(
                              // post.business!.name ?? '',
                              prestazioneRecommended.title ?? '',
                              // 'A partire da € 60,00',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                              // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                              gradient: LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: [
                                    // Color(0xff8921aa),
                                    // Color(0xffDA44bb),
                                    // Color(0xffDA44bb)
                                    // Color(0xfffd746c),
                                    // Color(0xffff9068),
                                    // Colors.yellow,
                                    // Colors.yellow,
                                    Colors.white,
                                    Colors.white,
                                  ]
                              ),
                              // gradient: LinearGradient(
                              //     begin: Alignment.bottomLeft,
                              //     end: Alignment.topRight,
                              //     colors: [
                              //       Colors.blue[500],
                              //       Color(0xffDA44bb),
                              //
                              //       Color(0xff8921aa),
                              //     ]
                              // ),
                              style: TextStyle(
                                  color: Colors.blue[500],
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13
                              ),
                              textAlign: TextAlign.left,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }
              // ImageCard(
              //   imageData: imageList[index],
              // ),
            ),

            SizedBox(
              height: 20,
            ),
          ],
        )
      ),

    );
  }
}
