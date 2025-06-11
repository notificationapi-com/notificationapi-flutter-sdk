import 'package:flutter/material.dart';
import 'package:notificationapi_flutter_sdk/notificationapi_flutter_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotificationAPI Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NotificationAPIExample(),
    );
  }
}

class NotificationAPIExample extends StatefulWidget {
  const NotificationAPIExample({super.key});

  @override
  State<NotificationAPIExample> createState() => _NotificationAPIExampleState();
}

class _NotificationAPIExampleState extends State<NotificationAPIExample> {
  final List<String> _notifications = [];
  final List<String> _logs = [];
  bool _isInitialized = false;
  bool _showForegroundNotifications = true;
  bool _autoRequestPermission = true;
  String _userId = 'userA';
  String _clientId = 'mfu066mcj317z3mjmnk7wvngww';

  @override
  void initState() {
    super.initState();
    _setupNotificationListeners();
  }

  void _setupNotificationListeners() {
    // Listen for foreground notifications
    NotificationAPI.onMessage.listen((notification) {
      setState(() {
        _notifications.insert(
          0,
          'Foreground: ${notification.title} - ${notification.body}',
        );
        _logs.insert(
          0,
          'Received foreground notification: ${notification.title}',
        );
      });
    });

    // Listen for notification taps (when user opens app via notification)
    NotificationAPI.onMessageOpenedApp.listen((notification) {
      setState(() {
        _notifications.insert(
          0,
          'Opened: ${notification.title} - ${notification.body}',
        );
        _logs.insert(0, 'App opened via notification: ${notification.title}');
      });

      // Handle deep linking if needed
      if (notification.deepLink != null) {
        _logs.insert(0, 'Deep link: ${notification.deepLink}');
      }
    });
  }

  Future<void> _initializeNotificationAPI() async {
    print(
        'Initializing NotificationAPI for user: $_userId in client: $_clientId');

    try {
      setState(() {
        _logs.insert(0,
            'Initializing NotificationAPI for user: $_userId in client: $_clientId');
      });

      await NotificationAPI.setup(
        clientId: _clientId,
        userId: _userId,
        autoRequestPermission: _autoRequestPermission,
        showForegroundNotifications: _showForegroundNotifications,
      );

      setState(() {
        _isInitialized = NotificationAPI.isReady;
        _logs.insert(0, 'NotificationAPI initialized successfully!');
        _logs.insert(0, 'Current user: ${NotificationAPI.currentUser}');
      });

      _showMessage('NotificationAPI initialized successfully!');
    } catch (e) {
      setState(() {
        _isInitialized = false;
        _logs.insert(0, 'Error initializing NotificationAPI: $e');
      });
      _showMessage('Error: $e');
    }
  }

  Future<void> _requestPermission() async {
    try {
      setState(() {
        _logs.insert(0, 'Requesting notification permission...');
      });

      final granted = await NotificationAPI.requestPermission();

      setState(() {
        _logs.insert(0, 'Permission ${granted ? 'granted' : 'denied'}');
      });

      _showMessage('Permission ${granted ? 'granted' : 'denied'}');
    } catch (e) {
      setState(() {
        _logs.insert(0, 'Error requesting permission: $e');
      });
      _showMessage('Error: $e');
    }
  }

  void _toggleForegroundNotifications() {
    setState(() {
      _showForegroundNotifications = !_showForegroundNotifications;
      _logs.insert(
        0,
        'Foreground notifications ${_showForegroundNotifications ? 'enabled' : 'disabled'}',
      );
    });

    NotificationAPI.setShowForegroundNotifications(
      _showForegroundNotifications,
    );
    _showMessage(
      'Foreground notifications ${_showForegroundNotifications ? 'enabled' : 'disabled'}',
    );
  }

  void _clearLogs() {
    setState(() {
      _logs.clear();
      _notifications.clear();
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('NotificationAPI Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Configuration Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Client ID',
                        hintText: 'Enter your NotificationAPI client ID',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _clientId = value;
                        });
                      },
                      controller: TextEditingController(text: _clientId),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'User ID',
                        hintText: 'Enter user identifier',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _userId = value;
                        });
                      },
                      controller: TextEditingController(text: _userId),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            title: const Text('Show Foreground Notifications'),
                            value: _showForegroundNotifications,
                            onChanged: (value) {
                              setState(() {
                                _showForegroundNotifications = value;
                              });
                              if (_isInitialized) {
                                NotificationAPI.setShowForegroundNotifications(
                                    value);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SwitchListTile(
                            title: const Text('Auto Request Permission'),
                            value: _autoRequestPermission,
                            onChanged: (value) {
                              setState(() {
                                _autoRequestPermission = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Initialize Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _initializeNotificationAPI,
                style: ElevatedButton.styleFrom(
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: Text(
                    _isInitialized ? 'Reinitialize SDK' : 'Initialize SDK'),
              ),
            ),
            const SizedBox(height: 24),

            // Status Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      _isInitialized ? Icons.check_circle : Icons.cancel,
                      color: _isInitialized ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isInitialized ? 'Initialized' : 'Not Initialized',
                      style: TextStyle(
                        color: _isInitialized ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _clearLogs,
                    child: const Text('Clear Logs'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Logs and Notifications
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      tabs: [
                        Tab(text: 'Notifications'),
                        Tab(text: 'Logs'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Notifications Tab
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Received Notifications',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: _notifications.isEmpty
                                        ? const Center(
                                            child: Text(
                                              'No notifications received yet',
                                            ),
                                          )
                                        : ListView.builder(
                                            itemCount: _notifications.length,
                                            itemBuilder: (context, index) {
                                              return Card(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 2,
                                                ),
                                                child: ListTile(
                                                  leading: const Icon(
                                                    Icons.notifications,
                                                  ),
                                                  title: Text(
                                                    _notifications[index],
                                                  ),
                                                  dense: true,
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Logs Tab
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Debug Logs',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: _logs.isEmpty
                                        ? const Center(
                                            child: Text('No logs yet'),
                                          )
                                        : ListView.builder(
                                            itemCount: _logs.length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 2,
                                                ),
                                                child: Text(
                                                  '${DateTime.now().toString().substring(11, 19)}: ${_logs[index]}',
                                                  style: const TextStyle(
                                                    fontFamily: 'monospace',
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
