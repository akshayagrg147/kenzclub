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
  int _loadingProgress = 0;
  bool _canGoBack = false;
  bool _canGoForward = false;
  WebResourceError? _lastError;
  String _currentUrl = _homeUri.host;
  int _webRefreshToken = 0;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      _loadingProgress = 100;
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) {
              return;
            }

            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageStarted: (url) {
            if (!mounted) {
              return;
            }

            setState(() {
              _lastError = null;
              _currentUrl = _formatUrl(url);
            });
            _refreshNavigationState();
          },
          onPageFinished: (url) {
            if (!mounted) {
              return;
            }

            setState(() {
              _loadingProgress = 100;
              _currentUrl = _formatUrl(url);
            });
            _refreshNavigationState();
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

  Future<void> _refreshNavigationState() async {
    final controller = _controller;
    if (controller == null) {
      return;
    }

    final canGoBack = await controller.canGoBack();
    final canGoForward = await controller.canGoForward();

    if (!mounted) {
      return;
    }

    setState(() {
      _canGoBack = canGoBack;
      _canGoForward = canGoForward;
    });
  }

  String _formatUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return url;
    }

    return uri.host.isEmpty ? url : uri.host;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Kenzclub',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              _currentUrl,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _canGoBack && _controller != null
                ? () async {
                    await _controller!.goBack();
                    _refreshNavigationState();
                  }
                : null,
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          IconButton(
            onPressed: _canGoForward && _controller != null
                ? () async {
                    await _controller!.goForward();
                    _refreshNavigationState();
                  }
                : null,
            tooltip: 'Forward',
            icon: const Icon(Icons.arrow_forward_ios_rounded),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _lastError = null;
                _loadingProgress = kIsWeb ? 100 : 0;
                if (kIsWeb) {
                  _webRefreshToken++;
                }
              });
              _controller?.reload();
            },
            tooltip: 'Reload',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: _loadingProgress < 100
              ? LinearProgressIndicator(value: _loadingProgress / 100)
              : const SizedBox(height: 3),
        ),
      ),
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
                                  _loadingProgress = 0;
                                });
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
