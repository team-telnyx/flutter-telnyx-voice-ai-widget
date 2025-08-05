import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../models/widget_theme.dart';

class ErrorDisplayWidget extends StatelessWidget {
  final double width;
  final double height;
  final WidgetTheme theme;
  final VoidCallback onLaunchUrl;

  const ErrorDisplayWidget({
    super.key,
    required this.width,
    required this.height,
    required this.theme,
    required this.onLaunchUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              'An error occurred',
              style: TextStyle(
                color: theme.textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // First error message
            Text(
              'Failed to initialize the Telnyx AI Agent client. Please check your agent ID and ensure that you are connected to the internet.',
              style: TextStyle(
                color: theme.secondaryTextColor,
                fontSize: 14,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            
            // Second error message with link
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  color: theme.secondaryTextColor,
                  fontSize: 14,
                  height: 1.4,
                ),
                children: [
                  const TextSpan(
                    text: 'Make sure that the ',
                  ),
                  TextSpan(
                    text: 'Support Unauthenticated Web Calls',
                    style: TextStyle(
                      color: theme.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = onLaunchUrl,
                  ),
                  const TextSpan(
                    text: ' option is enabled in your Telnyx agent settings.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}