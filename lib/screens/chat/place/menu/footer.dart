import 'package:flutter/cupertino.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/wide_button.dart';

class Footer extends StatefulWidget {
  const Footer({
    super.key,
  });

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFD9D9D9),
            width: 1,
          ),
        ),
      ),
      child: WideButton(
        text: 'Pay',
        onPressed: () => {},
        color: Color(0xFF171717),
      ),
    );
  }
}
