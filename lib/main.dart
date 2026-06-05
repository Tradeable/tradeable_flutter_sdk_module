import 'package:flutter/material.dart';
import 'package:tradeable_flutter_sdk/src/ioswrapper/flutter_bridge.dart';
import 'package:tradeable_flutter_sdk/src/ioswrapper/view_state.dart';
import 'package:tradeable_flutter_sdk/src/models/enums/page_types.dart';
import 'package:tradeable_flutter_sdk/src/ui/pages/topic_list_page.dart';
import 'package:tradeable_flutter_sdk/src/ui/widgets/tradeable_right_side_drawer.dart';
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
  bool _isSideDrawerOpen = false;

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

  void _openSideDrawerIfNeeded(BuildContext context, ViewState state) {
    if (!_isSideDrawerMode(state.mode) || _isSideDrawerOpen) return;

    final tagId = _resolveTagId(state.pageId);
    if (tagId == null) return;

    _isSideDrawerOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TradeableRightSideDrawer.open(
        context: context,
        drawerBorderRadius: 24,
        body: TopicListPage(
          tagId: tagId,
          onClose: () {
            Navigator.of(context).pop();
          },
        ),
      );

      if (!mounted) return;

      _isSideDrawerOpen = false;
      state.update({'mode': 'direct'});
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = FlutterBridge().navHandler.state;

    return AnimatedBuilder(
      animation: state,
      builder: (_, __) {
        _openSideDrawerIfNeeded(context, state);

        return MaterialApp(
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
        return const SizedBox.shrink();
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
