# DapurKasih — Project Analysis & Development Roadmap

_Analysis date: 2026-07-09. Sources: `REPORT DAPUR KASIH GROUP 5.pdf` (primary reference),
wireframe PDF, main Flutter project (`C:\flutter_project\dapur_kasih_kab`), and two group-member
copies (`C:\dapur kab info\dapur` and `C:\dapur kab info\dapur_kasih_kab`)._

---

## 1. System Overview (from the report)

Dapur Kasih is a kitchen-booking system for Kolej Aminuddin Baki (KAB). Students book
1-hour kitchen slots, cancel bookings, and submit damage reports. Staff (admin) approve/reject
bookings and update damage-report status.

**Roles:** `student`, `admin` (staff).

**Functional requirements (report §3.1):**
| # | Requirement | Role |
|---|---|---|
| 1 | Register with member ID + email | both |
| 2 | Login | both |
| 3 | View kitchen availability by date/time | both |
| 4 | Book kitchen slot | student |
| 5 | Cancel booking | student |
| 6 | Submit damage report | student |
| 7 | View booking history | student |
| 8 | View damage report history | student |
| 9 | Manage bookings (Approve/Reject) | admin |
| 10 | Manage damage reports (Pending / In Review / Resolved) | admin |

**Key business rules (report §2.1, §3.3):**
- Unique Member_ID (matric / staff ID) per user.
- One booking ↔ one slot; only one Approved booking per slot/session.
- Booking stores number of users, purpose, group members, status (Pending/Approved/Rejected).
- Minimum 4 users per group booking; one person books on behalf of the group.
- Damage report: category, description, urgency (Low/Medium/High), status (Pending/In Review/Resolved), date.

## 2. Existing Flutter Architecture

- Plain Flutter + Firebase (no state-management package). Screens call
  `FirebaseAuth` / `FirebaseFirestore` directly; one member introduced a light
  `services/` layer (`FirestoreService`, `StorageService`) — adopted.
- Folder layout: `lib/` (auth pages + `main.dart` + `styles.dart`), `lib/screens/`,
  `lib/widgets/`, `lib/services/` (new), `lib/utils/` (new).
- Shared styling via `styles.dart` (`AppColors`, `AppTextStyles`, `AppSpacing`, `AppButtonStyles`).
- All three copies point to the same Firebase project **`dapurkasih`**.

## 3. Firebase structure (canonical, after merge)

- `users/{uid}`: name, memberId, email, phone, address, dob, imageUrl, role (`student`|`admin`), createdAt
- `bookings/{autoId}`: slotId, time, date (`YYYY-MM-DD`), purpose, members, totalUsers, userId, status (`Pending`|`Approved`|`Rejected`), createdAt
- `damage_reports/{autoId}`: userId, slot, item, description, urgency (`Low`|`Medium`|`High`), status (`Pending`|`In Review`|`Resolved`), createdAt
- Storage: `profile_images/{uid}.jpg`

## 4. Feature comparison (web report vs Flutter, at analysis time)

| Feature | Main project | Member `dapur` | Member variant | Status |
|---|---|---|---|---|
| Welcome/Login/Signup/Forgot pwd | ✅ Firebase Auth | same + Admin Login link | signup also writes `users` doc | merged |
| Dashboard + slot availability | ✅ Firestore stream | same | same | kept |
| Create booking | ✅ writes `bookings` (no status!) | in-memory only | same as main | fixed (+status) |
| Booking history | ❌ placeholder | ✅ UI, but in-memory only | placeholder | rebuilt on Firestore |
| Update booking | ❌ | ✅ UI, in-memory | ❌ | rebuilt on Firestore |
| Cancel booking | ❌ | ✅ UI, in-memory | ❌ | rebuilt on Firestore |
| Report damage | ✅ Firestore | placeholder | placeholder | kept main |
| Damage report history | ❌ | ❌ | ❌ | built new |
| Profile / edit profile / photo | ❌ placeholder | placeholder | ✅ full (Firestore+Storage) | merged |
| Admin login/signup | ❌ | ✅ | ❌ | merged + role check |
| Admin manage bookings | ❌ | ✅ (lowercase statuses) | ❌ | merged + normalized |
| Admin manage damage | ❌ | ✅ (wrong collection `damageReports`) | ❌ | merged + fixed |

## 5. Defects found during analysis

1. **Dead code:** `main.dart` contained an entire unused `MainAppController` + `BorangBookingPage`
   (old pink drawer prototype, never reachable — `home:` is `WelcomePage`). Removed.
