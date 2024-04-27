import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'data/data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  final _createRoomController = TextEditingController();
  String? roomId;

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    Data().onAddRemoteStream = (stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    };
    super.initState();
  }

  @override
  void dispose() {
    _createRoomController.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Web Rtc Social'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          children: [
            TextButton(
                onPressed: () async {
                  Data().openUserMedia(_localRenderer, _remoteRenderer);
                  roomId = await Data().createRoom(_remoteRenderer);
                  _createRoomController.text = roomId!;
                  setState(() {});
                },
                child: const Text('Create Room')),
            TextFormField(
              controller: _createRoomController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
          ],
        ),
      ),
    );
  }
}
