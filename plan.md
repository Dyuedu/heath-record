# Update Implementation Plan: Complete Removal of email Field from Profile/Relative Entities

## Context
We have determined that `email` belongs strictly to the `User` entity (Account level) and should not exist within the `Profile` entity or any "Add Relative" flows. The current plan needs to reflect a total removal of this field from DTOs and UI inputs, rather than just making it read-only. This ensures strict adherence to a Single Source of Truth architecture.

---

## Task Requirements

### 1. Backend Refactoring (Spring Boot)

*   **Database/Entity**: Ensure the `Profile` entity does not contain an `email` field. Only the `User` entity retains the `email` field as it is strictly tied to account registration and authentication.
*   **DTO Removal**: 
    *   Completely remove the `email` field from `UpdateMyProfileRequest.java`.
    *   Ensure any `CreateProfileRequest` or `AddRelativeRequest` (for relatives) does not contain an `email` field.
*   **Service Logic**: Remove all logic in `UserService.java` (and `ProfileService.java` / `RelativeService.java` if applicable) that attempts to map, validate, or save an `email` field during profile creation or updates. Specifically, remove the duplicate email validation block in `updateCurrentUser()`.

### 2. Frontend Data Layer (Flutter)

*   **Model Update**: Remove the `email` field from `UserProfileModel.dart` (or confirm it is purely for read-only aggregation directly from the `User` object, though the prompt suggests removing it if it was duplicated).
*   **ViewModel Update**: Update `UserViewModel.dart` to remove the `email` parameter from the `updateMyProfile` method. Ensure `ProfileViewModel.dart` (if applicable) does not include an email parameter in `addRelative`.

### 3. Frontend UI Removal

*   **Edit Profile Page (`edit_profile_page.dart`)**: 
    *   Remove `_emailController`.
    *   Remove its initialization.
    *   Remove the corresponding UI input field entirely.
*   **Add Profile (Relative) Page (`add_profile_page.dart`)**: 
    *   Remove the `email` input field entirely. Relatives should be created without an email address to avoid data redundancy with the main User account.

---

## Verification Criteria

1.  **API Verification**: Ensure that updating a profile (PUT `/api/users/me`) or adding a relative (POST `/api/relatives`) via the API no longer requires or accepts an `email` key in the payload.
2.  **UI Verification**: Confirm that the UI only displays the User email in the main profile view (fetched from the User object at the account level) and does not provide an editable input field in any form (Edit Profile or Add Relative).
