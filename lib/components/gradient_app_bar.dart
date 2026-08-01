import 'package:flutter/material.dart';
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final double? leadingWidth;
  final List<Widget>? actions;
  final bool? centerTitle;
  final double? toolbarHeight;
  const GradientAppBar({
    super.key,
    this.title,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.leadingWidth,
    this.actions,
    this.centerTitle,
    this.toolbarHeight,
  });
  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFDE3EC), Color(0xFFFFF1F5), Colors.white],
    stops: [0.0, 0.45, 1.0],
  );
  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight ?? kToolbarHeight);
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leadingWidth: leadingWidth,
      actions: actions,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,
      backgroundColor: Colors.transparent,
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(gradient: _gradient),
      ),
    );
  }
}
