//
//  Extensions.swift
//  Role histories
//
//  Created by Kenny Zhou on 2021/7/31.
//

import Foundation
import SwiftUI
//import struct Kingfisher.KFImage

extension Color {
    var uiColor: UIColor { .init(self) }
    typealias RGBA = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    var rgba: RGBA? {
        var (r,g,b,a): RGBA = (0,0,0,0)
        return uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) ? (r,g,b,a) : nil
    }
    var hexaRGB: String? {
        guard let rgba = rgba else { return nil }
        return String(format: "#%02x%02x%02x",
            Int(rgba.red*255),
            Int(rgba.green*255),
            Int(rgba.blue*255))
    }
    var hexaRGBA: String? {
        guard let rgba = rgba else { return nil }
        return String(format: "#%02x%02x%02x%02x",
            Int(rgba.red * 255),
            Int(rgba.green * 255),
            Int(rgba.blue * 255),
            Int(rgba.alpha * 255))
    }
    
    var RGBOcomponents: (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat) {

        #if canImport(UIKit)
        typealias NativeColor = UIColor
        #elseif canImport(AppKit)
        typealias NativeColor = NSColor
        #endif

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var o: CGFloat = 0

        guard NativeColor(self).getRed(&r, green: &g, blue: &b, alpha: &o) else {
            // You can handle the failure here as you want
            return (0, 0, 0, 0)
        }

        return (r, g, b, o)
    }
}
//
//  Color+Extension.swift
//  Helpers pack with:
//
//  1 - encode/decode RGBA
//  2 - accessibleFontColor depends on background color
//  3 - isLightColor - color lightness detection
//
//  Created by Alexo on 19.12.2020.
//

extension Color: Codable {
    private struct Components {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
    }
    
    private enum CodingKeys: String, CodingKey {
        case red
        case green
        case blue
        case alpha
        }
    
    /// A new random color.
    static var random: Color {
        let red = Double.random(in: 0...1)
        let green = Double.random(in: 0...1)
        let blue = Double.random(in: 0...1)
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
    
    private var components: Components {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return Components(red: Double(red),
                                green: Double(green),
                                blue: Double(blue),
                                alpha: Double(alpha))
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let alpha = try container.decode(Double.self, forKey: .alpha)
        self.init(Components(red: red, green: green, blue: blue, alpha: alpha))
    }
    
    private init(_ components: Components) {
        self.init(.sRGB, red: components.red, green: components.green, blue: components.blue, opacity: components.alpha)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let components = self.components
        try container.encode(components.red, forKey: .red)
        try container.encode(components.green, forKey: .green)
        try container.encode(components.blue, forKey: .blue)
        try container.encode(components.alpha, forKey: .alpha)
    }
    
    // MARK: - font colors
    /// This color is either black or white, whichever is more accessible when viewed against the scrum color.
    var accessibleFontColor: Color {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: nil)
        return isLightColor(red: red, green: green, blue: blue) ? .black : .white
    }
    
    private func isLightColor(red: CGFloat, green: CGFloat, blue: CGFloat) -> Bool {
        let lightRed = red > 0.65
        let lightGreen = green > 0.65
        let lightBlue = blue > 0.65
        
        let lightness = [lightRed, lightGreen, lightBlue].reduce(0) { $1 ? $0 + 1 : $0 }
        return lightness >= 2
    }
}

extension Date {
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

}

// SwiftUI-十六进制字符串转颜色
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b, a) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (r, g, b, a) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (r, g, b, a) = (1, 1, 0, 1)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

//extension Array {
//    var last: <T> {
//        return self[self.endIndex - 1]
//    }
//}




// 判断是否为奇数
extension BinaryInteger {
    func isOdd() -> Bool {
        self % 2 != 0
    }
}

////如果不存在文件夹，则创建新的文件夹。并返回bool值
//func createFolderIfNotExisits(folderPath : String)->Bool {
//    let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)//.first! as NSString
//    let fileManager = FileManager.default
//    let filePath = documentPath as String + "/" + folderPath
//    let exist = fileManager.fileExists(atPath: filePath)
//    if !exist {
//        try! fileManager.createDirectory(atPath: filePath,withIntermediateDirectories: true, attributes: nil)
//
//    }
//    return exist
//
//}

