//
//  ChatScreen.swift
//  Role histories
//
//  Created by Kenny Zhou on 2021/7/31.
//

import SwiftUI

struct ChatScreen: View {
    @State var UserData: UserInfo
    @EnvironmentObject var ChatHistory: UserChatHistory


    var body: some View {
        VStack {
            // MARK: Chat history.

           ScrollView { // 1
                // MARK: Coming soon!
            ScrollViewReader { value in
            
//                LazyVStack {
                    
                    ForEach(self.ChatHistory.ChatHistoryList){ item in
                        UserChatView(index: item.id, userName: item.userName, message: item.message, color: self.UserData.UserList[self.UserData.UserList.firstIndex(where:{ $0.userName == item.userName})!].color)
//                    }
                }.onChange(of: self.ChatHistory.ChatHistoryList.count) { _ in
                    // MARK: 自动向下滚动
                    withAnimation{
                        value.scrollTo(self.ChatHistory.ChatHistoryList.count-1)
                    }
                    
                }
                }
                
                }
        }
    
            }

//            // MARK: Message field.
//            HStack {
//                TextField("Message", text: $message) // 2
//                    .padding(10)
//                    .background(Color.secondary.opacity(0.2))
//                    .cornerRadius(5)
//
//                Button(action: {}) { // 3
//                    Image(systemName: "arrowshape.turn.up.right")
//                        .font(.system(size: 20))
//                }
//                .padding()
//                .disabled(message.isEmpty) // 4
//            }
//            .padding()
        }

class UserChatHistory: ObservableObject {
    
    @Published var ChatHistoryList: [SingleUserChatHistory]
    @State var UserData: UserInfo
    
    var allCount: Int = 0
    
    init(UserData:UserInfo){
        self.ChatHistoryList = []
        self.UserData = UserData
    }
    
    init(data: [SingleUserChatHistory], UserData:UserInfo){
        self.ChatHistoryList = []
        self.UserData = UserData
        for item in data {
            self.add(userName: item.userName, message: item.message)
        }
    }
    
    func userTalkCount(userName: String) -> Int{
        var count: Int
        
        count =  self.UserData.UserNameDict[userName]!
//        index = self.UserData.UserList.firstIndex(where: { $0.userName == userName})!
        count += 1
        
        self.UserData.UserNameDict.updateValue(count, forKey: userName)
        
        return count
        
    }
    
    
    func add(userName: String,message: String) {

        self.ChatHistoryList.append(SingleUserChatHistory(id: self.allCount, userName: userName, userTalkCount: self.userTalkCount(userName:userName) ,message: message ,timeStamp: Date()))
        self.allCount += 1
    
    }
    
    func getLastId() -> Int {
        return self.allCount
    }
    
    func change(id: Int,message: String) {
        
        self.ChatHistoryList[id].message = message
    
    }
}

