import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TabBarSliverPersistentHeaderDelegate extends SliverPersistentHeaderDelegate{
  static const TAG = 'TabBarSliverPersistentHeaderDelegate';

  Widget? child;
  double? extent;

  TabBarSliverPersistentHeaderDelegate({this.child, this.extent});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      child: child,
      color: Theme.of(context).cardColor,
      elevation: overlapsContent ? 4 : 0,
    );
  }

  @override
  // double get maxExtent => 70.0;
  double get maxExtent => extent!;

  @override
  // double get minExtent => 48.0;
  double get minExtent => 48.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }


}