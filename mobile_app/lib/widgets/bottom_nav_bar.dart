import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    const double baseHeight = 70.0;
    const double floatingButtonOffset = 24.0;

    return Container(
      color: AppColors.scaffoldBg, // Match background to avoid white gap
      child: SizedBox(
        height: baseHeight + floatingButtonOffset + bottomPadding,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            // Custom Notched Background
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, baseHeight + bottomPadding),
                painter: NotchedBottomPainter(bottomPadding: bottomPadding),
              ),
            ),
            
            // Navigation Items
            Positioned(
              bottom: bottomPadding,
              left: 0,
              right: 0,
              height: baseHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home'),
                    _buildNavItem(1, Icons.local_cafe_outlined, Icons.local_cafe, 'Order'),
                    const SizedBox(width: 60), // Space for center button
                    _buildNavItem(3, Icons.favorite_border, Icons.favorite, 'Favs'),
                    _buildNavItem(4, Icons.person_outline, Icons.person, 'Profile'),
                  ],
                ),
              ),
            ),
            
            // Floating Center Button
            Positioned(
              bottom: bottomPadding + (baseHeight / 2) - 10,
              child: _buildCenterButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isActive = currentIndex == index;
    final color = isActive ? AppColors.primaryBrown : AppColors.textLight;
    
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: EdgeInsets.only(bottom: isActive ? 4 : 0),
              child: Icon(
                isActive ? activeIcon : icon,
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.navLabel.copyWith(
                color: color,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => onTap(2),
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primaryBrown,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBrown.withValues(alpha: 0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.shopping_cart_outlined,
            color: AppColors.textWhite, 
            size: 28,
          ),
        ),
      ),
    );
  }
}

class NotchedBottomPainter extends CustomPainter {
  final double bottomPadding;

  NotchedBottomPainter({required this.bottomPadding});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;

    // Draw multiple shadow layers for depth
    final Path shadowPath = Path();
    shadowPath.moveTo(0, 0);
    _drawNotchedPath(shadowPath, size);
    
    // Deeper shadow
    canvas.drawShadow(shadowPath, AppColors.primaryBrown.withValues(alpha: 0.08), 30.0, false);
    // Subtle definition shadow
    canvas.drawShadow(shadowPath, AppColors.shadow.withValues(alpha: 0.05), 10.0, true);

    final Path path = Path();
    path.moveTo(0, 0);
    _drawNotchedPath(path, size);
    
    canvas.drawPath(path, paint);

    // Subtle top border line
    final Paint borderPaint = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);
  }

  void _drawNotchedPath(Path path, Size size) {
    final double center = size.width / 2;
    const double notchRadius = 38.0;
    const double curveRadius = 18.0;

    path.lineTo(center - notchRadius - curveRadius, 0);
    
    // Smooth entry curve
    path.quadraticBezierTo(
      center - notchRadius,
      0,
      center - notchRadius,
      curveRadius / 2,
    );

    // Notch curve
    path.arcToPoint(
      Offset(center + notchRadius, curveRadius / 2),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    // Smooth exit curve
    path.quadraticBezierTo(
      center + notchRadius,
      0,
      center + notchRadius + curveRadius,
      0,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
