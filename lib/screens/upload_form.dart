import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:recordify/provider/app_provider.dart';
import 'package:recordify/screens/success_screen.dart';
import 'package:video_player/video_player.dart';
// import 'package:video_thumb_getter/video_thumbnail.dart';

class UploadForm extends StatefulWidget {
  const UploadForm(
      {super.key,
      required this.videoFile,
      required this.address,
      required this.videoName});

  final XFile videoFile;
  final String address;
  final String videoName;

  @override
  State<UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {
  int step = 1;
  late FlickManager flickManager;

  TextEditingController locationController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController categoryController = TextEditingController();

  List<String> categories = [
    'Gaming',
    'Comedy',
    'Music',
    'Sports',
    'Entertainment',
    'News',
    'Education',
    'Blogs',
  ];

  Future<String> uploadVideo() async {
    final storageRef =
        FirebaseStorage.instance.ref().child('videos/${widget.videoName}');

    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/music_video_temp.mp4');
    await tempFile.writeAsBytes(await widget.videoFile.readAsBytes());
    await storageRef.putFile(tempFile);
    await tempFile.delete();
    final url = await storageRef.getDownloadURL();
    return url;
  }

  Future<void> uploadUserData() async {
    final url = await uploadVideo();

    DatabaseReference ref = FirebaseDatabase.instance.ref("users").push();
    await ref.set({
      "title": titleController.text,
      "description": descriptionController.text,
      "category": categoryController.text,
      "location": locationController.text,
      "videoUrl": url,
    });
  }

  Future<void> createThumbnail() async {
    setState(() {
      step = 2;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      File file = File(widget.videoFile.path);
      flickManager = FlickManager(
        videoPlayerController: VideoPlayerController.file(file),
        autoPlay: false,
      );
      locationController.text = widget.address;
      titleController.addListener(() {});
    });
  }

  @override
  void dispose() {
    flickManager.dispose();
    locationController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    return Scaffold(
      body: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: [
          step == 1
              ? Container(
                  margin: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50.h,
                      ),
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: SizedBox(
                          width: ScreenUtil().screenWidth,
                          height: ScreenUtil().setHeight(250),
                          child: FlickVideoPlayer(
                            flickManager: flickManager,
                            flickVideoWithControls:
                                const FlickVideoWithControls(
                                    videoFit: BoxFit.contain,
                                    controls: FlickLandscapeControls()),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.black,
                        ),
                        height: ScreenUtil().setHeight(40.h),
                        width: ScreenUtil().screenWidth,
                        child: TextButton(
                          onPressed: createThumbnail,
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          child: Center(
                            child: Text(
                              'NEXT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Thumbnail',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          AspectRatio(
                            aspectRatio: 16 / 9,
                            child: SizedBox(
                              width: ScreenUtil().screenWidth,
                              height: ScreenUtil().setHeight(250),
                              child: FlickVideoPlayer(
                                flickManager: flickManager,
                                flickVideoWithControls:
                                    const FlickVideoWithControls(
                                        videoFit: BoxFit.contain,
                                        controls: FlickLandscapeControls()),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 20.h,
                          ),
                          Form(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: titleController,
                                  onChanged: (value) =>
                                      titleController.text = value,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20.sp, vertical: 15.sp),
                                    label: const Text('Title'),
                                    labelStyle: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.black),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15.h,
                                ),
                                TextFormField(
                                  controller: descriptionController,
                                  onChanged: (value) =>
                                      descriptionController.text = value,
                                  minLines: 4,
                                  maxLines: null,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20.sp,
                                      vertical: 20.sp,
                                    ),
                                    label: const Text(
                                      'Description',
                                    ),
                                    labelStyle: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.black),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15.h,
                                ),
                                TextFormField(
                                  controller: categoryController,
                                  decoration: InputDecoration(
                                    label: const Text(
                                      'Category',
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                        width: 2,
                                        color: Colors.black,
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    suffixIcon: Container(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          icon:
                                              const Icon(Icons.arrow_drop_down),
                                          onChanged: (newValue) {
                                            setState(() {
                                              categoryController.text =
                                                  newValue!;
                                            });
                                          },
                                          items: categories
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15.h,
                                ),
                                TextFormField(
                                  readOnly: true,
                                  controller: locationController,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20.sp, vertical: 15.sp),
                                    label: const Text('Location'),
                                    labelStyle: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.black),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          const BorderSide(color: Colors.black),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.black,
                                  ),
                                  height: ScreenUtil().setHeight(40.h),
                                  width: ScreenUtil().screenWidth,
                                  child: TextButton(
                                    onPressed: () async {
                                      appProvider.toggleLoading();
                                      await uploadUserData();
                                      appProvider.toggleLoading();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SuccessScreen(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.black,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'POST',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Visibility(
                      visible: appProvider.isLoading,
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        width: ScreenUtil().screenWidth,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ],
                )
        ],
      ),
    );
  }
}
