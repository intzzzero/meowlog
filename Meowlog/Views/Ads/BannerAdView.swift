import SwiftUI
import GoogleMobileAds

struct BannerAdView: View {
    var body: some View {
        GeometryReader { geometry in
            BannerRepresentable(width: geometry.size.width)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
        }
        .frame(height: 50)
    }
}

private struct BannerRepresentable: UIViewRepresentable {
    let width: CGFloat

    func makeUIView(context: Context) -> BannerView {
        let size = currentOrientationAnchoredAdaptiveBanner(width: width)
        let view = BannerView(adSize: size)
        view.adUnitID = AdsIDs.bannerUnitId
        view.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController
        view.load(Request())
        return view
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        let newSize = currentOrientationAnchoredAdaptiveBanner(width: width)
        if uiView.adSize.size != newSize.size {
            uiView.adSize = newSize
            uiView.load(Request())
        }
    }
}


