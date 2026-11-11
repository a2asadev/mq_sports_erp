import 'package:flutter_test/flutter_test.dart';
import 'package:mq_sports_erp/core/utils/stock_alerts.dart';
import 'package:mq_sports_erp/models/stock_audit_model.dart';
import 'package:mq_sports_erp/models/variant_model.dart';

void main() {
  group('isLowStock', () {
    test('alerts at or below the threshold', () {
      expect(isLowStock(5, 5), isTrue);
      expect(isLowStock(2, 5), isTrue);
      expect(isLowStock(-1, 5), isTrue);
      expect(isLowStock(6, 5), isFalse);
    });

    test('a threshold of 0 means no alert', () {
      expect(isLowStock(0, 0), isFalse);
      expect(isLowStock(-3, 0), isFalse);
    });
  });

  group('VariantModel alertThreshold', () {
    test('old records without the field load with no alert', () {
      final VariantModel old = VariantModel.fromMap(<String, dynamic>{
        'id': 'v',
        'sku': 'S',
        'costPrice': 1,
        'salePrice': 2,
      });
      expect(old.alertThreshold, 0);
    });

    test('round-trips and survives copyWith', () {
      final VariantModel v = VariantModel(sku: 'S', alertThreshold: 4);
      expect(VariantModel.fromMap(v.toMap()).alertThreshold, 4);
      expect(v.copyWith(salePrice: 9).alertThreshold, 4);
    });
  });

  group('StockAuditModel', () {
    test('variance is counted minus system, and round-trips', () {
      final StockAuditModel audit = StockAuditModel(
        auditNo: 'AUD-1',
        countedByName: 'Sara',
        items: const <StockAuditItem>[
          StockAuditItem(
            productId: 'p',
            variantId: 'v1',
            productName: 'Bat',
            variantLabel: 'S',
            sku: 'B1',
            systemQuantity: 10,
            countedQuantity: 7,
          ),
          StockAuditItem(
            productId: 'p',
            variantId: 'v2',
            productName: 'Bat',
            variantLabel: 'M',
            sku: 'B2',
            systemQuantity: 1,
            countedQuantity: 4,
          ),
        ],
      );
      expect(audit.items.first.variance, -3);
      expect(audit.totalVariance, 0);
      final StockAuditModel copy = StockAuditModel.fromMap(audit.toMap());
      expect(copy.items.last.variance, 3);
      expect(copy.countedByName, 'Sara');
    });
  });
}
