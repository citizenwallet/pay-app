import 'package:flutter/cupertino.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

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

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: CupertinoColors.systemBackground,
      child: GestureDetector(
        child: SafeArea(
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              CustomScrollView(
                scrollBehavior: const CupertinoScrollBehavior(),
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Text('My Account'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
