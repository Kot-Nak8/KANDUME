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
    //説明
    private let Description = """
    本アプリをダウンロードしていただきありがとうございます。
    気が付いたら缶詰の期限がいつの間にか過ぎていたことってありませんか？
    「モノの管理」って大変です・・・できれば簡潔に、シンプルな操作で「モノの管理」をしたい・・・
    そんな悩みを解決しようと生まれたのがこのアプリ「KANDUME」です。
    「KANDUME」は缶詰や保存食など、ついつい消費期限を忘れてしまいがちな食品、モノを管理します。
    「モノの管理」というめんどくさいことは「KANDUME」を使ってあなたのケータイの奥底にしまっておきましょう。
    ＜主な機能＞
    ・缶詰、保存食などの登録（名前、カテゴリ、メモ、期限日にち設定、いつ通知するかなど）
    ・一覧表示（名前、カテゴリ、期限日にち、画面表示の切り替え）
    ・検索機能（名前、カテゴリ、期限の期間などにより検索ができる）
    ・アラーム機能（選んだ日時日時にローカルプッシュ通知が送られます）
    """
    
    private let Description_app = """
    ホーム画面について
    「ゴミ箱のマーク」でホーム画面の追加されたモノの削除ができます。
    「➕」ボタンでモノを追加してください。
    「Edit Menu」で管理するモノの編集ができます。
    期限の一週間前になりますと、日付がオレンジ色になります。
    
    画像の変更について
    「カメラ」を押すと、カメラが起動しアイコン写真を撮影できます。
    「アルバム」を押すと、アルバムが起動しアイコン写真にする画像を選択できます。
    
    ジャンルについて
    「ジャンルを選択」を押すと、モノのジャンルが選べます。検索をするときに役に立ちます。
    品名について
    「品名」にモノの品名を入力してください。品名が入力されていないと追加、更新の時にエラーが出てしまいます
    
    メモについて
    「メモ」に何かしら入力してください、のちに参照することができます。入力しなくても問題はございません。
    
    期限の変更について
    「期限を選択」で賞味期限の設定を行ってください。
    「いつ通知しますか」に選択がない場合は「期限を選択」で設定された日に通知が飛びます。
    「何時に通知しますか」に選択がない場合は「期限を選択」と「いつ通知しますか」で選択された日の7:00に通知が行きます。
    
    
    """
    
    private let TermsOfUse = """
    利用規約
        この利用規約（以下，「本規約」といいます。）は，KANDUME（以下，「本アプリ」といいます。）がこのウェブサイト上で提供するサービス（以下，「本サービス」といいます。）の利用条件を定めるものです。登録ユーザーの皆さま（以下，「ユーザー」といいます。）には，本規約に従って，本サービスをご利用いただきます。
     
    第1条（適用）
    本規約は，ユーザーと本アプリとの間の本サービスの利用に関わる一切の関係に適用されるものとします。
    本アプリは本サービスに関し，本規約のほか，ご利用にあたってのルール等，各種の定め（以下，「個別規定」といいます。）をすることがあります。これら個別規定はその名称のいかんに関わらず，本規約の一部を構成するものとします。
    本規約の規定が前条の個別規定の規定と矛盾する場合には，個別規定において特段の定めなき限り，個別規定の規定が優先されるものとします。
    第2条（利用登録)
    本アプリが第三者によって使用されたことによって生じた損害は，本アプリに故意又は重大な過失がある場合を除き，本アプリは一切の責任を負わないものとします。
    第3条（利用料金および支払方法）
    ユーザーは，本サービスの有料部分の対価として，本アプリが別途定め，本ウェブサイトに表示する利用料金を，本アプリが指定する方法により支払うものとします。
    ユーザーが利用料金の支払を遅滞した場合には，ユーザーは年14．6％の割合による遅延損害金を支払うものとします。
    第4条（禁止事項）
    ユーザーは，本サービスの利用にあたり，以下の行為をしてはなりません。
    
    法令または公序良俗に違反する行為
    犯罪行為に関連する行為
    本サービスの内容等，本サービスに含まれる著作権，商標権ほか知的財産権を侵害する行為
    本アプリ，ほかのユーザー，またはその他第三者のサーバーまたはネットワークの機能を破壊したり，妨害したりする行為
    本サービスによって得られた情報を商業的に利用する行為
    本アプリのサービスの運営を妨害するおそれのある行為
    不正アクセスをし，またはこれを試みる行為
    他のユーザーに関する個人情報等を収集または蓄積する行為
    不正な目的を持って本サービスを利用する行為
    本サービスの他のユーザーまたはその他の第三者に不利益，損害，不快感を与える行為
    他のユーザーに成りすます行為
    本アプリが許諾しない本サービス上での宣伝，広告，勧誘，または営業行為
    面識のない異性との出会いを目的とした行為
    本アプリのサービスに関連して，反社会的勢力に対して直接または間接に利益を供与する行為
    その他，本アプリが不適切と判断する行為
    第5条（本サービスの提供の停止等）
    本アプリは，以下のいずれかの事由があると判断した場合，ユーザーに事前に通知することなく本サービスの全部または一部の提供を停止または中断することができるものとします。
    本サービスにかかるコンピュータシステムの保守点検または更新を行う場合
    地震，落雷，火災，停電または天災などの不可抗力により，本サービスの提供が困難となった場合
    コンピュータまたは通信回線等が事故により停止した場合
    その他，本アプリが本サービスの提供が困難と判断した場合
    本アプリは，本サービスの提供の停止または中断により，ユーザーまたは第三者が被ったいかなる不利益または損害についても，一切の責任を負わないものとします。
    第6条（利用制限および登録抹消）
    本アプリは，ユーザーが以下のいずれかに該当する場合には，事前の通知なく，ユーザーに対して，本サービスの全部もしくは一部の利用を制限し，またはユーザーとしての登録を抹消することができるものとします。
    本規約のいずれかの条項に違反した場合
    登録事項に虚偽の事実があることが判明した場合
    料金等の支払債務の不履行があった場合
    本アプリからの連絡に対し，一定期間返答がない場合
    本サービスについて，最終の利用から一定期間利用がない場合
    その他，本アプリが本サービスの利用を適当でないと判断した場合
    本アプリは，本条に基づき本アプリが行った行為によりユーザーに生じた損害について，一切の責任を負いません。
    
    第7条（保証の否認および免責事項）
    本アプリは，本サービスに事実上または法律上の瑕疵（安全性，信頼性，正確性，完全性，有効性，特定の目的への適合性，セキュリティなどに関する欠陥，エラーやバグ，権利侵害などを含みます。）がないことを明示的にも黙示的にも保証しておりません。
    本アプリは，本サービスに起因してユーザーに生じたあらゆる損害について一切の責任を負いません。ただし，本サービスに関する本アプリとユーザーとの間の契約（本規約を含みます。）が消費者契約法に定める消費者契約となる場合，この免責規定は適用されません。
    前項ただし書に定める場合であっても，本アプリは，本アプリの過失（重過失を除きます。）による債務不履行または不法行為によりユーザーに生じた損害のうち特別な事情から生じた損害（本アプリまたはユーザーが損害発生につき予見し，または予見し得た場合を含みます。）について一切の責任を負いません。また，本アプリの過失（重過失を除きます。）による債務不履行または不法行為によりユーザーに生じた損害の賠償は，ユーザーから当該損害が発生した月に受領した利用料の額を上限とします。
    本アプリは，本サービスに関して，ユーザーと他のユーザーまたは第三者との間において生じた取引，連絡または紛争等について一切責任を負いません。
    第8条（サービス内容の変更等）
    本アプリは，ユーザーに通知することなく，本サービスの内容を変更しまたは本サービスの提供を中止することができるものとし，これによってユーザーに生じた損害について一切の責任を負いません。
    
    第9条（利用規約の変更）
    本アプリは，必要と判断した場合には，ユーザーに通知することなくいつでも本規約を変更することができるものとします。なお，本規約の変更後，本サービスの利用を開始した場合には，当該ユーザーは変更後の規約に同意したものとみなします。
    
    第10条（通知または連絡）
    ユーザーと本アプリとの間の通知または連絡は，本アプリの定める方法によって行うものとします。本アプリは,ユーザーから,本アプリが別途定める方式に従った変更届け出がない限り,現在登録されている連絡先が有効なものとみなして当該連絡先へ通知または連絡を行い,これらは,発信時にユーザーへ到達したものとみなします。
    
    第11条（権利義務の譲渡の禁止）
    ユーザーは，本アプリの書面による事前の承諾なく，利用契約上の地位または本規約に基づく権利もしくは義務を第三者に譲渡し，または担保に供することはできません。
    
    第12条（準拠法・裁判管轄）
    本規約の解釈にあたっては，日本法を準拠法とします。
    本サービスに関して紛争が生じた場合には，本アプリの本店所在地を管轄する裁判所を専属的合意管轄とします。
    本アプリでの損失は一切の責任を持ちません。
    以上
    """
    
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
                        )
                        .toolbar { MyEditButton() } //.navigationBarItemsじゃなくて.toolbarにしたらバグが治った
                }
                .tabItem {
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
                    ScrollView{
                    VStack{
                        Spacer()
                        HStack{
                            Image("200")
                                .resizable()
                                .frame(width: 50, height: 50)
                            Text("本アプリについて").font(.title)
                        Image("200")
                            .resizable()
                            .frame(width: 50, height: 50)
                        }
                        ShowMoreView(text: Description)
                        
                        HStack{
                            Image("200")
                                .resizable()
                                .frame(width: 50, height: 50)
                        Text("本アプリの使い方").font(.title)
                            Image("200")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        ShowMoreView(text: Description_app)
                        
                        HStack{
                            Image("200")
                                .resizable()
                                .frame(width: 50, height: 50)
                        Text("利用規約").font(.title)
                            Image("200")
                                .resizable()
                                .frame(width: 50, height: 50)
                        }
                        ShowMoreView(text: TermsOfUse)
                        
                        }.navigationBarTitle("Description", displayMode: .inline)
                }
                }.tabItem {
                    Image(systemName: "gearshape")
                    Text("Description")}
                //設定タブここまで
            //アプリ起動時にonApperでsetting.alertがfalseならshowingAlertをtrueにして.alertを表示
        }.onAppear(perform: {
            if !self.setting.alert_p{
                self.showingAlert = true
                self.setting.alert_p = true
            }
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
            .alert(isPresented: $showingAlert) {
                    Alert(title: Text("追加してみよう！"),
                          message: Text("「＋」ボタンから追加できるよ！")) 
                }
          .accentColor(.orange) //オレンジ色にしてみた
    }
}




