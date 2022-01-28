//
//  InputViewController.swift
//  taskapp
//
//  Created by ryouta.araki4 on 2022/01/24.
//

import UIKit
import RealmSwift    // 追加する
import UserNotifications    // 追加
import DropDown

class InputViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
            
    // カテゴリー設定
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var categoryDropDownView: UIView!
    let categoryDropDown = DropDown()
    var selectedCategory = Category()
    
    // realm設定
    let realm = try! Realm()    // 追加する
    var task: Task!   // 追加する
    // DB内のカテゴリーが格納されるリスト。
    // idでソート：昇順
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var categoryArray = try! Realm().objects(Category.self).sorted(byKeyPath: "id", ascending: true)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        
        // カテゴリーのドロップダウンリストの設定
        categoryDropDown.anchorView = categoryDropDownView
        categoryTextField.text = ""
        // カテゴリーのドロップダウンリストの更新
        var categoryDropDownArray: [String] = []
        for category in categoryArray {
            categoryDropDownArray.append(category.categoryName)
            if category.id == task.categoryId {
                categoryTextField.text = category.categoryName
                selectedCategory.id = category.id
                selectedCategory.categoryName = category.categoryName
            }
        }
        categoryDropDown.dataSource = categoryDropDownArray
    }
    
    // カテゴリーのドロップダウンリスト選択
    @IBAction func categoryDropDownAction(_ sender: Any) {
        categoryDropDown.show()
        categoryDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
          print("Selected item: \(item) at index: \(index)")
            categoryTextField.text = categoryArray[index].categoryName
            selectedCategory.categoryName = categoryArray[index].categoryName
            selectedCategory.id = categoryArray[index].id
        }
    }
    

    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    // 追加する
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.task.categoryId = selectedCategory.id
            self.realm.add(self.task, update: .modified)
        }
        
        setNotification(task: task)   // 追加

        super.viewWillDisappear(animated)
    }
    
    // タスクのローカル通知を登録する --- ここから ---
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default

        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id), content: content, trigger: trigger)

        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }

        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    } // --- ここまで追加 ---
    
    // カテゴリー追加画面から戻ってきた時に TableView を更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // カテゴリーのドロップダウンリストの更新
        var categoryDropDownArray: [String] = []
        for category in categoryArray {
            categoryDropDownArray.append(category.categoryName)
        }
        categoryDropDown.dataSource = categoryDropDownArray
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
