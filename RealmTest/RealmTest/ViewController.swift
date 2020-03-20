//
//  ViewController.swift
//  RealmTest
//
//  Created by 김지나 on 2020/03/16.
//  Copyright © 2020 김지나. All rights reserved.
/* 참고:
 https://jinshine.github.io/2018/11/20/iOS/Realm%20사용방법/
 https://realm.io/docs/swift/latest/#notifications
*/

import UIKit
import RealmSwift

class ShoppingList: Object {
    @objc dynamic var name = ""
    @objc dynamic var price = ""
}

class ViewController: UIViewController {
    
    var realm: Realm?
    var notificationToken: NotificationToken?
    
    var item: Results<ShoppingList>?
    var searchItem = [ShoppingList]()
    var searching = false
    
    @IBOutlet weak var itemTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var shoppingListTB: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try! Realm()
        
        // ShoppingList 데이터 가져옴
        item = realm?.objects(ShoppingList.self)
        
        notificationRealm() 
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    //MARK: fuction ---------------------------------------------------------------------------
    // Realm 파일 위치
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // Realm 알림
    func notificationRealm() {
        notificationToken = item?.observe { [weak self] (changes: RealmCollectionChange) in
                guard let tableView = self?.shoppingListTB else { return }
                switch changes {
                case .initial:
                    tableView.reloadData()
                case .update(_, let deletions, let insertions, let modifications):
                    tableView.beginUpdates()
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                         with: .automatic)
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                         with: .automatic)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                         with: .automatic)
                    tableView.endUpdates()
                case .error(let error):
                    fatalError("\(error)")
                }
            }
    }

    // 텍스트필드 값 item(ShoppingList)에 대입
    func inputData(database: ShoppingList) -> ShoppingList {
        if let name = itemTF.text {
            database.name = name
        }
        if let price = priceTF.text {
            database.price = price
        }
        return database
    }
    
    //MARK: Button Action ---------------------------------------------------------------------------
    @IBAction func add(_ sender: UIButton) {
        try! realm?.write {
            realm?.add(inputData(database: ShoppingList()))
        }
    }
    
    @IBAction func deleteData(_ sender: UIButton) {
        do {
            try realm?.write {
                guard let result = realm?.objects(ShoppingList.self).filter("name = %@", itemTF.text).first else { return }
                realm?.delete(result)
            }
        } catch {
            print("Error")
        }
    }
    
    @IBAction func update(_ sender: UIButton) {
        try! realm?.write {
            guard let items = item else { return }
            
            items.forEach({ (list) in
                if let name = itemTF.text, let price = priceTF.text {
                    if list.name == name {
                        list.name = name
                        list.price = price
                    }
                }
            })
        }
    }
    
    @IBAction func check(_ sender: UIButton) {
        guard let result = realm?.objects(ShoppingList.self).filter("name Contains[cd] %@", itemTF.text).sorted(byKeyPath: "name", ascending: true) else { return }
        
        result.forEach({ list in
            searchItem.append(list)
        })
        searching = true
        shoppingListTB.reloadData()
        print(result)
    }
}

//MARK: extension ---------------------------------------------------------------------------
// tableView
class ShoppingListCell: UITableViewCell {
    @IBOutlet weak var itemLB: UILabel!
    @IBOutlet weak var priceLB: UILabel!
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let items = item else { return 0 }
        
        if searching {
            return searchItem.count
        }
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ShoppingListCell
        guard let items = item else { return cell }

        if searching {
            cell.itemLB.text = searchItem[indexPath.row].name
            cell.priceLB.text = searchItem[indexPath.row].price
        } else {
            cell.itemLB.text = items[indexPath.row].name
            cell.priceLB.text = items[indexPath.row].price
        }
        return cell
    }

}

// textField
extension ViewController: UITextFieldDelegate {

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        itemTF.resignFirstResponder()
        searchItem.removeAll()
        if let items = item {
            items.forEach({ list in
                searchItem.append(list)
            })
        }
        shoppingListTB.reloadData()
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let itemText = itemTF.text, let items = item {
            if itemText.count != 0 {
                searchItem.removeAll()
                guard let result = realm?.objects(ShoppingList.self).filter("name Contains[cd] %@", itemTF.text).sorted(byKeyPath: "name", ascending: true) else { return false }
                result.forEach({ list in
                    searchItem.append(list)
                })
            }
        }
        shoppingListTB.reloadData()
        return true
    }
    
}