//获取指定路径下所有文件名
func getAllFileName(folderPath: String)->[String]{
    let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        .first! as NSString
    let manager = FileManager.default
    let fileUrl = documentPath as String + "/" + folderPath
    let subPaths = manager.subpaths(atPath: fileUrl)
    let array = subPaths?.filter({$0 != ".DS_Store"})
    return array!
}

//删除置指定路径的文件，并返回Bool值。
func deleteFile(folderPath: String, fileName: String)->Bool{
    var success = false
    let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! as NSString
    let manager = FileManager.default; let fileUrl = documentPath as String + "/" + folderPath
    let subPaths = manager.subpaths(atPath: fileUrl)
    let removePath = fileUrl + "/" + fileName
    for fileStr in subPaths!{
            if fileName == fileStr {
                try! manager.removeItem(atPath: removePath)
                success = true
            }
    }
        return success
    
}

//MARK: 获取当前时间的时间戳(毫秒Millisecond为单位)

 func getNowTimeStampMillisecond() -> Int {
     let formatter = DateFormatter()

     formatter.dateStyle = .medium

     formatter.timeStyle = .short

     formatter.dateFormat = "YYYY-MM-dd HH:mm:ss SSS"//设置时间格式；hh——>12小时制， HH———>24小时制

     

     //设置时区

     let timeZone = TimeZone.init(identifier: "Asia/Shanghai")

     formatter.timeZone = timeZone

     

     let dateNow = Date()//当前时间

     let timeStamp =  Int(dateNow.timeIntervalSince1970) * 1000

     return timeStamp


 }


//func getImage(imageUrl: String) -> KFImage {
//    
//    return KFImage(URL(string: imageUrl)!) //如果网络图片属性的值不为空，则显示下载后的网络图片，否则显示占位符图片
//
//}


//    // 查看颜色RBG
//
//    let col: Color = Color(red: 0.5, green: 0.5, blue: 0.5)
//    func printColor(_ col: Color){
//        print(col.components)
//    }


//struct CustomScrollView<Content>: View where Content: View {
//    var axes: Axis.Set = .vertical
//    var reversed: Bool = false
//    var scrollToEnd: Bool = false
//    var content: () -> Content
//
//    @State private var contentHeight: CGFloat = .zero
//    @State private var contentOffset: CGFloat = .zero
//    @State private var scrollOffset: CGFloat = .zero
//
//    var body: some View {
//        GeometryReader { geometry in
//            if self.axes == .vertical {
//                self.vertical(geometry: geometry)
//            } else {
//                // implement same for horizontal orientation
//            }
//        }
//        .clipped()
//    }
//
//    private func vertical(geometry: GeometryProxy) -> some View {
//        VStack {
//            content()
//        }
//        .modifier(ViewHeightKey())
//        .onPreferenceChange(ViewHeightKey.self) {
//            self.updateHeight(with: $0, outerHeight: geometry.size.height)
//        }
//        .frame(height: geometry.size.height, alignment: (reversed ? .bottom : .top))
//        .offset(y: contentOffset + scrollOffset)
//        .animation(.easeInOut)
//        .background(Color.white)
//        .gesture(DragGesture()
//            .onChanged { self.onDragChanged($0) }
//            .onEnded { self.onDragEnded($0, outerHeight: geometry.size.height) }
//        )
//    }
//
//    private func onDragChanged(_ value: DragGesture.Value) {
//        self.scrollOffset = value.location.y - value.startLocation.y
//    }
//
//    private func onDragEnded(_ value: DragGesture.Value, outerHeight: CGFloat) {
//        let scrollOffset = value.predictedEndLocation.y - value.startLocation.y
//
//        self.updateOffset(with: scrollOffset, outerHeight: outerHeight)
//        self.scrollOffset = 0
//    }
//
//    private func updateHeight(with height: CGFloat, outerHeight: CGFloat) {
//        let delta = self.contentHeight - height
//        self.contentHeight = height
//        if scrollToEnd {
//            self.contentOffset = self.reversed ? height - outerHeight - delta : outerHeight - height
//        }
//        if abs(self.contentOffset) > .zero {
//            self.updateOffset(with: delta, outerHeight: outerHeight)
//        }
//    }
//
//    private func updateOffset(with delta: CGFloat, outerHeight: CGFloat) {
//        let topLimit = self.contentHeight - outerHeight
//
//        if topLimit < .zero {
//             self.contentOffset = .zero
//        } else {
//            var proposedOffset = self.contentOffset + delta
//            if (self.reversed ? proposedOffset : -proposedOffset) < .zero {
//                proposedOffset = 0
//            } else if (self.reversed ? proposedOffset : -proposedOffset) > topLimit {
//                proposedOffset = (self.reversed ? topLimit : -topLimit)
//            }
//            self.contentOffset = proposedOffset
//        }
//    }
//}
//
//struct ViewHeightKey: PreferenceKey {
//    static var defaultValue: CGFloat { 0 }
//    static func reduce(value: inout Value, nextValue: () -> Value) {
//        value = value + nextValue()
//    }
//}
//
//extension ViewHeightKey: ViewModifier {
//    func body(content: Content) -> some View {
//        return content.background(GeometryReader { proxy in
//            Color.clear.preference(key: Self.self, value: proxy.size.height)
//        })
//    }
//}




