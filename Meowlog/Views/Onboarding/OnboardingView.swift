import SwiftUI

struct OnboardingView: View {
    @State private var showingAddCat = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                Spacer()
                
                // 앱 아이콘과 제목
                VStack(spacing: 20) {
                    Image(systemName: "cat.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                    
                    Text("MeowLog")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("우리 고양이의 건강을 체계적으로 관리해보세요")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // 주요 기능 소개
                VStack(spacing: 20) {
                    FeatureRow(icon: "heart.text.square.fill", title: "건강 기록", description: "배변, 호흡, 심박수 등을 기록하고 관리")
                    FeatureRow(icon: "pills.fill", title: "투약 관리", description: "약물 복용 일정을 설정하고 알림 받기")
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "건강 리포트", description: "주간/월간 건강 상태 분석 리포트")
                }
                .padding(.horizontal)
                
                Spacer()
                
                // 시작하기 버튼
                Button(action: {
                    showingAddCat = true
                }) {
                    Text("고양이 등록하고 시작하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        .sheet(isPresented: $showingAddCat) {
            AddCatView()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    OnboardingView()
} 