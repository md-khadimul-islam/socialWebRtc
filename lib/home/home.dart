// ignore_for_file: use_build_context_synchronously

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
  final _createRoomController = TextEditingController();
  final _remoteRenderer = RTCVideoRenderer();
  final _data = Data();
  String? roomId;

  @override
  void dispose() {
    _createRoomController.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _remoteRenderer.initialize();
    super.initState();
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
                  roomId = await _data.createRoom(_remoteRenderer);
                  _createRoomController.text = roomId!;
                  setState(() {});
                  Future.delayed(const Duration(seconds: 4), () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CallingScreen(
                            data: _data,
                          ),
                        ));
                  });
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
          ],
        ),
      ),
    );
  }
}
