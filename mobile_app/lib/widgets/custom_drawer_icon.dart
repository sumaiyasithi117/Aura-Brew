import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class CustomDrawerIcon extends StatelessWidget {
  final Color color;
  const CustomDrawerIcon({super.key, this.color = AppColors.primaryBrown});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 25,
          height: 4.5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 3.5),
        Container(
          width: 18,
          height: 4.5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 3.5),
        Container(
          width: 11,
          height: 4.5,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }
}
