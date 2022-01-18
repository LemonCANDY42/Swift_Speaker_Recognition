//
//  UserStruct.swift
//  Role histories
//
//  Created by Kenny Zhou on 2021/8/1.
//

import Foundation
import SwiftUI

class UserInfo: ObservableObject {
    
    @Published var UserList: [UserStruct]
    @Published var UserNameDict: [String: Int]
    
    // App根目录
    @Published var appSupportURL: URL?
    @Published var appMeetingLogURL: URL?
    @Published var appVoiceDataURL: URL?
    @Published var appTrainSessionURL: URL?
    @Published var appModelURL: URL?
    @Published var appUserURL: URL?
    
    @Published var hadBeTrain = false
    
    var appModelFolderURL: URL?
    
    var count: Int = 0
//    var userFloderUrl: URL? = createdFolder(userName: String)
    
    init() {
        self.UserList = []
        self.UserNameDict = [:]
        self.createdFolder(userName: "")
        
    }

    init(data: [UserStruct]) {
        self.UserList = []
        self.UserNameDict = [:]
        self.createdFolder(userName: "")
        for item in data {
            let userUrl =  self.createdFolder(userName: item.userName)
            self.UserList.append(UserStruct(id: Int64(self.count), timestamp: item.timestamp, userName: item.userName ,color: item.color, userUrl: userUrl, uuid: item.uuid))
            self.UserNameDict.updateValue(0, forKey: item.userName)
            self.count += 1
        self.sort()
        }
    }
    
    func updateList(data: [UserStruct]) {
        for item in data {
            let userUrl =  self.createdFolder(userName: item.userName)
            self.UserList.append(UserStruct(id: Int64(self.count), timestamp: item.timestamp, userName: item.userName ,color: item.color, userUrl: userUrl, uuid: item.uuid))
            self.UserNameDict.updateValue(0, forKey: item.userName)
            self.count += 1
        self.sort()
        }
    }
    
    func createdMeetingLogURLFolder(logName: String) -> URL {
        let manager = FileManager.default
        
        self.appMeetingLogURL =  self.appSupportURL!.appendingPathComponent("MeetingLog")
        try! manager.createDirectory (at:  self.appMeetingLogURL!, withIntermediateDirectories: true, attributes: nil)
        print(self.appMeetingLogURL!)
        return self.appMeetingLogURL!
        
    }
    
    
    func createdFolder(userName: String) -> URL {
        let manager = FileManager.default
        
        if userName == "" {do {
            
            // MARK: 创建沙箱中的应用程序支持目录
            let appSupportUrl = try manager.url(for:.applicationSupportDirectory,
                                    in: .userDomainMask, appropriateFor: nil, create: true) // use appSupportURL here
            
            self.appSupportURL = appSupportUrl.appendingPathComponent("com.Kenny Zhou.Role histories")
                       
            self.appUserURL = self.appSupportURL!.appendingPathComponent("User")
            
            try manager.createDirectory (at:  self.appSupportURL!, withIntermediateDirectories: true, attributes: nil)
            
            appModelFolderURL = self.appSupportURL!.appendingPathComponent("Model")
            try! manager.createDirectory (at: appModelFolderURL!, withIntermediateDirectories: true, attributes: nil)
            self.appModelURL = appModelFolderURL!.appendingPathComponent("model" ,isDirectory:false).appendingPathExtension("mlmodel")
            
            self.appVoiceDataURL = self.appSupportURL!.appendingPathComponent("Voice")
            try! manager.createDirectory (at: self.appVoiceDataURL!, withIntermediateDirectories: true, attributes: nil)

            
//            // 添加资源文件夹
//            let NbackgroundUrl = self.appVoiceDataURL!.appendingPathComponent("background")
//            let backgroundUrl = Bundle.main.resourceURL?.appendingPathComponent("background")
//            try manager.copyItem(at: backgroundUrl!, to: NbackgroundUrl)

            print(self.appSupportURL!)

            
        return self.appSupportURL!
       } catch {
        
        print("Oops: \(error)")
           let appSupportUrl = try! manager.url(for:.applicationSupportDirectory,
                                   in: .userDomainMask, appropriateFor: nil, create: true) // use
           self.appSupportURL = appSupportUrl.appendingPathComponent("com.Kenny Zhou.Role histories")

        return self.appSupportURL!
        }
        } else {
        
            appTrainSessionURL = self.appSupportURL!.appendingPathComponent("TrainSession")
            
            try! manager.createDirectory (at: appTrainSessionURL!, withIntermediateDirectories: true, attributes: nil)
            

                        
            let folderUrl: URL = self.appUserURL!.appendingPathComponent(userName)
            let voiceUser = self.appVoiceDataURL!.appendingPathComponent(userName)
            try! manager.createDirectory (at: voiceUser, withIntermediateDirectories: true, attributes: nil)
            print(voiceUser,self.appVoiceDataURL!)
            
            
            do{
                try manager.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
                print(folderUrl)
                return folderUrl
            }
            catch{
                print("Oops: \(error)")
                return folderUrl
            }
            
           }
    
    }
        
