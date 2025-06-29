import SwiftUI
import SwiftData

struct HealthRecordListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var healthRecords: [HealthRecord]
    
    var body: some View {
        NavigationStack {
            List {
                if healthRecords.isEmpty {
                    ContentUnavailableView(
                        "건강 기록이 없습니다",
                        systemImage: "heart.text.square",
                        description: Text("첫 번째 건강 기록을 추가해보세요")
                    )
                } else {
                    ForEach(healthRecords) { record in
                        HStack {
                            Text(record.type.icon)
                                .font(.title2)
                            
                            VStack(alignment: .leading) {
                                Text(record.type.rawValue)
                                    .font(.headline)
                                
                                Text(record.date.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("건강 기록")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // TODO: 건강 기록 추가
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    HealthRecordListView()
        .modelContainer(for: HealthRecord.self, inMemory: true)
} 