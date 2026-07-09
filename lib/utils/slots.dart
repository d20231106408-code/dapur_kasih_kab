/// Shared kitchen slot definitions.
///
/// The kitchen operates hourly slots from 08:00 to 23:00. This list was
/// previously duplicated in `dashboard.dart` and `report_damage.dart`.
final List<Map<String, String>> kitchenSlots = List.generate(15, (index) {
  final startHour = 8 + index;
  final endHour = startHour + 1;
  return {
    "slotId": "$startHour", // unique ID for Firestore
    "title": "Slot ${index + 1}",
    "time":
        "${startHour.toString().padLeft(2, '0')}:00 - ${endHour.toString().padLeft(2, '0')}:00",
  };
});

/// Booking statuses that no longer occupy a slot.
const List<String> kNonBlockingBookingStatuses = ["rejected", "cancelled"];

/// True when a booking with [status] still blocks its slot
/// (Pending and Approved bookings block; Rejected/Cancelled free the slot).
bool bookingBlocksSlot(String? status) {
  if (status == null) return true; // legacy bookings without status = Pending
  return !kNonBlockingBookingStatuses.contains(status.toLowerCase());
}
