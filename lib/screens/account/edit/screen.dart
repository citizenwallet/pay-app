import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/blurry_child.dart';
import 'package:pay_app/widgets/loaders/progress_bar.dart';

import 'package:pay_app/widgets/wide_button.dart';
import 'package:pay_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'profile_picture.dart';
import 'username.dart';
import 'name.dart';
import 'description.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  late ProfileState _profileState;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // make initial requests here
      _profileState = context.read<ProfileState>();
    });
  }

  @override
  void dispose() {
    _profileState.resetUsernameTaken();
    _profileState.resetName();
    _profileState.resetDescription();
    _profileState.resetEditingImage();
    super.dispose();
  }

  void goBack() {
    GoRouter.of(context).pop();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  void handleDescriptionFocused() {
    _scrollController.animateTo(
      200,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void handleSave() async {
    _dismissKeyboard();

    await _profileState.saveProfile();

    _dismissKeyboard();
    goBack();
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;
    final width = MediaQuery.of(context).size.width;

    final loading = context.select((ProfileState p) => p.loading);
    final updateState =
        context.select((ProfileState p) => p.profileUpdateState);

    final profile = context.select((ProfileState p) => p.profile);
    final hasChanges = context.select((ProfileState p) => p.hasChanges);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: goBack,
          child: Icon(
            CupertinoIcons.back,
            color: Color(0xFF09090B),
            size: 20,
          ),
        ),
      ),
      backgroundColor: CupertinoColors.systemBackground,
      child: GestureDetector(
        onTap: _dismissKeyboard,
        behavior: HitTestBehavior.opaque,
        child: SafeArea(
          bottom: false,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              ListView(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                children: [
                  ProfilePicture(),
                  const SizedBox(height: 16),
                  Username(username: profile.username),
                  const SizedBox(height: 16),
                  Name(name: profile.name),
                  const SizedBox(height: 16),
                  Description(
                    description: profile.description,
                    onFocused: handleDescriptionFocused,
                  ),
                  const SizedBox(height: 60),
                  SizedBox(height: safeAreaBottom),
                ],
              ),
              if (!loading && hasChanges)
                Positioned(
                  bottom: safeAreaBottom,
                  width: width,
                  child: BlurryChild(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: dividerColor,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          WideButton(
                            onPressed: handleSave,
                            child: Text(
                              AppLocalizations.of(context)!.save,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: CupertinoColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (loading)
                Positioned(
                  bottom: safeAreaBottom,
                  width: width,
                  child: BlurryChild(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: dividerColor,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 25,
                            child: Center(
                              child: ProgressBar(
                                updateState.progress,
                                width: width - 40,
                                height: 16,
                                borderRadius: 8,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                switch (updateState) {
                                  ProfileUpdateState.existing =>
                                    AppLocalizations.of(context)!
                                        .fetchingExistingProfile,
                                  ProfileUpdateState.uploading =>
                                    AppLocalizations.of(context)!
                                        .uploadingNewProfile,
                                  ProfileUpdateState.fetching =>
                                    AppLocalizations.of(context)!.almostDone,
                                  _ => AppLocalizations.of(context)!.saving,
                                },
                                style: TextStyle(
                                  fontSize: 16,
                                  color: textMutedColor,
                                ),
                              ),
                              const SizedBox(width: 10),
                              CupertinoActivityIndicator(
                                color: textMutedColor,
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
