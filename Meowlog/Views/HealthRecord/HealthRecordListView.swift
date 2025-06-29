import SwiftUI
import SwiftData

struct HealthRecordListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var healthRecords: [HealthRecord]
    @State private var showingAddBowelMovement = false
    @State private var showingAddUrineRecord = false
    
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
                    ForEach(healthRecords.sorted(by: { $0.date > $1.date })) { record in
                        HealthRecordRow(record: record)
                    }
                    .onDelete(perform: deleteRecords)
                }
            }
            .navigationTitle("건강 기록")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            showingAddBowelMovement = true
                        }) {
                            Label("배변 기록", systemImage: "toilet")
                        }
                        
                        Button(action: {
                            showingAddUrineRecord = true
                        }) {
                            Label("소변 기록", systemImage: "drop")
                        }
                        
                        Divider()
                        
                        Button(action: {
                            // TODO: 다른 건강 기록들
                        }) {
                            Label("기타 기록", systemImage: "heart.text.square")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBowelMovement) {
                AddBowelMovementView()
            }
            .sheet(isPresented: $showingAddUrineRecord) {
                AddUrineRecordView()
            }
        }
    }
    
    private func deleteRecords(offsets: IndexSet) {
        withAnimation {
            let sortedRecords = healthRecords.sorted(by: { $0.date > $1.date })
            for index in offsets {
                modelContext.delete(sortedRecords[index])
            }
        }
    }
}

#Preview {
    HealthRecordListView()
        .modelContainer(for: HealthRecord.self, inMemory: true)
} 