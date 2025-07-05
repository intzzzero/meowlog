import SwiftUI
import SwiftData

struct MedicationListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var medications: [MedicationSchedule]
    @State private var showingAddMedication = false
    @State private var showingNotificationPermission = false
    @EnvironmentObject var notificationManager: NotificationManager
    
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
                    ForEach(medications.filter { $0.isActive }) { medication in
                        MedicationRowView(medication: medication)
                    }
                    .onDelete(perform: deleteMedications)
                }
            }
            .navigationTitle("투약 관리")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        handleAddMedication()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddMedication) {
                AddMedicationScheduleView()
            }
            .sheet(isPresented: $showingNotificationPermission) {
                NotificationPermissionView()
            }
            .task {
                await notificationManager.checkAuthorizationStatus()
            }
            .onAppear {
                checkAndUpdateAuthStatus()
            }
        }
    }
    
    private func handleAddMedication() {
        if notificationManager.authorizationStatus == .notDetermined {
            showingNotificationPermission = true
        } else {
            showingAddMedication = true
        }
    }
    
    private func deleteMedications(offsets: IndexSet) {
        withAnimation {
            let activeMedications = medications.filter { $0.isActive }
            for index in offsets {
                let medication = activeMedications[index]
                medication.isActive = false
                medication.updatedAt = Date()
            }
            
            do {
                try modelContext.save()
            } catch {
                print("투약 일정 삭제 실패: \(error)")
            }
        }
    }
    
    private func checkAndUpdateAuthStatus() {
        Task {
            await notificationManager.checkAuthorizationStatus()
        }
    }
}

struct MedicationRowView: View {
    @Environment(\.modelContext) private var modelContext
    let medication: MedicationSchedule
    
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: {
            showingDetail = true
        }) {
            HStack(spacing: 12) {
                // 약물 아이콘
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Text(medication.frequency.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(medication.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        // 다음 투약 시간
                        if let nextDose = medication.nextDoseDate {
                            Text(formatNextDose(nextDose))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Text("\(medication.dosage) • \(medication.frequency.rawValue)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        // 준수율 표시
                        if medication.frequency != .asNeeded {
                            HStack(spacing: 4) {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.caption)
                                Text("\(Int(medication.adherenceRate * 100))%")
                                    .font(.caption)
                            }
                            .foregroundColor(adherenceColor(medication.adherenceRate))
                        }
                    }
                }
                
                // 투약 완료 버튼
                Button(action: {
                    markAsTaken()
                }) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
                .buttonStyle(.borderless)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingDetail) {
            MedicationDetailView(medication: medication)
        }
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
    
    private func adherenceColor(_ rate: Double) -> Color {
        if rate >= 0.8 {
            return .green
        } else if rate >= 0.6 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func markAsTaken() {
        let log = MedicationLog(date: Date(), wasGiven: true)
        log.medicationSchedule = medication
        medication.medicationLogs.append(log)
        
        modelContext.insert(log)
        
        do {
            try modelContext.save()
        } catch {
            print("투약 기록 저장 실패: \(error)")
        }
    }
}

#Preview {
    MedicationListView()
        .modelContainer(for: MedicationSchedule.self, inMemory: true)
} 