import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final Function()? function;
  final String text;
  final Color textColor;
  const FollowButton({
    super.key,
    this.function,
    required this.backgroundColor,
    required this.borderColor,
    required this.text,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 2),
      child: TextButton(
        onPressed: function,

        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width * 0.6,
          height: 27,

          child: Text(
            text,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
