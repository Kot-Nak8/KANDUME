//
//  LocalPush.swift
//  realm_app
//
//  Created by 田久保公瞭 on 2021/01/07.
//

import SwiftUI
import UserNotifications

  
struct LocalPush1: View {
    
    var body: some View {
        VStack {
            Button("Request Permission") {
                // first
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
            }

            Button("Schedule Notification") {
                
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("All set!")
                    } else if let error = error {
                        print(error.localizedDescription)
                    }
                }
                let kimi = 5
                // second
                let content = UNMutableNotificationContent()
                content.title = "今日までのものがあるみたいよ"
                content.subtitle = "アプリで確認してみよう"
                content.sound = UNNotificationSound.default

                // show this notification five seconds from now
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(kimi), repeats: false)

                // choose a random identifier
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                // add our notification request
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
}
  
  struct LocalPush_Previews: PreviewProvider {
      static var previews: some View {
        LocalPush1()
      }
  }
