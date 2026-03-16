import 'package:frontend/data/models/record/relative.dart';
import 'package:frontend/data/models/user/user_profile_model.dart';

abstract class ProfileRepository {
  Future<UserProfileModel?> fetchMyProfile();

  Future<List<Relative>> fetchFamilyProfiles();
}