    func deleteFolder(url: URL) {
        let manager = FileManager.default
//        let documentPath = manager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        do{
            try manager.removeItem(at: url)
            print("deleted "+url.path)
        }
        catch{
            print("Oops: \(error)")
        }
    }

    func switchable(id: Int) {
        self.UserList[id].isEnable.toggle()
    }

    func add(data: UserStruct) {
        
        let userUrl =  self.createdFolder(userName: data.userName)
        self.UserList.append(UserStruct(id: Int64(self.count), timestamp: data.timestamp, userName: data.userName ,color: data.color, userUrl: userUrl))
        self.UserNameDict.updateValue(0, forKey: data.userName)
        self.count += 1
        
        self.hadBeTrain = false
        
        print("add \(data)")
        
        self.sort()
    }
    
    func delete(id index: Int) {
        let userName = self.UserList[index].userName
        let userFileUrl: URL = self.appUserURL!.appendingPathComponent(userName,isDirectory:false)
        let voiceUserUrl = self.appVoiceDataURL!.appendingPathComponent(userName,isDirectory:false)
        
        self.deleteFolder(url: userFileUrl)
        self.deleteFolder(url: voiceUserUrl)

        _ = self.UserList.remove(at: index)
        self.UserNameDict.removeValue(forKey: userName)
        self.count -= 1
        self.hadBeTrain = false
        
        self.sort()
    }

    func sort() {
        
        self.UserList.sort {(data1, data2) in
            return data1.timestamp.timeIntervalSince1970 < data2.timestamp.timeIntervalSince1970
        }
        // MARK: id 排序
        for i in 0..<self.UserList.count {
            self.UserList[i].id = Int64(i)
        }
    }
    
}


struct UserStruct: Identifiable {
    
    @State var isEnable: Bool = false
    var id: Int64 = 0
    var timestamp = Date()
    var userName: String = "Kenny"
    var color: Color = Color.blue
    var userUrl: URL?
    var uuid = UUID()
    
}

struct SingleUserChatHistory: Identifiable, Hashable {
    
    //第N条
    var id: Int = 0
    var userName: String = ""
    //本人第N条
    var userTalkCount: Int = 0
    var message: String = ""
    var timeStamp: Date = Date()
    
}
    
struct UserChatView: View {
    
    // 查看是否为深色模式
    @Environment(\.colorScheme) var colorScheme
    
    var index = 0
    var userName: String
    var message: String
    var color: Color
    var direction: ChatBubbleShape.Direction {if index.isOdd(){
        return ChatBubbleShape.Direction.left
    } else {
        return ChatBubbleShape.Direction.right
    }
    }

    var body: some View{

        HStack {
            if direction == ChatBubbleShape.Direction.left{
                SingleHeadPortraitView(userName: userName, color: color)
                
                ChatBubbleCat(message: message, color: color, direction: direction)
            }
                else {
                    
                    ChatBubbleCat(message: message, color: color, direction: direction)
                    SingleHeadPortraitView(userName: userName, color: color)
                    
                }
            
                    
        }.padding(.horizontal)
        }
    }

struct ChatBubbleCat: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var message: String
    var color: Color
    var direction: ChatBubbleShape.Direction

    var body: some View{
        
        HStack {
            ChatBubble(direction: direction) {
                Text(message)
                    .padding(.all, 20)
                    .background(color)
                .foregroundColor(colorScheme == .light ? Color.black: Color.white )}
            Spacer()
        }
            
    }
    
}

    
    
    

