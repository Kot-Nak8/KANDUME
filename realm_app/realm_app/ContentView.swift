//
//  ContentView.swift
//  realm_app
//
//  Created by 中村幸太 on 2020/12/27.
//
//取り組む問題：空のデータは入れないようにする、検索した時に更新したらちゃんと戻らないで再度更新をしようとすると反映されずバグる(更新した時に検索条件から外れるから)どうにかせんとあかん。


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
    @State var genre = "食品"
    @State var name = ""
    @State var quan = ""
    @State var day =  Date()
    @ObservedObject var getModel = get_data()
    @State private var deleteAlert = false
    @State private var updateAlert = false
    let gen = ["食品", "日用雑貨" , "備品", "防災用品", "その他"]
    
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
                            //OnotherView(datas: datas)
                            VStack{
                                //Spacer()
                                Form{
                                    HStack{
                                        Spacer()
                                        Button(action: {
                                            print("写真追加")
                                        }){
                                            Text("写真を選択")
                                        }
                                        Spacer()
                                        }
                                    VStack{
                                        Text("登録済み："+"\(datas.genre)")
                                        Picker(selection: $genre, label: Text("ジャンルを選択：")) {
                                                        ForEach(gen, id: \.self) { Gen in  // id指定の繰り返し
                                                            Text(Gen)
                                                        }}}
                                    HStack{
                                    Text("品名：")
                                        TextField("登録済み：「"+"\(datas.name)" + " 」", text: $name).textFieldStyle(RoundedBorderTextFieldStyle())}
                                HStack{
                                    Text("個数：")
                                    TextField("登録済み：「"+"\(datas.quan)" + " 」", text: $quan).textFieldStyle(RoundedBorderTextFieldStyle())}
                                HStack{
                                    Text("登録済み期限：")
                                    Text("\(datas.day,style: .date)")
                                    Spacer()
                                }
                                DatePicker("新しい期限を選択", selection: $day, displayedComponents: .date)
                                }
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
                                                    i.quan = self.quan
                                                    i.day = self.day
                                                    i.genre = self.genre
                                                    realm.add(i)
                                                }
                                            }
                                            print("success")
                                            print(type(of: datas))
                                            self.name = ""
                                            self.quan = ""
                                            self.genre = "食品"
                                            self.day = Date()
                                        })
                                    }
                                    catch{
                                        print(error.localizedDescription)
                                    }
                                    
                                    }) {
                                    Text("更新")
                                    }
                                    .alert(isPresented: $updateAlert) {
                                            Alert(title: Text("更新"),
                                            message: Text("データの更新完了"))   // 詳細メッセージの追加
                                    }
                                    .padding(10)
                                    Spacer()
                                    }
                        }.navigationBarTitle("Edit Menu", displayMode: .inline)
                        ){
                //リストの内容
                VStack{
                Text("\(datas.name)" + "　" + "\(datas.quan)")
                Text("\(datas.day,style: .date)")
                }}}.onDelete(perform: self.deleteRow)
        }
    }
}

struct OnotherView: View {
    @Binding var datas: realm_data
    var body: some View {
        Text("\(datas.name)")
    }
}



//データ追加のビュー
struct AddView: View {
    @State var name = ""
    @State var quan = ""
    @State var day =  Date()
    @State private var showingAlert = false
    @State private var empty_alert = false
    @State var genre = "食品"
    let gen = ["食品", "日用雑貨" , "備品", "防災用品", "その他"]
    
    var body: some View {
        NavigationView{
            VStack{
            //入力するところ
                //写真を追加するボタン
                Spacer()
                Form{
                    HStack{
                        Spacer()
                        Button(action: {
                            print("写真追加")
                        }){
                            Text("写真を選択")
                        }
                        Spacer()
                        }
                    
                //ジャンルや品名、個数の入力
                    Picker(selection: $genre, label: Text("ジャンルを選択：")) {
                                ForEach(gen, id: \.self) { Gen in  // id指定の繰り返し
                                    Text(Gen)
                                }}
                    HStack{
                        Text("品名：")
                        TextField("(例：電池)", text: $name).textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    HStack{
                        Text("個数：")
                        TextField ("(例：2)", text: $quan).textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        }
                    DatePicker("期限を選択", selection: $day, displayedComponents: .date)}

                //入力したのを保存するボタン
                Button(action: {
                    if self.name.isEmpty || self.quan.isEmpty{ //どっちかが空だと追加しない
                        self.empty_alert = true
                        self.showingAlert = true
                    }else{
                        self.empty_alert = false
                        let config = Realm.Configuration(schemaVersion :1)
                        do{
                            let realm = try Realm(configuration: config)
                            let newdata = realm_data()
                            //主キーを決定するやつ
                            //保存されてるデータの最大のidを取得
                            var maxId: Int { return try! Realm().objects(realm_data.self).sorted(byKeyPath: "id").last?.id ?? 0 }
                            newdata.id = maxId + 1
                            newdata.name = self.name
                            newdata.quan = self.quan
                            newdata.genre = self.genre
                            newdata.day = self.day
                            try realm.write({
                                realm.add(newdata)
                                print("success")
                                self.name = ""
                                self.quan = ""
                                self.genre = "食品"
                                self.day = Date()
                                self.showingAlert = true
                            })
                        }
                        catch{
                            print(error.localizedDescription)
                            }
                        }
                    
                    }) {Text("データ追加")}
                        .alert(isPresented: $showingAlert) {
                            if self.empty_alert {
                                return Alert(title: Text("全部入力してね"))
                            }else{
                                return Alert(title: Text("データ追加完了"))
                            }
                    }
                    .padding(10)
                Spacer()
            }
        }.navigationBarTitle("New Data", displayMode: .inline)
    }
}





//検索のビュー
struct SearchView: View {
    @State var s_name = ""
    @State var s_quan = ""
    @State var s_pday =  Date()
    @State var s_fday =  Date()
    @State var s_genre = "選択しない"
    let gen = ["選択しない","食品", "日用雑貨" , "備品", "防災用品", "その他"]
    @ObservedObject var getModel = get_data()
    
