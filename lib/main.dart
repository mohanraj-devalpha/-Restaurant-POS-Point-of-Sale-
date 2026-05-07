import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local_data_source.dart';
import 'data/repositories/pos_repository_impl.dart';
import 'domain/repositories/pos_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/menu/menu_bloc.dart';
import 'presentation/bloc/cart/cart_bloc.dart';
import 'presentation/bloc/order/order_bloc.dart';
import 'presentation/screens/welcome_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  final localDataSource = LocalDataSource();
  final posRepository = PosRepositoryImpl(localDataSource: localDataSource);

  runApp(EmzoPosApp(repository: posRepository));
}

class EmzoPosApp extends StatelessWidget {
  final PosRepository repository;

  const EmzoPosApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(repository: repository),
        ),
        BlocProvider<MenuBloc>(
          create: (_) => MenuBloc(repository: repository),
        ),
        BlocProvider<CartBloc>(
          create: (_) => CartBloc(),
        ),
        BlocProvider<OrderBloc>(
          create: (_) => OrderBloc(repository: repository),
        ),
      ],
      child: MaterialApp(
        title: 'Emzo POS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const WelcomeScreen(),
      ),
    );
  }
}
