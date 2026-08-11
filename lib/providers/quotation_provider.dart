import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/mesh_item.dart';
import '../services/mesh_calculator.dart';

class QuotationProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  bool get isDarkMode => _isDarkMode;

  int _currentStep = 1; // Step 1 to 6 (Wizard), Step 7 (Summary Table)
  int get currentStep => _currentStep;

  // Header Details
  final QuotationHeader _header = QuotationHeader();
  QuotationHeader get header => _header;

  // Active Item Draft State
  MeshGrade _selectedGrade = MeshGrade.gradeA;
  int _selectedSize = 5;
  bool _isCustomDimension = false;

  String _lengthStr = '6.0';
  String _widthStr = '2.2';
  String _activeDimField = 'length'; // 'length' or 'width'

  String _disc1Str = '0';
  String _disc2Str = '0';
  String _activeDiscField = 'disc1'; // 'disc1' or 'disc2'

  String _qtyStr = '0'; // Default set to 0 per specification
  double? _draftCustomUnitPrice;

  // Shopping Cart Items - Grouped by Grade (A -> B -> DA) and Size
  final List<MeshItem> _cartItems = [];
  List<MeshItem> get cartItems {
    final sorted = List<MeshItem>.from(_cartItems);
    sorted.sort((a, b) {
      final orderMap = {MeshGrade.gradeA: 1, MeshGrade.gradeB: 2, MeshGrade.gradeDA: 3};
      final orderA = orderMap[a.grade] ?? 99;
      final orderB = orderMap[b.grade] ?? 99;
      if (orderA != orderB) {
        return orderA.compareTo(orderB);
      }
      return a.size.compareTo(b.size);
    });
    return List.unmodifiable(sorted);
  }

  // Getters for Active Draft
  MeshGrade get selectedGrade => _selectedGrade;
  int get selectedSize => _selectedSize;
  bool get isCustomDimension => _isCustomDimension;
  String get lengthStr => _lengthStr;
  String get widthStr => _widthStr;
  String get activeDimField => _activeDimField;
  String get disc1Str => _disc1Str;
  String get disc2Str => _disc2Str;
  String get activeDiscField => _activeDiscField;
  String get qtyStr => _qtyStr;

  double get currentLength => double.tryParse(_lengthStr) ?? 6.0;
  double get currentWidth => double.tryParse(_widthStr) ?? 2.2;
  double get currentArea => currentLength * currentWidth;

  double get currentUnitWeight => MeshCalculator.getUnitWeight(_selectedGrade, _selectedSize);
  double get currentListPriceRate => MeshCalculator.getListPriceRate(_selectedGrade, _selectedSize);
  double get currentBaseUnitPrice => currentListPriceRate * currentArea;

  double get currentDisc1 => double.tryParse(_disc1Str) ?? 0.0;
  double get currentDisc2 => double.tryParse(_disc2Str) ?? 0.0;

  double get calculatedUnitPrice => MeshCalculator.calculateFinalUnitPrice(
        currentBaseUnitPrice,
        currentDisc1,
        currentDisc2,
      );

  double get currentFinalUnitPrice => _draftCustomUnitPrice ?? calculatedUnitPrice;

  int get currentQty => int.tryParse(_qtyStr) ?? 0;
  double get currentTotalPrice => currentFinalUnitPrice * currentQty;

  // Grand Totals across Cart
  double get grandTotal => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get totalWeightKg => cartItems.fold(0.0, (sum, item) => sum + item.totalWeightKg);

  FleetLogistics get fleetLogistics => MeshCalculator.calculateFleetLogistics(cartItems);

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void goToStep(int step) {
    if (step >= 1 && step <= 7) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void nextStep() {
    if (_currentStep < 7) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      notifyListeners();
    }
  }

  void setGrade(MeshGrade grade) {
    _selectedGrade = grade;
    notifyListeners();
  }

  void setSize(int size) {
    _selectedSize = size;
    notifyListeners();
  }

  void setDimMode(bool isCustom) {
    _isCustomDimension = isCustom;
    if (!isCustom) {
      _lengthStr = '6.0';
      _widthStr = '2.2';
    } else {
      _lengthStr = '0';
      _widthStr = '0';
      _activeDimField = 'length';
    }
    notifyListeners();
  }

  void setActiveDimField(String field) {
    _activeDimField = field;
    notifyListeners();
  }

  void pressDimKey(String key) {
    String current = _activeDimField == 'length' ? _lengthStr : _widthStr;
    if (key == 'back') {
      if (current.length > 1) {
        current = current.substring(0, current.length - 1);
      } else {
        current = '0';
      }
    } else if (key == '.') {
      if (!current.contains('.')) {
        current += '.';
      }
    } else {
      if (current == '0') {
        current = key;
      } else {
        current += key;
      }
    }

    if (_activeDimField == 'length') {
      _lengthStr = current;
    } else {
      _widthStr = current;
    }
    notifyListeners();
  }

  void setActiveDiscField(String field) {
    _activeDiscField = field;
    notifyListeners();
  }

  void pressDiscKey(String key) {
    if (_activeDiscField == 'disc1') {
      if (key == 'back') {
        if (_disc1Str.length > 1) {
          _disc1Str = _disc1Str.substring(0, _disc1Str.length - 1);
        } else {
          _disc1Str = '0';
        }
      } else if (key == '.') {
        // Skip decimal for percentage integers
      } else {
        // Max 2 digits for 1st discount
        if (_disc1Str == '0') {
          _disc1Str = key;
        } else if (_disc1Str.length < 2) {
          _disc1Str += key;
        }

        // Auto-jump to 2nd discount box after 2 digits are entered
        if (_disc1Str.length >= 2) {
          _activeDiscField = 'disc2';
        }
      }
    } else {
      // 2nd Discount box logic (_activeDiscField == 'disc2')
      if (key == 'back') {
        if (_disc2Str != '0') {
          _disc2Str = '0';
        } else {
          // If disc2 is 0, backspace returns to 1st discount box
          _activeDiscField = 'disc1';
        }
      } else if (key == '.') {
        // Skip decimal
      } else {
        // Max 1 digit for 2nd discount
        _disc2Str = key;
      }
    }
    notifyListeners();
  }

  void pressQtyKey(String key) {
    if (key == 'back') {
      if (_qtyStr.length > 1) {
        _qtyStr = _qtyStr.substring(0, _qtyStr.length - 1);
      } else {
        _qtyStr = '0';
      }
    } else if (key == '00') {
      if (_qtyStr != '0') {
        _qtyStr += '00';
      }
    } else {
      if (_qtyStr == '0') {
        _qtyStr = key;
      } else {
        _qtyStr += key;
      }
    }
    notifyListeners();
  }

  void setSalesPerson(String name) {
    _header.salesPerson = name;
    notifyListeners();
  }

  void setPaymentTerm(PaymentTerm term) {
    _header.paymentTerm = term;
    notifyListeners();
  }

  void setValidityDays(dynamic days) {
    _header.validityDays = days;
    notifyListeners();
  }

  void setDraftCustomUnitPrice(double? price) {
    _draftCustomUnitPrice = price;
    notifyListeners();
  }

  void updateItemUnitPrice(String id, double newPrice) {
    if (id == 'draft') {
      _draftCustomUnitPrice = newPrice;
    } else {
      final index = _cartItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        _cartItems[index].customUnitPrice = newPrice;
      }
    }
    notifyListeners();
  }

  void addItemToCart() {
    final newItem = MeshItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      grade: _selectedGrade,
      size: _selectedSize,
      length: currentLength,
      width: currentWidth,
      isCustomDimension: _isCustomDimension,
      unitWeightKgPerM2: currentUnitWeight,
      listPriceRatePerM2: currentListPriceRate,
      disc1: currentDisc1,
      disc2: currentDisc2,
      quantity: currentQty,
      customUnitPrice: _draftCustomUnitPrice,
    );

    _cartItems.add(newItem);

    // Reset wizard back to Step 1 for next item entry
    _currentStep = 1;
    _disc1Str = '0';
    _disc2Str = '0';
    _activeDiscField = 'disc1';
    _qtyStr = '0';
    _draftCustomUnitPrice = null;
    notifyListeners();
  }

  void deleteCartItem(String id) {
    _cartItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _disc1Str = '0';
    _disc2Str = '0';
    _activeDiscField = 'disc1';
    _qtyStr = '0';
    notifyListeners();
  }

  String generateQuotationText() {
    final dateStr = DateFormat('dd/MM/yyyy').format(_header.date);
    final buffer = StringBuffer();
    final itemsList = cartItems; // Already sorted by Grade (A -> B -> DA)

    buffer.writeln('========================================');
    buffer.writeln('        OFFICIAL ECCO STEEL QUOTATION    ');
    buffer.writeln('========================================');
    buffer.writeln('Date: $dateStr');
    buffer.writeln('Salesperson: ${_header.salesPerson.isEmpty ? '-' : _header.salesPerson}');
    buffer.writeln('----------------------------------------');

    if (itemsList.isEmpty) {
      buffer.writeln('Current Item:');
      buffer.writeln('Fabric Ref: ${_selectedGrade.code}$_selectedSize');
      buffer.writeln('Spec Code: ${MeshCalculator.getMs145Code(_selectedGrade, _selectedSize)}');
      buffer.writeln('Dim: ${currentLength}m x ${currentWidth}m');
      buffer.writeln('Qty: $currentQty PCS');
      buffer.writeln('Unit Price: RM ${currentFinalUnitPrice.toStringAsFixed(2)}');
      buffer.writeln('Total: RM ${currentTotalPrice.toStringAsFixed(2)}');
    } else {
      for (int i = 0; i < itemsList.length; i++) {
        final item = itemsList[i];
        buffer.writeln('${i + 1}. Ref: ${item.fabricRefNo} (${item.ms145Code}) | ${item.length}m x ${item.width}m');
        buffer.writeln('   List Rate: RM ${item.listPriceRatePerM2.toStringAsFixed(2)}/m² | Weight: ${item.unitWeightKgPerM2} kg/m²');
        buffer.writeln('   Qty: ${item.quantity} PCS | Unit Net: RM ${item.finalUnitPrice.toStringAsFixed(2)}');
        buffer.writeln('   Item Total: RM ${item.totalPrice.toStringAsFixed(2)}');
      }
      buffer.writeln('----------------------------------------');
      buffer.writeln('GRAND TOTAL: RM ${grandTotal.toStringAsFixed(2)}');
    }

    buffer.writeln('----------------------------------------');
    buffer.writeln('Brand: ECCO');
    buffer.writeln('Term: ${_header.paymentTerm.label}');
    buffer.writeln('Validity: ${_header.validityDays} ${_header.validityDays == 1 ? "day" : "days"}, subjected to final confirmation');
    buffer.writeln('========================================');

    return buffer.toString();
  }

  String generateMeshPriceText() {
    final buffer = StringBuffer();
    final itemsList = cartItems;

    if (itemsList.isEmpty) {
      final ref = '${_selectedGrade.code}$_selectedSize';
      final spec = MeshCalculator.getMs145Code(_selectedGrade, _selectedSize);
      buffer.writeln('Fabric Ref: $ref ($spec)');
      buffer.writeln('Qty: $currentQty PCS');
      buffer.writeln('Mesh Price: RM ${currentTotalPrice.toStringAsFixed(2)}');
    } else {
      buffer.writeln('ECCO Steel Mesh Price Summary:');
      for (int i = 0; i < itemsList.length; i++) {
        final item = itemsList[i];
        buffer.writeln('${i + 1}. Ref: ${item.fabricRefNo} (${item.ms145Code}) | ${item.quantity} PCS | Price: RM ${item.totalPrice.toStringAsFixed(2)}');
      }
      buffer.writeln('----------------------------------------');
      buffer.writeln('GRAND TOTAL: RM ${grandTotal.toStringAsFixed(2)}');
    }

    return buffer.toString();
  }

  String generateWhatsAppText() {
    return Uri.encodeComponent(generateMeshPriceText());
  }
}
