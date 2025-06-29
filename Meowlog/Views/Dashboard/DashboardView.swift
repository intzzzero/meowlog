import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cats: [Cat]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let firstCat = cats.first {
                        Text("안녕하세요, \(firstCat.name)!")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Text("대시보드 기능은 곧 추가될 예정입니다.")
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("홈")
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: Cat.self, inMemory: true)
} 