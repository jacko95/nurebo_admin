//import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:nurebo_admin/models/business.dart';
import 'package:nurebo_admin/models/event.dart';
import 'package:nurebo_admin/models/post.dart';
import 'package:nurebo_admin/provider/business_provider.dart';
import 'package:nurebo_admin/provider/socket_provider.dart';
import 'package:nurebo_admin/screens/booking_business_profile_screen.dart';
import 'package:nurebo_admin/screens/booking_insert_screen2.dart';
import 'package:nurebo_admin/screens/booking_screen.dart';
import 'package:nurebo_admin/screens/calendar_screen.dart';
import 'package:nurebo_admin/screens/calendar_screen2.dart';
import 'package:nurebo_admin/screens/campaign_list_screen.dart';
import 'package:nurebo_admin/screens/campaign_selection_screen.dart';
import 'package:nurebo_admin/screens/business_events_screen.dart';
import 'package:nurebo_admin/screens/business_profile_screen.dart';
import 'package:nurebo_admin/screens/post_edit_screen.dart';
import 'package:nurebo_admin/screens/event_detail_screen.dart';
import 'package:nurebo_admin/screens/business_room_screen.dart';
import 'package:nurebo_admin/screens/news_screen.dart';
import 'package:nurebo_admin/screens/notifications_screen.dart';
import 'package:nurebo_admin/screens/post_list_screen.dart';
import 'package:nurebo_admin/screens/prestazione_list_screen.dart';
import 'package:nurebo_admin/screens/qr_code_scanner_screen.dart';
import 'package:nurebo_admin/screens/settings_screen.dart';
import 'package:nurebo_admin/screens/statistics_list_screen.dart';
import 'package:nurebo_admin/screens/vetrina_list_screen.dart';
import 'package:nurebo_admin/utils/business_preferences.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo_admin/utils/utils.dart';
import 'package:nurebo_admin/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';


class NavigationDrawerWidget extends StatefulWidget {
  // final Business business;

  NavigationDrawerWidget({Key? key/*, this.business*/});

  @override
  _NavigationDrawerWidgetState createState() => _NavigationDrawerWidgetState();
}

class _NavigationDrawerWidgetState extends State<NavigationDrawerWidget> {
  final padding = EdgeInsets.symmetric(horizontal: 10);
  late SocketProvider socketProvider;
  late BusinessProvider businessProvider;


