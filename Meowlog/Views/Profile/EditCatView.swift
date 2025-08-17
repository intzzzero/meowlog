import SwiftUI
import SwiftData
import PhotosUI

struct EditCatView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let cat: Cat
    
    @State private var name = ""
    @State private var birthDate = Date()
    @State private var adoptionDate = Date()
    @State private var breed = ""
    @State private var gender = CatGender.unknown
    @State private var isNeutered = false
    @State private var weight = ""
    @State private var notes = ""
    @State private var hasBirthDate = false
    @State private var hasAdoptionDate = false
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
                                Text("사진 변경")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                            }
                            
                            if profileImageData != nil {
                                Button("사진 제거") {
                                    profileImageData = nil
                                }
                                .font(.caption)
                                .foregroundColor(.red)
                            }
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
            .navigationTitle("프로필 편집")
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
                    .foregroundColor(.orange)
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        profileImageData = data
                    }
                }
            }
            .onAppear {
                loadCatData()
            }
        }
    }
    
    private func loadCatData() {
        name = cat.name
        birthDate = cat.birthDate ?? Date()
        adoptionDate = cat.adoptionDate ?? Date()
        breed = cat.breed
        gender = cat.gender
        isNeutered = cat.isNeutered
        weight = cat.weight?.description ?? ""
        notes = cat.notes
        hasBirthDate = cat.birthDate != nil
        hasAdoptionDate = cat.adoptionDate != nil
        profileImageData = cat.profileImageData
    }
    
    private func saveCat() {
        cat.name = name
        cat.birthDate = hasBirthDate ? birthDate : nil
        cat.adoptionDate = hasAdoptionDate ? adoptionDate : nil
        cat.breed = breed
        cat.gender = gender
        cat.isNeutered = isNeutered
        cat.weight = Double(weight)
        cat.profileImageData = profileImageData
        cat.notes = notes
        cat.updatedAt = Date()
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("고양이 정보 업데이트 실패: \(error)")
        }
    }
}

#Preview {
    EditCatView(cat: Cat(name: "미미", breed: "코리안 숏헤어", gender: .female))
        .modelContainer(for: Cat.self, inMemory: true)
}