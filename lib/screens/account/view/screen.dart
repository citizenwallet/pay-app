import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/state/account.dart';
import 'package:pay_app/state/profile.dart';
import 'package:pay_app/widgets/button.dart';

import 'package:provider/provider.dart';

import '../../../widgets/account_card.dart';

class MyAccount extends StatefulWidget {
  final String accountAddress;

  const MyAccount({super.key, required this.accountAddress});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // make initial requests here
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

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    final profile = context.select((ProfileState p) => p.profile);
    final alias = context.select((ProfileState p) => p.alias);

    final isLoggingOut = context.select((AccountState a) => a.loggingOut);

    final theme = CupertinoTheme.of(context);
    final primaryColor = theme.primaryColor;

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
                SizedBox(height: safeAreaBottom),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
