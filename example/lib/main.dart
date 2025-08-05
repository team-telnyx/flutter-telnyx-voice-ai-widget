import 'package:flutter/material.dart';
import 'package:flutter_telnyx_voice_ai_widget/flutter_telnyx_voice_ai_widget.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _expandedWidthController = TextEditingController();
  final TextEditingController _expandedHeightController = TextEditingController();
  
  String? _assistantId;
  double? _width;
  double? _height;
  double? _expandedWidth;
  double? _expandedHeight;
  bool _showWidget = false;

  @override
  void initState() {
    super.initState();
    _assistantIdController.text = 'demo-assistant-id';
    _widthController.text = '300';
    _heightController.text = '60';
    _expandedWidthController.text = '400';
    _expandedHeightController.text = '300';
    _requestPermissions();
  }
  
  Future<void> _requestPermissions() async {
    // Request microphone permission
    final microphoneStatus = await Permission.microphone.request();
    
    // Request bluetooth permissions for Android 12+
    if (await Permission.bluetoothConnect.isGranted == false) {
      await Permission.bluetoothConnect.request();
    }
    
    if (microphoneStatus.isDenied || microphoneStatus.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Microphone permission is required for voice calls'),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _assistantIdController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _expandedWidthController.dispose();
    _expandedHeightController.dispose();
    super.dispose();
  }

  void _createWidget() {
    final assistantId = _assistantIdController.text.trim();
    final widthText = _widthController.text.trim();
    final heightText = _heightController.text.trim();
    final expandedWidthText = _expandedWidthController.text.trim();
    final expandedHeightText = _expandedHeightController.text.trim();
    
    if (assistantId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an Assistant ID')),
      );
      return;
    }
    
    final width = double.tryParse(widthText);
    final height = double.tryParse(heightText);
    
    if (width == null || height == null || width <= 0 || height <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid width and height')),
      );
      return;
    }
    
    // Parse expanded dimensions (optional)
    double? expandedWidth;
    double? expandedHeight;
    
    if (expandedWidthText.isNotEmpty) {
      expandedWidth = double.tryParse(expandedWidthText);
      if (expandedWidth == null || expandedWidth <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid expanded width')),
        );
        return;
      }
    }
    
    if (expandedHeightText.isNotEmpty) {
      expandedHeight = double.tryParse(expandedHeightText);
      if (expandedHeight == null || expandedHeight <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid expanded height')),
        );
        return;
      }
    }
    
    setState(() {
      _assistantId = assistantId;
      _width = width;
      _height = height;
      _expandedWidth = expandedWidth;
      _expandedHeight = expandedHeight;
      _showWidget = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Telnyx Voice AI Widget Configuration',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Assistant ID input
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
            ),
            const SizedBox(height: 16),
            
            // Width and Height inputs
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Width:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _widthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'e.g. 300',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Height:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'e.g. 60',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Expanded Width and Height inputs
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expanded Width (optional):',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _expandedWidthController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'e.g. 400',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Expanded Height (optional):',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _expandedHeightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'e.g. 300',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Create Widget button
            Center(
              child: ElevatedButton(
                onPressed: _createWidget,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Create Widget',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            // Show widget if created
            if (_showWidget && _assistantId != null && _width != null && _height != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Your Voice AI Widget:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TelnyxVoiceAiWidget(
                  assistantId: _assistantId!,
                  height: _height!,
                  width: _width!,
                  expandedHeight: _expandedHeight,
                  expandedWidth: _expandedWidth,
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
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
                    '1. Enter your assistant ID\n'
                    '2. Set width and height for the collapsed widget\n'
                    '3. Optionally set expanded dimensions (defaults to 2x height)\n'
                    '4. Click "Create Widget" to display the voice AI widget\n'
                    '5. Tap the widget to start a voice conversation\n'
                    '6. Widget expands during calls, conversation view is full screen',
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