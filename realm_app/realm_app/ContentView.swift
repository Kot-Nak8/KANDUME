//
//  ContentView.swift
//  realm_app
//
//  Created by 中村幸太 on 2020/12/27.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    
    var body: some View {
        TabView{
            NavigationView{
                ListView()
                    .navigationBarTitle("Home", displayMode: .inline)
                    .navigationBarItems(leading: NavigationLink(destination:
                        AddView()
                        ){ Image(systemName: "plus")
                                .resizable()
                                .frame(width: 20, height: 20)
                        })
            }.tabItem {
                    Image(systemName: "house")
                    Text("Home")}
            NavigationView{
                SearchView()
                    .navigationBarTitle("Search", displayMode: .inline)
            }.tabItem {
                Image(systemName: "magnifyingglass")
                Text("Search")}
        }
    }
}




//リスト表示とデータ変更のビュー
struct ListView: View {
    @State var name = ""
    @State var age = ""
    @State var day =  Date()
    @ObservedObject var getModel = get_data()
    @State private var deleteAlert = false
    @State private var updateAlert = false
    @State var datas_view = ""
    
    var body: some View {
        List {
            ForEach(getModel.dataEntities.freeze(), id: \.id) { datas in
                NavigationLink(destination:
                        NavigationView{
                            //遷移のビューを別のビューにまとめたいがdatasを別のビューに渡す方法がわからん
                            VStack{
                                Text("登録した名前：「 " + "\(datas.name)" + " 」")
                                TextField("名前の変更", text: $name).textFieldStyle(RoundedBorderTextFieldStyle())
                                Text("登録した年齢：「 " + "\(datas.age)" + " 」")
                                TextField("年齢の変更", text: $age).textFieldStyle(RoundedBorderTextFieldStyle())
                                    Text("登録した日付")
                                    Text("\(datas.day,style: .date)")
                                DatePicker("新しい日付を選択", selection: $day, displayedComponents: .date)
                                    //要素の変更編ボタン
                                    Button(action: {
                                        let config = Realm.Configuration(schemaVersion :1)
                                        do{
                                            let realm = try Realm(configuration: config)
                                            let result = realm.objects(realm_data.self)
                                            self.updateAlert = true
                                            try realm.write({
                                                //繰り返しと条件一致での方法しか考えられなかった
                                                for i in result{
                                                    if i.id == datas.id{
                                                        i.name = self.name
                                                        i.age = self.age
                                                        i.day = self.day
                                                        realm.add(i)
                                                    }
                                                }
                                                print("success")
                                                self.name = ""
                                                self.age = ""
                                                self.day = Date()
                                            })
                                        }
                                        catch{
                                            print(error.localizedDescription)
                                        }
                                        
                                        }) {
                                        Text("更新")
                                        }.padding(20)
                                        .alert(isPresented: $updateAlert) {
                                                Alert(title: Text("更新"),
                                                message: Text("データの更新完了"))   // 詳細メッセージの追加
                                        }
                                    //削除ボタンを設置
                                    Button(action: {
                                        self.deleteAlert = true
                                        }) {
                                        Text("削除")
                                        }.padding(20)
                                        //削除ボタンを押すと出るアラート
                                        .alert(isPresented: $deleteAlert) {
                                                Alert(title: Text("削除"),
                                                      message: Text("データを削除しますか"),
                                                      primaryButton: .cancel(Text("キャンセル")),
                                                      secondaryButton: .destructive(Text("削除"),
                                                                //削除を押した時の処理
                                                                //削除した時にホームに戻らないとバグる
                                                                    action: {
                                                                        let config = Realm.Configuration(schemaVersion :1)
                                                                        do{
                                                                            let realm = try Realm(configuration: config)
                                                                            let result = realm.objects(realm_data.self)
                                                                            try! realm.write({
                                                                                for i in result{
                                                                                    if i.id == datas.id{
                                                                                        realm.delete(i)
                                                                                    }}
                                                                                })
                                                                        }
                                                                        catch{
                                                                            print(error.localizedDescription)
                                                                        }
                                                                    }))
                                                            }
                                        }.padding(20)
                        }.navigationBarTitle("Edit Menu", displayMode: .inline)
                    ){
                //リストの内容
                VStack{
                Text("\(datas.name)" + "　" + "\(datas.age)")
                Text("\(datas.day,style: .date)")
                }}}
        }
    }
}


//データ追加のビュー
struct AddView: View {
    @State var name = ""
    @State var age = ""
    @State var day =  Date()
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView{
            VStack{
            //入力するところ
                //写真を追加するボタン
                Button(action: {
                    print("写真追加")
                }){
                    Text("写真を選択")
                }
                TextField("名前", text: $name).textFieldStyle(RoundedBorderTextFieldStyle())
                TextField ("年齢", text: $age).textFieldStyle(RoundedBorderTextFieldStyle())
                //日付を取得
                DatePicker("日付を選択", selection: $day, displayedComponents: .date)

            //入力したのを保存するところ
                Button(action: {
                    let config = Realm.Configuration(schemaVersion :1)
                    do{
                        let realm = try Realm(configuration: config)
                        let newdata = realm_data()
                        //主キーを決定するやつ
                        //保存されてるデータの最大のidを取得
                        var maxId: Int { return try! Realm().objects(realm_data.self).sorted(byKeyPath: "id").last?.id ?? 0 }
                        newdata.id = maxId + 1
                        newdata.name = self.name
                        newdata.age = self.age
                        newdata.day = self.day
                        try realm.write({
                            realm.add(newdata)
                            print("success")
                            self.name = ""
                            self.age = ""
                            self.day = Date()
                            self.showingAlert = true
                        })
                    }
                    catch{
                        print(error.localizedDescription)
                    }
                    
                }) {
                    Text("データ追加")
                }.alert(isPresented: $showingAlert) {
                    Alert(title: Text("データ追加完了"))
                }
                
            //デバッグエリアに保存したものを表示する
                Button(action: {
                    let config = Realm.Configuration(schemaVersion :1)
                    do{
                        let realm = try Realm(configuration: config)
                        let result = realm.objects(realm_data.self)
                        //取り出し
                        print(result)
                    }
                    catch{
                        print(error.localizedDescription)
                    }
                    
                }) {
                    Text("デバッグエリアに表示")
                }
            
            //データ全削除
                Button(action: {
                    let config = Realm.Configuration(schemaVersion :1)
                    do{
                        let realm = try Realm(configuration: config)
                        let result = realm.objects(realm_data.self)
                        for i in result{
                            try realm.write({
                                realm.delete(i)
                            })
                        }
                        print("delete")
                    }
                    catch{
                        print(error.localizedDescription)
                    }
                    
                }) {
                    Text("データ全削除")
                }
            }.padding()
        }.navigationBarTitle("New Data", displayMode: .inline)
    }
}


//検索のビュー
struct SearchView: View {
    @State var name = ""
    @State var age = ""
    @State var day =  Date()
    @ObservedObject var getModel = get_data()
    
    var body: some View {
        TextField("名前", text: $name).textFieldStyle(RoundedBorderTextFieldStyle())
        Text("検索")
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
