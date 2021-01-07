//
//  ContentView.swift
//  realm_app
//
//  Created by 中村幸太 on 2020/12/27.
//


import SwiftUI
import RealmSwift
import UserNotifications
//import UIKit


struct ContentView: View {
    @ObservedObject var setting = Setting()//UserDefaultsなので変更が保持される
    @State var showingAlert = false //通知の許可アラートのフラグ
    
    var body: some View {
        TabView{
                //ホームタブ
                NavigationView{
                    ListView()
                        .navigationBarTitle("Home", displayMode: .inline)
                        .navigationBarItems(leading: NavigationLink(destination:
                            AddView()
                            ){ Image(systemName: "plus")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                            }
                        ,trailing: MyEditButton())
                }.tabItem {
                        Image(systemName: "house")
                        Text("Home")}
                //ホームタブここまで
                //検索タブ
                NavigationView{
                    SearchView()
                        .navigationBarTitle("Search", displayMode: .inline)
                }.tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")}
                //検索タブここまで
                //設定タブ
                NavigationView{
                    VStack{
                        Text("通知設定")
                        //setting.Alert_Pushがtrueの場合通知を送るようにする
                        Toggle("ラベル", isOn : $setting.Alert_Push).labelsHidden()
                        }.navigationBarTitle("Setting", displayMode: .inline)
                }.tabItem {
                    Image(systemName: "gearshape")
                    Text("Setting")}
                //設定タブここまで

            //アプリ起動時にonApperでsetting.alertがfalseならshowingAlertをtrueにして.alertを表示
        }.onAppear(perform: {
            sleep(1)//ビューの表示を１秒遅らせることで一瞬で消えてしまうタイトル画面を１秒にする
            //プッシュ通知の機能
            //通知をカレンダーにした
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                if success {
                    print("All set!")
                    
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
            
                    )
          .accentColor(.orange) //オレンジ色にしてみた
    }
}




//エディットボタン、ホーム画面で削除するためのボタン。ゴミ箱ボタン
struct MyEditButton: View {
    @Environment(\.editMode) var editMode
    
    var body: some View {
        Button(action: {
            withAnimation() {
                if editMode?.wrappedValue.isEditing == true {
                    editMode?.wrappedValue = .inactive
                } else {
                    editMode?.wrappedValue = .active
                }
            }
        }) {
            if editMode?.wrappedValue.isEditing == true {
                Image(systemName:"trash.slash")
            } else {
                Image(systemName:"trash")
            }
        }
    }
}




//リスト表示とデータ変更のビュー
struct ListView: View {
    @State var genre = "食品"
    @State var name = ""
    @State var memo = ""
    @State var day =  Date()
    @State var i_d = Int()
    //画像の機能に必要な変数
    @State var image = Data()
    //画像の機能に必要な変数
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    
    @ObservedObject var getModel = get_data()
    @State private var updateAlert = false
    @State private var empty_alert = false
    @Environment(\.editMode) var envEditMode
    @State var link_appear = true
    let gen = ["食品", "日用雑貨" , "備品", "防災用品", "その他"]
    
    @State var day_change = "当日"
    let day_change_list = ["当日","一日前","二日前","三日前","一週間前","一ヶ月前"]
    let day_change_dict = [
        "当日": 0,
        "一日前": 1,
        "二日前": 2,
        "三日前": 3,
        "一週間前": 7,
        "一ヶ月前": 30
    ]

    @State var day_time = "7:00"
    let day_time_list = ["7:00","8:00","9:00","10:00","17:00","18:00"]
    let day_time_dict = [
        "7:00": 7,
        "8:00": 8,
        "9:00": 9,
        "10:00": 10,
        "17:00": 17,
        "18:00": 18
    ]
    
    //リストを削除する関数
    private func deleteRow(offsets: IndexSet) {
        let index: Int = offsets.first ?? -1
                let config = Realm.Configuration(schemaVersion : 1)
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
            }
    
    var body: some View {
        List {
            //freeze()を付けないと更新ができない。理由は知らない
            ForEach(getModel.dataEntities.freeze(), id: \.id) { datas in
                NavigationLink(destination:
                            VStack{
                                Spacer()
                                //写真を追加するボタン
                                if selectedImage != nil {
                                    Image(uiImage: selectedImage!)
                                         .resizable()
                                         .aspectRatio(contentMode: .fill)
                                         .clipShape(Circle())
                                        .frame(width: 100, height: 100)
                                }else if datas.image.count != 0 {
                                        Image(uiImage: UIImage(data: datas.image)!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .clipShape(Circle())
                                            .frame(width: 100, height:100)
                                }else{
                                    Image(systemName: "snow")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipShape(Circle())
                                        .frame(width: 100, height: 100)
                                }
                                HStack{
                                    Button(action: {
                                        self.sourceType = .camera
                                        self.isImagePickerDisplay.toggle()

                                    }){
                                        Text("カメラ")
                                    }.padding()
                                    
                                    Button(action: {
                                        self.sourceType = .photoLibrary
                                        self.isImagePickerDisplay.toggle()
                //                        image = (selectedImage?.jpegData(compressionQuality: 1))!
                                    }){
                                        Text("アルバム")
                                    }.padding()
                                    }.sheet(isPresented: self.$isImagePickerDisplay) {
                                        ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
                                    }
                                Form{
                                    Picker(selection: $genre, label: Text("ジャンル：")) {
                                                        ForEach(gen, id: \.self) { Gen in  // id指定の繰り返し
                                                            Text(Gen)
                                                        }}
                                    HStack{
                                    Text("品名：")
                                        TextField("登録済み：「"+"\(datas.name)"+" 」", text: $name).textFieldStyle(RoundedBorderTextFieldStyle())}
                                HStack{
                                    Text("メモ：")
                                    TextField("登録済み：「"+"\(datas.memo)"+" 」", text: $memo).textFieldStyle(RoundedBorderTextFieldStyle())}
                                DatePicker("期限：", selection: $day, displayedComponents: .date)
                                    Picker(selection: $day_change, label: Text("いつ通知しますか？：")) {
                                                ForEach(day_change_list, id: \.self) { Gen in  // id指定の繰り返し
                                                    Text(Gen)
                                                }}
                                    
                                    Picker(selection: $day_time, label: Text("何時に通知しますか？：")) {
                                                ForEach(day_time_list, id: \.self) { Gen in  // id指定の繰り返し
                                                    Text(Gen)
                                                }}
                                }
                                    //要素の変更編ボタン
                                BackView(name: $name, memo: $memo, genre: $genre, day: $day, image: $image, i_d: $i_d, empty_alert: $empty_alert, day_change: $day_change, day_time: $day_time, selectedImage: $selectedImage)
                                    .padding(10)
                            }
                                .onAppear(perform: {
                                if self.link_appear{
                                    self.genre = datas.genre
                                    self.name = datas.name
                                    self.memo = datas.memo
                                    self.day = datas.day
                                    self.day_change = datas.day_change
                                    self.day_time = datas.day_time
                                    self.i_d = datas.id
                                    self.link_appear = false
                                }
                                if self.selectedImage != nil {
                                    datas.image = (self.selectedImage?.jpegData(compressionQuality: 1))!
                                }
                                }) //リストをタップして編集画面を表示すると行う処理、これで編集画面に保存したデータが表示される
                             .navigationBarTitle("Edit Menu", displayMode: .inline)
                        ){
                //リストの内容
                    HStack{
                        if datas.image.count != 0 {
                            Image(uiImage: UIImage(data: datas.image)!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .frame(width: 50, height:50)
                    }else{
                        Image(systemName: "snow")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 50, height: 50)
                    }
                    VStack{
                    Text("\(datas.name)")
                    Text("\(datas.day,style: .date)")
                    }}.onAppear(perform: {self.link_appear = true})}}.onDelete(perform: envEditMode?.wrappedValue.isEditing ?? false ? self.deleteRow : nil)
        }
    }
}








//データ追加のビュー
struct AddView: View {
    @State var name = ""
    @State var memo = ""
    @State var day =  Date()
    //画像の機能に必要な変数
    @State var image = Data()
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    
    @State private var showingAlert = false
    @State private var empty_alert = false
    @State var genre = "食品"
    let gen = ["食品", "日用雑貨" , "備品", "防災用品", "その他"]
    @State var day_change = "当日"
    let day_change_list = ["当日","一日前","二日前","三日前","一週間前","一ヶ月前"]
    let day_change_dict = [
        "当日": 0,
        "一日前": 1,
        "二日前": 2,
        "三日前": 3,
        "一週間前": 7,
        "一ヶ月前": 30
    ]

    @State var day_time = "7:00"
    let day_time_list = ["7:00","8:00","9:00","10:00","17:00","18:00"]
    let day_time_dict = [
        "7:00": 7,
        "8:00": 8,
        "9:00": 9,
        "10:00": 10,
        "17:00": 17,
        "18:00": 18
    ]
    
    var body: some View {
            VStack{
            //入力するところ
                Spacer()
                //写真を追加するボタン
                if selectedImage != nil {
                    Image(uiImage: selectedImage!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 100, height:100)
                }else{
                    Image(systemName: "snow")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 100, height: 100)
                }
                HStack{
                    Button(action: {
                        self.sourceType = .camera
                        self.isImagePickerDisplay.toggle()
                    }){
                        Text("カメラ")
                    }.padding()
                    
                    Button(action: {
                        self.sourceType = .photoLibrary
                        self.isImagePickerDisplay.toggle()
                    }){
                        Text("アルバム")
                    }.padding()
                    }.sheet(isPresented: self.$isImagePickerDisplay) {
                        ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
                    }
                
                Form{
                    
                //ジャンルや品名、メモの入力
                    Picker(selection: $genre, label: Text("ジャンルを選択：")) {
                                ForEach(gen, id: \.self) { Gen in  // id指定の繰り返し
                                    Text(Gen)
                                }}
                    HStack{
                        Text("品名：")
                        TextField("(例：電池)", text: $name).textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    HStack{
                        Text("メモ：")
                        TextField ("(例：2個買った)", text: $memo).textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        }
                    DatePicker("期限を選択", selection: $day, displayedComponents: .date)
                Picker(selection: $day_change, label: Text("いつ通知しますか？：")) {
                            ForEach(day_change_list, id: \.self) { Gen in  // id指定の繰り返し
                                Text(Gen)
                            }}
                
                Picker(selection: $day_time, label: Text("何時に通知しますか？：")) {
                            ForEach(day_time_list, id: \.self) { Gen in  // id指定の繰り返し
                                Text(Gen)
                            }}
                }

                //入力したのを保存するボタン
                Button(action: {
                    if self.name.isEmpty{ //品名が空だと追加しない
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
                            newdata.memo = self.memo
                            newdata.genre = self.genre
                            newdata.day = self.day
                            newdata.day_change = self.day_change
                            newdata.day_time = self.day_time
                            if self.selectedImage != nil {
                                newdata.image = (self.selectedImage?.jpegData(compressionQuality: 1))!
                            }

                            try realm.write({
                                realm.add(newdata)
                                print("success")
                                self.name = ""
                                self.memo = ""
                                self.genre = "食品"
                                self.day = Date()
                                self.image = Data()
//                                self.day_change = "当日"
//                                self.day_time = "7:00"
                                self.showingAlert = true
                            })
                            //プッシュ通知の機能
                            //通知をカレンダーにした
                            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                if success {
                                    print("All set!")
                                    
                                } else if let error = error {
                                    print(error.localizedDescription)
                                }
                                
                                // second
                                let content = UNMutableNotificationContent()
                                content.title = "今日までのものがあるみたいよ"
                                content.subtitle = "アプリで確認してみよう"
                                content.sound = UNNotificationSound.default

                                // show this notification five seconds from now
                                var targetDate = Calendar.current.dateComponents([.year,.month,.day], from: self.day)
                                targetDate.day! -= day_change_dict[String(self.day_change)]!
                                targetDate.hour = day_time_dict[String(self.day_time)]!
                                
                                
                                let trigger = UNCalendarNotificationTrigger(dateMatching: targetDate, repeats: false)

                                // choose a random identifier
                                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                                // add our notification request
                                UNUserNotificationCenter.current().add(request)
                                self.day_change = "当日"
                                self.day_time = "7:00"
                            }
                        }
                        catch{
                            print(error.localizedDescription)
                            }
                        }
                    
                    }) {Text("データ追加")}
                        .alert(isPresented: $showingAlert) {
                            if self.empty_alert {
                                return Alert(title: Text("品名を入力してね"))
                            }else{
                                return Alert(title: Text("データ追加完了"))
                            }
                    }
                    .padding(10)
                Spacer()
            }.navigationBarTitle("New Data", displayMode: .inline)
    }
}








//検索のビュー
struct SearchView: View {
    @State var s_name = ""
//    @State var s_memo = ""
    @State var s_pday =  Date()
    @State var s_fday =  Date()
    @State var flag = false
    @State var s_genre = "選択しない"
    let gen = ["選択しない","食品", "日用雑貨" , "備品", "防災用品", "その他"]
    
