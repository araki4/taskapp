//
//  Task.swift
//  taskapp
//
//  Created by ryouta.araki4 on 2022/01/24.
//

import RealmSwift

class Category: Object {
    
    // 管理用ID（プライマリーキー）
    @objc dynamic var id = 0
    
    // カテゴリー名
    @objc dynamic var name = ""
    
    // カテゴリーの並び順
    @objc dynamic var order = 0
    
    let tasks = List<Task>()

    override static func primaryKey() -> String? {
        return "id"
    }
}

class Task: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var id = 0

    // タイトル
    @objc dynamic var title = ""

    // 内容
    @objc dynamic var contents = ""

    // 日時
    @objc dynamic var date = Date()
    
    // カテゴリー紐つけ
    let catgory = LinkingObjects(fromType: Category.self, property: "tasks")

    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "id"
    }
}
