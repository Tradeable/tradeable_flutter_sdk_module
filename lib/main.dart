import 'package:flutter/material.dart';
import 'package:tradeable_flutter_sdk/src/ioswrapper/flutter_bridge.dart';
import 'package:tradeable_flutter_sdk/src/ioswrapper/view_state.dart';
import 'package:tradeable_flutter_sdk/src/models/enums/page_types.dart';
import 'package:tradeable_flutter_sdk/src/ui/pages/topic_list_page.dart';
import 'package:tradeable_flutter_sdk/tradeable_flutter_sdk.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterBridge().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldState> _sideDrawerScaffoldKey =
      GlobalKey<ScaffoldState>();
  bool _isDrawerOpening = false;

  bool _isSideDrawerMode(String mode) {
    final normalized = mode.toLowerCase();
    return normalized == 'sidedrawer' || normalized == 'tradeablesidedrawer';
  }

  int? _resolveTagId(int pageId) {
    for (final id in PageId.values) {
      if (id.topicTagId == pageId) return pageId;
    }

    if (pageId >= 0 && pageId < PageId.values.length) {
      return PageId.values[pageId].topicTagId;
    }

    return null;
  }

  void _openRealEndDrawerIfNeeded(ViewState state) {
    if (!_isSideDrawerMode(state.mode) || _isDrawerOpening) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final scaffold = _sideDrawerScaffoldKey.currentState;
      if (scaffold == null || scaffold.isEndDrawerOpen) return;
      _isDrawerOpening = true;
      scaffold.openEndDrawer();
      _isDrawerOpening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = FlutterBridge().navHandler.state;

    return AnimatedBuilder(
      animation: state,
      builder: (_, __) {
        _openRealEndDrawerIfNeeded(state);

        return MaterialApp(
          navigatorKey: _navigatorKey,
          home: Scaffold(
            backgroundColor:
                state.mode == 'fullscreen' ? Colors.white : Colors.transparent,
            body: _build(state),
          ),
        );
      },
    );
  }

  Widget _build(ViewState state) {
    switch (state.mode) {
      case 'sidedrawer':
      case 'tradeablesidedrawer':
        return _realSideDrawer(state);
      case 'direct':
        return _direct(state);
      case 'card':
        return _card(state);
      case 'fullscreen':
        if (!TFS().isInitialized) {
          return const Center(child: CircularProgressIndicator());
        }
        return TopicDetailPage(topicId: state.topicId);
      default:
        return _direct(state);
    }
  }

  Widget _realSideDrawer(ViewState state) {
    final tagId = _resolveTagId(state.pageId);

    return Scaffold(
      key: _sideDrawerScaffoldKey,
      backgroundColor: Colors.transparent,
      onEndDrawerChanged: (isOpened) {
        if (!isOpened && _isSideDrawerMode(state.mode)) {
          state.update({'mode': 'direct'});
        }
      },
      body: _direct(state),
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width - 32,
        child: SafeArea(
          child: tagId != null
              ? TopicListPage(
                  tagId: tagId,
                  onClose: () {
                    _sideDrawerScaffoldKey.currentState?.closeEndDrawer();
                  },
                )
              : const Center(child: Text('Please provide pageId')),
        ),
      ),
    );
  }

  Widget _direct(ViewState s) {
    return Center(
      child: Container(
        width: s.width,
        height: s.height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(s.text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _card(ViewState s) {
    return GestureDetector(
      onTap: () {
        FlutterBridge.base.invokeMethod('closeCard');
      },
      child: Center(
        child: Container(
          width: s.width,
          height: s.height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(s.text, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
