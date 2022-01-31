//
//  CategoryInputViewController.swift
//  taskapp
//
//  Created by ryouta.araki4 on 2022/01/27.
//

import UIKit
import RealmSwift

class CategoryInputViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var categoryTableView: UITableView!
    
    // Realm設定
    let realm = try! Realm()
    
    // DB内のカテゴリーが格納されるリスト。
    // idでソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "order", ascending: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        categoryTableView.delegate = self
        categoryTableView.dataSource = self
        
        // 編集モードへの切り替え
        categoryTableView.isEditing = false
        categoryTableView.allowsSelectionDuringEditing = true
    }
    
    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = categoryTableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        // Cellに値を設定する
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        
        return cell
    }

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        if categoryTableView.isEditing {
            return .delete
        }
        return .none
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            // 削除するタスクを取得する
            let category = self.categoryArray[indexPath.row]

            // データベースから削除する
            try! realm.write {
                self.realm.delete(category)
                categoryTableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // ソート制御
        return true
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let isDownMove = sourceIndexPath.row < destinationIndexPath.row
        let targetId = categoryArray[sourceIndexPath.row].id
        // 並び順の更新
        for (i, category) in categoryArray.enumerated() {
            // ソート対象のデータの場合
            if category.id == targetId {
                // ソートで選択されたデータの場合
                try! realm.write {
                    category.order = destinationIndexPath.row
                    self.realm.add(category, update: .modified)
                }
            }else if isDownMove && sourceIndexPath.row < i && i <= destinationIndexPath.row {
                try! realm.write {
                    category.order = i - 1
                    self.realm.add(category, update: .modified)
                }
            }else if !isDownMove && destinationIndexPath.row <= i && i < sourceIndexPath.row {
                try! realm.write {
                    category.order = i + 1
                    self.realm.add(category, update: .modified)
                }
            }else{
                try! realm.write {
                    category.order = i
                    self.realm.add(category, update: .modified)
                }
            }
        }
        categoryTableView.reloadData()
    }
    
    // 設定ボタンによる編集モードの制御
    @IBAction func editSettingButton(_ sender: Any) {
        categoryTableView.isEditing = !categoryTableView.isEditing
    }
    
    // カテゴリー追加ボタン押下処理
    @IBAction func categoryAddButton(_ sender: Any) {
        
        // カテゴリー登録
        if self.categoryTextField.text != nil && self.categoryTextField.text != "" {
            let category = Category()
            // category.id = 1
            let allCategorys = realm.objects(Category.self)
            if allCategorys.count != 0 {
                category.id = allCategorys.max(ofProperty: "id")! + 1
                category.order = allCategorys.max(ofProperty: "order")! + 1
            }
            
            category.name = self.categoryTextField.text!

            try! realm.write {
                self.realm.add(category, update: .modified)
            }
            categoryTableView.reloadData()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
