import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:kosiservice/KosiPages/SignInScreen.dart';
import 'package:video_player/video_player.dart';

import '../KosiPages/SubCateogoryServiceList.dart';
import '../Utils/Pagerouter.dart';

class RecomendationSliderWidget extends StatefulWidget {
  @override
  _RecomendationSliderWidgetState createState() =>
      _RecomendationSliderWidgetState();
}

class _RecomendationSliderWidgetState extends State<RecomendationSliderWidget> {
  List<String> mediaUrls = [];
  List<String> eventList = [];
  List<String>catlist=[];
  List<String>titlelist=[];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> serviceCategories = [];
  List<String> servicesubtitle = [];
  List<String> servicekey = [];
  List<String> servicequotes = [];
  List<List<String>?> serimgvidlist = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromFirebase();
  }

  Future<void> fetchDataFromFirebase() async {
    try {
      final databaseReference = FirebaseDatabase.instance
          .reference()
          .child('KosiService/Recomendation');
      DataSnapshot dataSnapshot =
      await databaseReference.once().then((event) => event.snapshot);

      Map<dynamic, dynamic>? sliderData =
      dataSnapshot.value as Map<dynamic, dynamic>?;

      if (sliderData != null) {
        for (var entry in sliderData.entries) {
          String mediaUrl = entry.value['posterurl'];
          String mediaType = entry.value['mediatype'];
          String eventText = entry.value['posterevent'];
          String cat=entry.value['cat'];
          String title=entry.value['title'];

          if (mediaType == 'image' || mediaType == 'video') {
            mediaUrls.add(mediaUrl);
            eventList.add(eventText);
            catlist.add(cat);
            titlelist.add(title);
          }
        }

        setState(() {});
      } else {
        print('Data is not in the expected format');
      }
    } catch (e) {
      print('Error accessing Firebase: $e');
    }
  }
  Future<void> fetchCatData() async {
    final ref = FirebaseDatabase.instance.ref('KosiService/ServiceFolder');
    try {
      final snapshot = await ref.once();
      if (snapshot.snapshot.value != null) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        for (final entry in data.entries) {
          final title = entry.value['sercatname'];
          final subtitle=entry.value['catmsg'];
          dynamic photosUrlValue = entry.value['serimgvideo'];
          final key=entry.value['key'];
          final quotes=entry.value['quotes'];
          List<String>? imgvideolist;
          if (photosUrlValue is List<dynamic>) {
            imgvideolist = List<String>.from(
                photosUrlValue.map((dynamic item) => item.toString()));
          }
          serviceCategories.add(title);
          servicesubtitle.add(subtitle);
          servicekey.add(key);
          servicequotes.add(quotes);
          serimgvidlist.add(imgvideolist);
        }
        setState(() {
        });
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
      setState(() {
        // Handle the error
      });
    }
  }



  Widget buildCarouselItem(BuildContext context, int index) {
    String mediaUrl = mediaUrls[index];
    String eventText = eventList[index];
    String cattext=catlist[index];
    String titletext=titlelist[index];

    return Builder(
      builder: (BuildContext context) {
        return InkWell(
          child: Card(
            margin: EdgeInsets.all(4),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: mediaUrl.contains('.mp4')
                  ? VideoWidget(videoUrl: mediaUrl)
                  : Image.network(
                mediaUrl,
                fit: BoxFit.cover,
              ),
            ),
          ),
          onTap: () {
            if (eventText != "no") {
              if(cattext=='cat'){

              }else{
                Navigator.push(context, customPageRoute(SubCateogoryServiceList(subcatlistref:eventText,title: titletext,)));
              }

            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return mediaUrls.isNotEmpty
        ? InfiniteCarousel.builder(
      axisDirection: Axis.horizontal,
      controller: InfiniteScrollController(),
      itemCount: mediaUrls.length,
      itemExtent: MediaQuery.of(context).size.width * 0.46,
      itemBuilder: (BuildContext context, int itemIndex, int realIndex) {
        int actualIndex = realIndex % mediaUrls.length;
        return buildCarouselItem(context, actualIndex);
      },
    )
        : SizedBox(); // Return an empty SizedBox if mediaUrls is empty
  }



  }

class VideoWidget extends StatefulWidget {
  final String videoUrl;

  VideoWidget({required this.videoUrl});

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        _controller.play();
        _controller.setVolume(0);
        _controller.setLooping(true);
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: 9 / 21,
      child: VideoPlayer(_controller),
    )
        : Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
