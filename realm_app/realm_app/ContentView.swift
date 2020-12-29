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
    
    //リストを削除する関数
    private func deleteRow(offsets: IndexSet){
        if let index: Int = offsets.first {
                let config = Realm.Configuration(schemaVersion :1)
                do{
                    let realm = try Realm(configuration: config)
                    let result = realm.objects(realm_data.self)
                    try! realm.write({
                        let de = getModel.dataEntities[index].id
                        for i in result{
                            if i.id == de{
                                realm.delete(i)
                                print(index)
                            }}})
                }
                catch{
                    print(error.localizedDescription)
                }
            }}
    
    var body: some View {
        List {
            ForEach(getModel.dataEntities.freeze(), id: \.id) { datas in
                NavigationLink(destination:
                        NavigationView{
                            //遷移のビューを別のビューにまとめたいがdatasを別のビューに渡す方法がわからん
                            VStack{
                                HStack{
                                    Text("品名：")
                                    TextField("登録済み：「"+"\(datas.name)" + " 」", text: $name).textFieldStyle(RoundedBorderTextFieldStyle())}
                                HStack{
                                    Text("年齢：")
                                    TextField("登録済み：「"+"\(datas.age)" + " 」", text: $age).textFieldStyle(RoundedBorderTextFieldStyle())}
                                HStack{
                                    Text("日付：")
                                    Text("\(datas.day,style: .date)")
                                    Spacer()
                                }
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
                                        }.padding(30)
                        }.navigationBarTitle("Edit Menu", displayMode: .inline)
                        ){
                //リストの内容
                VStack{
                Text("\(datas.name)" + "　" + "\(datas.age)")
                Text("\(datas.day,style: .date)")
                }}}.onDelete(perform: self.deleteRow)
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
                TextField("品名(例：電池)", text: $name).textFieldStyle(RoundedBorderTextFieldStyle())
                TextField ("年齢(例：23)", text: $age).textFieldStyle(RoundedBorderTextFieldStyle())
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
                    
                }) {Text("データ追加")}
                    .alert(isPresented: $showingAlert) {
                        Alert(title: Text("データ追加完了"))
                    }
            }.padding()
        }.navigationBarTitle("New Data", displayMode: .inline)
    }
}


//検索のビュー
struct SearchView: View {
    @State var s_name = ""
    @State var s_age = ""
    @State var s_pday =  Date()
    @State var s_fday =  Date()
    @ObservedObject var getModel = get_data()
    
    var body: some View {
        VStack{
            Text("検索条件")
            TextField("品名", text: $s_name).textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("年齢", text: $s_age).textFieldStyle(RoundedBorderTextFieldStyle())
            NavigationLink(destination:
                            //検索ボタンを押したら表示されるビュー
                            S_ListView(s_name: $s_name, s_age: $s_age, s_pday: $s_pday, s_fday: $s_fday)
                            .navigationBarTitle("Search result", displayMode: .inline)
                ){
                Text("検索")
                }
        }.padding(30)
    }
}

//検索後のビュー
struct S_ListView: View {
    
    @Binding var s_name: String
    @Binding var s_age: String
    @Binding var s_pday: Date
    @Binding var s_fday: Date
    @State var name = ""
    @State var age = ""
    @State var day =  Date()
    @ObservedObject var getModel = get_data()
    @State private var deleteAlert = false
    @State private var updateAlert = false
    @State private var showingSecondView = true
    
    //リストを削除する関数
    private func deleteRow(offsets: IndexSet){
        if let index: Int = offsets.first {
                let config = Realm.Configuration(schemaVersion :1)
                do{
                    let realm = try Realm(configuration: config)
                    let result = realm.objects(realm_data.self)
                    try! realm.write({
                        let de = getModel.dataEntities[index].id
                        for i in result{
                            if i.id == de{
                                realm.delete(i)
                                print(index)
                            }}})
                }
                catch{
                    print(error.localizedDescription)
                }
            }}
    
    var body: some View {
        List {
            ForEach(getModel.dataEntities.freeze(), id: \.id) { datas in
                //どちらかが一致していれば表示
                if s_name == datas.name || s_age == datas.age{
                NavigationLink(destination:
                        NavigationView{
                            VStack{
                                HStack{
                                    Text("品名：")
                                    TextField("登録済み：「"+"\(datas.name)" + "」", text: $name).textFieldStyle(RoundedBorderTextFieldStyle())}
                                HStack{
                                    Text("年齢：")
                                    TextField("登録済み：「"+"\(datas.age)" + "」", text: $age).textFieldStyle(RoundedBorderTextFieldStyle())}
                                HStack{
                                    Text("日付：")
                                    Text("\(datas.day,style: .date)")
                                    Spacer()
                                }
                                DatePicker("新しい日付を選択", selection: $day, displayedComponents: .date)
                                    //要素の変更編ボタン
                                    Button(action: {
                                        self.updateAlert = true
                                        }) {Text("更新")}
                                            .alert(isPresented: $updateAlert) {
                                                Alert(title: Text("更新"),
                                                      message: Text("データ更新完了"),
                                                      dismissButton: .default(Text("OK"),
                                                                    action: {
                                                                        let config = Realm.Configuration(schemaVersion :1)
                                                                        do{
                                                                            let realm = try Realm(configuration: config)
                                                                            let result = realm.objects(realm_data.self)
                                                                            try! realm.write({
                                                                                for i in result{
                                                                                    if i.id == datas.id{
                                                                                        i.name = self.name
                                                                                        i.age = self.age
                                                                                        i.day = self.day
                                                                                        realm.add(i)
                                                                                        self.name = ""
                                                                                        self.age = ""
                                                                                        self.day = Date()
                                                                                    }}
                                                                                })
                                                                        }
                                                                        catch{
                                                                            print(error.localizedDescription)
                                                                        }
                                                                    }))
                                                        }
                                        }.padding(30)
                        }.navigationBarTitle("Edit Menu", displayMode: .inline)
                        ){
                //リストの内容
                VStack{
                    Text("\(datas.name)" + "　" + "\(datas.age)")
                    Text("\(datas.day,style: .date)")
                }}}
            }.onDelete(perform: self.deleteRow)//スワイプで削除
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
