import '../models/mesh_item.dart';

class MeshCalculator {
  // Master MS145:2014 Code Matrix
  static final Map<String, String> _ms145CodeMatrix = {
    // Grade A - SQUARE MESH
    'A4': 'A 63',
    'A5': 'A 98',
    'A6': 'A 142',
    'A7': 'A 193',
    'A8': 'A 252',
    'A9': 'A 318',
    'A10': 'A 393',
    'A11': 'A 475',
    'A12': 'A 565',
    'A13': 'A 663',
    // Grade B - RECTANGULAR MESH
    'B5': 'B 196',
    'B6': 'B 283',
    'B7': 'B 385',
    'B8': 'B 503',
    'B9': 'B 636',
    'B10': 'B 785',
    'B11': 'B 950',
    'B12': 'B 1131',
    'B13': 'B 1325',
    // Grade DA - SMALL SQUARE MESH
    'DA4': 'DA 126',
    'DA5': 'DA 196',
    'DA6': 'DA 283',
    'DA7': 'DA 385',
    'DA8': 'DA 503',
    'DA9': 'DA 636',
    'DA10': 'DA 785',
    'DA11': 'DA 950',
    'DA12': 'DA 1131',
    'DA13': 'DA 1325',
  };

  // Official MS145:2014 Unit Weight Matrix (kg/m^2)
  static final Map<String, double> _weightMatrix = {
    // Grade A
    'A4': 0.99,
    'A5': 1.54,
    'A6': 2.22,
    'A7': 3.02,
    'A8': 3.95,
    'A9': 4.99,
    'A10': 6.16,
    'A11': 7.46,
    'A12': 8.88,
    'A13': 10.42,
    // Grade B
    'B5': 3.05,
    'B6': 3.73,
    'B7': 4.53,
    'B8': 5.93,
    'B9': 6.97,
    'B10': 8.14,
    'B11': 9.44,
    'B12': 10.90,
    'B13': 12.40,
    // Grade DA
    'DA4': 1.93,
    'DA5': 3.08,
    'DA6': 4.44,
    'DA7': 6.04,
    'DA8': 7.90,
    'DA9': 9.98,
    'DA10': 12.32,
    'DA11': 14.91,
    'DA12': 17.76,
    'DA13': 20.85,
  };

  // Official List Price Rate Matrix (RM/m^2)
  static final Map<String, double> _priceRateMatrix = {
    // Grade A
    'A4': 7.50,
    'A5': 11.60,
    'A6': 15.00,
    'A7': 20.40,
    'A8': 26.70,
    'A9': 33.70,
    'A10': 41.60,
    'A11': 50.40,
    'A12': 66.60,
    'A13': 78.20,
    // Grade B
    'B5': 22.90,
    'B6': 25.20,
    'B7': 30.60,
    'B8': 40.10,
    'B9': 47.10,
    'B10': 54.90,
    'B11': 63.70,
    'B12': 81.40,
    'B13': 101.30,
    // Grade DA
    'DA4': 15.00,
    'DA5': 23.20,
    'DA6': 30.00,
    'DA7': 40.80,
    'DA8': 53.40,
    'DA9': 67.40,
    'DA10': 83.20,
    'DA11': 100.80,
    'DA12': 133.20,
    'DA13': 156.40,
  };

  static String getMs145Code(MeshGrade grade, int size) {
    final key = '${grade.code}$size';
    return _ms145CodeMatrix[key] ?? '${grade.code} $size';
  }

  static double getUnitWeight(MeshGrade grade, int size) {
    final key = '${grade.code}$size';
    return _weightMatrix[key] ?? 1.54;
  }

  static double getListPriceRate(MeshGrade grade, int size) {
    final key = '${grade.code}$size';
    return _priceRateMatrix[key] ?? 11.60;
  }

  static double calculateArea(double length, double width) {
    return length * width;
  }

  static double calculateBasePrice(double rate, double length, double width) {
    return rate * length * width;
  }

  static double calculateFinalUnitPrice(
    double baseUnitPrice,
    double disc1Percent,
    double disc2Percent,
  ) {
    final afterDisc1 = baseUnitPrice * (1 - (disc1Percent / 100));
    return afterDisc1 * (1 - (disc2Percent / 100));
  }

  // Fleet Lorry Transport Breakdown Calculation
  static FleetLogistics calculateFleetLogistics(List<MeshItem> cartItems) {
    double totalWeightKg = 0.0;
    for (var item in cartItems) {
      totalWeightKg += item.totalWeightKg;
    }

    final totalWeightTonnes = totalWeightKg / 1000.0;

    // Lorry Capacities (Tonnes)
    const double capacity20ft = 11.0; // 20FT lorry ~ 10-12 Tonnes max
    const double capacity40ft = 25.0; // 40FT lorry ~ 24-25 Tonnes max

    int lorry20ftCount = (totalWeightTonnes / capacity20ft).ceil();
    if (lorry20ftCount < 1) lorry20ftCount = 1;

    int lorry40ftCount = (totalWeightTonnes / capacity40ft).ceil();
    if (lorry40ftCount < 1) lorry40ftCount = 1;

    double util20ft = (totalWeightTonnes / capacity20ft) * 100.0;
    double util40ft = (totalWeightTonnes / capacity40ft) * 100.0;

    FleetCapacityStatus status;
    if (totalWeightTonnes == 0.0) {
      status = FleetCapacityStatus.normal;
    } else if (util20ft <= 85.0) {
      status = FleetCapacityStatus.normal;
    } else if (util20ft <= 100.0) {
      status = FleetCapacityStatus.reached;
    } else {
      status = FleetCapacityStatus.exceeded;
    }

    return FleetLogistics(
      totalWeightKg: totalWeightKg,
      totalWeightTonnes: totalWeightTonnes,
      lorry20ftCount: lorry20ftCount,
      lorry40ftCount: lorry40ftCount,
      lorry20ftUtilization: util20ft > 100.0 ? 100.0 : util20ft,
      lorry40ftUtilization: util40ft > 100.0 ? 100.0 : util40ft,
      status: status,
    );
  }
}
