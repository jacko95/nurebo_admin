//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_cache_business/flutter_cache_business.dart';
// import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/screens/business_settings_screen.dart';
import 'package:nurebo_admin/screens/notification_settings_screen.dart';
import 'package:nurebo_admin/screens/prestazione_list_screen.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:nurebo_admin/widgets/image_cache_manager.dart';
import 'package:nurebo_admin/widgets/signed_image.dart';
// import 'package:nurebo/main.dart';
// import 'package:nurebo/provider/business_provider.dart';
// import 'package:nurebo/screens/login_screen.dart';
// import 'package:nurebo/screens/upbooking_description_screen.dart';
// import 'package:nurebo/screens/upbooking_email_screen.dart';
// import 'package:nurebo/screens/upbooking_phone_number_screen.dart';
// import 'package:nurebo/screens/upbooking_username_screen.dart';
// import 'package:nurebo/utils/business_preferences.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
// import 'package:settings_ui/settings_ui.dart';

// import 'languages_screen.dart';

class SettingsScreen extends StatefulWidget {
  // final Business business;

  const SettingsScreen({super.key, /*Key? key,*//* this.business*/});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late BusinessProvider businessProvider;
  ImageCacheBusiness cacheBusiness = ImageCacheBusiness();


  @override
  void initState() {
    super.initState();
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    // cacheBusiness = Provider.of<ImageCacheBusiness>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    businessProvider = Provider.of<BusinessProvider>(context, listen: true);
    // cacheBusiness = Provider.of<ImageCacheBusiness>(context, listen: true);

    return Scaffold(
      backgroundColor: Colors.white,
      // floatingActionButton: Column(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     SizedBox(height: 25,),
      //     Column(
      //       mainAxisAlignment: MainAxisAlignment.end,
      //       children: [
      //         Divider(
      //           height: 1,
      //           indent: 0,
      //           endIndent: 0,
      //         ),
      //         Padding(
      //           padding: const EdgeInsets.only(top: 20, bottom: 10),
      //           // child: Image.asset(
      //           //   'assets/settings.png',
      //           //   height: 50,
      //           //   width: 50,
      //           //   color: Color(0xFF777777),
      //           // ),
      //           child: Text(
      //             // 'Versione: 2.4.0 (287)',
      //             'Versione: ${Utils.version_name} (${Utils.version_id})',
      //             style: TextStyle(color: Color(0xFF777777)),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ],
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
            // 'I miei dati',
            'Impostazioni',
            style: TextStyle(
                color: Colors.blue[500],
                // color: Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: 16
            ),
          ),
          actions: [

          ],
        ),
      ),
      // body: buildSettingsList(),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ListView(
          // backgroundColor: Colors.white,
          shrinkWrap: true,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 15, bottom: 7),
                  child: Text(
                    'Account',
                    style: GoogleFonts.roboto(
                      color: Colors.blue[500],
                      fontWeight: FontWeight.w800,
                      //color: Color.fromRGBO(245, 93, 62, 1),
                      // background:
                      // letterSpacing: -3,
                      fontSize: 15,
                      //fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ],
            ),

            ListTile(
              // title: Text('Nome'),
              title: Text(
                // 'Informazioni'
                  businessProvider.business!.name ?? ''
              ),
              // title: Text('Business'),
              trailing: Icon(
                Icons.arrow_forward_ios_sharp,
                size: 22,
                color: Colors.grey[400],
              ),
              leading: Padding(
                // padding: EdgeInsets.only(top: 7),
                padding: EdgeInsets.only(top: 0, left: 7),
                // child: Icon(Icons.business_outlined, size: 25,),
                child: ClipRRect(
                  // borderRadius: BorderRadius.circular(40),
                  borderRadius: BorderRadius.circular(4),
                  // child: SignedImage(
                  child: FutureImage(
                    businessProvider.business!.profile_image!,
                    width: 45,
                    height: 45,
                    // forceNetworkImage: true,
                  ),
                ),
              ),
              // subtitle: Text(businessProvider.user.username ?? ''),
              subtitle: Marquee(
                child: Text(
                    businessProvider.business!.address ?? ''
                ),
              ),

              // subtitle: Text(''),
              onTap: () {
                Navigator.push(
                  context,
                  PageTransition(
                    duration: const Duration(milliseconds: 500),
                    alignment: Alignment.center,
                    type: PageTransitionType.fade,
                    // child: UpbookingUsernameScreen(user: businessProvider.user,)
                    child: BusinessSettingsScreen()
                  ),
                ).then((value) async {
                  // print('businessProvider.business!.profile_image!dfg5fhfh5');
                  // print(businessProvider.business!.profile_image!);
                  // await cacheBusiness.getImageFromCache('${Utils.httpServerUrl}image?path=${businessProvider.business!.profile_image!}');
                });
              },
            ),

            // ListTile(
            //   title: Text(
            //     // 'Prestazioni'
            //       'Listino',
            //   ),
            //
            //   leading: Icon(
            //       Icons.book_outlined
            //   ),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       PageTransition(
            //           duration: const Duration(milliseconds: 500),
            //           alignment: Alignment.center,
            //           type: PageTransitionType.fade,
            //           // child: UpbookingUsernameScreen(user: businessProvider.user,)
            //           child: PrestazioneScreen(/*bookingBusiness: widget.business,*/)
            //       ),
            //     );
            //   },
            // ),

            // ListTile(
            //   title: Text('Numero di telefono'),
            //   trailing: Icon(
            //     Icons.arrow_forward_ios_sharp,
            //     size: 22,
            //   ),
            //   leading: Padding(
            //     padding: EdgeInsets.only(top: 7),
            //     child: Icon(Icons.phone_outlined, size: 25,),
            //   ),
            //   // subtitle: '+39 371 658 4578',
            //   // subtitle: Text(businessProvider.user.phone_number ?? ''),
            //   subtitle: Text(businessProvider.business.phone_number ?? ''),
            //   // subtitle: Text(''),
            //   onTap: () {
            //     // Navigator.push(
            //     //   context,
            //     //   PageTransition(
            //     //       duration: const Duration(milliseconds: 500),
            //     //       alignment: Alignment.center,
            //     //       type: PageTransitionType.fade,
            //     //       // child: UpbookingPhoneNumberScreen()
            //     //   ),
            //     // );
            //   },
            // ),
            //
            // ListTile(
            //   title: Text('Email'),
            //   trailing: Icon(
            //     Icons.arrow_forward_ios_sharp,
            //     size: 22,
            //   ),
            //   leading: Padding(
            //     padding: EdgeInsets.only(top: 7),
            //     child: Icon(Icons.email_outlined, size: 25,),
            //   ),
            //   // subtitle: 'metauros95@gmail.com',
            //   // subtitle: Text(businessProvider.user.email ?? ''),
            //   subtitle: Text(businessProvider.business.email ?? ''),
            //   // subtitle: Text(''),
            //   onTap: () {
            //     // Navigator.push(
            //     //   context,
            //     //   PageTransition(
            //     //       duration: const Duration(milliseconds: 500),
            //     //       alignment: Alignment.center,
            //     //       type: PageTransitionType.fade,
            //     //       // child: UpbookingEmailScreen(user: businessProvider.user,)
            //     //   ),
            //     // );
            //   },
            // ),

            // ListTile(
            //   title: Text('Descrizione'),
            //   trailing: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Icon(
            //         Icons.arrow_forward_ios_sharp,
            //         size: 22,
            //       ),
            //     ],
            //   ),
            //   leading: Padding(
            //     padding: EdgeInsets.only(top: 7),
            //     child: Icon(Icons.book_outlined, size: 25,),
            //   ),
            //   // subtitle: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.",
            //   subtitle: Text(
            //     // businessProvider.user.description ?? '',
            //     '',
            //     maxLines: 3,
            //     overflow: TextOverflow.ellipsis,
            //   ),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       PageTransition(
            //           duration: const Duration(milliseconds: 500),
            //           alignment: Alignment.center,
            //           type: PageTransitionType.rightToLeft,
            //           // child: UpbookingDescriptionScreen()
            //       ),
            //     );
            //   },
            // ),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 15, bottom: 5),
                  child: Text(
                    'Generale',
                    style: GoogleFonts.roboto(
                      color: Colors.blue[500],
                      fontWeight: FontWeight.w800,
                      //color: Color.fromRGBO(245, 93, 62, 1),
                      // background:
                      // letterSpacing: -3,
                      fontSize: 15,
                      //fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ],
            ),

            ListTile(
              title: Text('Ruoli'),
              subtitle: Text(
                  'Italiano'
              ),
              leading: Padding(
                padding: EdgeInsets.only(top: 7),
                child: Icon(Icons.people_alt_outlined, size: 25,),
              ),
              // subtitle: 'Italiano',
              // onTap: () {
              //   // Navigator.push(
              //   //   context,
              //   //   PageTransition(
              //   //       duration: const Duration(milliseconds: 500),
              //   //       alignment: Alignment.center,
              //   //       type: PageTransitionType.rightToLeft,
              //   //       // child: UpbookingUsernameScreen(user: businessProvider.user,)
              //   //       child: NotificationSettingsScreen(business: widget.business,)
              //   //   ),
              //   // );
              // },
            ),

            ListTile(
              title: Text('Lingua'),
              subtitle: Text(
                  'Italiano'
              ),
              leading: Padding(
                padding: EdgeInsets.only(top: 7),
                child: Icon(Icons.language_outlined, size: 25,),
              ),
              // subtitle: 'Italiano',
              // onTap: () {
              //   // Navigator.push(
              //   //   context,
              //   //   PageTransition(
              //   //       duration: const Duration(milliseconds: 500),
              //   //       alignment: Alignment.center,
              //   //       type: PageTransitionType.rightToLeft,
              //   //       // child: UpbookingUsernameScreen(user: businessProvider.user,)
              //   //       child: NotificationSettingsScreen(business: widget.business,)
              //   //   ),
              //   // );
              // },
            ),

            ListTile(
              title: Text(
                  'Pagamenti'
              ),
              // isThreeLine: true,
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                    'Attualmente sono disponibili solo pagamenti in negozio'
                ),
              ),
              leading: Icon(
                  Icons.payment_outlined
              ),
            ),

            // SizedBox(height: 5,),
            //
            // ListTile(
            //   title: Text(
            //     'Notifiche'
            //   ),
            //   leading: Icon(
            //     Icons.notifications_outlined
            //   ),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       PageTransition(
            //           duration: const Duration(milliseconds: 500),
            //           alignment: Alignment.center,
            //           type: PageTransitionType.fade,
            //           // child: UpbookingUsernameScreen(user: businessProvider.user,)
            //           child: NotificationSettingsScreen(/*business: widget.business,*/)
            //       ),
            //     );
            //   },
            // ),

            // ListTile(title: Text('Sicurezza'), leading: Icon(Icons.lock_outline_rounded)),
            // ListTile(title: Text('Chat'), leading: Icon(Icons.chat_bubble_outline)),
            // ListTile(title: Text('Dati'), leading: Icon(Icons.sd_card_outlined)),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top: 15, bottom: 10),
                  child: Text(
                    'Legale',
                    style: GoogleFonts.roboto(
                      color: Colors.blue[500],
                      fontWeight: FontWeight.w800,
                      //color: Color.fromRGBO(245, 93, 62, 1),
                      // background:
                      // letterSpacing: -3,
                      fontSize: 15,
                      //fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ],
            ),
            ListTile(
                title: Text('Termini di Servizio'), leading: Icon(Icons.description_outlined)),
            ListTile(
                title: Text('Licenze'),
                leading: Icon(Icons.collections_bookmark_outlined)
            ),
            // SizedBox(height: 70,),

            SizedBox(height: 25,),
            Column(
              children: [
                Divider(
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  // child: Image.asset(
                  //   'assets/settings.png',
                  //   height: 50,
                  //   width: 50,
                  //   color: Color(0xFF777777),
                  // ),
                  child: Text(
                    // 'Versione: 2.4.0 (287)',
                    'Versione: ${Utils.version_name} (${Utils.version_id})',
                    style: TextStyle(color: Color(0xFF777777)),
                  ),
                ),
                Divider(
                  height: 1,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}