2. **Collection mismatch:** student writes `damage_reports`, admin read `damageReports`. Unified to `damage_reports`.
3. **Status casing mismatch:** admin wrote `approved`/`rejected` (lowercase), history UI compared `'pending'`,
   student app writes `Pending`. Unified to capitalized values, read case-insensitively.
4. **Bookings created without `status`** → admin list showed `null`, history chips broken. Now `Pending`.
5. **Signup never stored the Firestore user profile** in the main project (no memberId/phone/role). Fixed;
   report requires registration with member ID.
6. **`FirestoreService`/`StorageService` read `currentUser!.uid` at construction** → crash if instantiated
   before login. Changed to lazy getters.
7. **Profile image upload used `dart:io File`** → breaks Flutter Web (team tests in Chrome). Now uploads bytes.
8. **`ProfilePage` imported `package:dapur/login_page.dart`** (works but inconsistent) → relative import.
9. **Dashboard bottom-nav "Home" pushed a duplicate DashboardPage** onto itself. Now a no-op when already there.
10. **Slot list duplicated** in `dashboard.dart` and `report_damage.dart`. Extracted to `lib/utils/slots.dart`.
11. **Slot availability counted Rejected bookings as blocking.** Now Rejected/Cancelled bookings free the slot.
12. **Group size rule:** report says minimum **4** users; the form enforced 5–8. Aligned to 4–8
    (report is the primary reference — change back in `booking_form.dart` if the group prefers 5).
13. **Admin signup domain check** hard-coded `@company.com`; kept behaviour but extracted to a constant
    (`admin_signup.dart` → `kAdminEmailDomain`) — set it to your real staff domain or empty to disable.
14. **Default counter widget test** referenced a counter UI that never existed → replaced with a real smoke test.
15. No session persistence: app always opened on Welcome even when logged in. Added `AuthGate` role-based routing.

## 6. Development roadmap (priority order)

1. ✅ Foundation: deps (`firebase_storage`, `image_picker`), shared slots util, services layer, `AuthGate`.
2. ✅ Registration completes user profile in Firestore (memberId, phone, role).
3. ✅ Booking lifecycle: status on create; Firestore booking history with update + cancel.
4. ✅ Profile + edit profile + photo upload (merged from member variant).
5. ✅ Damage report history for students.
6. ✅ Admin module: role-verified login, signup, manage bookings, manage damage reports.
7. ✅ Consistency pass: statuses, collections, navigation, styles; `flutter analyze` clean.
8. ✅ Firestore security rules written (`firestore.rules`) and **deployed** to the
   `dapurkasih` project via Firebase CLI: users edit only their own profile, bookings
   are created as Pending by their owner, only admins change status fields.
9. ✅ Double-booking guards: booking submission re-checks the slot, and admin Approve
   refuses when another Approved booking exists for the same slot/date.
10. ✅ Profile photos stored as base64 in Firestore (`users.imageBase64`) because
    Firebase Storage is **not enabled** on the `dapurkasih` project (needs console
    "Get Started" + possibly Blaze plan). If the team later enables Storage, the old
    `StorageService` can be restored from `C:\dapur kab info\dapur_kasih_kab`.
11. ✅ **Premium UI revamp (2026-07-09):** full visual redesign following the approved UI
    reference — design system in `styles.dart` (cream/orange/navy palette, Poppins via
    `google_fonts`, `AppGradients`/`AppShadows`/`AppRadius`/`AppDecorations`, shared
    `StatusChip` + `GradientButton` widgets), every screen restyled (welcome, login,
    signup, forgot password, dashboard, slots list, booking confirm with navy hero,
    booking history, update booking, report damage with colored urgency chips, new
    `report_success.dart` navy success screen, damage history, profile with gradient
    card + menu, edit profile, admin login/signup/dashboard/bookings/damage).
    Functional touches: password show/hide toggles, 4-8 stepper for total users,
    themed confirmation dialogs, empty states, and a role re-verification guard inside
    `AdminDashboardPage` so admin pages can never be opened by non-admin accounts.
    All business logic, Firebase CRUD and navigation flow unchanged.
12. ⬜ Optional polish: push notifications on approval, slot capacity > 1 group, admin analytics.

## 7. Notes for the team

- Test admin flow: register via **Login → Admin Login → Signup as admin** (email must end with the
  domain configured in `admin_signup.dart`).
- Old test bookings in Firestore without a `status` field are displayed as `Pending`.
- Do **not** commit `android/local.properties` (machine-specific paths).
