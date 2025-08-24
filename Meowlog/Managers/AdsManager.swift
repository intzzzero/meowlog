import Foundation

enum AdsIDs {
#if DEBUG
    static let bannerUnitId: String = "ca-app-pub-3940256099942544/2934735716" // Google test banner
    static let interstitialUnitId: String = "ca-app-pub-3940256099942544/4411468910" // Google test interstitial
#else
    static let bannerUnitId: String = "ca-app-pub-9941902100091939/1393375001"
    static let interstitialUnitId: String = "ca-app-pub-9941902100091939/8185195823"
#endif
}


