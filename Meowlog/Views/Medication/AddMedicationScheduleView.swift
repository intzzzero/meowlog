import SwiftUI
import SwiftData

struct AddMedicationScheduleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var cats: [Cat]
    
    @State private var name = ""
    @State private var dosage = ""
    @State private var frequency = MedicationFrequency.daily
    @State private var startDate = Date()
    @State private var endDate: Date?
    @State private var hasEndDate = false
    @State private var reminderTime = Date()
    @State private var notes = ""
    @State private var selectedCat: Cat?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("기본 정보") {
                    TextField("약품명", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("용량 (예: 1정, 5ml)", text: $dosage)
                        .textInputAutocapitalization(.words)
                    
                    Picker("투약 빈도", selection: $frequency) {
                        ForEach(MedicationFrequency.allCases, id: \.self) { freq in
                            Text(freq.rawValue)
                                .foregroundColor(.primary)
                                .tag(freq)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("고양이 선택") {
                    if cats.isEmpty {
                        Text("등록된 고양이가 없습니다")
                            .foregroundColor(.secondary)
                    } else {
                        Picker("고양이", selection: $selectedCat) {
                            ForEach(cats, id: \.id) { cat in
                                Text(cat.name)
                                    .tag(cat as Cat?)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                
                Section("일정 설정") {
                    DatePicker("시작일", selection: $startDate, displayedComponents: .date)
                    
                    Toggle("종료일 설정", isOn: $hasEndDate)
                    
                    if hasEndDate {
                        DatePicker("종료일", selection: Binding(
                            get: { endDate ?? Date() },
                            set: { endDate = $0 }
                        ), displayedComponents: .date)
                    }
                    
                    if frequency != .asNeeded {
                        DatePicker("알림 시간", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section("메모") {
                    TextField("추가 메모 (선택사항)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("투약 일정 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveMedicationSchedule()
                    }
                    .disabled(!isValidForm)
                }
            }
        }
        .onAppear {
            if selectedCat == nil {
                selectedCat = cats.first
            }
        }
    }
    
    private var isValidForm: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !dosage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedCat != nil
    }
    
    private func saveMedicationSchedule() {
        guard let cat = selectedCat else { return }
        
        let schedule = MedicationSchedule(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            dosage: dosage.trimmingCharacters(in: .whitespacesAndNewlines),
            frequency: frequency,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil,
            reminderTime: reminderTime,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        schedule.cat = cat
        cat.medicationSchedules.append(schedule)
        
        modelContext.insert(schedule)
        
        do {
            try modelContext.save()
            
            // 알림 설정
            Task {
                await NotificationManager.shared.scheduleMedicationNotification(for: schedule)
            }
            
            dismiss()
        } catch {
            print("투약 일정 저장 실패: \(error)")
        }
    }
}

#Preview {
    AddMedicationScheduleView()
        .modelContainer(for: MedicationSchedule.self, inMemory: true)
} 