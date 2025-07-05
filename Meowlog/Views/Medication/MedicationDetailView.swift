import SwiftUI
import SwiftData

struct MedicationDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let medication: MedicationSchedule
    
    @State private var showingEditView = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 기본 정보 카드
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(medication.frequency.rawValue)
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                            
                            VStack(alignment: .leading) {
                                Text(medication.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(medication.dosage)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(label: "투약 빈도", value: medication.frequency.rawValue)
                            InfoRow(label: "시작일", value: formatDate(medication.startDate))
                            
                            if let endDate = medication.endDate {
                                InfoRow(label: "종료일", value: formatDate(endDate))
                            }
                            
                            if medication.frequency != .asNeeded {
                                InfoRow(label: "알림 시간", value: formatTime(medication.reminderTime))
                            }
                            
                            if let nextDose = medication.nextDoseDate {
                                InfoRow(label: "다음 투약", value: formatNextDose(nextDose))
                            }
                        }
                        
                        if !medication.notes.isEmpty {
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("메모")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text(medication.notes)
                                    .font(.body)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // 준수율 카드
                    if medication.frequency != .asNeeded {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("투약 준수율")
                                .font(.headline)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("\(Int(medication.adherenceRate * 100))%")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(adherenceColor(medication.adherenceRate))
                                    
                                    Text("지난 30일 기준")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // 준수율 게이지
                                ZStack {
                                    Circle()
                                        .stroke(Color(.systemGray5), lineWidth: 8)
                                        .frame(width: 60, height: 60)
                                    
                                    Circle()
                                        .trim(from: 0, to: medication.adherenceRate)
                                        .stroke(adherenceColor(medication.adherenceRate), lineWidth: 8)
                                        .frame(width: 60, height: 60)
                                        .rotationEffect(.degrees(-90))
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // 최근 투약 기록
                    VStack(alignment: .leading, spacing: 12) {
                        Text("최근 투약 기록")
                            .font(.headline)
                        
                        if medication.medicationLogs.isEmpty {
                            Text("아직 투약 기록이 없습니다")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                        } else {
                            LazyVStack(spacing: 8) {
                                ForEach(medication.medicationLogs.sorted(by: { $0.date > $1.date }).prefix(10), id: \.id) { log in
                                    MedicationLogRow(log: log)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("투약 상세")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("닫기") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("편집") {
                        showingEditView = true
                    }
                }
            }
            .sheet(isPresented: $showingEditView) {
                EditMedicationScheduleView(medication: medication)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
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
            formatter.dateFormat = "M월 d일 HH:mm"
            return formatter.string(from: date)
        }
    }
    
    private func adherenceColor(_ rate: Double) -> Color {
        if rate >= 0.8 {
            return .green
        } else if rate >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct MedicationLogRow: View {
    let log: MedicationLog
    
    var body: some View {
        HStack {
            Image(systemName: log.wasGiven ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(log.wasGiven ? .green : .red)
            
            VStack(alignment: .leading) {
                Text(formatDate(log.date))
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if !log.notes.isEmpty {
                    Text(log.notes)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text(log.wasGiven ? "투약 완료" : "투약 안함")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 HH:mm"
        return formatter.string(from: date)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: MedicationSchedule.self, configurations: config)
    
    let medication = MedicationSchedule(
        name: "심장약",
        dosage: "1정",
        frequency: .daily,
        notes: "식후 30분에 복용"
    )
    
    container.mainContext.insert(medication)
    
    return MedicationDetailView(medication: medication)
        .modelContainer(container)
} 