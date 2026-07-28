import Foundation

enum PurchaseError: LocalizedError, Identifiable {
    case productUnavailable
    case productLoadingFailed(String)
    case purchaseFailed(String)
    case verificationFailed
    case purchasePending
    case restoreFailed(String)
    case nothingToRestore

    var id: String {
        switch self {
        case .productUnavailable:
            return "productUnavailable"
        case .productLoadingFailed(let message):
            return "productLoadingFailed-\(message)"
        case .purchaseFailed(let message):
            return "purchaseFailed-\(message)"
        case .verificationFailed:
            return "verificationFailed"
        case .purchasePending:
            return "purchasePending"
        case .restoreFailed(let message):
            return "restoreFailed-\(message)"
        case .nothingToRestore:
            return "nothingToRestore"
        }
    }

    var errorDescription: String? {
        switch self {
        case .productUnavailable:
            return "BUILT Pro is unavailable"
        case .productLoadingFailed:
            return "The App Store could not load BUILT Pro"
        case .purchaseFailed:
            return "The purchase could not be completed"
        case .verificationFailed:
            return "The purchase could not be verified"
        case .purchasePending:
            return "The purchase is pending"
        case .restoreFailed:
            return "Purchases could not be restored"
        case .nothingToRestore:
            return "No previous purchase was found"
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .productUnavailable:
            return "Confirm that the StoreKit configuration or App Store Connect product uses the exact product identifier expected by the app."
        case .productLoadingFailed(let message):
            return message
        case .purchaseFailed(let message):
            return message
        case .verificationFailed:
            return "No features were unlocked. Try again, or use Restore Purchases after the App Store finishes processing the transaction."
        case .purchasePending:
            return "The App Store is waiting for approval or another action. BUILT will unlock automatically when the transaction completes."
        case .restoreFailed(let message):
            return message
        case .nothingToRestore:
            return "Use the Apple Account that originally purchased BUILT Pro, then try again."
        }
    }
}
