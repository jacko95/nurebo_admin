library selector_bottom_sheet;

import 'package:flutter/material.dart';
import 'package:nurebo_admin/models/selector_tile.dart';
import 'package:nurebo_admin/widgets/single_selector_widget.dart';

import 'multi_selector_widget.dart';

showSelectorBottomSheet({
  required BuildContext context,
  required List<SelectorTile> accountList,
  int? initiallySelectedIndex = -1,
  Function(int index)? tapCallback,
  bool hideSheetOnItemTap = false,
  Color selectedRadioColor = Colors.green,
  bool showAddAccountOption = false,
  Function? addAccountTapCallback,
  String addAccountTitle = "Add Account",
  Color arrowColor = Colors.grey,
  Color backgroundColor = Colors.white,
  Color selectedTextColor = Colors.green,
  Color? unselectedTextColor = const Color(0xFF424242),
  Color? unselectedSubtitleColor = const Color(0xFF424242),
  Color? unselectedDatetimeColor = const Color(0xFF424242),
  Color unselectedRadioColor = Colors.grey,
  bool isSheetDismissible = true,
}) {
  List<SelectorTileBoolean> accountwithselectionList =
      setupAccountWithSelectionList(
    accountList,
    initiallySelectedIndex,
    showAddAccountOption,
    addAccountTitle,

  );
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isDismissible: isSheetDismissible,
    isScrollControlled: true,

    builder: (context) {
      return SingleSelectorWidget(
        accountwithselectionList: accountwithselectionList,
        initiallySelectedIndex: initiallySelectedIndex,
        tapCallback: tapCallback ?? (val) {},
        hideSheetOnItemTap: hideSheetOnItemTap,
        selectedRadioColor: selectedRadioColor,
        showAddAccountOption: showAddAccountOption,
        addAccountTapCallback: addAccountTapCallback ?? () {},
        arrowColor: arrowColor,
        backgroundColor: backgroundColor,
        selectedTextColor: selectedTextColor,
        unselectedTextColor: unselectedTextColor,
        unselectedSubtitleColor: unselectedSubtitleColor,
        unselectedDatetimeColor: unselectedDatetimeColor,
        unselectedRadioColor: unselectedRadioColor,
      );
    },
  );
}

Future<List<int>> showMultiSelectorBottomSheet({
  required BuildContext context,
  required List<SelectorTile> accountList,
  List<int>? initiallySelectedIndexList,
  Color checkedIconColor = Colors.green,
  Color doneButtonColor = Colors.blue,
  Color arrowColor = Colors.grey,
  Color backgroundColor = Colors.white,
  Color selectedTextColor = Colors.green,
  Color unselectedTextColor = const Color(0xFF424242),
  Color uncheckedIconColor = Colors.grey,
  String doneText = "DONE",
  bool isSheetDismissible = true,
}) async {
  List<SelectorTileBoolean> accountwithselectionList =
      setupAccountWithMultiSelectionList(
    accountList,
    initiallySelectedIndexList,
  );
  List<int>? selectedIndexList = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: isSheetDismissible,
      builder: (context) {
        return MultiSelectorWidget(
          accountwithselectionList: accountwithselectionList,
          initiallySelectedIndexList: initiallySelectedIndexList ?? [-1],
          checkedIconColor: checkedIconColor,
          doneText: doneText,
          doneButtonColor: doneButtonColor,
          arrowColor: arrowColor,
          backgroundColor: backgroundColor,
          selectedTextColor: selectedTextColor,
          unselectedTextColor: unselectedTextColor,
          uncheckedIconColor: uncheckedIconColor,
        );
      });
  return selectedIndexList ?? [];
}
