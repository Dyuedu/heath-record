# UI Refactor Plan – Doctor Module

> **Scope:** All `.dart` files inside `frontend/lib/views/doctor/` and its `widgets/` subfolder.
> **Goal:** Make the Doctor UI more beautiful, modern, and user-friendly while keeping the existing blue brand color (`#246BFF`) and MVVM architecture intact.

---

## 1. Design Tokens & Theme (Global, affects all files)

| Token | Current Value | Proposed Value |
|---|---|---|
| Primary | `#246BFF` | `#246BFF` *(keep)* |
| Primary Light | `#DDE3FF` | `#EEF2FF` *(softer)* |
| Background | `Colors.white` | `#F7F9FC` *(off-white)* |
| Card BG | `#DDE3FF` | `#FFFFFF` with subtle shadow |
| Radius – card | `24` | `20` (cards), `16` (inputs) |
| Text – body | `Colors.black87` | `#374151` |
| Text – caption | `Colors.black54` | `#6B7280` |
| Font | Default | **Inter** (add via `google_fonts` package) |

**Action:** Add `google_fonts: ^6.2.1` to `pubspec.yaml` and create a shared `AppTheme` helper class at `lib/utils/app_theme.dart`.

---

## 2. File-by-File Refactor Plan

---

### 2.1 `doctor_dashboard_page.dart`
**Current issues:**
- Plain centered layout with a single button – looks like a placeholder screen.
- No greeting personalization, no stats/summary cards.
- Logout button exposed in AppBar is visually jarring.

**Proposed changes:**
1. **Replace plain AppBar** → Use a gradient header card (blue gradient, `#246BFF → #1A56DB`) showing doctor name + avatar.
2. **Add stat summary row** – e.g., Today's Appointments count, Pending Records, Total Patients. Each stat in a white card with shadow.
3. **Replace single button** → A `2×2` grid of action tiles (Create Record, View Patients, Schedule, My Profile) using rounded containers with colored icons.
4. **Move logout** → to a settings/profile icon in the header (top-right), using `PopupMenuButton`.
5. **Add a "Recent Activity" list** – last 3 medical records created (future hook for API).
6. **Background** → set `backgroundColor: const Color(0xFFF7F9FC)`.

---

### 2.2 `doctors_list_page.dart`
**Current issues:**
- `_DoctorCard` uses a flat blue-purple background (`#DDE3FF`) – not visually differentiated.
- Filter bar is compact but icons have no labels; A-Z sort label is confusing (`Z -> A` shown when ascending).
- No search functionality (search icon does nothing).
- `leading` back arrow is not a button (no `onPressed`).

**Proposed changes:**
1. **Doctor Card redesign:**
   - White card with `BoxShadow` (`blurRadius: 12, color: black.withOpacity(0.06)`).
   - Larger avatar (radius 45) inside a slightly colored circle border (`#EEF2FF`).
   - Add specialty badge (small pill chip below name).
   - "Book Appointment" → replace with "View Profile" button using outlined style.
   - Rating shown as star row (filled/unfilled) instead of plain text.

2. **Filter bar:**
   - Make filter chips scrollable (`SingleChildScrollView` + `Row` → or use `FilterChip` widgets).
   - Add tooltip labels to icon filters.
   - Fix sort label: show `"A → Z"` when ascending, `"Z → A"` when descending.

3. **Search bar:**
   - Add a real search `TextField` below the AppBar (expand on tap).
   - Wire to `DoctorViewModel.searchQuery` (add field to VM if missing).

4. **AppBar:**
   - Wrap leading back icon inside `IconButton` with `Navigator.pop(context)` handler.
   - Apply transparent/white AppBar style with bottom divider.

5. **Empty / loading state:**
   - Replace bare `CircularProgressIndicator` with shimmer skeleton cards (use `shimmer` package or manual shimmer).
   - Add empty state widget (illustration + text) when `vm.doctors.isEmpty`.

---

### 2.3 `doctor_info.dart`
**Current issues:**
- Header card uses hardcoded placeholder text ("Lorem ipsum", "15 years experience") – not dynamic.
- Action icons (`info_outline`, `help_outline`, etc.) have no callbacks.
- Stats row items can overflow on small screens.
- `StadiumBorder()` on Schedule button triggers a lint warning (prefer `StadiumBorder()` → `const StadiumBorder()`).

