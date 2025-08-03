import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/state/account.dart';
import 'package:pay_app/state/onboarding.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/theme/colors.dart';

import 'package:pay_app/widgets/wide_button.dart';
import 'package:provider/provider.dart';
import 'package:pay_app/l10n/app_localizations.dart';

import 'about.dart';

class MyAccountSettings extends StatefulWidget {
  final String accountAddress;

  const MyAccountSettings({super.key, required this.accountAddress});

  @override
  State<MyAccountSettings> createState() => _MyAccountSettingsState();
}

class _MyAccountSettingsState extends State<MyAccountSettings> {
  late WalletState _walletState;
  late AccountState _accountState;
  late OnboardingState _onboardingState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // make initial requests here
      _walletState = context.read<WalletState>();
      _accountState = context.read<AccountState>();
      _onboardingState = context.read<OnboardingState>();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void goBack() {
    GoRouter.of(context).pop();
  }

  void handleLanguageSelection() {
    final accountAddress = widget.accountAddress;
    GoRouter.of(context).push('/$accountAddress/my-account/settings/language');
  }

  void handleLogout() async {
    final navigator = GoRouter.of(context);

    // show a confirmation modal
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.logOut),
        content: Text(AppLocalizations.of(context)!.logOutConfirm),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.logOut),
          ),
        ],
      ),
    );

    if (confirmed == null || !confirmed) {
      return;
    }

    _walletState.clear();

    final success = await _accountState.logout();
    if (success) {
      _onboardingState.clearConnectedAccountAddress();
      navigator.go('/');
    }
  }

  void handleDeleteData() async {
    final navigator = GoRouter.of(context);

    // show a confirmation modal
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CupertinoAlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteData),
        content: Text(AppLocalizations.of(context)!.deleteDataConfirm),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == null || !confirmed) {
      return;
    }

    _walletState.clear();

    final success = await _accountState.deleteData();
    if (success) {
      _onboardingState.clearConnectedAccountAddress();
      navigator.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaBottom = MediaQuery.of(context).padding.bottom;

    final isLoggingOut = context.select((AccountState a) => a.loggingOut);
    final isDeletingData = context.select((AccountState a) => a.deletingData);

    final theme = CupertinoTheme.of(context);
    final primaryColor = theme.primaryColor;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          AppLocalizations.of(context)!.settings,
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w600,
            color: Color(0xFF000000),
          ),
        ),
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
                // Notifications(),
                const SizedBox(height: 20),
                About(),
                const SizedBox(height: 40),
                Text(
                  AppLocalizations.of(context)?.language ?? 'Language',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 20),
                WideButton(
                  color: const Color(0xFF4D4D4D),
                  onPressed: handleLanguageSelection,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)?.selectLanguage ??
                            'Select Language',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  AppLocalizations.of(context)!.account,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 20),
                WideButton(
                  color: const Color(0xFF4D4D4D),
                  onPressed: handleLogout,
                  disabled: isLoggingOut || isDeletingData,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.logOut,
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
                const SizedBox(height: 20),
                Container(
                  height: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9),
                  ),
                ),
                const SizedBox(height: 20),
                WideButton(
                  color: dangerColor,
                  onPressed: handleDeleteData,
                  disabled: isDeletingData || isLoggingOut,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.deleteData,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: CupertinoColors.white,
                        ),
                      ),
                      if (isDeletingData)
                        CupertinoActivityIndicator(
                          color: CupertinoColors.white,
                        ),
                    ],
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
