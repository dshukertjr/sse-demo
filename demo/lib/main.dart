import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Playground
const supabaseUrl = 'https://yoywhocjyxkyympcvkei.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlveXdob2NqeXhreXltcGN2a2VpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTQzNjQ4MjgsImV4cCI6MjAyOTk0MDgyOH0.2MxOj7snzF647PAO03HXcsDu-vgXeaqohTOHg97We40';

Future<void> main() async {
  // final fetchClient = FetchClient(mode: RequestMode.cors);

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.implicit,
    ),
    // httpClient: fetchClient,
    debug: false,
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SSE Demo',
      home: SSEWidget(),
    );
  }
}

class SSEWidget extends StatefulWidget {
  const SSEWidget({super.key});

  @override
  State<SSEWidget> createState() => _SSEWidgetState();
}

class _SSEWidgetState extends State<SSEWidget> {
  String _responseText = '';
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _responseText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          )),
          Material(
            color: Colors.grey[200],
            child: Padding(
              padding: MediaQuery.of(context)
                  .padding
                  .copyWith(top: 8, left: 8, right: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration:
                          const InputDecoration(border: InputBorder.none),
                      controller: _controller,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      _responseText = '';
                      final text = _controller.text;
                      _controller.clear();

                      final res = await supabase.functions
                          .invoke('sse', body: {'query': text});

                      (res.data as ByteStream)
                          .transform(const Utf8Decoder())
                          .listen((val) {
                        setState(() {
                          if (!_responseText.endsWith('\n') &&
                              _responseText.isNotEmpty) {
                            _responseText += ' ';
                          }
                          _responseText += val;
                        });
                      });
                    },
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
