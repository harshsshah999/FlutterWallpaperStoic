import 'package:flutter/cupertino.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';

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
    debugPrint("available,$available");
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
    PurchaseDetails? purchase = hasPurchased(myProductID);
    // print(purchase.toString());

    if(purchase!=null){if (purchase.status == PurchaseStatus.purchased) {
      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
        isPurchased = true;
      }
    }}
  }

  PurchaseDetails? hasPurchased(String productID) {
    return purchases.firstWhere((purchase) => purchase.productID == productID,
        orElse: () => null);
  }

  Future<void> _getProducts() async {
    Set<String> ids = {myProductID};
    ProductDetailsResponse response = await _iap.queryProductDetails(ids);
    products = response.productDetails;
    print(products.length);
  }

  // Future<void> _getPastPurchases() async {
  //   // final response = await _iap.queryPastPurchases();
  //   // for (PurchaseDetails purchase in response.pastPurchases) {
  //   //   if (Platform.isIOS) {
  //   //     _iap.completePurchase(purchase);
  //   //   }
  //   // }
  //   // purchases = response.pastPurchases;
    
  // }

  Future<dynamic> _getPastPurchases() async {
  try {
    print("Incomming");
    await _iap.restorePurchases(); // Initiate purchase restoration

    // Listen for restored purchases on the purchase stream
    
    final streamSubscription = _iap.purchaseStream.listen((purchaseDetailsList) {
      print(purchaseDetailsList);
      final restoredPurchases = purchaseDetailsList
          .where((purchase) => purchase.status == PurchaseStatus.restored);
          // print("HI $restoredPurchases");

      // Do something with the restored purchases (e.g., update state)
      
        purchases = restoredPurchases.toList();
    });

    // print(streamSubscription);

    // Remember to cancel the stream subscription when finished
    await streamSubscription.cancel();

    return purchases; // This will be empty initially
  } catch (error) {
    print('Error restoring purchases: $error');
    return []; // Return an empty list on error
  }
}
}
