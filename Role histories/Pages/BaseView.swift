//
//  BaseView.swift
//  Role histories
//
//  Created by Kenny Zhou on 2021/7/31.
//

import SwiftUI
//import struct Kingfisher.KFImage


enum LoadingState {
    case loaded, empty, failed
}
@available(iOS 15.0, *)
struct BaseView: View {
    

    
    @Environment(\.managedObjectContext) var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.id, ascending: true)],
        animation: .default)
    
    var persons: FetchedResults<User>
    
    @State var viewRouter: ViewRouter = ViewRouter()
    @State var trainProgress = TrainModle()
    @State var UserData = UserInfo()
    @State var speechRecognizer: SpeechRecognizerLive?
    
    @State var showUserSheet = false
    
    @Environment(\.scenePhase) var scenePhase
//    @State var firstLaunch = true
    
//    @StateObject var needReturn:Return
    
//    @State var ChatHistory: UserChatHistory?
    
    
//    func reloadPersons() -> UserInfo {
//        // non always good, but can
//        print(persons)
//        if persons.count == 0 {
//            print("persons.is Empty")
//        return  UserInfo()
//
//        } else {
//            var userArray = [UserStruct]()
//            for person in persons.sorted(by: {$0.id > $1.id}) {
//                userArray.append(UserStruct(id: person.id,timestamp: person.timestamp!, userName: person.name! ,color:Color.init(hex: person.color!), userUrl: person.url!, uuid: person.uuid!))
//            }
//
//            print("persons.is not Empty")
//            return UserInfo(data: userArray)
//        }
//    }

    var body: some View {

        NavigationView {
        VStack {
            var ChatHistory = UserChatHistory(UserData: self.UserData)
            
            ShowUserView(trainProgress:  self.trainProgress,UserData: self.UserData, ChatHistory: ChatHistory, speechRecognizer:SpeechRecognizerLive(viewRouter:viewRouter,userData:self.UserData,chatHistory:ChatHistory)
                         
            )

                .environmentObject(viewRouter)
        }
        .onAppear{
            print("self.UserData.count",self.UserData.count)
            
            if persons.count == 0 {
                print("persons.is Empty")
    
            } else if self.UserData.count == 0 {
                var userArray = [UserStruct]()
                for person in persons.sorted(by: {$0.id > $1.id}) {
                    userArray.append(UserStruct(id: person.id,timestamp: person.timestamp!, userName: person.name! ,color:Color.init(hex: person.color!), userUrl: person.url!, uuid: person.uuid!))
                }
                
                print("persons.is not Empty")
                self.UserData.updateList(data: userArray)
//                self.firstLaunch = false

            }
            
        }
            
//                .navigationBarTitle("", displayMode: .inline)
//                .navigationBarHidden(true)
            
                .navigationTitle("角色")
                .navigationBarItems(trailing: Button(action: {
                    showUserSheet = true
                }, label: {
                    Image(systemName: "person.2.circle.fill")
                        .imageScale(.large)
        }))
                .sheet(isPresented: $showUserSheet) {
                    UserManagerView(UserData: self.UserData)
                }
        }
    }
}



@available(iOS 15.0, *)
struct ShowUserView: View {

    @EnvironmentObject var viewRouter: ViewRouter
    @State var showAddCharacterPage: Bool = false
    
    @State var trainProgress:TrainModle
    
    // MARK: Must be StateObject
    @StateObject var UserData: UserInfo
    @State var ChatHistory: UserChatHistory
    @State var speechRecognizer: SpeechRecognizerLive
    @State var timeStamp = 0
    
    @State var showAlert = false
    @State var logName:String?
    
    let timer = Timer.publish(every: 0.1, tolerance: 0.05, on: .main, in: .common).autoconnect()
    
    
//    @Binding var needReturn: Bool
    
//    @State var transcript = ""

    @State var showDefferentButton = false
    

