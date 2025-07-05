import Foundation
import UserNotifications
import SwiftData

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("알림 권한 요청 실패: \(error)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
    
    // MARK: - Medication Notifications
    
    func scheduleMedicationNotification(for medication: MedicationSchedule) async {
        guard authorizationStatus == .authorized else {
            print("알림 권한이 없습니다")
            return
        }
        
        // 기존 알림 제거
        await removeMedicationNotification(for: medication)
        
        // 새 알림 스케줄링
        switch medication.frequency {
        case .daily:
            await scheduleDailyNotification(for: medication)
        case .weekly:
            await scheduleWeeklyNotification(for: medication)
        case .monthly:
            await scheduleMonthlyNotification(for: medication)
        case .asNeeded:
            break // 필요시 투약은 알림 없음
        }
    }
    
    func removeMedicationNotification(for medication: MedicationSchedule) async {
        let identifier = "medication-\(medication.id.uuidString)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    private func scheduleDailyNotification(for medication: MedicationSchedule) async {
        let content = UNMutableNotificationContent()
        content.title = "투약 시간입니다"
        content.body = "\(medication.cat?.name ?? "고양이")의 \(medication.name) 투약 시간이에요"
        content.sound = .default
        content.badge = 1
        
        // 카테고리 및 액션 설정
        content.categoryIdentifier = "MEDICATION_REMINDER"
        content.userInfo = [
            "medicationId": medication.id.uuidString,
            "catName": medication.cat?.name ?? "",
            "medicationName": medication.name
        ]
        
        // 매일 반복 알림
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: medication.reminderTime)
        let minute = calendar.component(.minute, from: medication.reminderTime)
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let identifier = "medication-\(medication.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("매일 투약 알림 설정 완료: \(medication.name)")
        } catch {
            print("매일 투약 알림 설정 실패: \(error)")
        }
    }
    
    private func scheduleWeeklyNotification(for medication: MedicationSchedule) async {
        let content = UNMutableNotificationContent()
        content.title = "투약 시간입니다"
        content.body = "\(medication.cat?.name ?? "고양이")의 \(medication.name) 투약 시간이에요"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "MEDICATION_REMINDER"
        content.userInfo = [
            "medicationId": medication.id.uuidString,
            "catName": medication.cat?.name ?? "",
            "medicationName": medication.name
        ]
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: medication.reminderTime)
        let minute = calendar.component(.minute, from: medication.reminderTime)
        let weekday = calendar.component(.weekday, from: medication.startDate)
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.weekday = weekday
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let identifier = "medication-\(medication.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("주간 투약 알림 설정 완료: \(medication.name)")
        } catch {
            print("주간 투약 알림 설정 실패: \(error)")
        }
    }
    
    private func scheduleMonthlyNotification(for medication: MedicationSchedule) async {
        let content = UNMutableNotificationContent()
        content.title = "투약 시간입니다"
        content.body = "\(medication.cat?.name ?? "고양이")의 \(medication.name) 투약 시간이에요"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "MEDICATION_REMINDER"
        content.userInfo = [
            "medicationId": medication.id.uuidString,
            "catName": medication.cat?.name ?? "",
            "medicationName": medication.name
        ]
        
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: medication.reminderTime)
        let minute = calendar.component(.minute, from: medication.reminderTime)
        let day = calendar.component(.day, from: medication.startDate)
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.day = day
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let identifier = "medication-\(medication.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("월간 투약 알림 설정 완료: \(medication.name)")
        } catch {
            print("월간 투약 알림 설정 실패: \(error)")
        }
    }
    
    // MARK: - Notification Categories and Actions
    
    func setupNotificationCategories() {
        let takenAction = UNNotificationAction(
            identifier: "TAKEN_ACTION",
            title: "투약 완료",
            options: [.foreground]
        )
        
        let skipAction = UNNotificationAction(
            identifier: "SKIP_ACTION",
            title: "건너뛰기",
            options: []
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_ACTION",
            title: "10분 후 알림",
            options: []
        )
        
        let medicationCategory = UNNotificationCategory(
            identifier: "MEDICATION_REMINDER",
            actions: [takenAction, snoozeAction, skipAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([medicationCategory])
    }
    
    // MARK: - Notification Handling
    
    func handleNotificationAction(identifier: String, userInfo: [AnyHashable: Any]) async {
        guard let medicationIdString = userInfo["medicationId"] as? String,
              let medicationId = UUID(uuidString: medicationIdString) else {
            print("유효하지 않은 투약 ID")
            return
        }
        
        switch identifier {
        case "TAKEN_ACTION":
            await markMedicationAsTaken(medicationId: medicationId)
        case "SKIP_ACTION":
            await markMedicationAsSkipped(medicationId: medicationId)
        case "SNOOZE_ACTION":
            await snoozeMedicationNotification(medicationId: medicationId, userInfo: userInfo)
        default:
            break
        }
    }
    
    private func markMedicationAsTaken(medicationId: UUID) async {
        // SwiftData 컨텍스트에서 투약 기록 생성
        print("투약 완료 처리: \(medicationId)")
        // 실제 구현에서는 SwiftData ModelContext를 통해 MedicationLog 생성
    }
    
    private func markMedicationAsSkipped(medicationId: UUID) async {
        // 투약 건너뛰기 처리
        print("투약 건너뛰기 처리: \(medicationId)")
        // 실제 구현에서는 SwiftData ModelContext를 통해 MedicationLog 생성 (wasGiven: false)
    }
    
    private func snoozeMedicationNotification(medicationId: UUID, userInfo: [AnyHashable: Any]) async {
        let content = UNMutableNotificationContent()
        content.title = "투약 시간입니다"
        content.body = "\(userInfo["catName"] as? String ?? "고양이")의 \(userInfo["medicationName"] as? String ?? "약물") 투약 시간이에요"
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "MEDICATION_REMINDER"
        content.userInfo = userInfo
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 600, repeats: false) // 10분 후
        
        let identifier = "medication-snooze-\(medicationId.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("10분 후 다시 알림 설정 완료")
        } catch {
            print("다시 알림 설정 실패: \(error)")
        }
    }
    
    // MARK: - Utility Methods
    
    func getAllPendingNotifications() async -> [UNNotificationRequest] {
        return await UNUserNotificationCenter.current().pendingNotificationRequests()
    }
    
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
} 