import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginWithSocial implements UseCase<User, SocialLoginParams> {
  final AuthRepository repository;

  LoginWithSocial(this.repository);

  @override
  Future<Either<Failure, User>> call(SocialLoginParams params) async {
    if (params.provider == SocialProvider.google) {
      return await repository.loginWithGoogle();
    } else {
      return await repository.loginWithApple();
    }
  }
}

enum SocialProvider { google, apple }

class SocialLoginParams extends Equatable {
  final SocialProvider provider;

  const SocialLoginParams({required this.provider});

  @override
  List<Object> get props => [provider];
}
