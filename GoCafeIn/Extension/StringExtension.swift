//
//  StringExtension.swift
//  GoCafeIn
//
//  Created by RedMac on 2020/09/11.
//  Copyright © 2020 AppBoong. All rights reserved.
//

import Foundation

extension String {
    func safeDatabaseKey() -> String {
        return self.replacingOccurrences(of: ".", with: "-")
    }
    func safeChildKey() -> String {
        return self.replacingOccurrences(of: "https://gocafein-c430b.firebaseio.com/", with: "").replacingOccurrences(of: "-", with: "")
    }
    func getEmailKey() -> String {
        return self.replacingOccurrences(of: "-", with: ".")
    }
    func removeSpace() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
}
extension UIViewController {
    func containCharacter(text : String , searchText : @escaping(String) -> ()) {
        switch text.description{
        case let str where str.contains("서울"):
            searchText("서울특별시")
        case let str where str.contains("경기"):
            searchText("경기도")
        case let str where str.contains("충북"):
            searchText("충청북도")
        case let str where str.contains("충남"):
            searchText("충청남도")
        case let str where str.contains("경북"):
            searchText("경상북도")
        case let str where str.contains("경남"):
            searchText("경상남도")
        case let str where str.contains("전북"):
            searchText("전라북도")
        case let str where str.contains("전남"):
            searchText("전라남도")
        case let str where str.contains("강원"):
            searchText("강원도")
        case let str where str.contains("인천"):
            searchText("인천광역시")
        case let str where str.contains("대전"):
            searchText("대전광역시")
        case let str where str.contains("울산"):
            searchText("울산광역시")
        case let str where str.contains("대구"):
            searchText("대구광역시")
        case let str where str.contains("부산"):
            searchText("부산광역시")
        case let str where str.contains("광주"):
            searchText("광주광역시")
        case let str where str.contains("제주"):
            searchText("제주도")
        default:
            searchText(text)
        }
    }
}
