/// One line of a stock transfer.
class TransferLine {
  const TransferLine({required this.variantId, required this.productName, required this.variantLabel, required this.sku, required this.quantity});

  final String variantId;
  final String productName;
  final String variantLabel;
  final String sku;
  final int quantity;
}

/// Stock moved from one branch to another (`/v1/stock-transfers`).
class StockTransfer {
  const StockTransfer({
    required this.id,
    required this.transferNo,
    required this.fromBranchName,
    required this.toBranchName,
    required this.date,
    required this.note,
    required this.byName,
    required this.items,
  });

  final String id;
  final String transferNo;
  final String fromBranchName;
  final String toBranchName;
  final DateTime date;
  final String note;
  final String byName;
  final List<TransferLine> items;

  int get units => items.fold<int>(0, (int s, TransferLine l) => s + l.quantity);

  factory StockTransfer.fromMap(Map<String, dynamic> m) => StockTransfer(
        id: '${m['id'] ?? ''}',
        transferNo: '${m['transferNo'] ?? ''}',
        fromBranchName: '${m['fromBranchName'] ?? ''}',
        toBranchName: '${m['toBranchName'] ?? ''}',
        date: DateTime.tryParse('${m['transferDate'] ?? ''}')?.toLocal() ?? DateTime.now(),
        note: '${m['note'] ?? ''}',
        byName: '${m['byName'] ?? ''}',
        items: <TransferLine>[
          for (final Object? i in (m['items'] as List<Object?>? ?? <Object?>[]))
            if (i is Map<String, dynamic>)
              TransferLine(
                variantId: '${i['variantId'] ?? ''}',
                productName: '${i['productName'] ?? ''}',
                variantLabel: '${i['variantLabel'] ?? ''}',
                sku: '${i['sku'] ?? ''}',
                quantity: (i['quantity'] as num?)?.toInt() ?? 0,
              ),
        ],
      );
}
