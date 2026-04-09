import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

Widget buildPlatformKenzclubView({
  required Object? controller,
  required String url,
  required int refreshToken,
}) {
  return WebViewWidget(controller: controller! as WebViewController);
}