    var body: some View {
        // MARK: 滚动条

        ZStack {
                VStack {
                    Spacer()
                        .frame(height: 25)
//                    HStack{
//                        Spacer()
//                            .frame(width: 10.0)
//                        Text("角色").font(.title).fontWeight(.bold).multilineTextAlignment(.leading)
//
//                    Spacer()
//                    }
                    ScrollView(.horizontal, showsIndicators: true) {
                        VStack {
                            HStack {
                                Spacer()
                                ForEach(self.$UserData.UserList) { item in
                                    SingleHeadPortraitButton(UserData: self.UserData, userName: self.UserData.UserList[Int(exactly:item.id)!].userName, index: Int(exactly:item.id)!)//.environmentObject(self.UserData)
                                        .foregroundColor(self.UserData.UserList[Int(exactly:item.id)!].color)
                                        .disabled(self.UserData.UserList[Int(exactly:item.id)!].isEnable)
                        
                                }
                                Spacer()
                                AddPersonView(UserData:self.UserData,showDefferentButton: self.showDefferentButton)
                                    .environmentObject(viewRouter)
//                                    .environmentObject(UserData)
                                    .padding([.leading,]) // , .bottom
                                    
                                Spacer()
                                
                                NavigationLink(destination: TrainView(userData: self.UserData, trainProgress: self.trainProgress,speechRecognizer: self.speechRecognizer)) {
                                    
                                    Group {
                                        Image(systemName: "waveform.circle")
                                            .resizable()
                                            .aspectRatio(1, contentMode: .fit)
                                    }.frame(width: 48)
                                        

                                }.disabled(self.UserData.UserList.count<2 || self.showDefferentButton)
                                
                            }
                            .padding(.vertical)
                            
                        }
                    }
//                    .navigationBarTitle("角色")
                    Divider()
//                    Spacer()
                    ChatScreen(UserData: self.UserData).environmentObject(self.ChatHistory)
                    Spacer()

                    Button(action: {
                        //  fade in/out
                            self.showDefferentButton.toggle()
                        if self.showDefferentButton {self.showAlert = true}
                        else {
                            
                            self.speechRecognizer.stopRecording()
                            self.logName = nil

                        }
                        
//                        print("needReturn \(self.viewRouter.needReturn)")
                    }) {
                        if self.UserData.UserList.count > 0{
                        if !self.showDefferentButton {Image("custom.record.circle.fill")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 88)
                            .foregroundColor(.red)
                            .shadow(radius: 5)
                            .background(Color.init(hex: "EEE0A0"))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                            
//                            .overlay(Circle().stroke(Color.white, lineWidth: 4))}
                        } else {Image("custom.stop.circle.fill")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 88)
                            .foregroundColor(.red)
                            .shadow(radius: 5)
                            .background(Color.init(hex: "EEE0A0"))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                        }} else {Image("custom.record.circle.fill")
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: 88)
                                .foregroundColor(.black)
                                .shadow(radius: 5)
                                .background(Color.gray)
                                .clipShape(Circle())
                                .shadow(radius: 5)
                        }
                    }.disabled(!self.UserData.hadBeTrain)
                    .onChange(of: self.viewRouter.needReturn, perform: { value in
                        if self.viewRouter.needReturn != false {self.timeStamp = getNowTimeStampMillisecond()}

                    }).onReceive(timer, perform: { time in
                        // 毫秒差
//                        print(" self.viewRouter.transcript:\( self.viewRouter.transcript)")
                        // TODO: This.
                        if self.UserData.hadBeTrain {
                        
                        if self.timeStamp != 0 && (
                            String(self.viewRouter.transcript.suffix(1)) == "。" || String(self.viewRouter.transcript.suffix(1)) == "." || String(self.viewRouter.transcript.suffix(1)) == "！" || String(self.viewRouter.transcript.suffix(1)) == "？" || String(self.viewRouter.transcript.suffix(1)) == "!" || String(self.viewRouter.transcript.suffix(1)) == "?" || String(self.viewRouter.transcript.suffix(1)) == "," || String(self.viewRouter.transcript.suffix(1)) == "，" ||
                                getNowTimeStampMillisecond() - self.timeStamp > 3000
                    )
                            && getNowTimeStampMillisecond() - self.timeStamp > 1000{
                            if self.UserData.UserList.count > 0,  self.viewRouter.transcript != "" {
//                                print("$transcript \( self.viewRouter.transcript) \n \(self.UserData.UserList[self.UserData.UserList.count-1].userName)")
                                if self.ChatHistory.getLastId() > self.viewRouter.needReturnId {
                                    // MARK: 重铸信息
                                    print("重铸第\(self.viewRouter.needReturnId)条信息")
                                    self.ChatHistory.change(id: self.viewRouter.needReturnId, message: self.viewRouter.transcript)
                                    self.speechRecognizer.isSpeckEnd = true
                                    self.viewRouter.transcript = ""
                                } else {
                                    let user = self.speechRecognizer.checkUser()
                                    if user != "114154.$"{
                                self.ChatHistory.add(userName: user, message: self.viewRouter.transcript)
                                        self.speechRecognizer.isSpeckEnd = true
                                        }
                                    self.viewRouter.transcript = ""
                                }
                                
                        }
                            self.timeStamp = getNowTimeStampMillisecond()
                        }
                    }
                    })
                    .onChange(of: self.logName, perform: { value in
                        
                        withAnimation {
                                    //                    viewRouter.currentPage = .page2
                            //                            if self.UserData.UserList.count > 0{
                            //                                self.ChatHistory.add(userName: self.UserData.UserList[self.UserData.UserList.count-1].userName, message:self.UserData.UserList[self.UserData.UserList.count-1].userName)}
                            
                            if self.showDefferentButton && self.logName != nil && self.UserData.hadBeTrain {
                                print("startRecording")
                                do{try self.speechRecognizer.initAudio(logName: self.logName!)
                            }
                            catch {
                                print("can't get $transcript:\(error)")
                                self.logName = nil
                            }}
                         }
                    })

