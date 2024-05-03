import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class CustomStateManage extends ChangeNotifier
    implements ValueListenable<CallHolderAction> {
  CallHolderAction action = CallHolderAction(
      isFrontCameraOpen: true,
      isMicrophoneOpen: true,
      isVideoEnable: true,
      speakerToggle: true,
      timer: '00:00');

  @override
  CallHolderAction get value => action;

  void updateValue(
      {bool? isFrontCamera,
      bool? isMicroPhone,
      bool? isVideo,
      bool? speakerToggle}) {
    action = action.copyWith(
        isVideoEnable: isVideo,
        isFrontCameraOpen: isFrontCamera,
        speakerToggle: speakerToggle,
        isMicrophoneOpen: isMicroPhone);
    notifyListeners();
  }

  build(
      {required Function(BuildContext context, CallHolderAction value)
          builder}) {
    return ValueListenableBuilder(
      valueListenable: this,
      builder: (context, value, child) => builder(context, value),
    );
  }
}

class CallHolderAction {
  final bool isFrontCameraOpen, isMicrophoneOpen, isVideoEnable, speakerToggle;
  final String timer;

  CallHolderAction(
      {required this.isFrontCameraOpen,
      required this.isMicrophoneOpen,
      required this.isVideoEnable,
      required this.speakerToggle,
      required this.timer});

  copyWith(
      {bool? isFrontCameraOpen,
      bool? isMicrophoneOpen,
      bool? isVideoEnable,
      bool? speakerToggle,
      String? timer}) {
    return CallHolderAction(
        isFrontCameraOpen: isFrontCameraOpen ?? this.isFrontCameraOpen,
        isMicrophoneOpen: isMicrophoneOpen ?? this.isMicrophoneOpen,
        isVideoEnable: isVideoEnable ?? this.isVideoEnable,
        speakerToggle: speakerToggle ?? this.speakerToggle,
        timer: timer ?? this.timer);
  }
}
