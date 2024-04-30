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

  // Create Room Part
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
    peerConnection?.onTrack = (event) {
      event.streams[0].getTracks().forEach((track) {
        remoteStream?.addTrack(track);
      });
    };

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

    roomRef
        .collection(DBHelper.calleeCollection)
        .snapshots()
        .listen((snapshot) {
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
    this.roomId = roomId;
    return roomId;
  }

  // Join Room Part

  Future<void> joinRoom(String roomId, RTCVideoRenderer remoteRenderer) async {
    final roomRef = DBHelper.db.collection(DBHelper.collectionRoom).doc(roomId);
    final roomSnapshot = await roomRef.get();

    log('this romm id:  ${roomRef.toString()}');
    this.roomId = roomId;

    if (roomSnapshot.exists) {
      // Create Peer Connection
      peerConnection = await createPeerConnection(configuration);

      // RegisterPeerConnection
      registerPeerConnectionListeners();

      // Track Add in Local Stream
      localStream?.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream!);
      });

      // Code for collecting ICE candidates below
      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      peerConnection!.onIceCandidate = (RTCIceCandidate? candidate) {
        // Signaling Server Part
        if (candidate == null) {
          log('onIceCandidate: complete!');
          return;
        }
        log('onIceCandidate: ${candidate.toMap()}');
        calleeCandidatesCollection.add(candidate.toMap());
      };

      // Add track in Remote Stream
      peerConnection?.onTrack = (RTCTrackEvent event) {
        log('Got remote track: ${event.streams[0]}');
        event.streams[0].getTracks().forEach((track) {
          log('Add a track to the remoteStream: $track');
          remoteStream?.addTrack(track);
        });
      };

      // Creating SDP and set Signaling Server
      var data = roomSnapshot.data() as Map<String, dynamic>;
      log('Got offer $data');
      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(
          RTCSessionDescription(offer['sdp'], offer['type']));
      var answer = await peerConnection!.createAnswer();
      log('Created Answer $answer');
      await peerConnection!.setLocalDescription(answer);

      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp}
      };

      await roomRef.update(roomWithAnswer);
      // Finished creating SDP answer

      // Listening for remote ICE candidates below
      roomRef
          .collection(DBHelper.callerCollection)
          .snapshots()
          .listen((snapshot) {
        for (var document in snapshot.docChanges) {
          var data = document.doc.data() as Map<String, dynamic>;
          log(data.toString());
          log('Got new remote ICE candidate: $data');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      });
    }
  }

  // Hang UP
  Future<void> hangUp(RTCVideoRenderer localVideo) async {
    List<MediaStreamTrack> tracks = localVideo.srcObject!.getTracks();
    for (var track in tracks) {
      track.stop();
    }

    if (remoteStream != null) {
      remoteStream!.getTracks().forEach((track) => track.stop());
    }
    if (peerConnection != null) peerConnection!.close();

    if (roomId != null) {
      var roomRef = DBHelper.db.collection(DBHelper.collectionRoom).doc(roomId);
      log('This is roomRef: $roomRef');
      var calleeCandidates =
          await roomRef.collection(DBHelper.calleeCollection).get();
      for (var document in calleeCandidates.docs) {
        document.reference.delete();
      }

      var callerCandidates =
          await roomRef.collection(DBHelper.callerCollection).get();
      for (var document in callerCandidates.docs) {
        document.reference.delete();
      }

      await roomRef.delete();
    }

    localStream!.dispose();
    remoteStream?.dispose();
  }

  // mendetory this part
  // Future<void> openUserMedia(
  //   RTCVideoRenderer localVideo,
  //   RTCVideoRenderer remoteVideo,
  // ) async {
  //   var stream = await navigator.mediaDevices
  //       .getUserMedia({'video': true, 'audio': false});

  //   localVideo.srcObject = stream;
  //   localStream = stream;

  //   remoteVideo.srcObject = await createLocalMediaStream('key');
  // }

  Future<void> openUserMedia(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
    bool isFrontCamera,
    bool isMicOn,
    bool isCameraOn,
  ) async {
    // Get user media stream
    var stream = await navigator.mediaDevices.getUserMedia({
      'video': {
        'facingMode': isFrontCamera ? 'user' : 'environment',
        'audio': isMicOn,
      },
      'audio': isMicOn,
    });

    // Assign the stream to the local video renderer
    localVideo.srcObject = stream;
    localStream = stream;

    // Toggle local camera
    if (!isCameraOn) {
      localVideo.srcObject = null;
    } else {
      localVideo.srcObject = stream;
    }

    // Toggle local microphone
    if (!isMicOn) {
      // Mute microphone
      stream.getAudioTracks().forEach((track) => track.enabled = false);
    }

    // Toggle remote video
    if (!isCameraOn) {
      remoteVideo.srcObject = null;
    } else {
      // Here, 'createLocalMediaStream' is replaced with the appropriate method
      // to create a remote media stream. You might need to replace it with the
      // correct method from your application.
      remoteVideo.srcObject = await createLocalMediaStream('key');
    }
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
