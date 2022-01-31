//
//  ViewController.swift
//  taskapp
//
//  Created by ryouta.araki4 on 2022/01/23.
//

import UIKit
import RealmSwift   // ←追加
import DropDown

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // タスク表のIBOutlet
    @IBOutlet weak var tableView: UITableView!

    // カテゴリー設定
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var categoryDropDownView: UIView!
    let categoryDropDown = DropDown()
    var selectedCategory = Category()
        
    // Realm設定
    let realm = try! Realm()  // ←追加
    // DB内のタスクが格納されるリスト。
    // 日付の近い順でソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)  // ←追加
    // DB内のカテゴリーが格納されるリスト。
    // orderでソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "order", ascending: true)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // カテゴリーのドロップダウンリストの設定
        categoryDropDown.anchorView = categoryDropDownView
        // カテゴリーのドロップダウンリストの更新
        var categoryDropDownArray: [String] = []
        for category in categoryArray {
            categoryDropDownArray.append(category.name)
        }
        categoryDropDown.dataSource = categoryDropDownArray
    }
    
    
    
    // カテゴリードロップダウンリスト選択
    @IBAction func categoryDropDownAction(_ sender: Any) {
        categoryDropDown.show()
        categoryDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            selectedCategory = categoryArray[index]
            categoryTextField.text = categoryArray[index].name
        }
    }
    
    // 絞込みボタン押下処理
    @IBAction func filterButton(_ sender: Any) {
        if categoryTextField.text != nil && categoryTextField.text != "" {
            taskArray = selectedCategory.tasks.sorted(byKeyPath: "date", ascending: true)
            // 入力されたカテゴリで検索
            tableView.reloadData()
        }
    }
    
    // 絞込み解除ボタン押下処理
    @IBAction func filterCancelButton(_ sender: Any) {
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: true)
        selectedCategory = Category()
        categoryTextField.text = nil
        tableView.reloadData()
    }

    // データの数（＝セルの数）を返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count  // ←修正する
    }

    // 各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用可能な cell を得る
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Cellに値を設定する  --- ここから ---
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        // --- ここまで追加 ---
        
        return cell
    }

    // 各セルを選択した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue",sender: nil) // ←追加する
    }

    // セルが削除が可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath)-> UITableViewCell.EditingStyle {
        return .delete
    }

    // Delete ボタンが押された時に呼ばれるメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // --- ここから ---
        if editingStyle == .delete {
            // 削除するタスクを取得する
            let task = self.taskArray[indexPath.row]

            // ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])

            // データベースから削除する
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        } // --- ここまで変更 ---
    }
    
    // segue で画面遷移する時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let inputViewController:InputViewController = segue.destination as! InputViewController

        if segue.identifier == "cellSegue" {
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        } else {
            let task = Task()

            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0 {
                task.id = allTasks.max(ofProperty: "id")! + 1
            }

            inputViewController.task = task
        }
    }
    
    // 入力画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()

        // カテゴリーのドロップダウンリストの更新
        var categoryDropDownArray: [String] = []
        for category in categoryArray {
            categoryDropDownArray.append(category.name)
        }
        categoryDropDown.dataSource = categoryDropDownArray
    }
}

