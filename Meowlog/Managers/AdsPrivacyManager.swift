import Foundation
import AppTrackingTransparency

enum AdsPrivacyManager {
    static func requestATTAuthorizationIfNeeded() {
        guard #available(iOS 14.5, *) else { return }
        let status = ATTrackingManager.trackingAuthorizationStatus
        guard status == .notDetermined else { return }
        ATTrackingManager.requestTrackingAuthorization { _ in }
    }
}


