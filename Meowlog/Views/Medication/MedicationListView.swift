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
                    .listRowBackground(Color(.systemBackground))
                } else {
                    ForEach(medications.filter { $0.isActive }) { medication in
                        MedicationRowView(medication: medication)
                            .listRowBackground(Color(.systemBackground))
                    }
                    .onDelete(perform: deleteMedications)
                }
            }
            .listStyle(PlainListStyle())
            .background(Color(.systemBackground))
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
    
    // 오늘 투약 여부 확인
    private var isTakenToday: Bool {
        let calendar = Calendar.current
        let today = Date()
        return medication.medicationLogs.contains { calendar.isDate($0.date, inSameDayAs: today) }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // 약물 아이콘
            ZStack {
                Circle()
                    .fill(Color(.systemGray6))
                    .frame(width: 36, height: 36)
                
                Image(systemName: "pills.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
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
                MedicationDoseButton(isTakenToday: isTakenToday)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .onTapGesture {
            showingDetail = true
        }
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

struct MedicationDoseButton: View {
    let isTakenToday: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: isTakenToday ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 16))
                .foregroundColor(isTakenToday ? .green : .gray)
            
            Text(isTakenToday ? "완료" : "복용")
                .font(.caption)
                .foregroundColor(isTakenToday ? .green : .gray)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
        )
        .accessibilityLabel(isTakenToday ? "투약 완료됨" : "투약하기")
        .accessibilityHint(isTakenToday ? "오늘 이미 투약했습니다" : "탭하여 투약을 완료로 표시하세요")
    }
}

#Preview {
    MedicationListView()
        .modelContainer(for: MedicationSchedule.self, inMemory: true)
} 