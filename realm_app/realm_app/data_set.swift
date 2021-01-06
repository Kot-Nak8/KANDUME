//
//  data_set.swift
//  realm_app
//
//  Created by 中村幸太 on 2020/12/27.
//

import Foundation
import RealmSwift


//RealmのEntity
class realm_data :Object{
    @objc dynamic var id: Int = 0
    @objc dynamic var genre = ""
    @objc dynamic var name = ""
    @objc dynamic var quan = ""
    @objc dynamic var day = Date()
    private static var config = Realm.Configuration(schemaVersion :1)
    private static var realm = try! Realm(configuration: config)
    //idを主キーに設定
    override static func primaryKey() -> String? {
            return "id"
    }
    //realmのデータを取り出す関数
    static func all() -> Results<realm_data> {
        realm.objects(realm_data.self)
    }
}

//データを取得しておくクラス
class get_data : ObservableObject{
    @Published var dataEntities: Results<realm_data> = realm_data.all()
    //よくわからんけどここから下のずらっと書いてあるやつをコピペしたら保存した時にビューを更新してくれるようになった
    private var notificationTokens: [NotificationToken] = []
    
        init() {
            // DBに変更があったタイミングでdataEntitiesの変数に値を入れ直す
            notificationTokens.append(dataEntities.observe { change in
                switch change {
                case let .initial(results):
                    self.dataEntities = results
                case let .update(results, _, _, _):
                    self.dataEntities = results
                case let .error(error):
                    print(error.localizedDescription)
                }
            })
        }

        deinit {
            notificationTokens.forEach { $0.invalidate() }
        }
}


//通知設定の値を保持するUserDefaultsのクラス
class Setting: ObservableObject {
    //アプリ起動時に通知の許可を迫るか
    @Published var alert_p : Bool {
        didSet {
            UserDefaults.standard.set(alert_p, forKey: "alert_p")
        }
    }
    
    // 通知を許可するかしないか
    @Published var Alert_Push: Bool {
        didSet {
            UserDefaults.standard.set(Alert_Push, forKey: "Alert_Push")
        }
    }
    
    /// 初期化処理
    init() {
        alert_p = UserDefaults.standard.bool(forKey: "alert_p")
        Alert_Push = UserDefaults.standard.bool(forKey: "Alert_Push")
    }
}