                    .disabled(!(self.UserData.UserList.count > 0))
//                    Spacer()
                }
                .alert(isPresented: self.$showAlert,
                    TextAlert(title: "记录名称",
                                  message: "请输入新记录的名称" //keyboardType: .numberPad
                                  ) { result in
                    if result == "" {
                        self.showDefferentButton = false
                    } else {
                      if let text = result {
                       self.logName = text
                      } else {
                       self.logName = nil
                      self.showDefferentButton = false
                     
                        // The dialog was cancelled
                      }
                      }
                    })
            
            }
        
    }
}

struct AddPersonView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    @State var UserData: UserInfo
    @State var showDefferentButton: Bool = false
    
    @State private var showingPopover: Bool = false
    @State private var showAddCharacterPage: Bool = false

    
    var sendTitle: String = "新增"
    
    var body: some View {
        
        Button(action: {
            self.showAddCharacterPage = true
//            }
        }) {
            Group {
                Image(systemName: "person.crop.circle.badge.plus")
                    .resizable()
                    .aspectRatio(1.1, contentMode: .fit)
            }.frame(width: 48)
        }
        .disabled(self.showDefferentButton)
        .sheet(isPresented: self.$showAddCharacterPage, content: {
            UserInput()
            .environmentObject(self.UserData) })
            
        
}
}

struct SingleHeadPortraitButton: View {
    
    @State var UserData: UserInfo
    @State var userName: String
    @State var showingPopover: Bool = false
    @State private var selected = false
    var sendTitle: String = "追加语音信息"
    var index: Int
    
    var body: some View {
        Button(action: {
            self.selected.toggle()
            withAnimation {
                showingPopover = true
                //viewRouter.currentPage = .page3
            }
        })
            {
            SingleHeadPortraitView(userName:userName,color: self.UserData.UserList[index].color)
                // 抖动次数
//                .modifier(ShakeEffect(shakes: selected ? 8 : 0))
//                .animation(Animation.linear)
        
        }
        //popover是一个专用的修改器来显示弹出窗口，在iPadOS上它显示为浮动气球，而在iOS上则像一张纸一样滑到屏幕上。
        .popover(isPresented: $showingPopover){
            NewUserRegister(UserData:self.UserData, sendTitle:sendTitle, userName:userName,isShow:self.$showingPopover)
//            AudioRecorderView(audioRecorder: AudioRecorder())
    }
}
}

struct SingleHeadPortraitView: View {

//    @StateObject var UserData: UserInfo
    @State var userName: String
    @State var color: Color

    
    var body: some View {
        
        VStack {
        VStack {
            Image("Launch")
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .opacity(0)
                .background(color)
                .opacity(0.7) // 不透明度
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 7)
                .overlay(SingleHeadPortraitTextView(userName:userName))
                
        }
        .frame(width: 60, height: 60)
            Text(userName)
                .shadow(radius: 3)
        }
        .padding([ .leading])
    }

}

struct SingleHeadPortraitTextView: View {
    
    @State var userName: String
    
    var body: some View {

        ZStack {
            Text(userName.prefix(1))
                .foregroundColor(.white)
                .shadow(radius: 7)
                .font(.largeTitle)
        }
        .frame(width: 55, height: 55)
        .opacity(0.9)// 不透明度
    }

}

@available(iOS 15.0, *)
struct BaseView_Previews: PreviewProvider {

    @State var firstLaunch = true
    static var previews: some View {

        BaseView().environmentObject(ViewRouter())

    }
}



// MARK: Binding Preview

//struct BindingViewExamplePreviewContainer : View {
//     @State
//     private var value = false
//
//     var body: some View {
//         BaseView(firstLaunch: $value).environmentObject(ViewRouter())
//     }
//}
//
//#if DEBUG
//struct BaseView_Previews : PreviewProvider {
//    static var previews: some View {
//        BindingViewExamplePreviewContainer()
//    }
//}
//#endif
