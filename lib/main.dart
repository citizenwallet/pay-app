import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:pay_app/routes/router.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:pay_app/state/state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  // await MainDB().init('main');
  // await PreferencesService().init(MainDB().preference);

  WalletService();

  runApp(provideAppState(const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const theme = CupertinoThemeData(
    primaryColor: Color(0xFF3431C4),
    brightness: Brightness.light,
    scaffoldBackgroundColor: CupertinoColors.systemBackground,
    textTheme: CupertinoTextThemeData(
      textStyle: TextStyle(
        color: CupertinoColors.label,
        fontSize: 16,
      ),
    ),
    applyThemeToAll: true,
  );

  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorKey = GlobalKey<NavigatorState>();
  final observers = <NavigatorObserver>[];
  late GoRouter router;

  @override
  void initState() {
    super.initState();

    router = createRouter(_rootNavigatorKey, _shellNavigatorKey, observers);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return CupertinoApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: theme,
      title: 'Brussels Pay',
      locale: const Locale('en'),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1.0)),
        child: CupertinoPageScaffold(
          key: const Key('main'),
          backgroundColor: theme.scaffoldBackgroundColor,
          child: Column(
            children: [
              Expanded(
                child: child != null
                    ? CupertinoTheme(
                        data: theme,
                        child: child,
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