    var body: some View {
        VStack{
            Form{
            Picker(selection: $s_genre, label: Text("ジャンル：")) {
                        ForEach(gen, id: \.self) { Gen in  // id指定の繰り返し
                            Text(Gen)
                        }}
            TextField("品名", text: $s_name).textFieldStyle(RoundedBorderTextFieldStyle())
            VStack{
                HStack{
                    Text("期限を有効にする")
                    Toggle("ラベル", isOn : $flag).labelsHidden()
                }
                HStack{
                    DatePicker("", selection: $s_pday, displayedComponents: .date)
                    DatePicker("〜", selection: $s_fday, displayedComponents: .date)
                    Spacer()
                    }
                }}
            NavigationLink(destination:
                            //検索ボタンを押したら表示されるビュー
                            S_ListView(s_name: $s_name, s_pday: $s_pday, s_fday: $s_fday, s_genre: $s_genre, flag: $flag)
                            .navigationBarTitle("Search result", displayMode: .inline)
                ){
                Text("検索").padding(15)
            }
        }
    }
}





//検索後のビュー
struct S_ListView: View {
    
    @Binding var s_name: String
    //@Binding var s_memo: String
    @Binding var s_pday: Date
    @Binding var s_fday: Date
    @Binding var s_genre: String
    @Binding var flag: Bool
    let gen = ["食品", "日用雑貨" , "備品", "防災用品", "その他"]
    @State var name = ""
    @State var memo = ""
    @State var genre = "食品"
    @State var day =  Date()
    //画像の機能に必要な変数
    @State var image = Data()
    //画像の機能に必要な変数
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    
    @ObservedObject var getModel = get_data()
    @State private var updateAlert = false
    @State var empty_alert = false
    @State var i_d = Int()
    @State var link_appear = true
    
