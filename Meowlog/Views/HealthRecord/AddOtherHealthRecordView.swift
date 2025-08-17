import SwiftUI
import SwiftData
import PhotosUI

struct AddOtherHealthRecordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var cats: [Cat]
    
    @State private var selectedCat: Cat?
    @State private var selectedDate = Date()
    @State private var selectedType = HealthRecordType.general
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // 타입별 특화 데이터
    @State private var respiratoryRate = 20
    @State private var heartRate = 120
    @State private var weight = 4.0
    @State private var temperature = 38.5
    
    private let otherHealthRecordTypes: [HealthRecordType] = [
        .respiratoryRate, .heartRate, .weight, .temperature, .symptom, .general
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                CatSelectionSection(cats: cats, selectedCat: $selectedCat)
                
                DateTimeSection(selectedDate: $selectedDate)
                
                Section("기록 유형") {
                    Picker("유형", selection: $selectedType) {
                        ForEach(otherHealthRecordTypes, id: \.self) { type in
                            HStack {
                                Text(type.icon)
                                Text(type.rawValue)
                            }
                            .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // 타입별 특화 입력 필드
                TypeSpecificInputSection(
                    selectedType: selectedType,
                    respiratoryRate: $respiratoryRate,
                    heartRate: $heartRate,
                    weight: $weight,
                    temperature: $temperature
                )
                
                PhotoSection(
                    selectedPhoto: $selectedPhoto,
                    imageData: $imageData
                )
                
                NotesSection(notes: $notes)
                
                if selectedType == .symptom {
                    SymptomWarningSection()
                }
            }
            .navigationTitle("기타 기록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveHealthRecord()
                    }
                    .disabled(selectedCat == nil)
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
            .alert("알림", isPresented: $showingAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func saveHealthRecord() {
        guard let selectedCat = selectedCat else {
            alertMessage = "고양이를 선택해주세요."
            showingAlert = true
            return
        }
        
        let record = HealthRecord(
            type: selectedType,
            date: selectedDate,
            notes: notes,
            imageData: imageData
        )
        
        // 타입별 특화 데이터 설정
        switch selectedType {
        case .respiratoryRate:
            record.respiratoryRate = respiratoryRate
        case .heartRate:
            record.heartRate = heartRate
        case .weight:
            record.weight = weight
        case .temperature:
            record.temperature = temperature
        default:
            break
        }
        
        record.cat = selectedCat
        selectedCat.healthRecords.append(record)
        
        modelContext.insert(record)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            alertMessage = "저장 중 오류가 발생했습니다: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

// MARK: - Type Specific Input Section

struct TypeSpecificInputSection: View {
    let selectedType: HealthRecordType
    @Binding var respiratoryRate: Int
    @Binding var heartRate: Int
    @Binding var weight: Double
    @Binding var temperature: Double
    
    var body: some View {
        switch selectedType {
        case .respiratoryRate:
            Section {
                Stepper(value: $respiratoryRate, in: 1...100) {
                    HStack {
                        Text("호흡수")
                        Spacer()
                        Text("\(respiratoryRate)회/분")
                            .foregroundColor(.secondary)
                    }
                }
            } footer: {
                Text("정상 범위: 20-30회/분(*수면시 15-25회/분)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
        case .heartRate:
            Section {
                Stepper(value: $heartRate, in: 60...300) {
                    HStack {
                        Text("심박수")
                        Spacer()
                        Text("\(heartRate)회/분")
                            .foregroundColor(.secondary)
                    }
                }
            } footer: {
                Text("정상 범위: 120-180회/분")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
        case .weight:
            Section {
                HStack {
                    Text("체중")
                    Spacer()
                    TextField("체중", value: $weight, format: .number.precision(.fractionLength(1)))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                    Text("kg")
                        .foregroundColor(.secondary)
                }
            } footer: {
                Text("정확한 체중을 입력해주세요.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
        case .temperature:
            Section {
                HStack {
                    Text("체온")
                    Spacer()
                    TextField("체온", value: $temperature, format: .number.precision(.fractionLength(1)))
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                    Text("°C")
                        .foregroundColor(.secondary)
                }
            } footer: {
                Text("정상 범위: 38.0-39.5°C")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
        case .symptom, .general:
            EmptyView()
        default:
            EmptyView()
        }
    }
}

// MARK: - Symptom Warning Section

struct SymptomWarningSection: View {
    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.blue)
                    Text("증상 기록")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Spacer()
                }
                
                Text("고양이에게 나타나는 증상을 자세히 기록해주세요. 지속되는 증상이나 심각한 증상의 경우 즉시 동물병원에서 진료받으시기 바랍니다.")
                    .font(.body)
                    .foregroundColor(.primary)
                
                Text("응급상황: 호흡곤란, 의식잃음, 경련, 지속적인 구토, 혈변/혈뇨 등")
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
            }
            .padding(.vertical, 8)
        } header: {
            Text("주의사항")
        }
    }
}

#Preview {
    AddOtherHealthRecordView()
        .modelContainer(for: [Cat.self, HealthRecord.self], inMemory: true)
}