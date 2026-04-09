import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

Widget buildPlatformKenzclubView({
  required Object? controller,
  required String url,
  required int refreshToken,
}) {
  final viewType = 'kenzclub-iframe-$refreshToken';

  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final iframe = web.HTMLIFrameElement()
      ..src = url
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'fullscreen';

    return iframe;
  });

  return HtmlElementView(viewType: viewType);
}