**Proposed changes:**
1. **Dynamic data binding:**
   - Replace hardcoded "15 years experience" with `doctor.experience` field (update `DoctorModel` if needed).
   - Replace Lorem ipsum sections with actual `doctor.profile`, `doctor.careerPath`, `doctor.highlights` fields.

2. **Header card:**
   - Avatar with a gradient ring border.
   - Glassmorphism-style name badge (kept white but add `boxShadow`).
   - Stats row → wrap each `_whiteStatItem` in `Expanded` to prevent overflow.

3. **Action buttons:**
   - Schedule button → navigate to `DoctorProfilePage` (passing `doctor` object).
   - Favorite icon → toggle state (local `StatefulWidget`), update icon to `Icons.favorite` when active.
   - Info / Help icons → show `showModalBottomSheet` with doctor contact info.

4. **Section cards:**
   - Wrap each `_buildDetailSection` in a card container with subtle shadow instead of plain text blocks.
   - Add expand/collapse (`ExpansionTile`) for long text sections.

5. **Fix `StadiumBorder()` → `const StadiumBorder()`** in schedule button.

---

### 2.4 `doctor_profile_page.dart`
**Current issues:**
- AppBar body is `/* ... giữ nguyên app bar cũ ... */` – placeholder comment, no actual AppBar implementation.
- Placeholder image URL `https://via.placeholder.com/150`.
- Time chips are static/hardcoded (not stateful – selecting doesn't change UI state).
- `_sectionTitle` widget defined but never used in `build()`.
- Duplicate code vs `doctor_info.dart` (`_blueBadge`, `_focusBox`, `_infoIconBadge` are almost identical to `_blueInfoTag`, etc.).

**Proposed changes:**
1. **Implement AppBar properly:**
   ```dart
   AppBar(
     backgroundColor: Colors.white,
     elevation: 0,
     leading: IconButton(
       icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF246BFF)),
       onPressed: () => Navigator.pop(context),
     ),
     title: const Text('Book Appointment',
       style: TextStyle(color: Color(0xFF246BFF), fontWeight: FontWeight.bold)),
     centerTitle: true,
   )
   ```

2. **Make time chip selection stateful:**
   - Convert to `StatefulWidget`.
   - Add `String _selectedTime = ''` state variable.
   - `_buildTimeChip` reads from state; tapping updates `_selectedTime`.

3. **Remove placeholder image** – bind to `widget.doctor.imageUrl` (accept `doctor` param).

4. **Deduplicate helpers:**
   - Extract shared badge/chip helpers to a common file: `lib/utils/doctor_ui_helpers.dart`.
   - `DoctorProfilePage` and `DoctorInfoPage` both import from there.

5. **Remove unused `_sectionTitle` widget.**

6. **Book Appointment button:**
   - Validate that a time slot is selected before allowing booking.
   - Show a confirmation bottom sheet before submitting.

---

### 2.5 `create_medical_record_page.dart`
**Current issues:**
- Long monolithic file (526 lines) – all UI, state, and business logic in one widget.
- Diagnostic cards use basic `Card` with `elevation: 3` – white on white (low contrast).
- Section headers ("General Information", "Diagnostics") use plain inline `Text` – not visually distinct.
- `SnackBar` messages are short and unstyled.
- Image preview grid has no delete-image functionality.
- `_buildTextField` uses `.withValues(alpha: 0.3)` (non-standard method) – should use `withOpacity(0.3)`.

**Proposed changes:**
1. **Extract sub-widgets to separate files:**
   - `widgets/diagnostic_card.dart` → `DiagnosticCard` widget (index, model, onRemove, onPickImages).
   - `widgets/record_section_header.dart` → styled section header with a colored left bar accent.

2. **Section header redesign:**
   ```
   ┌─ Blue left bar (4px wide) — "General Information" in bold ─────┐
   ```
   Simple `Row` with a colored `Container` accent + `Text`.

3. **Diagnostic card redesign:**
   - White card with `border: Border.all(color: Color(0xFFE5E7EB))` and soft shadow.
   - Numbered badge circle (`#246BFF`) in the top-left corner.
   - Delete button → red outlined `OutlinedButton` (not bare `IconButton`).

4. **Image picker & preview:**
   - Add delete (×) overlay on each image thumbnail.
   - Show selected image count badge on pick button.

5. **Fix `withValues` → `withOpacity`:**
   ```dart
   // Before
   fillColor: const Color(0xFFDDE3FF).withValues(alpha: 0.3),
   // After
   fillColor: const Color(0xFFDDE3FF).withOpacity(0.3),
   ```

6. **Success/Error feedback:**
   - Replace plain `SnackBar` with styled snack bar (green for success, red for error, icon + message).

7. **Submit button:**
   - Show `CircularProgressIndicator` inside button when `_isLoading = true` (instead of replacing entire body).

---

### 2.6 `widgets/doctor_service_extensions.dart`
**Current issues:**
- Labels are in Vietnamese (`'Tạo Bệnh Án'`, `'QL Bệnh Nhân'`) – inconsistent with rest of the app (English).
- `_doctorServiceItem` container uses very small padding; icon size `28` might be too big for the card.
- "QL Bệnh Nhân" has an unimplemented `TODO` callback.

**Proposed changes:**
1. **Translate labels to English:**
   - `'Tạo Bệnh Án'` → `'New Record'`
   - `'QL Bệnh Nhân'` → `'Patients'`

2. **Improve card style:**
   - Add `boxShadow` to each service item container.
   - Use `InkWell` instead of `GestureDetector` for ripple effect.
   - Increase border radius slightly to `22`.

3. **Implement "Patients" navigation:**
   - Wire `onTap` to navigate to a patient list/management page route.

---

## 3. New Shared Utilities to Create

| File | Purpose |
|---|---|
| `lib/utils/app_theme.dart` | `AppTheme` class with `ThemeData`, colors, text styles |
| `lib/utils/doctor_ui_helpers.dart` | Shared badge/chip/stat helper widgets used across doctor pages |
| `lib/views/doctor/widgets/diagnostic_card.dart` | Extracted `DiagnosticCard` widget |
| `lib/views/doctor/widgets/record_section_header.dart` | Styled section header widget |

---

## 4. Packages to Add

| Package | Purpose |
|---|---|
| `google_fonts: ^6.2.1` | Inter font for modern typography |

> **Note:** The `shimmer` package is optional – a manual shimmer animation can be done with `AnimatedContainer` to avoid adding a dependency.

---

## 5. Implementation Order

```
Step 1 – Setup
  ├── Add google_fonts to pubspec.yaml
  └── Create lib/utils/app_theme.dart

Step 2 – Shared utilities
  └── Create lib/utils/doctor_ui_helpers.dart

Step 3 – Doctor pages (in order of dependency)
  ├── doctor_profile_page.dart   (fix critical placeholder AppBar & stateful time)
  ├── doctor_info.dart           (dynamic data, dedup helpers)
  ├── doctors_list_page.dart     (card redesign, filter, search)
  ├── doctor_dashboard_page.dart (full layout redesign)
  └── create_medical_record_page.dart (extract widgets, fix bugs)

Step 4 – Widgets
  └── doctor_service_extensions.dart (labels, style, navigation)

Step 5 – Verification
  └── Manual visual check on Android emulator / device
```

---

## 6. Verification Plan

### Manual Verification (run on Android emulator or physical device)

1. **Login as Doctor role** and verify the Dashboard screen renders the new gradient header, stat row, and action tile grid.
2. **Navigate to Doctors List** → verify card redesign, filter chips scroll, sort label is correct, back button works.
3. **Tap a Doctor card → Doctor Info page** → verify header card, stats do not overflow, section content is readable, Schedule button navigates.
4. **Doctor Profile page** → verify AppBar is implemented, time chip taps update selection, Book button validation works.
5. **Create Medical Record** → fill form, add diagnostic, pick images, verify image delete works, submit shows loading in button, success snackbar is styled.
6. **Doctor Service Extensions** → from Home screen verify English labels, InkWell ripple, and "Patients" navigation.

### Code Quality Checks
```bash
# Run Flutter analyze inside the frontend folder
cd frontend
flutter analyze
```
All issues in the modified files should be resolved (especially `withValues` → `withOpacity` and `StadiumBorder()` lint).
