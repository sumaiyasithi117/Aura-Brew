import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/product_provider.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/order_provider.dart';
import 'core/providers/favorites_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/main_shell.dart';
import 'screens/tea/tea_selection_screen.dart';
import 'screens/customize/customize_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/orders/order_history_screen.dart';
import 'screens/feedback/feedback_screen.dart';
import 'screens/profile/addresses_screen.dart';
import 'screens/profile/rewards_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/orders/order_success_screen.dart';
import 'core/models/models.dart';

void main() {
  runApp(const AuraBrewApp());
}

class AuraBrewApp extends StatelessWidget {
  const AuraBrewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'Aura Brew',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/splash',
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/onboarding': (_) => const OnboardingScreen(),
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/main': (_) => const MainShell(),
          '/tea-selection': (_) => const TeaSelectionScreen(),
          '/customize': (_) => const CustomizeScreen(),
          '/cart': (_) => const CartScreen(),
          '/order-history': (_) => const OrderHistoryScreen(),
          '/feedback': (_) => const FeedbackScreen(),
          '/rewards': (_) => const RewardsScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/addresses': (_) => const AddressesScreen(),
          '/order-success': (context) {
            final order = ModalRoute.of(context)!.settings.arguments as OrderModel;
            return OrderSuccessScreen(order: order);
          },
        },
      ),
    );
  }
}


