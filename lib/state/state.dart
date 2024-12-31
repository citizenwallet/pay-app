import 'package:flutter/cupertino.dart';
import 'package:pay_app/state/app.dart';
import 'package:pay_app/state/community.dart';
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
      ],
      builder: builder,
      child: child,
    );
