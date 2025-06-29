import SwiftUI
import SwiftData
import PhotosUI

struct AddCatView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var adoptionDate = Date()
    @State private var breed = ""
    @State private var gender = CatGender.unknown
    @State private var isNeutered = false
    @State private var weight = ""
    @State private var notes = ""
    @State private var hasBirthDate = false
    @State private var hasAdoptionDate = true
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var profileImageData: Data?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("기본 정보") {
                    // 프로필 사진
                    HStack {
                        if let imageData = profileImageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "cat.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.orange)
                        }
                        
                        VStack(alignment: .leading) {
                            PhotosPicker(selection: $selectedPhoto, matching: .images) {
                                Text("사진 선택")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                            }
                            
                            Text("고양이 사진을 추가해보세요")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding(.vertical, 8)
                    
                    TextField("이름", text: $name)
                        .textInputAutocapitalization(.words)
                    
                    TextField("품종 (선택사항)", text: $breed)
                        .textInputAutocapitalization(.words)
                    
                    Picker("성별", selection: $gender) {
                        ForEach(CatGender.allCases, id: \.self) { gender in
                            Text("\(gender.icon) \(gender.rawValue)")
                                .tag(gender)
                        }
                    }
                    
                    Toggle("중성화 수술 완료", isOn: $isNeutered)
                }
                
                Section("날짜 정보") {
                    Toggle("생일 알고 있음", isOn: $hasBirthDate)
                    
                    if hasBirthDate {
                        DatePicker("생일", selection: $birthDate, displayedComponents: .date)
                    }
                    
                    Toggle("입양일 기록", isOn: $hasAdoptionDate)
                    
                    if hasAdoptionDate {
                        DatePicker("입양일", selection: $adoptionDate, displayedComponents: .date)
                    }
                }
                
                Section("추가 정보") {
                    HStack {
                        Text("체중 (kg)")
                        Spacer()
                        TextField("0.0", text: $weight)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    TextField("메모", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("고양이 등록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveCat()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        profileImageData = data
                    }
                }
            }
        }
    }
    
    private func saveCat() {
        let cat = Cat(
            name: name,
            birthDate: hasBirthDate ? birthDate : nil,
            adoptionDate: hasAdoptionDate ? adoptionDate : nil,
            breed: breed,
            gender: gender,
            isNeutered: isNeutered,
            weight: Double(weight),
            profileImageData: profileImageData,
            notes: notes
        )
        
        modelContext.insert(cat)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("고양이 저장 실패: \(error)")
        }
    }
}

#Preview {
    AddCatView()
        .modelContainer(for: Cat.self, inMemory: true)
} 