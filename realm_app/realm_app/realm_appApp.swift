//
//  realm_appApp.swift
//  realm_app
//
//  Created by 中村幸太 on 2020/12/27.
//

import SwiftUI

@main
struct realm_appApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environment(\.locale, Locale(identifier: "ja_JP")) //日付を日本表記に
        }
    }
}
