//
//  MeowlogApp.swift
//  Meowlog
//
//  Created by petprice on 6/29/25.
//

import SwiftUI
import SwiftData
import UserNotifications
import GoogleMobileAds

@main
struct MeowlogApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var notificationManager = NotificationManager.shared
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Cat.self,
            HealthRecord.self,
            MedicationSchedule.self,
            MedicationLog.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(NotificationManager.shared)
                .onAppear {
                    AdsPrivacyManager.requestATTAuthorizationIfNeeded()
                    setupNotifications()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func setupNotifications() {
        notificationManager.setupNotificationCategories()
        
        // 알림 델리게이트 설정
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        // 앱 시작 시 알림 권한 상태 확인
        Task {
            await notificationManager.checkAuthorizationStatus()
        }
    }
}

// MARK: - Notification Delegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    private override init() {}
    
    // 앱이 포그라운드에 있을 때 알림 표시
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // 알림 액션 처리
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        Task {
            await NotificationManager.shared.handleNotificationAction(
                identifier: response.actionIdentifier,
                userInfo: response.notification.request.content.userInfo
            )
        }
        completionHandler()
    }
}