//エディットボタン、ホーム画面で削除するためのボタン。ゴミ箱ボタン
struct MyEditButton: View {
    @Environment(\.editMode) var editMode
    
    var body: some View {
        Button(action: {
            withAnimation() {
                if self.editMode?.wrappedValue.isEditing == true {
                    self.editMode?.wrappedValue = .inactive
                } else {
                    self.editMode?.wrappedValue = .active
                }
            }
        }) {
            if self.editMode?.wrappedValue.isEditing == true {
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
    let gen = ["食品", "缶詰" , "日用雑貨" , "借り物" , "備品" , "防災用品" , "目標" , "その他"]
    
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
    
    let today = Date()
    
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
                                //プッシュ通知の削除
                                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [String(i.id)])
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
                                    Image("200")
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
                                        ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.$sourceType)
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
                                    self.selectedImage = nil
                                    self.link_appear = false
                                }
                                }) //リストをタップして編集画面を表示すると行う処理、これで編集画面に保存したデータが表示される
                             .navigationBarTitle("Edit Menu", displayMode: .inline)
                        ){
                //リストの内容
                    let diff1 = Calendar(identifier: .gregorian).dateComponents([.day], from: today, to: datas.day).day!
                    HStack{
                        if datas.image.count != 0 {
                            Image(uiImage: UIImage(data: datas.image)!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .frame(width: 50, height:50)
                    }else{
                        Image("200")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 50, height: 50)
                    }
                    VStack{
                        Text("\(datas.name)")
                            .frame(width: 180, height: 25)
//                        HStack{
                        if diff1 < 7 {
                            Text("\(datas.day,style: .date)").foregroundColor(Color.orange)
                        }else{
                            Text("\(datas.day,style: .date)")
                        }
//                        Text("あと\(diff1)日")
//                        }
                        
                    }}.onAppear(perform: {
                        self.link_appear = true
                    })}}.onDelete(perform: envEditMode?.wrappedValue.isEditing ?? false ? self.deleteRow : nil)
        }
    }
}