    @State var day_change = "当日"
    let day_change_list = ["当日","一日前","二日前","三日前","一週間前","一ヶ月前"]
    let day_change_dict = [
        "当日": 0,
        "一日前": 1,
        "二日前": 2,
        "三日前": 3,
        "一週間前": 7,
        "一ヶ月前": 30
    ]

    @State var day_time = "7:00"
    let day_time_list = ["7:00","8:00","9:00","10:00","17:00","18:00"]
    let day_time_dict = [
        "7:00": 7,
        "8:00": 8,
        "9:00": 9,
        "10:00": 10,
        "17:00": 17,
        "18:00": 18
    ]
    
    //リストを削除する関数
    private func deleteRow(offsets: IndexSet){
        let index: Int = offsets.first ?? -1
                let config = Realm.Configuration(schemaVersion :1)
                do{
                    let realm = try Realm(configuration: config)
                    let result = realm.objects(realm_data.self)
                    let de = getModel.dataEntities[index].id
                    try! realm.write({
                        for i in result{
                            if i.id == de{
                                realm.delete(i)
                            }}})
                }
                catch{
                    print(error.localizedDescription)
                }
            }
    
    //検索条件の関数
    private func s_check(s_genre: String, s_name: String, s_pday: Date, s_fday: Date, d_genre: String, d_name: String, d_day: Date, flag: Bool) -> Bool {
        var TF = false
        let cal = Calendar(identifier: .gregorian)
        if !flag {
            if s_name.isEmpty{
                if s_genre == d_genre{
                        TF = true
                    }
            }else{
                if s_genre == "選択しない"{
                    if s_name == d_name{
                        TF = true
                    }
                }else{
                    if s_genre == d_genre && s_name == d_name{
                        TF = true
                    }}
            }
        }else{
            //日付の差とか計算
            let deff = cal.dateComponents([.day], from: s_pday, to: s_fday).day!
            //左側で選択した期限の方が過去の場合
            if deff >= 0 {
                for i in 0...deff {
                    if cal.dateComponents([.day], from: s_pday.addingTimeInterval(TimeInterval(60 * 60 * 24 * i)), to: d_day).day! == 0{
                        if s_name.isEmpty{
                            if s_genre == d_genre{
                                    TF = true
                                }
                        }else{
                            if s_genre == "選択しない"{
                                if s_name == d_name{
                                    TF = true
                                }
                            }else{
                                if s_genre == d_genre && s_name == d_name{
                                    TF = true
                                }}}
                    }
                }
            //右側で選択した期限の方が過去の場合
            }else{
                for i in 0...abs(deff) {
                    if cal.dateComponents([.day], from: s_fday.addingTimeInterval(TimeInterval(60 * 60 * 24 * i)), to: d_day).day! == 0{
                        if s_name.isEmpty{
                            if s_genre == d_genre{
                                    TF = true
                                }
                        }else{
                            if s_genre == "選択しない"{
                                if s_name == d_name{
                                    TF = true
                                }
                            }else{
                                if s_genre == d_genre && s_name == d_name{
                                    TF = true
                                }}
                        }}
                }
                
            }

        }
        return TF
        }
    
    
    var body: some View {
        List {
            ForEach(getModel.dataEntities.freeze(), id: \.id) { datas in
                //検索条件に引っ掛かれば表示
                if s_check(s_genre: self.s_genre, s_name: self.s_name, s_pday: self.s_pday, s_fday: self.s_fday, d_genre: datas.genre, d_name: datas.name, d_day: datas.day, flag: self.flag) {
                NavigationLink(destination:
                            VStack{
                                Spacer()
                                if selectedImage != nil {
                                    Image(uiImage: selectedImage!)
                                         .resizable()
                                         .aspectRatio(contentMode: .fill)
                                         .clipShape(Circle())
                                        .frame(width: 80, height:80)
                                }else if datas.image.count != 0 {
                                        Image(uiImage: UIImage(data: datas.image)!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .clipShape(Circle())
                                            .frame(width: 80, height:80)
                                }else{
                                    Image(systemName: "snow")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipShape(Circle())
                                        .frame(width: 80, height: 80)
                                }
                                HStack{
                                    Button(action: {
                                        self.sourceType = .camera
                                        self.isImagePickerDisplay.toggle()

                                    }){
                                        Text("カメラ")
                                    }.padding()

                                    Button(action: {
                                        self.sourceType = .photoLibrary
                                        self.isImagePickerDisplay.toggle()
                                    }){
                                        Text("アルバム")
                                    }.padding()
                                    }.sheet(isPresented: self.$isImagePickerDisplay) {
                                        ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
                                    }
                                Form{
                                    Picker(selection: $genre, label: Text("ジャンル：")) {
                                                        ForEach(gen, id: \.self) { Gen in  // id指定の繰り返し
                                                            Text(Gen)
                                                        }}
                                    HStack{
                                    Text("品名：")
                                        TextField("登録済み：「"+"\(datas.name)" + " 」", text: $name).textFieldStyle(RoundedBorderTextFieldStyle())}
                                HStack{
                                    Text("メモ：")
                                    TextField("登録済み：「"+"\(datas.memo)" + " 」", text: $memo).textFieldStyle(RoundedBorderTextFieldStyle())}
                                DatePicker("期限:", selection: $day, displayedComponents: .date)
                                    
                                Picker(selection: $day_change, label: Text("いつ通知しますか？：")) {
                                            ForEach(day_change_list, id: \.self) { Gen in  // id指定の繰り返し
                                                    Text(Gen)
                                                }}
                                    
                                Picker(selection: $day_time, label: Text("何時に通知しますか？：")) {
                                            ForEach(day_time_list, id: \.self) { Gen in  // id指定の繰り返し
                                                Text(Gen)
                                            }}
                                }
                                BackView(name: $name, memo: $memo, genre: $genre, day: $day, image: $image, i_d: $i_d, empty_alert: $empty_alert, day_change: $day_change, day_time: $day_time, selectedImage: $selectedImage)
                                    .padding(15)
                                
                                        }.onAppear(perform: {
                                        if self.link_appear{
                                            self.genre = datas.genre
                                            self.name = datas.name
                                            self.memo = datas.memo
                                            self.day = datas.day
                                            self.day_change = datas.day_change
                                            self.day_time = datas.day_time
//                                            if self.selectedImage != nil {
//                                                datas.image = (self.selectedImage?.jpegData(compressionQuality: 1))!
//                                            }
//                                            self.selectedImage = nil
                                            self.i_d = datas.id
                                            self.link_appear = false
                                            
                                                    }}
                                        ) //リストをタップして編集画面を表示すると行う処理、これで編集画面に保存したデータが表示される
                        ){
                //リストの内容
                HStack{
                    if datas.image.count != 0 {
                        Image(uiImage: UIImage(data: datas.image)!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 50, height:50)
                    }else{
                        Image(systemName: "snow")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 50, height: 50)
                    }
                VStack{
                    Text("\(datas.name)")
                    Text("\(datas.day,style: .date)")
                }
                }.onAppear(perform: {self.link_appear = true})}}
            }.onDelete(perform: self.deleteRow)//スワイプで削除
        }
    }
}

//検索後の更新で戻るための更新ボタン
struct BackView: View {
    @Binding var name: String
    @Binding var memo: String
    @Binding var genre: String
    @Binding var day: Date
    @Binding var image:Data
    @Binding var i_d: Int
    @Binding var empty_alert: Bool
    @Binding var day_change: String
    @Binding var day_time: String

