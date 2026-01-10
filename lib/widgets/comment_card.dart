import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurebo_admin/widgets/gradient_widgets/gradient_widgets.dart';
// import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:nurebo_admin/models/post_comment.dart';
import 'package:nurebo_admin/widgets/extensions.dart';
import 'package:nurebo_admin/widgets/future_image.dart';

class CommentCard extends StatefulWidget {
  final PostComment? comment;

  const CommentCard({
    Key? key,
    this.comment,
    // this.isActive = true,
    // this.email,
    // this.press,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {

  @override
  void initState() {
    super.initState();
    // initializeDateFormatting();
  }

  @override
  Widget build(BuildContext context) {
    //  Here the shadow is not showing properly
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: 15, vertical: 15 / 2),
      child: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: (){

        },
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 32,
                            // child: CircleAvatar(
                            //   backgroundColor: Colors.transparent,
                            //   // backgroundImage: NetworkImage('email.image'),
                            //   // backgroundImage: NetworkImage(widget.comment!.user!.profile_image!),
                            //   backgroundImage: FutureImage(
                            //       widget.comment!.user!.profile_image!),
                            // ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              child: FutureImage(
                                widget.comment!.is_admin == 1 ? widget.comment!.businessPost!.business!.profile_image! : widget.comment!.user!.profile_image,
                                width: 35,
                                height: 35,
                              ),
                            ),
                          ),
                          SizedBox(width: 20 / 2),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GradientText(
                                // text: "email.name \n",
                                widget.comment!.is_admin == 1
                                  ? widget.comment!.businessPost!.business!.name!
                                  : '@${widget.comment!.user!.username ?? ''}',
                                gradient: widget.comment!.is_admin == 1 ? LinearGradient(
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                    colors: [
                                      Color(0xff8921aa),
                                      Color(0xffDA44bb),
                                    ]
                                ) : LinearGradient(
                                    begin: Alignment.bottomLeft,
                                    end: Alignment.topRight,
                                    colors: [
                                      // Color(0xff8921aa),
                                      // Color(0xffDA44bb),
                                      Colors.grey[800]!,
                                      Colors.grey[800]!,
                                    ]
                                ),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  // color: Colors.blue,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                // text: "email.name \n",
                                widget.comment!.is_admin == 1
                                    ? widget.comment!.businessPost!.business!.category!.name!
                                    : widget.comment!.user!.name ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  // color: Colors.blue,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: (){

                        },
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 15, right: 5),
                          child: Icon(
                            // SimpleLineIcons.options_vertical,
                            Icons.more_vert_rounded,
                            size: 15,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  Container(
                    width: MediaQuery.of(context).size.width * .7,
                    child: Text(
                      // 'email.body',
                      widget.comment!.text!,
                      textAlign: TextAlign.center,
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.blue[500]!,
                        fontWeight: FontWeight.w600,
                        fontSize: 13
                      ),
                    ),
                  ),
                  SizedBox(height: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // 'email.time',
                        // comment.create_at.toString(),
                        '${DateFormat.yMMMMEEEEd('it_IT').format(widget.comment!.created_at!)} alle ${widget.comment!.created_at.toString().substring(11, 16)}',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                          fontSize: 11
                        ),
                      ),
                      // if (email.isAttachmentAvailable)
                      //   WebsafeSvg.asset(
                      //     "assets/Icons/Paperclip.svg",
                      //     color: isActive ? Colors.white70 : kGrayColor,
                      //   )
                    ],
                  ),
                ],
              ),
            ).addNeumorphism(
              blurRadius: 15,
              borderRadius: 15,
              offset: const Offset(5, 5),
              topShadowColor: Colors.white60,
              bottomShadowColor: const Color(0xFF234395).withOpacity(0.15),
            ),
            // if (!email.isChecked)
            //   Positioned(
            //     right: 8,
            //     top: 8,
            //     child: Container(
            //       height: 12,
            //       width: 12,
            //       decoration: BoxDecoration(
            //         shape: BoxShape.circle,
            //         color: kBadgeColor,
            //       ),
            //     ).addNeumorphism(
            //       blurRadius: 4,
            //       borderRadius: 8,
            //       offset: Offset(2, 2),
            //     ),
            //   ),
            // if (email.tagColor != null)
            //   Positioned(
            //     left: 8,
            //     top: 0,
            //     child: WebsafeSvg.asset(
            //       "assets/Icons/Markup filled.svg",
            //       height: 18,
            //       color: email.tagColor,
            //     ),
            //   )
          ],
        ),
      ),
    );
  }
}
