import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_rtc_social/home/calling_screen.dart';
import 'package:web_rtc_social/home/data/data.dart';
import 'package:web_rtc_social/home/data/db_helper.dart';

class RoomList extends StatefulWidget {
  const RoomList({super.key});

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  late Stream<QuerySnapshot> _documentStream;
  final _data = Data();
  final _remoteRenderer = RTCVideoRenderer();

  @override
  void initState() {
    _documentStream =
        DBHelper.db.collection(DBHelper.collectionRoom).snapshots();
    _remoteRenderer.initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: const Text('Room List')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _documentStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // or some other loading indicator
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No documents found.'));
          }
          // If data is available, display it
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              // You can access individual document fields using document.data()
              // For example, document.data()['field_name']
              return InkWell(
                onTap: () {
                  _data.joinRoom(document.id, _remoteRenderer);
                  log('this is room id: ${document.id}');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CallingScreen(
                          data: _data,
                          remote: _remoteRenderer,
                        ),
                      ));
                },
                child: ListTile(
                  title: Text(document.id), // Assuming document ID is displayed
                  // Display document data
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
