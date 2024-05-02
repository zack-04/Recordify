
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:recordify/provider/app_provider.dart';
import 'package:recordify/screens/login_screen.dart';
import 'package:recordify/screens/upload_form.dart';
import 'package:recordify/components/video_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? lat;

  double? long;

  String address = "";

  Future<Position> _determinePosition() async {
    // bool serviceEnabled;
    LocationPermission permission;

    // serviceEnabled = await Geolocator.isLocationServiceEnabled();
    // if (!serviceEnabled) {
    //   return Future.error('Location services are disabled.');
    // }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  getUserAddress() async {
    Position data = await _determinePosition();
    setState(() {
      lat = data.latitude;
      long = data.longitude;
    });

    await getAddressFromCoordinates(data.latitude, data.longitude);
  }

//For convert lat long to address
  getAddressFromCoordinates(lat, long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    setState(() {
      address = "${placemarks[0].locality!} ${placemarks[0].country!}";
    });
  }

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('users');
    final appProvider = Provider.of<AppProvider>(context);

    recordVideo() async {
      await getUserAddress();
      final XFile? cameraVideo =
          await ImagePicker().pickVideo(source: ImageSource.camera);

      if (cameraVideo != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadForm(
              videoFile: cameraVideo,
              address: address,
              videoName: cameraVideo.name,
            ),
          ),
        );
      }
    }

    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.sp),
                child: const Text(
                  'Home Page',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout),
                ),
              ],
            ),
            body: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 6,
                        child: TextField(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.sp, vertical: 15.sp),
                            hintText: 'Search videos',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextButton(
                          onPressed: () {},
                          child: Icon(
                            Icons.filter_alt_outlined,
                            size: 35.sp,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FirebaseAnimatedList(
                    query: ref,
                    itemBuilder: (context, snapshot, animation, index) {
                      return VideoCard(
                        title: snapshot.child('title').value.toString(),
                        description: snapshot.child('description').value.toString(),
                        category: snapshot.child('category').value.toString(),
                        location: snapshot.child('location').value.toString(),
                        videoUrl: snapshot.child('videoUrl').value.toString(),
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: FloatingActionButton(
              onPressed: () async{
                appProvider.toggleLoading();
                await recordVideo();
                appProvider.toggleLoading();
              },
              backgroundColor: const Color.fromARGB(255, 75, 128, 154),
              mini: false,
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 30.sp,
              ),
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
      ),
    );
  }
}
