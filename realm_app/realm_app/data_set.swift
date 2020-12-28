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
    @objc dynamic var name = ""
    @objc dynamic var age = ""
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
