import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:pay_app/widgets/profile_circle.dart';
import 'package:provider/provider.dart';

class AccountCardFront extends StatefulWidget {
  final void Function() onTap;

  const AccountCardFront({super.key, required this.onTap});

  @override
  State<AccountCardFront> createState() => _AccountCardFrontState();
}

class _AccountCardFrontState extends State<AccountCardFront> {
  late WalletState _walletState;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _walletState = context.read<WalletState>();
    });
  }

  void _navigateToEditAccount() {
    final myAddress = _walletState.address?.hexEip55;

    if (myAddress == null) {
      return;
    }

    final navigator = GoRouter.of(context);

    final myUserId = navigator.state?.pathParameters['id'];

    navigator.go('/$myUserId/my-account/edit', extra: {'myAddress': myAddress});
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        GestureDetector(
          onTap: _navigateToEditAccount,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Color(0xFFF7F7FF),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: theme.primaryColor, width: 2),
            ),
            padding: EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ProfileCircle(
                  size: 135,
                ),
                Text(
                  'Kevin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: Color(0xFF171717),
                  ),
                ),
                Text(
                  '@kevin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: Color(0xFF171717),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
