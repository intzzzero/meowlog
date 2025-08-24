import Foundation
import GoogleMobileAds
import UIKit

final class InterstitialAdManager: NSObject {
    static let shared = InterstitialAdManager()

    private var interstitial: InterstitialAd?
    private var isLoading: Bool = false

    func load() {
        guard !isLoading else { return }
        isLoading = true

        let request = Request()
        InterstitialAd.load(with: AdsIDs.interstitialUnitId, request: request) { [weak self] ad, error in
            guard let self else { return }
            self.isLoading = false
            if let error = error {
                print("[Ads] Interstitial load failed: \(error.localizedDescription)")
                return
            }
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
            print("[Ads] Interstitial loaded")
        }
    }

    func show(from viewController: UIViewController) {
        if interstitial == nil { load() }
        guard let interstitial else {
            print("[Ads] Interstitial not ready")
            return
        }
        interstitial.present(from: viewController)
    }
}

extension InterstitialAdManager: FullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        interstitial = nil
        load()
    }
}


