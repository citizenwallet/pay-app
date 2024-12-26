import 'package:flutter/cupertino.dart';
import 'package:pay_app/widgets/coin_logo.dart';
import 'package:pay_app/widgets/text_field.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<Footer> createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  bool _showAmountField = true;

  void _toggleField() {
    setState(() {
      _showAmountField = !_showAmountField;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: _showAmountField
                ? AmountFieldWithMessageToggle(onToggle: _toggleField)
                : MessageFieldWithAmountToggle(onToggle: _toggleField),
          ),
          SizedBox(width: 10),
          SendButton(),
        ],
      ),
    );
  }
}

class SendButton extends StatelessWidget {
  const SendButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        // Your onPressed logic
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Color(0xFF3431C4),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            CupertinoIcons.arrow_up,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}

class AmountFieldWithMessageToggle extends StatelessWidget {
  final VoidCallback onToggle;
  const AmountFieldWithMessageToggle({super.key, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            placeholder: 'Enter amount',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: CoinLogo(size: 33),
            ),
          ),
        ),
        SizedBox(width: 10),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onToggle,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.text_bubble,
                color: Color(0xFF3431C4),
              ),
            ),
          ),
        )
      ],
    );
  }
}

class MessageFieldWithAmountToggle extends StatelessWidget {
  final VoidCallback onToggle;
  const MessageFieldWithAmountToggle({super.key, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            placeholder: 'Add a message',
          ),
        ),
        SizedBox(width: 10),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: onToggle,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.back,
                color: Color(0xFF3431C4),
              ),
            ),
          ),
        )
      ],
    );
  }
}
