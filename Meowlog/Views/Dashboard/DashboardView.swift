import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cats: [Cat]
    @Query private var medications: [MedicationSchedule]
    @Query(sort: \HealthRecord.date, order: .reverse) private var healthRecords: [HealthRecord]
    
    private var todayHealthRecords: [HealthRecord] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return healthRecords.filter { calendar.isDate($0.date, inSameDayAs: today) }
    }
    
    private var activeMedications: [MedicationSchedule] {
        medications.filter { $0.isActive }
    }
    
    private var upcomingMedications: [(MedicationSchedule, Date)] {
        activeMedications.compactMap { medication in
            guard let nextDose = medication.nextDoseDate else { return nil }
            return (medication, nextDose)
        }.sorted { $0.1 < $1.1 }.prefix(3).map { $0 }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 인사말
                    if let firstCat = cats.first {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("안녕하세요!")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("\(firstCat.name)의 건강을 체크해보세요")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                            
                            if let imageData = firstCat.profileImageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "cat.circle.fill")
                                    .font(.system(size: 50))
                                    .foregroundColor(.orange)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // 오늘의 건강 기록
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("오늘의 건강 기록", systemImage: "heart.text.square")
                                .font(.headline)
                            Spacer()
                            
                            NavigationLink(destination: HealthRecordListView()) {
                                Text("전체보기")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        if todayHealthRecords.isEmpty {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                    .foregroundColor(.green)
                                Text("오늘은 아직 기록이 없어요")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(todayHealthRecords.prefix(3)) { record in
                                    DashboardHealthRecordRow(record: record)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // 다음 투약 일정
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("다음 투약 일정", systemImage: "pills")
                                .font(.headline)
                            Spacer()
                            
                            NavigationLink(destination: MedicationListView()) {
                                Text("전체보기")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        if upcomingMedications.isEmpty {
                            HStack {
                                Image(systemName: "pills")
                                    .foregroundColor(.orange)
                                Text("예정된 투약이 없어요")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(upcomingMedications, id: \.0.id) { medication, nextDose in
                                    DashboardMedicationRow(medication: medication, nextDose: nextDose)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // 빠른 기록 추가
                    VStack(alignment: .leading, spacing: 12) {
                        Label("빠른 기록", systemImage: "plus.circle")
                            .font(.headline)
                        
                        HStack(spacing: 12) {
                            QuickActionButton(
                                title: "배변",
                                icon: "toilet",
                                color: .brown,
                                destination: AddBowelMovementView()
                            )
                            
                            QuickActionButton(
                                title: "소변",
                                icon: "drop",
                                color: .yellow,
                                destination: AddUrineRecordView()
                            )
                            
                            QuickActionButton(
                                title: "투약",
                                icon: "pills",
                                color: .orange,
                                destination: AddMedicationScheduleView()
                            )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .navigationTitle("홈")
        }
    }
}

struct DashboardHealthRecordRow: View {
    let record: HealthRecord
    
    var body: some View {
        HStack {
            Image(systemName: record.type.icon)
                .font(.title3)
                .foregroundColor(record.type.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(record.type.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(formatTime(record.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let catName = record.cat?.name {
                Text(catName)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

struct DashboardMedicationRow: View {
    let medication: MedicationSchedule
    let nextDose: Date
    
    var body: some View {
        HStack {
            Image(systemName: "pills.fill")
                .font(.title3)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(medication.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(medication.dosage)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatNextDose(nextDose))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.orange)
                
                if let catName = medication.cat?.name {
                    Text(catName)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatNextDose(_ date: Date) -> String {
        let formatter = DateFormatter()
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "HH:mm"
            return "오늘 \(formatter.string(from: date))"
        } else if calendar.isDateInTomorrow(date) {
            formatter.dateFormat = "HH:mm"
            return "내일 \(formatter.string(from: date))"
        } else {
            formatter.dateFormat = "M/d HH:mm"
            return formatter.string(from: date)
        }
    }
}

struct QuickActionButton<Destination: View>: View {
    let title: String
    let icon: String
    let color: Color
    let destination: Destination
    
    @State private var showingSheet = false
    
    var body: some View {
        Button(action: {
            showingSheet = true
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showingSheet) {
            destination
        }
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: Cat.self, inMemory: true)
} 