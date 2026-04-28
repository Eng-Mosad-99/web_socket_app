import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:web_socket_app/chat_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  static const url = 'wss://echo.websocket.org';
  late WebSocketChannel channel;
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  _connectToWebSocket() {
    try {
      // Connect to a WebSocket server
      channel = WebSocketChannel.connect(Uri.parse(url));

      channel.stream
          .listen(
            (message) {
              setState(() {
                messages.add(ChatModel(message: message, time: DateTime.now()));
              });
            },
            onDone: () {
              print('Done');
            },
          )
          .onError((error) {
            print('Error: $error');

            _reconnect();
          });
    } catch (e) {
      print('Failed To Connect ==> ${e.toString()}');
      rethrow;
    }
  }

  void _reconnect() {
    if (_timer != null) {
      _timer = Timer(const Duration(seconds: 3), () {
        _timer = null;
        print('Reconnecting to websocket');
        _connectToWebSocket();
      });
    }
  }

  List<ChatModel> messages = [];

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            TextField(controller: _controller),

            ElevatedButton(
              onPressed: () async {
                if (_controller.text.isNotEmpty) {
                  await channel.ready;
                  channel.sink.add(_controller.text);
                }
                _controller.clear();
              },
              child: Text('Send message'),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      messages[index].message,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(messages[index].time.toString()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
