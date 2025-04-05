import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/state/account.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/theme/colors.dart';
import 'package:pay_app/widgets/button.dart';

import 'package:pay_app/widgets/wide_button.dart';
import 'package:provider/provider.dart';

import 'notifications.dart';
import 'about.dart';
import '../../../widgets/account_card.dart';

class MyAccountSettings extends StatefulWidget {
  final String accountAddress;

  const MyAccountSettings({super.key, required this.accountAddress});

  @override
  State<MyAccountSettings> createState() => _MyAccountSettingsState();
}

class _MyAccountSettingsState extends State<MyAccountSettings> {
  late AccountState _accountState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // make initial requests here
      _accountState = context.read<AccountState>();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void goBack() {
    GoRouter.of(context).pop();
  }

  void handleEditAccount() {
    final navigator = GoRouter.of(context);

    navigator.push('/${widget.accountAddress}/my-account/edit');
  }

  void handleLogout() async {
    final navigator = GoRouter.of(context);

    final success = await _accountState.logout();
    if (success) {
      navigator.go('/');
    }
  }

  void handleDeleteAccount() {
    debugPrint('delete account');
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    final profile = context.select((ProfileState p) => p.profile);
    final alias = context.select((ProfileState p) => p.alias);

    final isLoggingOut = context.select((AccountState a) => a.loggingOut);

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
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            ListView(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: [
                Center(
                  child: AccountCard(
                    profile: profile,
                    alias: alias,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Button(
                      onPressed: isLoggingOut ? null : handleEditAccount,
                      text: 'Edit account',
                      color: primaryColor.withAlpha(30),
                      labelColor: primaryColor,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9),
                  ),
                ),
                const SizedBox(height: 20),
                // Notifications(),
                // const SizedBox(height: 20),
                About(),
                const SizedBox(height: 60),
                WideButton(
                  color: const Color(0xFF4D4D4D),
                  onPressed: handleLogout,
                  disabled: isLoggingOut,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Log out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                        ),
                      ),
                      if (isLoggingOut)
                        CupertinoActivityIndicator(
                          color: CupertinoColors.white,
                        ),
                    ],
                  ),
                ),
                Container(
                  height: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9),
                  ),
                ),
                WideButton(
                  color: const Color(0xFFFC4343),
                  onPressed: handleDeleteAccount,
                  disabled: isLoggingOut,
                  child: Text(
                    'Delete account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
                SizedBox(height: safeAreaBottom),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
