import 'package:flutter/cupertino.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/theme/colors.dart';

import 'package:pay_app/widgets/profile_circle.dart';
import 'package:provider/provider.dart';

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({super.key});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  late ProfileState _profileState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _profileState = context.read<ProfileState>();

      onLoad();
    });
  }

  void onLoad() {
    _profileState.startEditing();
  }

  void _handleSelectPhoto() {
    FocusScope.of(context).unfocus();

    _profileState.selectPhoto();
  }

  String image = 'assets/icons/profile.png';

  @override
  Widget build(BuildContext context) {
    final profile = context.select((ProfileState p) => p.profile);
    final editingImage = context.select((ProfileState p) => p.editingImage);

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
                imageUrl: profile.imageMedium,
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
                color: editingImage != null ? transparentColor : blackColor,
                size: 40,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
