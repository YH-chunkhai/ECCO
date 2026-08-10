import '../services/mesh_calculator.dart';

enum MeshGrade {
  gradeA('Grade A', 'Square Mesh'),
  gradeB('Grade B', 'Rectangular'),
  gradeDA('Grade DA', 'Small Square');

  final String label;
  final String subLabel;
  const MeshGrade(this.label, this.subLabel);

  String get code {
    switch (this) {
      case MeshGrade.gradeA:
        return 'A';
      case MeshGrade.gradeB:
        return 'B';
      case MeshGrade.gradeDA:
        return 'DA';
    }
  }
}

class MeshItem {
  final String id;
  final MeshGrade grade;
  final int size; // e.g., 5, 6, 7, 8, 9, 10
  final double length; // meters
  final double width; // meters
  final bool isCustomDimension;

  final double unitWeightKgPerM2; // kg/m^2
  final double listPriceRatePerM2; // RM/m^2
  final double disc1; // %
  final double disc2; // %
  final int quantity; // PCS / sheets
  double? customUnitPrice; // Editable unit price override

  MeshItem({
    required this.id,
    required this.grade,
    required this.size,
    required this.length,
    required this.width,
    required this.isCustomDimension,
    required this.unitWeightKgPerM2,
    required this.listPriceRatePerM2,
    required this.disc1,
    required this.disc2,
    required this.quantity,
    this.customUnitPrice,
  });

  String get fabricRefNo => '${grade.code}$size';
  String get ms145Code => MeshCalculator.getMs145Code(grade, size);
  String get specLabel => ms145Code;

  double get areaM2 => length * width;

  // Base list price per sheet before discount = Rate * Area
  double get baseUnitPrice => listPriceRatePerM2 * areaM2;

  // Sequential dual discount: Base * (1 - disc1/100) * (1 - disc2/100)
  double get priceAfterDisc1 => baseUnitPrice * (1 - (disc1 / 100));
  double get calculatedUnitPrice => priceAfterDisc1 * (1 - (disc2 / 100));
  double get finalUnitPrice => customUnitPrice ?? calculatedUnitPrice;

  // Total price for item quantity
  double get totalPrice => finalUnitPrice * quantity;

  // Total weight for item
  double get totalWeightKg => unitWeightKgPerM2 * areaM2 * quantity;
}

enum PaymentTerm {
  cbd('CBD'),
  cod('COD'),
  na('-N/A-');

  final String label;
  const PaymentTerm(this.label);
}

class QuotationHeader {
  String salesPerson;
  DateTime date;
  PaymentTerm paymentTerm;
  dynamic validityDays; // 1, 3, 7, 14, or '-N/A-'

  QuotationHeader({
    this.salesPerson = '',
    DateTime? date,
    this.paymentTerm = PaymentTerm.cbd,
    this.validityDays = 1,
  }) : date = date ?? DateTime.now();
}

enum FleetCapacityStatus {
  normal('Normal Capacity', 'Load is within standard transport limit.'),
  reached('Capacity Reached', 'Optimal truck capacity reached.'),
  exceeded('Fleet Limit Exceeded', 'Requires additional truck allocation.');

  final String title;
  final String description;
  const FleetCapacityStatus(this.title, this.description);
}

class FleetLogistics {
  final double totalWeightKg;
  final double totalWeightTonnes;
  final int lorry20ftCount;
  final int lorry40ftCount;
  final double lorry20ftUtilization;
  final double lorry40ftUtilization;
  final FleetCapacityStatus status;

  FleetLogistics({
    required this.totalWeightKg,
    required this.totalWeightTonnes,
    required this.lorry20ftCount,
    required this.lorry40ftCount,
    required this.lorry20ftUtilization,
    required this.lorry40ftUtilization,
    required this.status,
  });
}
