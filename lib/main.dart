import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:satellite_hex_parsing/models/device_type.dart';
import 'package:satellite_hex_parsing/models/message_type.dart';
import 'package:satellite_hex_parsing/services/parser_service.dart';
import 'package:satellite_hex_parsing/views/widgets/parsed_data_tile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Satellite Message Parser',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.light,
        ),
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.symmetric(vertical: 4),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const SatelliteParserPage(),
    );
  }
}

class SatelliteParserPage extends StatefulWidget {
  const SatelliteParserPage({super.key});

  @override
  State<SatelliteParserPage> createState() => _SatelliteParserPageState();
}

class _SatelliteParserPageState extends State<SatelliteParserPage>
    with TickerProviderStateMixin {
  final TextEditingController _hexController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  DeviceType? _selectedDeviceType;
  String? _selectedMessageType;
  Map<String, dynamic>? _parsedData;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _parseMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _parsedData = null;
    });

    // Add a small delay for better UX
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final parsedData = ParserService.parse(
        hex: _hexController.text.trim(),
        deviceType: _selectedDeviceType!,
        messageType: _selectedMessageType!,
      );

      setState(() {
        _parsedData = parsedData;
        _isLoading = false;
      });

      _animationController.forward();
      _showSuccessMessage('Message parsed successfully!');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Error parsing message: ${e.toString()}');
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _selectedDeviceType = null;
      _selectedMessageType = null;
      _parsedData = null;
      _hexController.clear();
    });
    _animationController.reset();
  }

  String? _validateHexInput(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a hex string';
    }

    final hexPattern = RegExp(r'^[0-9A-Fa-f\s]+$');
    if (!hexPattern.hasMatch(value.replaceAll(' ', ''))) {
      return 'Invalid hex format. Use only 0-9 and A-F characters';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.satellite_alt, size: 28),
            SizedBox(width: 8),
            Text('Satellite Message Parser'),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (_parsedData != null || _hexController.text.isNotEmpty)
            IconButton(
              onPressed: _clearAll,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear all',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Configuration Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.settings,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Configuration',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Device Selection
                      DropdownButtonFormField<DeviceType>(
                        value: _selectedDeviceType,
                        hint: const Text('Select Device Type'),
                        items: DeviceType.values.map((device) {
                          return DropdownMenuItem(
                            value: device,
                            child: Row(
                              children: [
                                const SizedBox(width: 8),
                                Text(device.toString().split('.').last),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (DeviceType? newValue) {
                          setState(() {
                            _selectedDeviceType = newValue;
                            _selectedMessageType = null;
                            _parsedData = null;
                          });
                          _animationController.reset();
                        },
                        decoration: const InputDecoration(
                          labelText: 'Device Type',
                          prefixIcon: Icon(Icons.device_hub),
                        ),
                        validator: (value) => value == null
                            ? 'Please select a device type'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Message Type Dropdown
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: _selectedDeviceType != null ? null : 0,
                        child: _selectedDeviceType != null
                            ? DropdownButtonFormField<String>(
                                value: _selectedMessageType,
                                hint: const Text('Select Message Type'),
                                items:
                                    MessageStructure.getMessageTypes(
                                      _selectedDeviceType!,
                                    ).map((messageType) {
                                      return DropdownMenuItem(
                                        value: messageType,
                                        child: Row(
                                          children: [
                                            const SizedBox(width: 8),
                                            Text(messageType),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedMessageType = newValue;
                                    _parsedData = null;
                                  });
                                  _animationController.reset();
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Message Type',
                                  prefixIcon: Icon(Icons.message),
                                ),
                                validator: (value) => value == null
                                    ? 'Please select a message type'
                                    : null,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Input Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.input,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hex Message Input',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _hexController,
                        maxLines: 2,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9A-Fa-f\s]'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Hex Message',
                          hintText: 'Enter hex string (e.g., A1B2C3D4E5F6...)',
                          prefixIcon: Icon(Icons.code),
                          helperText:
                              'Only hexadecimal characters (0-9, A-F) allowed',
                        ),
                        validator: _validateHexInput,
                        onChanged: (value) {
                          if (_parsedData != null) {
                            setState(() {
                              _parsedData = null;
                            });
                            _animationController.reset();
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Parse Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _parseMessage,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.play_arrow),
                          label: Text(
                            _isLoading ? 'Parsing...' : 'Parse Message',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Results Section
              if (_parsedData != null) ...[
                const SizedBox(height: 16),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.data_object,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Parsed Results',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              Chip(
                                label: Text('${_parsedData!.length} fields'),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          ..._parsedData!.entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: ParsedDataTile(
                                label: entry.key,
                                value: entry.value,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hexController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
