import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:pay_app/widgets/profile_circle.dart';

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({super.key});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  Uint8List? editingImage;

  void _handleSelectPhoto() {
    print('select photo');
  }

  String image = 'https://robohash.org/ZZZ.png?set=set2';

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        editingImage != null
            ? ProfileCircle(
                size: 160,
                imageBytes: editingImage,
              )
            : ProfileCircle(
                size: 160,
                imageUrl: image,
              ),
        CupertinoButton(
          onPressed: _handleSelectPhoto,
          padding: const EdgeInsets.all(0),
          child: Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(16, 19, 51, 211),
              borderRadius: BorderRadius.circular(80),
            ),
            padding: const EdgeInsets.all(10),
            height: 160,
            width: 160,
            child: Center(
              child: Icon(
                CupertinoIcons.photo,
                color: Color.fromARGB(255, 0, 0, 0),
                size: 40,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
