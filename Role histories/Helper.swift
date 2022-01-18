//
//  Helper.swift
//  Role histories
//
//  Created by Kenny Zhou on 2021/7/31.
//

import SwiftUI


enum Page {
    case page1
    case page2
    case page3
}


// MAKR: 此函数在给定路径读取文件并返回创建日期。如果失败，我们只需返回当前日期
func getCreationDate(for file: URL) -> Date {
    if let attributes = try? FileManager.default.attributesOfItem(atPath: file.path) as [FileAttributeKey: Any],
        let creationDate = attributes[FileAttributeKey.creationDate] as? Date {
        return creationDate
    } else {
        return Date()
    }
}
