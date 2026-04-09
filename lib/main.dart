import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'platform_kenzclub_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KenzclubApp());
}

class KenzclubApp extends StatelessWidget {
  const KenzclubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kenzclub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0E4D92)),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        useMaterial3: true,
      ),
      home: const KenzclubWebViewPage(),
    );
  }
}

class KenzclubWebViewPage extends StatefulWidget {
  const KenzclubWebViewPage({super.key});

  @override
  State<KenzclubWebViewPage> createState() => _KenzclubWebViewPageState();
}

class _KenzclubWebViewPageState extends State<KenzclubWebViewPage> {
  static final Uri _homeUri = Uri.parse('https://kenzclub.com');

  WebViewController? _controller;
  WebResourceError? _lastError;
  int _webRefreshToken = 0;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) return;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (!mounted) {
              return;
            }

            setState(() {
              _lastError = null;
            });
          },
          onWebResourceError: (error) {
            if (!mounted) {
              return;
            }

            setState(() {
              _lastError = error;
            });
          },
        ),
      )
      ..loadRequest(_homeUri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          buildPlatformKenzclubView(
            controller: _controller,
            url: _homeUri.toString(),
            refreshToken: _webRefreshToken,
          ),
          if (_lastError != null)
            ColoredBox(
              color: theme.scaffoldBackgroundColor,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wifi_off_rounded,
                              size: 40,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Unable to load Kenzclub',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _lastError!.description,
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () {
                                setState(() {
                                  _lastError = null;
                                  if (kIsWeb) {
                                    _webRefreshToken++;
                                  }
                                });
                                if (kIsWeb) {
                                  return;
                                }
                                _controller?.loadRequest(_homeUri);
                              },
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
