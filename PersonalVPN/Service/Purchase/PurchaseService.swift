import Foundation
import StoreKit

typealias ProductIdentifier = String
typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

extension Notification.Name {
    static let PurchaseServiceNotification = Notification.Name("IAPHelperPurchaseNotification")
    static let PurchaseCompleteValidationNotification = Notification.Name("PurchaseCompleteValidation")
}

open class PurchaseService: NSObject  {

    let queue = SKPaymentQueue.default()
    var validProductId: String?
    private var productIdentifiers: Set<ProductIdentifier>
    private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?
    private var savedPayment: SKPayment?

    deinit {
        queue.remove(self)
    }

    init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        for productIdentifier in productIds {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
        super.init()

        queue.add(self)
    }
}

// MARK: - StoreKit API

extension PurchaseService {

    func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }

    func requestProducts(productIds: Set<String>, _ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler
        productsRequest = SKProductsRequest(productIdentifiers: productIds)
        productsRequest!.delegate = self
        productsRequest!.start()
    }

    func subscribe(subscribeId: String?) {
        guard let sid = subscribeId else { subscribeYearly(); return }
        productIdentifiers.insert(sid)
        requestProducts { [weak self] result, products in
            if !result { return }
            let product: SKProduct? = products!.filter { (product: SKProduct) -> Bool in
                product.productIdentifier == sid
            }.first
            guard let p = product else { self?.subscribeYearly(); return }
            self?.buyProduct(p)
        }
    }

    func subscribeYearly() {
        requestProducts { [weak self] result, products in
            if !result { return }
            self?.buyProduct(products!.first!)
        }
    }

    func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        queue.add(payment)
    }

    func continueProcessingPayment() {
        if let payment = savedPayment {
            queue.add(payment)
        }
    }

    func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        purchasedProductIdentifiers.contains(productIdentifier)
    }

    class func canMakePayments() -> Bool {
        SKPaymentQueue.canMakePayments()
    }

    func restorePurchases() {
        queue.restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate

extension PurchaseService: SKProductsRequestDelegate {

    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()

        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }

    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver

extension PurchaseService: SKPaymentTransactionObserver {

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                break
            case .purchasing:
                break
            @unknown default:
                break
            }
        }
    }

    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        let result = PurchaseService.canMakePayments()
        if !result {
            savedPayment = payment
        }
        return result
    }

    private func complete(transaction: SKPaymentTransaction) {
        print("complete transaction \(transaction.transactionIdentifier ?? "unknown")")
        queue.finishTransaction(transaction)
        handlePurchaseEvent(for: transaction.payment.productIdentifier, error: nil)
    }

    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier,
              let validProductId = validProductId, productIdentifier == validProductId else { return }
        queue.finishTransaction(transaction)
        print("restore transaction with id \(productIdentifier)")
        handlePurchaseEvent(for: productIdentifier, error: nil)
    }

    private func fail(transaction: SKPaymentTransaction) {
        print("fail transaction \(transaction.transactionIdentifier ?? "unknown")")
        queue.finishTransaction(transaction)
        var error: Error?
        if let transactionError = transaction.error as NSError?,
           let localizedDescription = transaction.error?.localizedDescription {
            error = transactionError.code != SKError.paymentCancelled.rawValue ? transaction.error : PurchaseError.alreadyPayed
            print("Transaction Error: \(localizedDescription)")
        }
        handlePurchaseEvent(for: transaction.payment.productIdentifier, error: error)
    }

    private func handlePurchaseEvent(for identifier: String?, error: Error?) {
        guard let identifier = identifier else { return }
        if error == nil {
            purchasedProductIdentifiers.insert(identifier)
            UserDefaults.standard.set(true, forKey: identifier)
        }
        let userInfo = error != nil ? ["error": error!] : nil
        NotificationCenter.default.post(name: .PurchaseServiceNotification, object: identifier, userInfo: userInfo)
    }
}

enum PurchaseError: Error {
    case alreadyPayed
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price) ?? ""
    }
}
