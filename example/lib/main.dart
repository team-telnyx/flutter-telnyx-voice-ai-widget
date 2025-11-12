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
  final TextEditingController _iconSizeController = TextEditingController();
  
  String? _assistantId;
  double? _width;
  double? _height;
  double? _expandedWidth;
  double? _expandedHeight;
  double? _iconSize;
  bool _showWidget = false;
  bool _iconOnlyMode = false;

  @override
  void initState() {
    super.initState();
    _assistantIdController.text = 'demo-assistant-id';
    _widthController.text = '300';
    _heightController.text = '60';
    _expandedWidthController.text = '400';
    _expandedHeightController.text = '300';
    _iconSizeController.text = '56';
    _requestPermissions();
  }
  
  Future<void> _requestPermissions() async {
    // Request microphone permission at launch (required for voice calls)
    final micStatus = await Permission.microphone.request();

    // Request bluetooth permissions for Android 12+
    if (await Permission.bluetoothConnect.isGranted == false) {
      await Permission.bluetoothConnect.request();
    }

    // Only show snackbar if microphone permission was denied
    if (micStatus.isDenied || micStatus.isPermanentlyDenied) {
      _showPermissionSnackbar('Microphone permission is required for voice calls');
    }

    // Note: Camera and photo library permissions are requested on-demand
    // when the user attempts to use those features, not at launch
  }

  void _showPermissionSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Settings',
            onPressed: () => openAppSettings(),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _assistantIdController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _expandedWidthController.dispose();
    _expandedHeightController.dispose();
    _iconSizeController.dispose();
    super.dispose();
  }

  void _createWidget() {
    final assistantId = _assistantIdController.text.trim();
    
    if (assistantId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an Assistant ID')),
      );
      return;
    }
    
    if (_iconOnlyMode) {
      // Icon-only mode validation
      final iconSizeText = _iconSizeController.text.trim();
      final iconSize = double.tryParse(iconSizeText);
      
      if (iconSize == null || iconSize <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid icon size')),
        );
        return;
      }
      
      setState(() {
        _assistantId = assistantId;
        _iconSize = iconSize;
        _showWidget = true;
      });
    } else {
      // Regular mode validation
      final widthText = _widthController.text.trim();
      final heightText = _heightController.text.trim();
      final expandedWidthText = _expandedWidthController.text.trim();
      final expandedHeightText = _expandedHeightController.text.trim();
      
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
            
            // Mode selection
            Row(
              children: [
                const Text(
                  'Widget Mode:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: _iconOnlyMode,
                        onChanged: (value) {
                          setState(() {
                            _iconOnlyMode = value!;
                          });
                        },
                      ),
                      const Text('Regular'),
                      const SizedBox(width: 16),
                      Radio<bool>(
                        value: true,
                        groupValue: _iconOnlyMode,
                        onChanged: (value) {
                          setState(() {
                            _iconOnlyMode = value!;
                          });
                        },
                      ),
                      const Text('Icon Only'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Icon size input (only for icon-only mode)
            if (_iconOnlyMode) ...[
              const Text(
                'Icon Size:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _iconSizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 56',
                  helperText: 'Size of the circular icon widget',
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Width and Height inputs (only for regular mode)
            if (!_iconOnlyMode) ...[
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
            ],
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
            if (_showWidget && _assistantId != null) ...[
              const Divider(),
              const SizedBox(height: 16),
              Text(
                _iconOnlyMode ? 'Your Voice AI Widget (Icon Only Mode):' : 'Your Voice AI Widget (Regular Mode):',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: _iconOnlyMode
                    ? (_iconSize != null
                        ? TelnyxVoiceAiWidget(
                            assistantId: _assistantId!,
                            iconOnlySettings: IconOnlySettings(
                              size: _iconSize!,
                              logoIconSettings: LogoIconSettings(
                                size: _iconSize! * 0.6, // Icon size is 60% of widget size
                                borderRadius: _iconSize! / 2, // Circular
                               // backgroundColor: Colors.blue.shade100,
                                // borderColor: Colors.blue.shade300,
                                borderWidth: 2,
                              ),
                            ),
                          )
                        : const Text('Please create widget with icon-only mode selected'))
                    : (_width != null && _height != null
                        ? TelnyxVoiceAiWidget(
                            assistantId: _assistantId!,
                            height: _height!,
                            width: _width!,
                            expandedHeight: _expandedHeight,
                            expandedWidth: _expandedWidth,
                            /*startCallTextStyling: TextStyle(
                              color: Colors.red,
                              fontSize: 24,
                              fontWeight: FontWeight.w500,
                            ),
                            logoIconSettings: LogoIconSettings(
                              avatarUrl: 'https://example.com/avatar.png',
                              size: 12,
                              borderRadius: 20,
                              backgroundColor: Colors.blue.shade100,
                              borderColor: Colors.blue.shade300,
                              borderWidth: 2,
                            ),
                            widgetSettingOverride: WidgetSettings(
                              startCallText: "Let's go!",
                              logoIconUrl: 'https://example.com/logo.png',
                            ),*/
                          )
                        : const Text('Please create widget with regular mode selected')),
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
                    '2. Choose between Regular Mode or Icon Only Mode\n'
                    '3. For Regular Mode: Set width/height and optional expanded dimensions\n'
                    '4. For Icon Only Mode: Set the icon size (e.g., 56 for FAB-style)\n'
                    '5. Click "Create Widget" to display the voice AI widget\n'
                    '6. Tap the widget to start a voice conversation\n'
                    '7. Regular mode expands during calls, Icon Only mode goes full screen immediately\n'
                    '8. Icon Only mode shows red warning icon on errors',
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