    var body: some View {
        VStack{
            Picker(selection: $s_genre, label: Text("ジャンルを選択：")) {
                        ForEach(gen, id: \.self) { Gen in  // id指定の繰り返し
                            Text(Gen)
                        }}
            TextField("品名", text: $s_name).textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("個数", text: $s_quan).textFieldStyle(RoundedBorderTextFieldStyle())
            NavigationLink(destination:
                            //検索ボタンを押したら表示されるビュー
                            S_ListView(s_name: $s_name, s_quan: $s_quan, s_pday: $s_pday, s_fday: $s_fday, s_genre: $s_genre)
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
    @Binding var s_quan: String
    @Binding var s_pday: Date
    @Binding var s_fday: Date
    @Binding var s_genre: String
    let gen = ["食品", "日用雑貨" , "備品", "防災用品", "その他"]
    @State var name = ""
    @State var quan = ""
    @State var genre = "食品"
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
    
    //検索条件の関数
    private func s_check(s_genre: String, s_name: String, s_quan: String, d_genre: String, d_name: String, d_quan: String) -> Bool {
        var TF = false
        if s_genre == "選択しない"{
            if s_name == d_name || s_quan == d_quan{
                TF = true
            }
        }else{
            if s_genre == d_genre && s_name == d_name || s_quan == d_quan{
                TF = true
        }}
        return TF
        }
    
    
    var body: some View {
        List {
            ForEach(getModel.dataEntities.freeze(), id: \.id) { datas in
                //検索条件に引っ掛かれば表示
                if s_check(s_genre: self.s_genre, s_name: self.s_name, s_quan: self.s_quan, d_genre: datas.genre, d_name: datas.name, d_quan: datas.quan) {
                NavigationLink(destination:
                        NavigationView{
                            VStack{
                                Spacer()
                                Form{
                                    HStack{
                                        Spacer()
                                        Button(action: {
                                            print("写真追加")
                                        }){
                                            Text("写真を選択")
                                        }
                                        Spacer()
                                        }
                                    VStack{
                                        Text("登録済み："+"\(datas.genre)")
                                        Picker(selection: $genre, label: Text("ジャンルを選択：")) {
                                                        ForEach(gen, id: \.self) { Gen in  // id指定の繰り返し
                                                            Text(Gen)
                                                        }}}
                                    HStack{
                                    Text("品名：")
                                        TextField("登録済み：「"+"\(datas.name)" + " 」", text: $name).textFieldStyle(RoundedBorderTextFieldStyle())}
                                HStack{
                                    Text("個数：")
                                    TextField("登録済み：「"+"\(datas.quan)" + " 」", text: $quan).textFieldStyle(RoundedBorderTextFieldStyle())}
                                HStack{
                                    Text("登録済み期限：")
                                    Text("\(datas.day,style: .date)")
                                    Spacer()
                                }
                                DatePicker("新しい期限を選択", selection: $day, displayedComponents: .date)
                                }
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
                                                    i.quan = self.quan
                                                    i.day = self.day
                                                    i.genre = self.genre
                                                    realm.add(i)
                                                }
                                            }
                                            print("success")
                                            self.name = ""
                                            self.quan = ""
                                            self.genre = "食品"
                                            self.day = Date()
                                        })
                                    }
                                    catch{
                                        print(error.localizedDescription)
                                    }
                                    
                                    }) {
                                    Text("更新")
                                    }
                                    .alert(isPresented: $updateAlert) {
                                            Alert(title: Text("更新"),
                                            message: Text("データの更新完了"))
                                    }
                                    .padding(10)
                                    Spacer()
                                        }
                        }.navigationBarTitle("Edit Menu", displayMode: .inline)
                        ){
                //リストの内容
                VStack{
                    Text("\(datas.name)" + "　" + "\(datas.quan)")
                    Text("\(datas.day,style: .date)")
                }}}
            }.onDelete(perform: self.deleteRow)//スワイプで削除
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()//.environmentObject(get_data())
    }
}
