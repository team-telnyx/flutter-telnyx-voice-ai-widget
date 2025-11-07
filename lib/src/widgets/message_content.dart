
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:telnyx_webrtc/model/transcript_item.dart';
import '../models/widget_theme.dart';

class MessageContent extends StatelessWidget {
  final TranscriptItem item;
  final bool isUser;
  final WidgetTheme theme;
  final Color? textColor;

  const MessageContent({
    super.key,
    required this.item,
    required this.isUser,
    required this.theme,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display text content if available
        if (item.content.isNotEmpty) ...[
          Text(
            item.content,
            style: TextStyle(
              // Use provided textColor if available, otherwise fall back to default logic
              // Slightly reduce opacity for partial messages to indicate they're still being received
              color: (textColor ?? (isUser ? Colors.white : theme.textColor))
                  .withValues(alpha: item.isPartial == true ? 0.8 : 1.0),
              fontSize: 14,
            ),
          ),
          if (item.hasImages()) const SizedBox(height: 8),
        ],
        // Display images if available
        if (item.hasImages()) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: item.imageUrls!.map((imageUrl) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _DataUrlImage(
                  dataUrl: imageUrl,
                  width: 100,
                  height: 100,
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _DataUrlImage extends StatefulWidget {
  const _DataUrlImage({
    required this.dataUrl,
    this.width = 100,
    this.height = 100,
  });

  final String dataUrl;
  final double width;
  final double height;

  @override
  State<_DataUrlImage> createState() => _DataUrlImageState();
}

class _DataUrlImageState extends State<_DataUrlImage> {
  Uint8List? _imageData;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _decodeDataUrl();
  }

  @override
  void didUpdateWidget(_DataUrlImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dataUrl != oldWidget.dataUrl) {
      _decodeDataUrl();
    }
  }

  void _decodeDataUrl() {
    setState(() {
      _imageData = null;
      _error = null;
    });
    try {
      final uri = Uri.parse(widget.dataUrl);
      if (uri.scheme != 'data') {
        throw const FormatException('Invalid scheme: expected "data"');
      }
      if (uri.data == null) {
        throw const FormatException('Data URL contains no image data');
      }
      _imageData = uri.data!.contentAsBytes();
    } catch (e) {
      _error = e;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _imageErrorWidget();
    }

    if (_imageData == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Image.memory(
      _imageData!,
      width: widget.width,
      height: widget.height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _imageErrorWidget(),
    );
  }

  Widget _imageErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[300],
      child: const Icon(Icons.image_not_supported),
    );
  }
}

