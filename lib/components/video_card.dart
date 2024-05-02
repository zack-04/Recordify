import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class VideoCard extends StatefulWidget {
  const VideoCard({
    super.key,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.videoUrl,
  });

  final String title;
  final String description;
  final String category;
  final String location;
  final String videoUrl;

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late FlickManager flickManager;
  @override
  void initState() {
    super.initState();
    setState(() {
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.network(widget.videoUrl),
        autoPlay: false,
      );
    });
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10.sp),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            offset: Offset(0, 20),
            blurRadius: 25,
            spreadRadius: -5,
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            offset: Offset(0, 10),
            blurRadius: 10,
            spreadRadius: -5,
          ),
        ],
        // border: Border.all(
        //   color: Color.fromARGB(255, 224, 220, 220),
        //   width: 1,
        //   style: BorderStyle.solid,
        // ),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              width: ScreenUtil().screenWidth,
              height: ScreenUtil().setHeight(250),
              child: FlickVideoPlayer(
                flickManager: flickManager,
                flickVideoWithControls: FlickVideoWithControls(
                  videoFit: BoxFit.contain,
                  
                  controls: FlickLandscapeControls(),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(15),
            color: Color.fromARGB(255, 219, 216, 216),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 20.sp,fontWeight: FontWeight.bold,),
                ),
                SizedBox(height: 5.sp),
                Text(
                  widget.description,
                  style: TextStyle(fontSize: 14.sp),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5.sp),
                Row(
                  children: [
                    Text(
                      widget.category,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(width: 5.sp,),
                    Icon(Icons.circle,size: 5.sp,),
                    SizedBox(width: 5.sp,),
                    Text(
                      widget.location,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
