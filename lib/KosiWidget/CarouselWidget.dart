import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class CarouselWidget extends StatefulWidget {
  final List<String>? imgvideolist;

  CarouselWidget({Key? key, required this.imgvideolist}) : super(key: key);

  @override
  _CarouselWidgetState createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {

  List<Widget> buildCarouselItems() {
    List<Widget> items = [];

    for (int i = 0; i < (widget.imgvideolist?.length ?? 0); i++) {
      String url = widget.imgvideolist![i];

      if (url.contains('.mp4')) {
        // If it's an MP4 video, create a VideoPlayer widget
        items.add(
           ScreenTypeLayout(
             mobile: Container(
               margin: const EdgeInsets.all(0),
               child: ClipRRect(
                 borderRadius: BorderRadius.circular(0),
                 child: Container(
                   height: 200,
                   child: VideoPlayerWidget(url: url),
                 ),
               ),
             ),
             desktop: Container(
               margin: const EdgeInsets.all(0),
               child: ClipRRect(
                 borderRadius: BorderRadius.circular(0),
                 child: Container(
                   height: 200,
                   child: VideoPlayerWidget(url: url),
                 ),
               ),
             ),

           ),
        );
      } else {
        items.add(
          ScreenTypeLayout(
            mobile: Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Image.network(url, fit: BoxFit.fill,
                  height: 200,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return const SizedBox(
                        width: 130,
                        height: 120,
                        child: Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                  },
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Image.asset(
                      'assets/images/placeholder.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            desktop: Container(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(0),
                child: Image.network(url, fit: BoxFit.fill,
                  height: 450,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return const SizedBox(
                        width: 130,
                        height: 120,
                        child: Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      );
                    }
                  },
                  errorBuilder: (BuildContext context, Object error,
                      StackTrace? stackTrace) {
                    return Image.asset(
                      'assets/images/placeholder.png',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),

          ),
        );
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> carouselItems = buildCarouselItems();
    if (carouselItems.isEmpty) {
      // Return a placeholder widget or an empty container if there are no items
      return Container();
    }
    return ScreenTypeLayout(
      mobile: ExpandableCarousel.builder(
        itemCount: widget.imgvideolist?.length ?? 0,
        itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
          return buildCarouselItems()[itemIndex];
        },
        options: CarouselOptions(
          aspectRatio: 16 / 9,
          viewportFraction: 1.0,
          autoPlay: false,
          allowImplicitScrolling: true,
          pageSnapping: true,
          autoPlayInterval: Duration(seconds: 2),
        ),
      ),
      desktop: ExpandableCarousel.builder(
        itemCount: widget.imgvideolist?.length ?? 0,
        itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) {
          return buildCarouselItems()[itemIndex];
        },
        options: CarouselOptions(
          height:600,
          aspectRatio: 16 / 9,
          viewportFraction: 1.0,
          autoPlay: false,
          allowImplicitScrolling: true,
          pageSnapping: true,
          autoPlayInterval: Duration(seconds: 2),
        ),
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String url;

  VideoPlayerWidget({required this.url});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    _controller.play();
    _initializeVideoPlayerFuture = _controller.initialize();
    _controller.setLooping(true); // Set looping to true so that it repeats
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
