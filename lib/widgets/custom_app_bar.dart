import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomAppBar({
    Key? key,
    required this.titleText,
    this.actions,
    this.showBackButton = true, // Default to true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          : null,
      title: Text(titleText),
      actions: actions,
      backgroundColor: Colors.blueGrey, // Example custom color
      elevation: 4.0, // Example shadow
      centerTitle: false, // You can set to true if you prefer
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}