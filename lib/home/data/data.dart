import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_rtc_social/home/data/db_helper.dart';

typedef StreamStateCallback = void Function(MediaStream stream);

class Data {
  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  StreamStateCallback? onAddRemoteStream;
  String? currentRoomText;
  String? roomId;

  Future<String> createRoom(RTCVideoRenderer remoteRenderer) async {
    final roomRef = DBHelper.db.collection(DBHelper.collectionRoom).doc();

    // 1st create peer connection
    peerConnection = await createPeerConnection(configuration);

    // 2nd register peer connection
    registerPeerConnectionListeners();

    // 3rd add track in local stream
    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    final callerCollection = roomRef.collection(DBHelper.callerCollection);

    // 4th create and add onIceCandidate
    peerConnection?.onIceCandidate = (candidate) {
      callerCollection.add(
          candidate.toMap()); //this candidate add firebase or signaling server
    };

    // 5th create offer and set local description
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    // this part work for signaling server

    Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};

    await roomRef.set(roomWithOffer);
    var roomId = roomRef.id;

    log('New room created with SDK offer. Room ID: $roomId');
    currentRoomText = 'Current room is $roomId - You are the caller!';

    // 6th create onTrack and set remote stream
    // peerConnection?.onTrack = (event) {
    //   event.streams[0].getTracks().forEach((track) {
    //     remoteStream?.addTrack(track);
    //   });
    // };

    // 7th Listening for remote session description below

    roomRef.snapshots().listen((snapshot) async {
      Map<String, dynamic> data = snapshot.data()
          as Map<String, dynamic>; // this data comming from signaling server

      // data from signaling server or fireabse collection snapshot data
      if (peerConnection?.getRemoteDescription() != null &&
          data['answer'] != null) {
        var answer = RTCSessionDescription(
          data['answer']['sdp'], // sdp
          data['answer']['type'], // type
        ); // data['answer'] comming from signaling server

        // now set this answer remote description
        await peerConnection?.setRemoteDescription(answer);
      }
    });

    // 8th Listen for remote Ice candidates below

    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          log('Got new remote ICE candidate: ${jsonEncode(data)}');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      }
    });
    return roomId;
  }

  void joinRoom(String roomId, RTCVideoRenderer remoteRenderer) async {
    final roomRef = DBHelper.db.collection(DBHelper.collectionRoom).doc();
    final roomSnapshot = await roomRef.get();

    if (roomSnapshot.exists) {
      peerConnection = await createPeerConnection(configuration);
    }
  }

  // mendetory this part
  Future<void> openUserMedia(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    var stream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': false});

    localVideo.srcObject = stream;
    localStream = stream;

    remoteVideo.srcObject = await createLocalMediaStream('key');
  }

  void registerPeerConnectionListeners() {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      log('ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      log('Connection state change: $state');
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      log('Signaling state change: $state');
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      log('ICE connection state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      log("Add remote stream");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };
  }
}
