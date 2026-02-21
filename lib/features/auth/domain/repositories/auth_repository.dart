import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> loginWithEmail({
    required String email,
    required String password,
  });
  Future<Either<Failure, User>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });
  Future<Either<Failure, User>> loginWithGoogle();
  Future<Either<Failure, User>> loginWithApple();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User>> getCurrentUser();
}
