# Admin User Management Page

Add a protected admin page that lets users with the `ADMIN` role list all users, create new users (with any role including ADMIN), and update any user's information. Non-admin users are denied access both at the API level and on the Flutter UI.

## User Review Required

> [!IMPORTANT]
> The backend currently assigns the default role `USER` on registration. Creating an admin account for the first time must be done directly in the database (e.g., `UPDATE users SET role_id = (SELECT id FROM roles WHERE name = 'ROLE_ADMIN') WHERE email = 'admin@example.com'`). This plan does **not** add a seeding script.

> [!WARNING]
> The `@PreAuthorize("hasRole('ADMIN')")` annotation relies on `@EnableMethodSecurity` already present in [SecurityConfig.java](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/backend/src/main/java/backend/config/SecurityConfig.java). The Flutter auth guard reads `role` from [UserProfileModel](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/frontend/lib/data/models/user/user_profile_model.dart#1-38) – make sure the JWT/profile endpoint returns the correct role string (e.g., `ROLE_ADMIN`).

---

## Proposed Changes

### Backend

---

#### [NEW] `AdminUserRequest.java` – `backend/src/main/java/backend/model/dto/request/`

New DTO for admin create/update user operations:

```java
public record AdminUserRequest(
    @NotBlank String fullName,
    @NotBlank @Email String email,
    @NotBlank String phoneNumber,
    String password,       // required only for create; ignored on update if blank
    @NotBlank String role, // e.g. "USER", "DOCTOR", "ADMIN"
    String gender,
    String dateOfBirth,
    String address
) {}
```

---

#### [NEW] `AdminUserResponse.java` – `backend/src/main/java/backend/model/dto/response/`

Extends `UserResponse` with an explicit `id` field already present – reuse `UserResponse` as-is (it already has `id`, `role`, etc.). No new file needed unless extra fields are required.

---

#### [NEW] `AdminController.java` – `backend/src/main/java/backend/controller/`

```java
@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {
    // GET  /api/admin/users          – list all users (pageable)
    // POST /api/admin/users          – create user
    // PUT  /api/admin/users/{id}     – update user
}
```

All three endpoints are protected with class-level `@PreAuthorize("hasRole('ADMIN')")`.

---

#### [NEW] `AdminUserService.java` – `backend/src/main/java/backend/service/`

Business logic methods:
- `List<UserResponse> getAllUsers()` – calls `userRepository.findAll()`, maps using existing mapper.
- `UserResponse createUser(AdminUserRequest req)` – validates email/phone uniqueness, hashes password with `BCryptPasswordEncoder`, looks up `Role` via `RoleRepository.findByName("ROLE_" + req.role())`, persists `User` + `Profile`.
- `UserResponse updateUser(UUID id, AdminUserRequest req)` – finds user, updates profile fields and role, saves.

---

#### [MODIFY] `SecurityConfig.java` – `backend/src/main/java/backend/config/`

No change needed. `@EnableMethodSecurity` is already present and `anyRequest().authenticated()` covers `/api/admin/**`.

---

#### [MODIFY] `RoleRepository.java` – `backend/src/main/java/backend/repository/`

Add `findByName` if not present:

```java
Optional<Role> findByName(String name);
```

---

### Frontend

---

#### [NEW] `admin_repository.dart` – `frontend/lib/data/repositories/`

```dart
abstract class AdminRepository {
  Future<List<UserProfileModel>> getAllUsers();
  Future<UserProfileModel?> createUser({...fields...});
  Future<UserProfileModel?> updateUser({required String id, ...fields...});
}
```

---

#### [NEW] `admin_repository_imp.dart` – `frontend/lib/data/repositories/impl/`

Implements `AdminRepository` using `DioClient`:

| Method | HTTP | Endpoint |
|---|---|---|
| `getAllUsers` | `GET` | `/api/admin/users` |
| `createUser` | `POST` | `/api/admin/users` |
| `updateUser` | `PUT` | `/api/admin/users/{id}` |

Returns `UserProfileModel.fromMap(...)` or `null` on error.

---

#### [NEW] `admin_viewmodel.dart` – `frontend/lib/viewmodels/`

```dart
class AdminViewModel extends ChangeNotifier {
  bool isLoading;
  String? errorMessage;
  String? successMessage;
  List<UserProfileModel> users;

  Future<void> loadAllUsers();
  Future<bool> createUser({...});
  Future<bool> updateUser({required String id, ...});
}
```

---

#### [NEW] `admin_page.dart` – `frontend/lib/views/admin/`

- Guards access: in `initState`, checks `context.read<AuthViewModel>().currentUserRole` (loaded from `/api/users/me`). If role is not `ROLE_ADMIN`, pops with an "Unauthorized" snackbar.
- UI layout:
  - **AppBar** with title "Quản lý người dùng".
  - **ListView** of all users, each card shows avatar, name, email, role chip.
  - **FAB** `+` to open create-user bottom sheet / dialog.
  - Tapping a user card opens an edit dialog.
- Create / Edit **AlertDialog** with fields: Full Name, Email, Phone, Password (create only), Role dropdown (`USER`, `DOCTOR`, `ADMIN`), Gender, DOB, Address.
- Design follows existing color palette: primary `Color(0xFF246BFF)`, gradient `Color(0xFF26BC9B)` → `Color(0xFF246BFF)`.

---

#### [MODIFY] `app_routers.dart` – `frontend/lib/utils/`

Add route constant and case:

```dart
static const String admin = '/admin';

case admin:
  return MaterialPageRoute(builder: (_) => const AdminPage(), settings: settings);
```

---

#### [MODIFY] `app_providers.dart` – `frontend/lib/utils/`

Register `AdminRepository` and `AdminViewModel`:

```dart
ProxyProvider<DioClient, AdminRepository>(
  update: (ctx, dio, _) => AdminRepositoryImp(dio),
),
ChangeNotifierProxyProvider<AdminRepository, AdminViewModel>(
  create: (ctx) => AdminViewModel(repository: ctx.read<AdminRepository>()),
  update: (ctx, repo, prev) => prev ?? AdminViewModel(repository: repo),
),
```

---

#### [MODIFY] `auth_viewmodel.dart` – `frontend/lib/viewmodels/`

Expose a `String? currentRole` getter (read from the cached profile or `/api/users/me`) so `AdminPage` can perform a frontend guard without an extra repository call.

---

## Verification Plan

### Manual Testing Steps

1. **Backend – role protection**
   - Start the Spring Boot backend (`mvn spring-boot:run` inside `backend/`).
   - Log in as a **non-admin** user and call `GET /api/admin/users` – expect `403 Forbidden`.
   - Log in as an **admin** user and call `GET /api/admin/users` – expect `200 OK` with user list.

2. **Backend – create user**
   - `POST /api/admin/users` with body `{ "fullName":"Test", "email":"t@t.com", "phoneNumber":"0901234567", "password":"123456", "role":"USER", "gender":"MALE", "dateOfBirth":"2000-01-01", "address":"HCM" }`.
   - Expect `201` and a `UserResponse` JSON.
   - Verify user appears in `GET /api/admin/users`.

3. **Backend – update user**
   - `PUT /api/admin/users/{userId}` to change role from `USER` to `DOCTOR`.
   - Verify via `GET /api/admin/users` that the role is updated.

4. **Frontend – route guard**
   - Log in as a non-admin user.
   - Navigate to `/admin` directly (e.g., via `Navigator.pushNamed(context, AppRouter.admin)`).
   - Expect immediate redirect away with a "Không có quyền truy cập" SnackBar.

5. **Frontend – admin flow**
   - Log in as an admin user.
   - Open the Admin page; verify the user list loads.
   - Press `+` FAB, fill in fields, press Save; verify new user appears in the list.
   - Tap a user card, change their role, save; verify the role chip updates.
