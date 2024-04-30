import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_rtc_social/home/calling_screen.dart';
import 'package:web_rtc_social/home/room_list.dart';

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
  final _data = Data();
  String? roomId;

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    _data.onAddRemoteStream = (stream) {
      _remoteRenderer.srcObject = stream;
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
                  // _data.openUserMedia(_localRenderer, _remoteRenderer);
                  // roomId = await _data.createRoom(_remoteRenderer);
                  // _createRoomController.text = roomId!;
                  // setState(() {});
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CallingScreen(),
                      ));
                },
                child: const Text('Create Room')),
            TextFormField(
              controller: _createRoomController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 50),
            TextButton(
                onPressed: () {
                  // Data().openUserMedia(_localRenderer, _remoteRenderer);
                  // Data().joinRoom(
                  //     _createRoomController.text.trim(), _remoteRenderer);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RoomList(),
                      ));
                },
                child: const Text('Room List')),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                  const SizedBox(width: 30),
                  Expanded(child: RTCVideoView(_remoteRenderer)),
                ],
              ),
            ),
            TextButton(
                onPressed: () {
                  _data.hangUp(_localRenderer);
                },
                child: const Text('End Call'))
          ],
        ),
      ),
    );
  }
}