public struct TextAlert {
  public var title: String // Title of the dialog
  public var message: String // Dialog message
  public var placeholder: String = "" // Placeholder text for the TextField
  public var accept: String = "OK" // The left-most button label
  public var cancel: String? = "Cancel" // The optional cancel (right-most) button label
  public var secondaryActionTitle: String? = nil // The optional center button label
  public var keyboardType: UIKeyboardType = .default // Keyboard tzpe of the TextField
  public var action: (String?) -> Void // Triggers when either of the two buttons closes the dialog
  public var secondaryAction: (() -> Void)? = nil // Triggers when the optional center button is tapped
}

extension UIAlertController {
  convenience init(alert: TextAlert) {
    self.init(title: alert.title, message: alert.message, preferredStyle: .alert)
    addTextField {
       $0.placeholder = alert.placeholder
       $0.keyboardType = alert.keyboardType
    }
    if let cancel = alert.cancel {
      addAction(UIAlertAction(title: cancel, style: .cancel) { _ in
        alert.action(nil)
      })
    }
    if let secondaryActionTitle = alert.secondaryActionTitle {
       addAction(UIAlertAction(title: secondaryActionTitle, style: .default, handler: { _ in
         alert.secondaryAction?()
       }))
    }
    let textField = self.textFields?.first
    addAction(UIAlertAction(title: alert.accept, style: .default) { _ in
      alert.action(textField?.text)
    })
  }
}

struct AlertWrapper<Content: View>: UIViewControllerRepresentable {
  @Binding var isPresented: Bool
  let alert: TextAlert
  let content: Content

  func makeUIViewController(context: UIViewControllerRepresentableContext<AlertWrapper>) -> UIHostingController<Content> {
    UIHostingController(rootView: content)
  }

  final class Coordinator {
    var alertController: UIAlertController?
    init(_ controller: UIAlertController? = nil) {
       self.alertController = controller
    }
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator()
  }

  func updateUIViewController(_ uiViewController: UIHostingController<Content>, context: UIViewControllerRepresentableContext<AlertWrapper>) {
    uiViewController.rootView = content
    if isPresented && uiViewController.presentedViewController == nil {
      var alert = self.alert
      alert.action = {
        self.isPresented = false
        self.alert.action($0)
      }
      context.coordinator.alertController = UIAlertController(alert: alert)
      uiViewController.present(context.coordinator.alertController!, animated: true)
    }
    if !isPresented && uiViewController.presentedViewController == context.coordinator.alertController {
      uiViewController.dismiss(animated: true)
    }
  }
}

extension View {
  public func alert(isPresented: Binding<Bool>, _ alert: TextAlert) -> some View {
    AlertWrapper(isPresented: isPresented, alert: alert, content: self)
  }
}


struct CirclerPercentProgressViewStyle: ProgressViewStyle {
    public func makeBody(configuration: LinearProgressViewStyle.Configuration) -> some View {
        VStack {
            configuration.label
                .foregroundColor(Color.secondary)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 15.0)
                    .opacity(0.3)
                    .foregroundColor(Color.accentColor.opacity(0.5))
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0))
                    .stroke(style: StrokeStyle(lineWidth: 15.0, lineCap: .round, lineJoin: .round))
                    .foregroundColor(Color.accentColor)
                
                Text("\(Int((configuration.fractionCompleted ?? 0) * 100)) %")
                    .font(.headline)
                    .foregroundColor(Color.secondary)
            }
        }
    }
}
