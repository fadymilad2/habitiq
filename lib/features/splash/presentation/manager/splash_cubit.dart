import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial()) {
    checkUserStatus();
  }

  Future<void> checkUserStatus() async {
    emit(SplashLoading());

    await Future.delayed(const Duration(seconds: 2));

    emit(SplashNavigateToOnboarding());
  }
}
