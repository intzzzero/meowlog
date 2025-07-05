import SwiftUI

struct NotificationPermissionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var isRequestingPermission = false
    @State private var showingAddMedication = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                // 아이콘
                Image(systemName: "bell.badge")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                VStack(spacing: 16) {
                    Text("투약 알림 설정")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("정확한 투약 시간을 놓치지 않도록\n알림을 받아보세요")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    PermissionFeatureRow(
                        icon: "clock",
                        title: "정시 알림",
                        description: "설정한 시간에 투약 알림을 받을 수 있어요"
                    )
                    
                    PermissionFeatureRow(
                        icon: "checkmark.circle",
                        title: "빠른 완료 처리",
                        description: "알림에서 바로 투약 완료를 체크할 수 있어요"
                    )
                    
                    PermissionFeatureRow(
                        icon: "clock.arrow.circlepath",
                        title: "다시 알림",
                        description: "놓친 투약 시간을 10분 후 다시 알려드려요"
                    )
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: {
                        requestPermission()
                    }) {
                        HStack {
                            if isRequestingPermission {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            
                            Text(isRequestingPermission ? "권한 요청 중..." : "알림 허용")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(isRequestingPermission)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("나중에 설정")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .navigationTitle("알림 권한")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddMedication) {
                AddMedicationScheduleView()
            }
        }
    }
    
    private func requestPermission() {
        isRequestingPermission = true
        
        Task {
            let granted = await notificationManager.requestPermission()
            
            await MainActor.run {
                isRequestingPermission = false
                if granted {
                    showingAddMedication = true
                }
            }
        }
    }
}

struct PermissionFeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    NotificationPermissionView()
} 