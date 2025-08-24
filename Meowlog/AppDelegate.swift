import UIKit
import GoogleMobileAds

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Initialize Google Mobile Ads SDK (v11 API)
        let appId = Bundle.main.object(forInfoDictionaryKey: "GADApplicationIdentifier") as? String ?? "<nil>"
        print("[Ads] GADApplicationIdentifier in Info.plist = \(appId)")
        if appId.hasPrefix("ca-app-pub-") {
            MobileAds.shared.start()
        } else {
            print("[Ads] Skipping MobileAds.start(): missing/invalid App ID in Info.plist")
        }
        return true
    }
}


