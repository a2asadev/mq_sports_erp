/// The one customer record that stands for "someone who walked in and paid".
/// The server creates it (same id everywhere), so every device has it after
/// its first sync, and staff who cannot create customers can still sell.
const String walkInCustomerId = '00000000-0000-4000-8000-000000000001';

bool isWalkIn(String customerId) => customerId == walkInCustomerId;
