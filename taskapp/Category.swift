//
//  Category.swift
//  taskapp
//
//  Created by ryouta.araki4 on 2022/01/27.
//

import RealmSwift

class Category: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0

    // カテゴリー名
    @objc dynamic var categoryName = ""
    
    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}

