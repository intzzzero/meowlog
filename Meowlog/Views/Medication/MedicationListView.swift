import SwiftUI
import SwiftData

struct MedicationListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var medications: [MedicationSchedule]
    
    var body: some View {
        NavigationStack {
            List {
                if medications.isEmpty {
                    ContentUnavailableView(
                        "투약 일정이 없습니다",
                        systemImage: "pills",
                        description: Text("첫 번째 투약 일정을 추가해보세요")
                    )
                } else {
                    ForEach(medications) { medication in
                        HStack {
                            Text(medication.frequency.icon)
                                .font(.title2)
                            
                            VStack(alignment: .leading) {
                                Text(medication.name)
                                    .font(.headline)
                                
                                Text(medication.frequency.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if medication.isActive {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                }
            }
            .navigationTitle("투약 관리")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // TODO: 투약 일정 추가
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    MedicationListView()
        .modelContainer(for: MedicationSchedule.self, inMemory: true)
} 