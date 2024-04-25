import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';
import 'dart:io';

class ProviderModel with ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool available = true;
  StreamSubscription? subsription;
  final String myProductID = 'stoic_autochange';

  bool _isPurchased = false;
  bool get isPurchased => _isPurchased;
  set isPurchased(bool value) {
    _isPurchased = value;
    notifyListeners();
  }

  List _purchases = [];
  List get purchases => _purchases;
  set purchases(List value) {
    _purchases = value;
    notifyListeners();
  }

  List _products = [];
  List get products => _products;
  set products(List value) {
    _products = value;
    notifyListeners();
  }

  void initialize() async {
    available = await _iap.isAvailable();
    print("available");
    if (available) {
      await _getProducts();
      await _getPastPurchases();
      verifyPurchase();
      subsription = _iap.purchaseStream.listen((data) {
        purchases.addAll(data);
        verifyPurchase();
      });
    }
  }

  void verifyPurchase() {
    PurchaseDetails purchase = hasPurchased(myProductID);

    if (purchase.status == PurchaseStatus.purchased) {
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
        isPurchased = true;
      }
    }
  }

  PurchaseDetails hasPurchased(String productID) {
    return purchases.firstWhere((purchase) => purchase.productID == productID,
        orElse: () => null);
  }

  Future<void> _getProducts() async {
    Set<String> ids = {myProductID};
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    products = response.productDetails;
  }

  Future<void> _getPastPurchases() async {
    // QueryPurchaseDetailsResponse response = await _iap.queryPastPurchases();
    // for (PurchaseDetails purchase in response.pastPurchases) {
    //   if (Platform.isIOS) {
    //     _iap.completePurchase(purchase);
    //   }
    // }
    // purchases = response.pastPurchases;
  }
}
