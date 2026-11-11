/// A variant is low on stock when it has an alert level (greater than 0) and
/// its stock on hand is at or below it. A threshold of 0 means no alert.
bool isLowStock(int onHand, int alertThreshold) {
  return alertThreshold > 0 && onHand <= alertThreshold;
}
