import Foundation

enum AppProducts {
    static let SubscribeForYear = "app.yourpersonalvpn.yearly"

    static let productIdentifiers: Set<String> = [AppProducts.SubscribeForYear]

    private static let EmptyReceipt = "null" 

    static var receipt: String {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else { return EmptyReceipt }
        do {
            return try Data(contentsOf: receiptUrl).base64EncodedString()
        } catch {
            print("Error while reading receipt \(error.localizedDescription)")
            return EmptyReceipt
        }
    }
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    productIdentifier.components(separatedBy: ".").last
}