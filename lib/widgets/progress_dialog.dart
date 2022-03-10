import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:easy_localization/easy_localization.dart';

ProgressDialog loadingDialog(BuildContext context) {
  final ProgressDialog pr = ProgressDialog(
    context,
    type: ProgressDialogType.Normal,
    isDismissible: false,
    showLogs: true,
  );

  pr.style(
    message: 'please_wait'.tr(),
    borderRadius: 10.0,
    backgroundColor: Colors.white,
    elevation: 10.0,
    insetAnimCurve: Curves.easeInOut,
    progress: 0.0,
    progressWidgetAlignment: Alignment.center,
    maxProgress: 100.0,
    progressTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 13.0,
      fontWeight: FontWeight.w400,
    ),
    messageTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 19.0,
      fontWeight: FontWeight.w600,
    ),
  );

  return pr;
}
