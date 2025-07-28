import 'package:flutter/material.dart';
import 'package:flutter_telnyx_voice_ai_widget/flutter_telnyx_voice_ai_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Telnyx Voice AI Widget Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Telnyx Voice AI Widget Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _assistantIdController = TextEditingController();
  String _assistantId = 'demo-assistant-id';

  @override
  void initState() {
    super.initState();
    _assistantIdController.text = _assistantId;
  }

  @override
  void dispose() {
    _assistantIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Telnyx Voice AI Widget Demo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Assistant ID:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _assistantIdController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter assistant ID',
              ),
              onChanged: (value) {
                setState(() {
                  _assistantId = value;
                });
              },
            ),
            const SizedBox(height: 32),
            
            const Text(
              'Widget Examples:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // Small widget example
            const Text('Small Widget (300x60):'),
            const SizedBox(height: 8),
            Center(
              child: TelnyxVoiceAiWidget(
                height: 60,
                width: 300,
                assistantId: _assistantId,
              ),
            ),
            const SizedBox(height: 24),
            
            // Medium widget example
            const Text('Medium Widget (350x70):'),
            const SizedBox(height: 8),
            Center(
              child: TelnyxVoiceAiWidget(
                height: 70,
                width: 350,
                assistantId: _assistantId,
              ),
            ),
            const SizedBox(height: 24),
            
            // Large widget example
            const Text('Large Widget (400x80):'),
            const SizedBox(height: 8),
            Center(
              child: TelnyxVoiceAiWidget(
                height: 80,
                width: 400,
                assistantId: _assistantId,
              ),
            ),
            
            const Spacer(),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Instructions:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Enter your assistant ID above\n'
                    '2. Tap any widget to start a conversation\n'
                    '3. The widget will expand during the call\n'
                    '4. Tap the expanded widget to view the conversation\n'
                    '5. Use mute/unmute and end call controls',
                    style: TextStyle(color: Colors.blue),
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