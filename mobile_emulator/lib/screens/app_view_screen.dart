import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../models/app_config.dart';

class AppViewScreen extends StatefulWidget {
  final AppConfig appConfig;

  const AppViewScreen({
    Key? key,
    required this.appConfig,
  }) : super(key: key);

  @override
  State<AppViewScreen> createState() => _AppViewScreenState();
}

class _AppViewScreenState extends State<AppViewScreen> {
  late final WebViewController _controller;
  bool isLoading = true;
  bool isConnected = true;
  String? errorMessage;
  StreamSubscription? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _setupWebView();
    _setupConnectivity();
  }

  void _setupWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
              errorMessage = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              isLoading = false;
              errorMessage = error.description;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // Allow navigation within the same domain
            final currentUri = Uri.parse(widget.appConfig.appUrl);
            final requestUri = Uri.parse(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.appConfig.appUrl));
  }

  void _setupConnectivity() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        isConnected = result != ConnectivityResult.none;
      });
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  void _reloadApp() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appConfig.appName),
        actions: [
          if (isConnected)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reloadApp,
              tooltip: 'Reload App',
            ),
          IconButton(
            icon: Icon(isConnected ? Icons.wifi : Icons.wifi_off),
            onPressed: () {}, // Empty callback for status indicator
            tooltip: isConnected ? 'Connected' : 'Disconnected',
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _reloadApp,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          if (!isConnected)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Text(
                  'No Internet Connection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
} 