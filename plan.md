# Relative Detail Page — Encounters & Diagnostics by Profile ID

## Background

[ProfilePage](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/frontend/lib/views/user/profile_page.dart#16-22) → [FamilyCard](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/frontend/lib/views/user/profile_page.dart#233-292) already navigates to [RelativeDetailPage](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/frontend/lib/views/user/relative_detail_page.dart#8-21), passing `relativeId` and `relativeName`. The [Relative](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/backend/src/main/java/backend/model/Relative.java#24-52) Dart model also carries an optional `profileId`.

Backend data model:
- [MedicalRecord](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/backend/src/main/java/backend/model/MedicalRecord.java#24-82) entity → mapped to table **`encounters`** (has `relativeId`, `profileId`, `doctor`, `hospital`, `datetimeStart/End`, and a list of [DiagnosticRecord](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/backend/src/main/java/backend/model/DiagnosticRecord.java#24-82))
- [DiagnosticRecord](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/backend/src/main/java/backend/model/DiagnosticRecord.java#24-82) entity → mapped to table **`diagnostic_records`** (has `category`, `tag`, `doctor`, [data](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/frontend/.metadata), `profileId`, `encounterId`)
- [RelativeHealthHistoryResponse](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/backend/src/main/java/backend/model/dto/response/RelativeHealthHistoryResponse.java#9-18) already includes `profileId` + `history: List<MedicalRecordResponse>` where each [MedicalRecordResponse](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/backend/src/main/java/backend/model/dto/response/MedicalRecordResponse.java#10-26) contains `List<DiagnosticRecordResponse>`

**Goal:** When user taps a [FamilyCard](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/frontend/lib/views/user/profile_page.dart#233-292), navigate to [RelativeDetailPage](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/frontend/lib/views/user/relative_detail_page.dart#8-21) which shows:
1. All **Encounters** (medical records from `encounters` table) as expandable cards
2. Under each encounter, show all **Diagnostic Records** as sub-cards
3. All data is loaded **by the relative's `profileId`** (not just `relativeId`)

---

## Proposed Changes

### Backend

#### [MODIFY] [RecordController.java](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/backend/src/main/java/backend/controller/RecordController.java)
- Add new `GET /api/profiles/{profileId}/health-history` endpoint
- Returns [RelativeHealthHistoryResponse](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/backend/src/main/java/backend/model/dto/response/RelativeHealthHistoryResponse.java#9-18) (same DTO, reuses mapper)
- Requires authenticated user

#### [MODIFY] [MedicalRecordRepository.java](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/backend/src/main/java/backend/repository/MedicalRecordRepository.java)
- Add method: `List<MedicalRecord> findByProfileId(UUID profileId)`

#### [MODIFY] [RecordService.java](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/backend/src/main/java/backend/service/RecordService.java)
- Add method: `RelativeHealthHistoryResponse getRecordsByProfileId(UUID profileId)`
  - Fetches encounters via `medicalRecordRepository.findByProfileId(profileId)`
  - Looks up Relative that owns this profile to fill `relativeId`, `relativeName`, `relationship`
  - Reuses `medicalRecordMapper.toRelativeHistory(relative, records)`

#### [MODIFY] [ProfileRepository.java](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/backend/src/main/java/backend/repository/ProfileRepository.java)
- Already exists; confirm `findById(UUID)` is available (it is, via `JpaRepository`)

---

### Frontend — Models

#### [NEW] `lib/data/models/record/encounter_model.dart`
New Dart model for an encounter (maps from [MedicalRecordResponse](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/backend/src/main/java/backend/model/dto/response/MedicalRecordResponse.java#10-26)):
```dart
class EncounterModel {
  final long id;
  final String title;
  final String? tag;
  final String? note;
  final String? hospitalName;
  final DateTime? datetimeStart;
  final DateTime? datetimeEnd;
  final List<String> tagNames;
  final List<DiagnosticModel> diagnostics;
}
```

#### [NEW] `lib/data/models/record/diagnostic_model.dart`
New Dart model for a diagnostic record (maps from [DiagnosticRecordResponse](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/backend/src/main/java/backend/model/dto/response/DiagnosticRecordResponse.java#9-22)):
```dart
class DiagnosticModel {
  final long id;
  final String category;
  final String? tag;
  final String? doctor;
  final String? data;
  final DateTime? datetimeEnd;
  final String? hospitalName;
  final List<String> tagNames;
  final List<String> attachmentUrls;
}
```

#### [NEW] `lib/data/models/record/relative_history_model.dart`
Wrapper model mapping [RelativeHealthHistoryResponse](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/backend/src/main/java/backend/model/dto/response/RelativeHealthHistoryResponse.java#9-18):
```dart
class RelativeHistoryModel {
  final String relativeId;
  final String profileId;
  final String relativeName;
  final String relationship;
  final List<EncounterModel> encounters;
}
```

---

### Frontend — Repository

#### [MODIFY] [record_repository.dart](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/frontend/lib/data/repositories/record_repository.dart)
- Add method `getHealthHistoryByProfileId(String profileId) → Future<RelativeHistoryModel?>`
  - Calls `GET /api/profiles/{profileId}/health-history`
  - Parses response into `RelativeHistoryModel`

---

### Frontend — ViewModel

#### [NEW] `lib/viewmodels/relative_detail_viewmodel.dart`
New `ChangeNotifier` ViewModel:
- State: `isLoading`, `errorMessage`, `RelativeHistoryModel? history`
- Method: `loadHistory(String profileId)` — calls `RecordRepository.getHealthHistoryByProfileId`
- Method: `refresh(String profileId)`

---

### Frontend — Page

#### [MODIFY] [profile_page.dart](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/frontend/lib/views/user/profile_page.dart)
- In [_buildFamilyCard](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/frontend/lib/views/user/profile_page.dart#233-292), pass `profileId: relative.profileId` in addition to `relativeId` and `relativeName` when navigating to [RelativeDetailPage](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/frontend/lib/views/user/relative_detail_page.dart#8-21)

#### [MODIFY] [relative_detail_page.dart](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/frontend/lib/views/user/relative_detail_page.dart)
Complete redesign to:
1. Accept `profileId` as a required parameter (alongside existing `relativeId`, `relativeName`)
2. Use `RelativeDetailViewModel` (via `ChangeNotifierProvider`) to call `loadHistory(profileId)`
3. Display encounters as expandable `ExpansionTile` cards:
   - Card header: encounter title, hospital name, date range, tags
   - Expanded body: list of `DiagnosticModel` cards
4. Each diagnostic card shows: `category`, `doctor`, [data](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/frontend/.metadata) (text), `datetimeEnd`, tag chips
5. Empty state and error state UI

#### [MODIFY] [lib/main.dart](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/frontend/lib/main.dart) (or wherever providers are registered)
- Register `RelativeDetailViewModel` as a `ChangeNotifierProvider`

---

## Verification Plan

### Backend
Run the Spring Boot app and test the new endpoint with a REST client (Postman / curl):
```
GET /api/profiles/{profileId}/health-history
Authorization: Bearer <token>
```
Expected: `200 OK` with [RelativeHealthHistoryResponse](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/backend/src/main/java/backend/model/dto/response/RelativeHealthHistoryResponse.java#9-18) JSON containing `relativeId`, `profileId`, `relativeName`, `relationship`, and `history[]` with nested `diagnosticRecords[]`.

### Frontend
1. Start the Flutter app: `flutter run`
2. Log in as a user who has at least one relative with medical records
3. Navigate to **Profile** tab → tap a **FamilyCard**
4. Verify [RelativeDetailPage](file:///d:/FPTdocument/2.ky8/1.PRM392/Health-record/frontend/lib/views/user/relative_detail_page.dart#8-21) opens and shows the relative's name in the AppBar
5. Verify the list shows encounter cards with title, hospital, dates
6. Expand an encounter card → verify nested diagnostic records are shown with category, doctor, data, tags
7. Verify empty state appears when a relative has no encounters
8. Pull to refresh → list reloads without crashing
