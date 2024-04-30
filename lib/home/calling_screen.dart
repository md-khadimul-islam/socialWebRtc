// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_rtc_social/home/data/data.dart';

class CallingScreen extends StatefulWidget {
  const CallingScreen({super.key});

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  final _data = Data();

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();

    super.dispose();
  }

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();
    rebuildLocalRenderer();
    _data.onAddRemoteStream = (stream) {
      _remoteRenderer.srcObject = stream;
    };

    super.initState();
  }

  void rebuildLocalRenderer() async {
    await _data.openUserMedia(_localRenderer, _remoteRenderer);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/background.jpg',
            fit: BoxFit.cover,
            height: double.infinity,
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomIconButton(
                  icon: Icons.volume_up,
                ),
                CustomIconButton(
                  icon: Icons.flip_camera_ios_rounded,
                ),
                CustomIconButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                ),
                CustomIconButton(
                  icon: Icons.keyboard_voice_rounded,
                ),
                CustomIconButton(
                  icon: Icons.videocam,
                )
              ],
            ),
          ),
          Positioned(
            bottom: 120,
            right: 20,
            child: Container(
              height: 300,
              width: 200,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: RTCVideoView(
                    _localRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  const CustomIconButton(
      {super.key, required this.icon, this.onTap, this.color});

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
          shape: const OvalBorder(), color: color ?? Colors.white24),
      child: IconButton(
          onPressed: onTap,
          icon: Icon(
            icon,
            color: Colors.white,
          )),
    );
  }
}
