import 'package:flutter/services.dart';
import 'view_state.dart';

class NavigationHandler {
  final ViewState state = ViewState();

  Future<dynamic> handle(MethodCall call) async {
    switch (call.method) {
      case 'openTradeableSideDrawer':
        _openSideDrawer(call.arguments);
        return null;

      case 'navigateTo':
        state.update(call.arguments);
        return null;

      case 'replaceRoute':
        state.update(call.arguments);
        return null;

      case 'popToRoot':
        state.update(call.arguments);
        return null;

      case 'receiveData':
        state.update(call.arguments);
        return null;

      case 'goBack':
        return null;

      case 'sendData':
        return null;
    }
    return null;
  }

  Future<dynamic> handleLegacy(MethodCall call) async {
    if (call.method == 'setData') {
      state.update(Map<String, dynamic>.from(call.arguments));
    }
    if (call.method == 'openTradeableSideDrawer') {
      _openSideDrawer(call.arguments);
    }
    if (call.method == 'closeCard') {
      SystemNavigator.pop();
    }
    return null;
  }

  void _openSideDrawer(dynamic args) {
    if (args is Map) {
      final payload = Map<String, dynamic>.from(args);
      payload['mode'] = 'sidedrawer';
      state.update(payload);
      return;
    }

    state.update({'mode': 'sidedrawer', 'pageId': args});
  }
}
