import 'dart:developer';

import 'package:flutter/material.dart';
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
  // Connect to a WebSocket server
  final WebSocketChannel channel = WebSocketChannel.connect(
    Uri.parse('wss://echo.websocket.org'),
  );

  List<String> messages = [];

  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    channel.sink.close();
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
            StreamBuilder(
              stream: channel.stream,
              builder: (context, snapshot) {
                // return Text(snapshot.hasData ? '${snapshot.data}' : '');

                if (snapshot.hasData) {
                  messages.add(snapshot.data);
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      return Text(messages[index]);
                    },
                  );
                }

                return Container();
              },
            ),

            ElevatedButton(
              onPressed: () {
                channel.sink.add(_controller.text);
                _controller.clear();
              },
              child: Text('Send message'),
            ),
          ],
        ),
      ),
    );
  }
}
