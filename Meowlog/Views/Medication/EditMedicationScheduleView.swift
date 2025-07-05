import SwiftUI
import SwiftData

struct EditMedicationScheduleView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var cats: [Cat]
    
    let medication: MedicationSchedule
    
    @State private var name: String
    @State private var dosage: String
    @State private var frequency: MedicationFrequency
    @State private var startDate: Date
    @State private var endDate: Date?
    @State private var hasEndDate: Bool
    @State private var reminderTime: Date
    @State private var notes: String
    @State private var selectedCat: Cat?
    @State private var isActive: Bool
    
    init(medication: MedicationSchedule) {
        self.medication = medication
        self._name = State(initialValue: medication.name)
        self._dosage = State(initialValue: medication.dosage)
        self._frequency = State(initialValue: medication.frequency)
        self._startDate = State(initialValue: medication.startDate)
        self._endDate = State(initialValue: medication.endDate)
        self._hasEndDate = State(initialValue: medication.endDate != nil)
        self._reminderTime = State(initialValue: medication.reminderTime)
        self._notes = State(initialValue: medication.notes)
        self._selectedCat = State(initialValue: medication.cat)
        self._isActive = State(initialValue: medication.isActive)
    }
    
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
                                .tag(freq)
                        }
                    }
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
                    
                    Toggle("활성 상태", isOn: $isActive)
                }
                
                Section("메모") {
                    TextField("추가 메모 (선택사항)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("투약 일정 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveChanges()
                    }
                    .disabled(!isValidForm)
                }
            }
        }
    }
    
    private var isValidForm: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !dosage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        selectedCat != nil
    }
    
    private func saveChanges() {
        guard let cat = selectedCat else { return }
        
        // 기존 고양이에서 제거
        if let currentCat = medication.cat, currentCat != cat {
            currentCat.medicationSchedules.removeAll { $0.id == medication.id }
        }
        
        // 새로운 고양이에 추가
        if !cat.medicationSchedules.contains(where: { $0.id == medication.id }) {
            cat.medicationSchedules.append(medication)
        }
        
        // 투약 스케줄 업데이트
        medication.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        medication.dosage = dosage.trimmingCharacters(in: .whitespacesAndNewlines)
        medication.frequency = frequency
        medication.startDate = startDate
        medication.endDate = hasEndDate ? endDate : nil
        medication.reminderTime = reminderTime
        medication.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        medication.cat = cat
        medication.isActive = isActive
        medication.updatedAt = Date()
        
        do {
            try modelContext.save()
            
            // 알림 재설정
            Task {
                await NotificationManager.shared.scheduleMedicationNotification(for: medication)
            }
            
            dismiss()
        } catch {
            print("투약 일정 수정 실패: \(error)")
        }
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
    
    return EditMedicationScheduleView(medication: medication)
        .modelContainer(container)
} 