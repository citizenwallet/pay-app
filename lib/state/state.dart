import 'package:flutter/cupertino.dart';
import 'package:pay_app/state/app.dart';
import 'package:pay_app/state/community.dart';
import 'package:pay_app/state/place.dart';
import 'package:pay_app/state/wallet.dart';
import 'package:provider/provider.dart';

Widget provideAppState(
  Widget? child, {
  Widget Function(BuildContext, Widget?)? builder,
}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppState(),
        ),
        ChangeNotifierProvider(
          create: (_) => CommunityState(),
        ),
        ChangeNotifierProvider(
          create: (_) => PlaceState(),
        ),
        ChangeNotifierProvider(
          create: (_) => WalletState(),
        ),
      ],
      builder: builder,
      child: child,
    );