  @override
  void initState() {
    super.initState();
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    businessProvider = Provider.of<BusinessProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(this.context, listen: true);
    businessProvider = Provider.of<BusinessProvider>(this.context, listen: true);

    return SafeArea(
      child: Drawer(
        child: Material(
          // color: Color.fromRGBO(50, 75, 205, 1),
          // color: Color.fromRGBO(27, 30, 41, .6),
          // color: Colors.blue[800].withOpacity(.7),
          color: Colors.white,
          // color: Color(0xFF2D2F41).withOpacity(.8),
          child: NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: ListView(
              children: <Widget>[
                InkWell(
                  onTap: (){
                    Navigator.push(
                        context,
                        PageTransition(
                            duration: const Duration(milliseconds: 500),
                            alignment: Alignment.center,
                            type: PageTransitionType.fade,
                            // child: BusinessProfileScreen(
                            child: BookingBusinessProfileScreen(
                              business: businessProvider.business,
                              // bookingBusiness: businessProvider.business,
                            )
                        )
                    );

                    Future.delayed(
                      const Duration(milliseconds: 500),
                      () => Scaffold.of(context).openEndDrawer()
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.only(top: 40, bottom: 35, left: 15),
                    child: Row(
                      children: [
                        ClipOval(
                          child: FutureImage(
                            businessProvider.business != null && businessProvider.business!.profile_image != null ? businessProvider.business!.profile_image! : 'immagine profilo drawer',
                            width: 60,
                            height: 60,
                          )
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * .45,
                              child: Marquee(
                                direction: Axis.horizontal,
                                animationDuration: Duration(milliseconds: 5000),
                                backDuration: Duration(milliseconds: 5000),
                                textDirection: TextDirection.ltr,
                                child: Row(
                                  children: [
                                    Text(
                                      businessProvider.business != null && businessProvider.business!.name != null ? businessProvider.business!.name! : '',
                                      style: TextStyle(
                                          fontSize: 20,
                                          // color: Colors.white
                                          color: Colors.blue[500],
                                          // color: Colors.grey[600],
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // const SizedBox(height: 4),
                            const SizedBox(height: 1),
                            Container(
                              width: MediaQuery.of(context).size.width * .45,
                              child: Marquee(
                                direction: Axis.horizontal,
                                animationDuration: Duration(milliseconds: 5000),
                                backDuration: Duration(milliseconds: 5000),
                                textDirection: TextDirection.ltr,
                                child: Row(
                                  children: [
                                    Text(
                                      businessProvider.business != null && businessProvider.business!.email != null ? businessProvider.business!.email! : '',
                                      style: TextStyle(
                                          fontSize: 14,
                                          // color: Colors.white
                                          // color: Colors.blue,
                                          color: Colors.grey[500],
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 3.5),
                            Container(
                              width: MediaQuery.of(context).size.width * .45,
                              child: Marquee(
                                direction: Axis.horizontal,
                                animationDuration: Duration(milliseconds: 5000),
                                backDuration: Duration(milliseconds: 5000),
                                textDirection: TextDirection.ltr,
                                child: Row(
                                  children: [
                                    Text(
                                      businessProvider.business != null && businessProvider.business!.address != null ? businessProvider.business!.address! : '',
                                      maxLines: 1,
                                      style: TextStyle(
                                          fontSize: 12,
                                          // color: Colors.white
                                          // color: Colors.blue,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Spacer(),
                        // CircleAvatar(
                        //   radius: 24,
                        //   backgroundColor: Color.fromRGBO(30, 60, 168, 1),
                        //   child: Icon(Icons.add_comment_outlined, color: Colors.white),
                        // )
                      ],
                    ),
                  ),
                ),
                Divider(color: Colors.grey[500], indent: 15, endIndent: 20, height: 0),

                Container(
                  padding: padding,
                  child: Column(
                    children: [
                      // const SizedBox(height: 12),
                      // buildSearchField(),
                      // const SizedBox(height: 24),
                      // Divider(color: Colors.white70),
                      // Divider(color: Colors.grey[500], indent: 10, endIndent: 10,),
                      const SizedBox(height: 5),

                      drawerItem(
                        text: 'Notifiche',
                        // text: 'Aggiornamenti',
                        icon: Icons.notifications_outlined,
                        iconSize: 24,
                        trailing: DateTime.tryParse(socketProvider.notificationList.isNotEmpty ? socketProvider.notificationList.first['sent_at'] : DateTime.now().subtract(Duration(days: 2)).toIso8601String())!.isAfter(DateTime.tryParse(BusinessPreferences.getBusinessLastUpdateNotification() ?? DateTime.now().subtract(Duration(hours: 2)).toIso8601String())!) ? Padding(
                        // trailing: socketProvider.notificationList.isNotEmpty ? Padding(
                          padding: EdgeInsets.only(
                            // right: MediaQuery.of(context).size.width * 0.05
                              right: 10
                          ),
                          child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // color: Colors.greenAccent
                                  color: Colors.blue[500]
                              )
                          ),
                        ) : SizedBox(),
                        onClicked: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                duration: const Duration(milliseconds: 500),
                                alignment: Alignment.center,
                                type: PageTransitionType.fade,
                                child: const NotificationsScreen(),
                              )
                          );

                          Future.delayed(
                              const Duration(milliseconds: 500),
                                  () => Scaffold.of(context).openEndDrawer()
                          );
                        },
                      ),

                      Visibility(
                        visible: false,
                        child: drawerItem(
                          text: 'Novità',
                          icon: Icons.newspaper_outlined,
                          iconSize: 24,
                          onClicked: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                  duration: const Duration(milliseconds: 500),
                                  alignment: Alignment.center,
                                  type: PageTransitionType.fade,
                                  child: NewsScreen(
                                    // business: widget.business,
                                    // business: businessProvider.business,
                                  ),
                                )
                            );

                            Future.delayed(
                                const Duration(milliseconds: 500),
                                () => Scaffold.of(context).openEndDrawer()
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 4),
                      // Divider(color: Colors.white70, endIndent: 20, indent: 20,),
                      Divider(color: Colors.grey[500], endIndent: 15, indent: 15,),
                      const SizedBox(height: 4),

                      // buildMenuItem(
                      //   text: 'Eventi',
                      //   icon: Icons.event,
                      //   onClicked: () => selectedItem(context, 0),
                      // ),
                      // const SizedBox(height: 16),
                      Visibility(
                        // visible: businessProvider.business!.type_id == 1,
                        visible: false,
                        child: drawerItem(
                          text: 'Inserisci prenotazione',
                          icon: Icons.note_add_outlined,
                          // icon: Icons.add_circle_outline,
                          // icon: Icons.add_box_outlined,
                          iconSize: 24,
                          onClicked: () {
                            // return selectedItem(context, 4);
                            Navigator.push(
                                context,
                                PageTransition(
                                  duration: const Duration(milliseconds: 500),
                                  alignment: Alignment.center,
                                  type: PageTransitionType.fade,
                                  child: const BookingInsertScreen2(
                                    // bookingBusiness: businessProvider.business,
                                  )
                                )
                            );

                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () => Scaffold.of(context).openEndDrawer()
                            );
                            // Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      ),

                      Visibility(
                        visible: businessProvider.business!.type_id == 2,
                        // visible: true,
                        child: drawerItem(
                          text: 'Crea evento',
                          icon: Icons.celebration_outlined,
                          // icon: Icons.add_circle_outline,
                          // icon: Icons.add_box_outlined,
                          iconSize: 24,
                          onClicked: () {
                            // return selectedItem(context, 4);
                            Navigator.push(
                                context,
                                PageTransition(
                                  duration: const Duration(milliseconds: 500),
                                  alignment: Alignment.center,
                                  type: PageTransitionType.fade,
                                  child: EventDetailScreen(
                                    event: Event(
                                      title: '',
                                      description: '',
                                    ),
                                    isNewEvent: true,
                                  )
                                )
                            );

                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () => Scaffold.of(context).openEndDrawer()
                            );
                            // Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      ),

                      Visibility(
                        visible: businessProvider.business!.type_id == 1,
                        // visible: true,
                        child: drawerItem(
                          text: 'Calendario',
                          // text: 'Appuntamenti',
                          // text: 'Prenotazioni',
                          // icon: Icons.style,
                          // icon: Icons.my_library_books_outlined,
                          icon: Icons.event,
                          iconSize: 24,
                          onClicked: () {
                            // return selectedItem(context, 4);
                            Navigator.push(
                                context,
                                PageTransition(
                                  duration: const Duration(milliseconds: 500),
                                  alignment: Alignment.center,
                                  type: PageTransitionType.fade,
                                  // child: CalendarScreen2(
                                  child: CalendarScreen(
                                    // business: widget.business,
                                    // business: businessProvider.business,
                                  ),
                                )
                            );

                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () => Scaffold.of(context).openEndDrawer()
                            );
                            // Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      ),
                      // const SizedBox(height: 16),
                      // buildMenuItem(
                      //   text: 'Storico appuntamenti',
                      //   // icon: Icons.style,
                      //   // icon: Icons.my_library_books_outlined,
                      //   icon: Icons.event_available_outlined,
                      //   onClicked: () => selectedItem(context, 4),
                      // ),
                      // const SizedBox(height: 16),

                      Visibility(
                        visible: businessProvider.business!.type_id == 1,
                        child: drawerItem(
                          // text: 'Pagamenti',
                          text: 'Prenotazioni',
                          icon: Icons.event_note,
                          iconSize: 24,
                          onClicked: () {
                            // return selectedItem(context, 5);
                            Navigator.push(
                                context,
                                PageTransition(
                                  duration: const Duration(milliseconds: 500),
                                  alignment: Alignment.center,
                                  type: PageTransitionType.fade,
                                  child: BookingScreen(
                                    // bookingBusiness: widget.business,
                                    // bookingBusiness: businessProvider.business,
                                  ),
                                )
                            );

                            Future.delayed(
                                const Duration(milliseconds: 500),
                                    () => Scaffold.of(context).openEndDrawer()
                            );
                            // Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      ),

                      Visibility(
                        visible: true,
                        child: drawerItem(
                          text: 'Vetrina',
                          icon: Icons.perm_media_outlined,
                          iconSize: 23,
                          onClicked: () {
                            // return selectedItem(context, 4);
                            Navigator.push(
                                context,
                                PageTransition(
                                    duration: const Duration(milliseconds: 500),
                                    alignment: Alignment.center,
                                    type: PageTransitionType.fade,
                                    child: VetrinaListScreen()
                                )
                            );

                            Future.delayed(
                                const Duration(milliseconds: 500),
                                    () => Scaffold.of(context).openEndDrawer()
                            );
                            // Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      ),

                      Visibility(
                        visible: businessProvider.business!.type_id == 1,
                        // visible: true,
                        child: drawerItem(
                          text: 'Listino',
                          icon: Icons.book_outlined,
                          iconSize: 24,
                          onClicked: () {
                            // return selectedItem(context, 4);
                            Navigator.push(
                                context,
                                PageTransition(
                                  duration: const Duration(milliseconds: 500),
                                  alignment: Alignment.center,
                                  type: PageTransitionType.fade,
                                  child: const PrestazioneListScreen(
                                    // business: widget.business,
                                    // business: businessProvider.business,
                                  ),
                                )
                            );

                            Future.delayed(
                                const Duration(milliseconds: 500),
                                    () => Scaffold.of(context).openEndDrawer()
                            );
                            // Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      ),

                      Visibility(
                        visible: true,
                        child: drawerItem(
                          text: 'Post',
                          // icon: Icons.image_outlined,
                          icon: Icons.photo_library_outlined,
                          iconSize: 25,
                          onClicked: () {
                            // return selectedItem(context, 4);
                            Navigator.push(
                              context,
                              PageTransition(
                                duration: const Duration(milliseconds: 500),
                                alignment: Alignment.center,
                                type: PageTransitionType.fade,
                                child: PostListScreen()
                              )
                            );

                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () => Scaffold.of(context).openEndDrawer()
                            );
                            // Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      ),

                      Visibility(
                        // visible: businessProvider.business!.business_type_id == 1,
                        visible: true,
                        child: drawerItem(
                          text: 'Chat',
                          // text: 'Appuntamenti',
                          // text: 'Prenotazioni',
                          // icon: Icons.style,
                          // icon: Icons.my_library_books_outlined,
                          icon: Icons.chat_bubble_outline,
                          iconSize: 24,
                          onClicked: () {
                            // return selectedItem(context, 4);
                            Navigator.push(
                                context,
                                PageTransition(
                                  duration: const Duration(milliseconds: 500),
                                  alignment: Alignment.center,
                                  type: PageTransitionType.fade,
                                  child: BusinessRoomScreen(
                                    // child: CalendarScreen(
                                    // business: widget.business,
                                    // business: businessProvider.business,
                                  ),
                                )
                            );

                            Future.delayed(
                                const Duration(milliseconds: 500),
                                    () => Scaffold.of(context).openEndDrawer()
                            );
                            // Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      ),

                      Visibility(
                        visible: false,
                        child: drawerItem(
                          text: 'Campagne',
                          icon: Icons.campaign_outlined,
                          iconSize: 28,
                          onClicked: () {
                            // return selectedItem(context, 4);
                            Navigator.push(
                                context,
                                PageTransition(
                                  duration: const Duration(milliseconds: 500),
                                  alignment: Alignment.center,
                                  type: PageTransitionType.fade,
                                  child: const CampaignListScreen(
                                    // business: widget.business,
                                    // business: businessProvider.business,
                                  ),
                                )
                            );

                            Future.delayed(
                                const Duration(milliseconds: 500),
                                    () => Scaffold.of(context).openEndDrawer()
                            );
                            // Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      ),

                      Visibility(
                        visible: true,
                        child: drawerItem(
                          text: 'Statistiche',
                          // icon: Icons.analytics_outlined,
                          // icon: Icons.insights_outlined,
                          // icon: Icons.assessment_outlined,
                          icon: Icons.insert_chart_outlined,
                          iconSize: 28,
                          onClicked: () {
                            // return selectedItem(context, 4);
                            Navigator.push(
                                context,
                                PageTransition(
                                  duration: const Duration(milliseconds: 500),
                                  alignment: Alignment.center,
                                  type: PageTransitionType.fade,
                                  child: const StatisticsListScreen(
                                    // business: widget.business,
                                    // business: businessProvider.business,
                                  ),
                                )
                            );

                            Future.delayed(
                                const Duration(milliseconds: 500),
                                    () => Scaffold.of(context).openEndDrawer()
                            );
                            // Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      ),

                      Visibility(
                        visible: businessProvider.business!.type_id == 2,
                        child: drawerItem(
                          text: 'Eventi',
                          icon: Icons.event_note,
                          iconSize: 24,
                          onClicked: () {
                            // return selectedItem(context, 4);
                            Navigator.push(
                                context,
                                PageTransition(
                                  duration: const Duration(milliseconds: 500),
                                  alignment: Alignment.center,
                                  type: PageTransitionType.fade,
                                  child: const BusinessEventsScreen(
                                    // business: widget.business,
                                    // business: businessProvider.business,
                                  ),
                                )
                            );

                            Future.delayed(
                                const Duration(milliseconds: 500),
                                    () => Scaffold.of(context).openEndDrawer()
                            );
                            // Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      ),

                      Visibility(
                        // visible: businessProvider.business!.business_type_id == 1,
                        visible: false,
                        child: drawerItem(
                          text: 'Ruoli',
                          // text: 'Appuntamenti',
                          // text: 'Prenotazioni',
                          // icon: Icons.style,
                          // icon: Icons.my_library_books_outlined,
                          icon: Icons.people_alt_outlined,
                          iconSize: 24,
                          onClicked: () {
                            // return selectedItem(context, 4);
                            // Navigator.push(
                            //     context,
                            //     PageTransition(
                            //       duration: const Duration(milliseconds: 500),
                            //       alignment: Alignment.center,
                            //       type: PageTransitionType.fade,
                            //       child: CalendarScreen2(
                            //         // child: CalendarScreen(
                            //         // business: widget.business,
                            //         // business: businessProvider.business,
                            //       ),
                            //     )
                            // );

                            Future.delayed(
                                const Duration(milliseconds: 500),
                                    () => Scaffold.of(context).openEndDrawer()
                            );
                            // Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      ),

                      Visibility(
                        visible: businessProvider.business!.type_id == 2,
                        // visible: true,
                        child: drawerItem(
                          text: 'Convalida',
                          icon: Icons.qr_code_outlined,
                          // icon: Icons.add_circle_outline,
                          // icon: Icons.add_box_outlined,
                          iconSize: 24,
                          onClicked: () {
                            // return selectedItem(context, 4);
                            Navigator.push(
                              context,
                              PageTransition(
                                duration: const Duration(milliseconds: 500),
                                alignment: Alignment.center,
                                type: PageTransitionType.fade,
                                child: QrCodeScanner(
                                  // bookingBusiness: businessProvider.business,
                                )
                              )
                            );

                            Future.delayed(
                              const Duration(milliseconds: 500),
                              () => Scaffold.of(context).openEndDrawer()
                            );
                            // Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      ),

                      const SizedBox(height: 4),
                      // Divider(color: Colors.white70, endIndent: 20, indent: 20,),
                      Divider(color: Colors.grey[500], endIndent: 15, indent: 15,),
                      const SizedBox(height: 4),
                      drawerItem(
                        text: 'Impostazioni',
                        icon: Icons.settings,
                        iconSize: 24,
                        onClicked: () {
                          // return selectedItem(context, 6);
                          Navigator.push(
                              context,
                              PageTransition(
                                  duration: const Duration(milliseconds: 500),
                                  alignment: Alignment.center,
                                  type: PageTransitionType.fade,
                                  child: SettingsScreen(
                                    // business: businessProvider.business,
                                  )
                              )
                          );

                          Future.delayed(
                              const Duration(milliseconds: 500),
                                  () => Scaffold.of(context).openEndDrawer()
                          );
                          // Scaffold.of(context).openEndDrawer();
                        },
                      ),

                      // const SizedBox(height: 16),
                      // buildMenuItem(
                      //   text: 'Statistiche',
                      //   icon: Icons.insert_chart_outlined_outlined,
                      //   onClicked: () => selectedItem(context, 4),
                      // ),
                      // const SizedBox(height: 16),

                      Visibility(
                        visible: false,
                        child: drawerItem(
                          text: 'Assistenza',
                          icon: Icons.live_help_outlined,
                          iconSize: 24,
                          onClicked: () {

                            Future.delayed(
                                const Duration(milliseconds: 500),
                                    () => Scaffold.of(context).openEndDrawer()
                            );
                            // Scaffold.of(context).openEndDrawer();
                          },
                        ),
                      ),

                      const SizedBox(height: 4),
                      Divider(color: Colors.grey[500], endIndent: 15, indent: 15,),
                      drawerItem(
                        text: 'Esci',
                        icon: Icons.logout,
                        iconSize: 24,
                        onClicked: () async {
                          await businessProvider.logout(context, true);
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSearchField() {
    final color = Colors.white;

    return TextField(
      style: TextStyle(color: color),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        hintText: 'Search',
        hintStyle: TextStyle(color: color),
        prefixIcon: Icon(Icons.search, color: color),
        filled: true,
        fillColor: Colors.white12,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: color.withOpacity(0.7)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide(color: color.withOpacity(0.7)),
        ),
      ),
    );
  }

  Widget drawerItem({
    required String text,
    required IconData icon,
    required double iconSize,
    Widget? trailing,
    VoidCallback? onClicked,
  }) {
    // final color = Colors.white;
    final color = Colors.grey[600];
    final hoverColor = Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onClicked,
        splashColor: Colors.transparent,
        child: ListTile(
          leading: Icon(
            icon,
            color: color,
            size: iconSize,
          ),
          title: Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 14
            )
          ),
          trailing: trailing,
          hoverColor: hoverColor,
          // onTap: onClicked,
        ),

      ),
    );
  }

}
