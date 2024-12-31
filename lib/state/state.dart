import 'package:flutter/cupertino.dart';
import 'package:pay_app/state/app.dart';
import 'package:provider/provider.dart';

// TODO: Config state

Widget provideAppState(
  Widget? child, {
  Widget Function(BuildContext, Widget?)? builder,
}) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppState(),
        ),
      ],
      builder: builder,
      child: child,
    );
