import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? profileImageUrl;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
  });

  @override
  List<Object?> get props => [id, email, displayName, profileImageUrl];
}
