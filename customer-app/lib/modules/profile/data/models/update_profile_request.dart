import 'dart:io';

class UpdateProfileRequest {
  final String userName, email, gender;
  final File? image;
  final String? dob;

  const UpdateProfileRequest({
    required this.userName,
    required this.email,
    required this.gender,
    this.image,
    this.dob,
  });
}
