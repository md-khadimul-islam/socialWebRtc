// ignore_for_file: unnecessary_null_comparison

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_rtc_social/home/data/custom_state_management.dart';
import 'package:web_rtc_social/home/data/data.dart';

class CallingScreen extends StatefulWidget {
  const CallingScreen({super.key, required this.data});

  final Data data;

  @override
  State<CallingScreen> createState() => _CallingScreenState();
}

class _CallingScreenState extends State<CallingScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();

  final _stateManage = CustomStateManage();

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    // widget.data.dispose();
    log('this dispose call');
    super.dispose();
  }

  @override
  void initState() {
    // _localRenderer.initialize();
    // _remoteRenderer.initialize();
    _initRenderers();
    // rebuildLocalRenderer();
    widget.data.onAddRemoteStream = (stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    };

    super.initState();
  }

  Future<void> _initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
    _setupStream();
  }

  void _setupStream() async {
    await widget.data.openUserMedia(_localRenderer, _remoteRenderer);
    // widget.data.onAddRemoteStream = (stream) {
    //   _remoteRenderer.srcObject = stream;
    //   setState(() {});
    // };
  }

  // void rebuildLocalRenderer() async {
  //   await widget.data.openUserMedia(_localRenderer, _remoteRenderer);
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
  //     setState(() {});
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          RTCVideoView(
            _remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stateManage.build(builder: (context, value) {
                  widget.data
                      .loudspeakerToggle(isSpeakerOn: value.speakerToggle);
                  return CustomIconButton(
                    icon: value.speakerToggle
                        ? Icons.volume_down
                        : Icons.volume_up,
                    onTap: () {
                      _stateManage.updateValue(
                          speakerToggle: !value.speakerToggle);
                    },
                  );
                }),
                CustomIconButton(
                  icon: Icons.flip_camera_ios_rounded,
                  onTap: () {
                    widget.data.switchCamera();
                  },
                ),
                CustomIconButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: () {
                    widget.data.hangUp(_localRenderer);

                    Navigator.pop(context);
                  },
                ),
                _stateManage.build(builder: (context, value) {
                  widget.data
                      .toggleMicrophone(isMicOpen: value.isMicrophoneOpen);
                  return CustomIconButton(
                    icon: value.isMicrophoneOpen
                        ? Icons.keyboard_voice_rounded
                        : Icons.mic_off,
                    onTap: () {
                      _stateManage.updateValue(
                          isMicroPhone: !value.isMicrophoneOpen);
                    },
                  );
                }),
                _stateManage.build(builder: (context, value) {
                  widget.data.toggleVideo(isVideoOpen: value.isVideoEnable);
                  return CustomIconButton(
                    icon: value.isVideoEnable
                        ? Icons.videocam
                        : Icons.videocam_off,
                    onTap: () {
                      _stateManage.updateValue(isVideo: !value.isVideoEnable);
                    },
                  );
                })
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
