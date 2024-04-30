import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_rtc_social/home/data/data.dart';
import 'package:web_rtc_social/home/home.dart';

class JoinCallPage extends StatefulWidget {
  const JoinCallPage({super.key, required this.id});

  final String id;

  @override
  State<JoinCallPage> createState() => _JoinCallPageState();
}

class _JoinCallPageState extends State<JoinCallPage> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  final _data = Data();

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
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Join Call Page'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              TextButton(
                onPressed: () {
                  // _data.openUserMedia(
                  //   _localRenderer,
                  //   _remoteRenderer,
                  // );
                  _data.joinRoom(widget.id, _remoteRenderer);
                  setState(() {});
                },
                child: const Text('Join Call'),
              ),
              const SizedBox(width: 30),
              TextButton(
                onPressed: () {
                  _data.hangUp(_localRenderer);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ));
                },
                child: const Text('End Call'),
              ),
            ],
          ),
          const SizedBox(height: 100),
          Expanded(
            child: Row(
              children: [
                Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                const SizedBox(width: 30),
                Expanded(child: RTCVideoView(_remoteRenderer)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
