import SwiftUI
import SwiftData

struct CatProfileListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cats: [Cat]
    @State private var showingAddCat = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(cats) { cat in
                    NavigationLink(destination: CatProfileDetailView(cat: cat)) {
                        HStack {
                            // 프로필 사진
                            if let imageData = cat.profileImageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 44, height: 44)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "cat.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.gray)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(cat.name)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                HStack(spacing: 4) {
                                    Text(cat.gender.icon)
                                    Text(cat.gender.rawValue)
                                    
                                    if cat.age > 0 {
                                        Text("• \(cat.age)살")
                                    }
                                    
                                    if !cat.breed.isEmpty {
                                        Text("• \(cat.breed)")
                                    }
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 2)
                    }
                    .listRowBackground(Color(.systemBackground))
                }
                .onDelete(perform: deleteCats)
            }
            .listStyle(PlainListStyle())
            .background(Color(.systemBackground))
            .navigationTitle("프로필")
            .safeAreaInset(edge: .bottom) {
                BannerAdView()
                    .background(Color(.systemBackground))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddCat = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddCat) {
                AddCatView()
            }
        }
    }
    
    private func deleteCats(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(cats[index])
            }
        }
    }
}

#Preview {
    CatProfileListView()
        .modelContainer(for: Cat.self, inMemory: true)
} 