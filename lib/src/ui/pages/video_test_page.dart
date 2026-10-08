import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tradeable_learn_widget/tradeable_learn_widget.dart';

// TEST-ONLY page (used by native instrumentation tests, not production flows).
// Renders VideoEduCorner directly from a VideoEduCornerModel JSON string,
// e.g. '{"video_id": "aammbFGGk68"}'. Falls back to the sample video when the
// payload is missing or invalid.
class VideoTestPage extends StatelessWidget {
  static const fallbackModelJson = '{"video_id": "aammbFGGk68"}';

  final String modelJson;

  const VideoTestPage({super.key, required this.modelJson});

  @override
  Widget build(BuildContext context) {
    dynamic data;
    try {
      data = jsonDecode(modelJson);
    } catch (_) {
      data = null;
    }
    final model = (data is Map && data['video_id'] is String)
        ? VideoEduCornerModel.fromJson(data)
        : VideoEduCornerModel.fromJson(
            jsonDecode(fallbackModelJson) as Map<String, dynamic>);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: VideoEduCorner(model: model, onNextClick: () {}),
      ),
    );
  }
}
