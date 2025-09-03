import 'package:flutter/material.dart';
import 'package:flutter_telnyx_voice_ai_widget/flutter_telnyx_voice_ai_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telnyx Voice AI Widget - Icon Only Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Icon Only Mode Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Regular Mode Widget:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            TelnyxVoiceAiWidget(
              height: 60,
              width: 300,
              assistantId: 'your-assistant-id',
            ),
            SizedBox(height: 40),
            Text(
              'Icon-Only Mode Widget (as FloatingActionButton):',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 20),
            Text(
              'See the floating action button in the bottom right corner',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: TelnyxVoiceAiWidget(
        assistantId: 'your-assistant-id',
        iconOnlySettings: IconOnlySettings(
          size: 56.0,
          logoIconSettings: LogoIconSettings(
            size: 40.0,
            borderRadius: 20.0,
            backgroundColor: Colors.blue,
          ),
        ),
      ),
    );
  }
}