import 'package:flutter/material.dart';
import 'package:thewasher/core/resources/color_manager.dart';

class ToggleShared extends StatelessWidget {
  final bool toggleSelected;
  final Function(bool?) onChanged;
  const ToggleShared({
    super.key,
    required this.toggleSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOn = toggleSelected;
    return GestureDetector(
      onTap: () => onChanged(!isOn),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 52,
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color: isOn ? ColorManager.secondary : ColorManager.lightGray,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Align(
          alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: ColorManager.white,
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
