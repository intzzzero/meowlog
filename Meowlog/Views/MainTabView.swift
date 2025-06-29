import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cats: [Cat]
    @State private var showingOnboarding = false
    
    var body: some View {
        Group {
            if cats.isEmpty {
                OnboardingView()
            } else {
                TabView {
                    DashboardView()
                        .tabItem {
                            Label("홈", systemImage: "house.fill")
                        }
                    
                    HealthRecordListView()
                        .tabItem {
                            Label("건강기록", systemImage: "heart.text.square.fill")
                        }
                    
                    MedicationListView()
                        .tabItem {
                            Label("투약관리", systemImage: "pills.fill")
                        }
                    
                    CatProfileListView()
                        .tabItem {
                            Label("프로필", systemImage: "cat.fill")
                        }
                }
                .tint(.orange)
            }
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: Cat.self, inMemory: true)
} 