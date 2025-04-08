import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/utils/delay.dart';

class ConnectedWebViewModal extends StatefulWidget {
  final String? modalKey;
  final String url;
  final String redirectUrl;

  final String closeUrl;
  final String pluginUrl;

  const ConnectedWebViewModal({
    super.key,
    this.modalKey,
    required this.url,
    required this.redirectUrl,
  })  : closeUrl = '$redirectUrl/close',
        pluginUrl = '$redirectUrl/#/?dl=plugin';

  @override
  State<ConnectedWebViewModal> createState() => _WebViewModalState();
}

class _WebViewModalState extends State<ConnectedWebViewModal> {
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  HeadlessInAppWebView? headlessWebView;
  late InAppWebViewSettings settings;

  bool _show = false;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    settings = InAppWebViewSettings(
      javaScriptEnabled: true,
    );

    headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
      initialSettings: settings,
      onWebViewCreated: (controller) {
        webViewController = controller;
      },
      shouldOverrideUrlLoading: shouldOverrideUrlLoading,
      onLoadStop: (controller, url) {
        setState(() {
          _show = true;
        });
      },
      onConsoleMessage: kDebugMode ? handleConsoleMessage : null,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // make initial requests here

      handleRunWebView();
    });
  }

  void handleConsoleMessage(
      InAppWebViewController controller, ConsoleMessage message) {
    print('>>>> ${message.message}');
  }

  Future<NavigationActionPolicy?> shouldOverrideUrlLoading(
      InAppWebViewController controller, NavigationAction action) async {
    final uri = Uri.parse(action.request.url.toString());

    if (uri.scheme != 'http' && uri.scheme != 'https') {
      // widget.walletLogic.launchPluginUrl(uri.toString());

      return NavigationActionPolicy.CANCEL;
    }

    if (uri.toString().startsWith(widget.closeUrl)) {
      handleClose();

      return NavigationActionPolicy.CANCEL;
    }

    if (uri.toString().startsWith(widget.redirectUrl) &&
        !uri.toString().startsWith(widget.pluginUrl)) {
      // handleDisplayActionModal(uri);

      return NavigationActionPolicy.CANCEL;
    }

    return NavigationActionPolicy.ALLOW;
  }

  @override
  void dispose() {
    super.dispose();

    headlessWebView?.dispose();
    webViewController = null;
  }

  void handleClose() async {
    handleDismiss(context);
  }

  void handleDismiss(BuildContext context, {String? path}) async {
    if (_isDismissing) {
      return;
    }

    _isDismissing = true;

    webViewController?.stopLoading();

    final navigator = GoRouter.of(context);

    await delay(const Duration(milliseconds: 250));

    navigator.pop(path);
  }

  void handleBack({InAppWebViewController? controller}) async {
    await (controller ?? webViewController)?.goBack();
  }

  void handleForward({InAppWebViewController? controller}) async {
    await (controller ?? webViewController)?.goForward();
  }

  void handleRefresh({InAppWebViewController? controller}) async {
    await (controller ?? webViewController)?.reload();
  }

  void handleRunWebView() async {
    if (headlessWebView == null || headlessWebView!.isRunning()) {
      return;
    }

    headlessWebView!.run();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: CupertinoPageScaffold(
        backgroundColor: primaryColor,
        child: SafeArea(
          bottom: false,
          child: Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                  child: Stack(
                children: [
                  AnimatedOpacity(
                    opacity: _show ? 1 : 0,
                    duration: const Duration(milliseconds: 750),
                    child: _show
                        ? InAppWebView(
                            key: webViewKey,
                            headlessWebView: headlessWebView,
                            initialUrlRequest:
                                URLRequest(url: WebUri(widget.url)),
                            initialSettings: settings,
                            onWebViewCreated: (controller) {
                              headlessWebView = null;
                              webViewController = controller;
                            },
                            shouldOverrideUrlLoading: shouldOverrideUrlLoading,
                            onLoadStop: (controller, url) {
                              setState(() {
                                _show = true;
                              });
                            },
                            onConsoleMessage:
                                kDebugMode ? handleConsoleMessage : null,
                          )
                        : const SizedBox(),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: CupertinoButton(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(22),
                      padding: const EdgeInsets.all(5),
                      onPressed: () => handleDismiss(context),
                      child: Icon(
                        CupertinoIcons.xmark,
                        color: iconColor,
                      ),
                    ),
                  ),
                  if (!_show)
                    Center(
                      child: CupertinoActivityIndicator(
                        color: whiteColor,
                        radius: 15,
                      ),
                    ),
                ],
              )),
            ],
          ),
        ),
      ),
    );
  }
}
