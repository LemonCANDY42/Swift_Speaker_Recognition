//
//  CreateUserPage.swift
//  Role histories
//
//  Created by Kenny Zhou on 2021/8/2.
//

import SwiftUI

struct UserInput: View {
    // MARK: 环境目标
    
    @Environment(\.managedObjectContext) var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.id, ascending: true)],
        animation: .default)
    private var items: FetchedResults<User>
    
    @EnvironmentObject var UserData: UserInfo
    

    @State var title: String = ""
    @State var timestamp = Date()
    
    @State var showAlert = false
    @State var alertText = ""
    
    var id: Int? = nil
    
    // MARK: 添加页面状态变量
    @Environment(\.presentationMode) var presentation
    @State private var color: Color = .blue
    @State var showingPopover: Bool = false

    var body: some View {
        
        // MARK: 添加导航视图
        NavigationView {
            
            // MARK: 添加表单
            Form {
                Section(header: Text("角色名")) {
                    TextField("请输入角色名", text: self.$title)
                    //DatePicker(selection: self.$duedate, label: { Text("截止时间") })
                    ColorPicker("代表色", selection: $color)
                }
                Section {
                    Button(action: {
                        if self.title == "" {
                            self.showAlert = true
                            self.alertText = "角色名不能为空！"
                            
                        }
                        // 查询是否存在相同的userName
                        else if self.UserData.UserList.contains(where: { $0.userName == self.title }){
                            self.showAlert = true
                            self.alertText = "重复的用户名！"
                        }
                        else {
                            self.UserData.add(data: UserStruct(timestamp: self.timestamp, userName: self.title, color: self.color))
                            let newItem = User(context: viewContext)
                            newItem.timestamp = self.timestamp
                            newItem.name = self.title
                            newItem.url = self.UserData.UserList.last?.userUrl
                            newItem.color = self.color.hexaRGBA
//                            print("self.color.description:",self.color.description)
//                            print("self.color.hexaRGBA:",self.color.hexaRGBA)
//                            print(Color.init(hex: self.color.hexaRGBA!).description)
                            newItem.uuid = self.UserData.UserList.last?.uuid
                            newItem.id = Int64(self.UserData.UserList.last!.id)
                            
                            showingPopover = true // 开启记录角色声纹界面
                            
//                            // MARK: 关闭页面显示
//                            self.presentation.wrappedValue.dismiss()
                        }
                    }
                        )
                        {
                        Text("确认")
                    }.alert(isPresented: self.$showAlert){
                        Alert(title: Text("注意"), message: Text(self.alertText), dismissButton: .default(Text("OK")))
                    }.popover(isPresented: $showingPopover){
                        NewUserRegister(UserData:self.UserData, sendTitle:"记录角色声音",userName: self.title,isShow:self.$showingPopover)
                    }.onChange(of: showingPopover, perform: {value in
                        if !showingPopover{
                            // MARK: 关闭页面显示
                            self.presentation.wrappedValue.dismiss()
                        }
                    })
                    
                    Button(action: {
                        self.presentation.wrappedValue.dismiss()
                    }) {
                        Text("取消")
                    }
                   
                }
            }
            // MARK: 添加标题
            .navigationBarTitle("添加角色")
        }
        
    }

}

struct UserInput_Previews: PreviewProvider {
    static var previews: some View {
        UserInput()
    }
}
