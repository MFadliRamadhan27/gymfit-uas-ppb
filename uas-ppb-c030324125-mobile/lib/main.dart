import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'views/auth/login_screen.dart';
import 'views/dashboard/dashboard_screen.dart';
import 'providers/member_provider.dart';
import 'providers/dashboard_provider.dart';

void main() {
  runApp(const GymFitApp());
}

class GymFitApp extends StatelessWidget {
  const GymFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MemberProvider()),
        // 2. Daftarkan DashboardProvider dengan memberikan DashboardService
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GymFit Mobile',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const AuthGate(),
      ),
    );
  }
}

/// Komponen Penjaga Gerbang (Auth Gate)
/// Otomatis mengarahkan ke Dashboard jika sudah login, atau ke LoginScreen jika belum.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return FutureBuilder(
      future: authProvider.tryAutoLogin(),
      builder: (context, snapshot) {
        // Tampilkan layar loading memutar sementara Flutter memeriksa ke dalam SharedPreferences
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Konsumsi status autentikasi dari AuthProvider
        return Consumer<AuthProvider>(
          builder: (context, auth, _) {
            if (auth.isAuthenticated) {
              // Mengarahkan ke DashboardScreen asli yang barusan dibuat
              return const DashboardScreen();
            }
            return const LoginScreen();
          },
        );
      },
    );
  }
}