    //画像の機能に必要な変数
    @Binding var selectedImage: UIImage?
    //これで前のビューに戻る
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var updateAlert = false
    
    let day_change_dict = [
        "当日": 0,
        "一日前": 1,
        "二日前": 2,
        "三日前": 3,
        "一週間前": 7,
        "一ヶ月前": 30
    ]
    
    let day_time_dict = [
        "7:00": 7,
        "8:00": 8,
        "9:00": 9,
        "10:00": 10,
        "17:00": 17,
        "18:00": 18
    ]
    
    var body: some View {
        Button(action: {
            if self.name.isEmpty{
                self.empty_alert = true
                self.updateAlert = true
            }else{
                self.empty_alert = false
                self.updateAlert = true
                }
            }) {
            Text("更新")
            }
            .alert(isPresented: $updateAlert) {
                if self.empty_alert {
                    return Alert(title: Text("品名を入力してね"))
                }else{
                    return Alert(title: Text("データ更新完了"), dismissButton: .default(Text("OK"),
                        action: {
                            let config = Realm.Configuration(schemaVersion :1)
                            do{
                                let realm = try Realm(configuration: config)
                                let result = realm.objects(realm_data.self)
                                try realm.write({
                                    for i in result{
                                        if i.id == i_d{
                                            i.name = self.name
                                            i.memo = self.memo
                                            i.day = self.day
                                            i.genre = self.genre
                                            i.day_change = self.day_change
                                            i.day_time = self.day_time
                                            if self.selectedImage != nil {
                                                i.image = (self.selectedImage?.jpegData(compressionQuality: 1))!
                                            }
                                            realm.add(i)
                                        }
//                                        self.selectedImage = nil
                                    }
                                    self.name = ""
                                    self.memo = ""
                                    self.genre = "食品"
                                    self.day = Date()
                                    self.image = Data()
//                                    self.day_change = ""
//                                    self.day_change = ""
                                    self.presentationMode.wrappedValue.dismiss()
                                })
                                //プッシュ通知の機能
                                //通知をカレンダーにした
                                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                                    if success {
                                        print("All set!")
                                        
                                    } else if let error = error {
                                        print(error.localizedDescription)
                                    }
                                    
                                    // second
                                    let content = UNMutableNotificationContent()
                                    content.title = "今日までのものがあるみたいよ"
                                    content.subtitle = "アプリで確認してみよう"
                                    content.sound = UNNotificationSound.default

                                    // show this notification five seconds from now
                                    var targetDate = Calendar.current.dateComponents([.year,.month,.day], from: self.day)
                                    targetDate.day! -= day_change_dict[String(self.day_change)]!
                                    targetDate.hour = day_time_dict[String(self.day_time)]!
                                    
//                                    print(targetDate)
                                    
                                    let trigger = UNCalendarNotificationTrigger(dateMatching: targetDate, repeats: false)

                                    // choose a random identifier
                                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

                                    // add our notification request
                                    UNUserNotificationCenter.current().add(request)
                                    self.day_change = "当日"
                                    self.day_time = "7:00"
                                }
//                                self.day_change = ""
//                                self.day_change = ""
                            }
                            catch{
                                print(error.localizedDescription)
                            }}))}}
        }
    }
      
                    

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