//データ追加のビュー
struct AddView: View {
    @State var name = ""
    @State var memo = ""
    @State var day =  Date()
    @State var day_id = Int()
    //画像の機能に必要な変数
    @State var image = Data()
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    
    @State private var showingAlert = false
    @State private var empty_alert = false
    @State var genre = "食品"
    let gen = ["食品", "缶詰" , "日用雑貨" , "借り物" , "備品" , "防災用品" , "目標" , "その他"]
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
                    Image("200")
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
                        ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.$sourceType)
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
                            self.day_id = newdata.id
                            newdata.name = self.name
                            newdata.memo = self.memo
                            newdata.genre = self.genre
                            newdata.day = self.day
                            newdata.day_change = self.day_change
                            newdata.day_time = self.day_time
                            if self.selectedImage != nil {
                                newdata.image = (self.selectedImage?.jpegData(compressionQuality: 1))!
                            }
//                            self.selectedImage=nil
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
                                content.title = "期限近いものがあるみたいです！"
                                content.subtitle = "アプリで確認してみよう！"
                                content.sound = UNNotificationSound.default

                                // show this notification five seconds from now
                                var targetDate = Calendar.current.dateComponents([.year,.month,.day], from: self.day)
                                targetDate.day! -= day_change_dict[String(self.day_change)]!
                                targetDate.hour = day_time_dict[String(self.day_time)]!
                                
                                
                                let trigger = UNCalendarNotificationTrigger(dateMatching: targetDate, repeats: false)

                                // choose a random identifier
                                let request = UNNotificationRequest(identifier: String(self.day_id), content: content, trigger: trigger)

                                // add our notification request
                                UNUserNotificationCenter.current().add(request)
                                self.day_change = "当日"
                                self.day_time = "7:00"
                            }
                            

                            try realm.write({
                                realm.add(newdata)
                                print("success")
                                self.name = ""
                                self.memo = ""
                                self.genre = "食品"
                                self.day = Date()
                                self.day_id = Int()
                                self.image = Data()
//                                self.day_change = "当日"
//                                self.day_time = "7:00"
                                self.selectedImage=nil
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
    let gen = ["選択しない","食品", "缶詰" , "日用雑貨" , "借り物" , "備品" , "防災用品" , "目標" , "その他"]
    
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
    let gen = ["食品", "缶詰" , "日用雑貨" , "借り物" , "備品" , "防災用品" , "目標" , "その他"]
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
    
    let today = Date()
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
                                }else if s_genre == "選択しない"{
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
                                }else if s_genre == "選択しない"{
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
                                    Image("200")
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
                                        ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.$sourceType)
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
                                            self.selectedImage = nil
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
                        Image("200")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 50, height: 50)
                    }
                VStack{
                    Text("\(datas.name)")
                        .frame(width: 200, height: 25)
                    if Calendar(identifier: .gregorian).dateComponents([.day], from: today, to: datas.day).day! < 7 {
                        Text("\(datas.day,style: .date)").foregroundColor(Color.orange)
                    }else{
                        Text("\(datas.day,style: .date)")
                    }
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
//                                       self.selectedImage = nil
                                    }
                                    self.name = ""
                                    self.memo = ""
                                    self.genre = "食品"
                                    self.day = Date()
                                    self.image = Data()
//                                    self.day_change = ""
//                                    self.day_change = ""
                                    self.selectedImage = nil
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
                                    content.title = "期限が近いものがあるみたいです！"
                                    content.subtitle = "アプリで確認してみよう！"
                                    content.sound = UNNotificationSound.default

                                    // show this notification five seconds from now
                                    var targetDate = Calendar.current.dateComponents([.year,.month,.day], from: self.day)
                                    targetDate.day! -= day_change_dict[String(self.day_change)]!
                                    targetDate.hour = day_time_dict[String(self.day_time)]!
                                    
//                                    print(targetDate)
                                    
                                    let trigger = UNCalendarNotificationTrigger(dateMatching: targetDate, repeats: false)

                                    // choose a random identifier
                                    let request = UNNotificationRequest(identifier: String(self.i_d), content: content, trigger: trigger)

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
