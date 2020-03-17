//
//  ViewController.swift
//  RealmTest
//
//  Created by 김지나 on 2020/03/16.
//  Copyright © 2020 김지나. All rights reserved.
// 참고: https://jinshine.github.io/2018/11/20/iOS/Realm%20사용방법/

import UIKit
import RealmSwift

class ShoppingList: Object {
    @objc dynamic var name = ""
    @objc dynamic var price = ""
}

class ViewController: UIViewController {
    var item: Results<ShoppingList>?
    var realm: Realm?
    
    @IBOutlet weak var itemTF: UITextField!
    @IBOutlet weak var priceTF: UITextField!
    @IBOutlet weak var shoppingListTB: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        realm = try? Realm()
        
        // ShoppingList 데이터 가져옴
        item = realm?.objects(ShoppingList.self)
        
    }
    
    func inputData(database: ShoppingList) -> ShoppingList {
        if let name = itemTF.text {
            database.name = name
        }
        if let price = priceTF.text {
            database.price = price
        }
        
        return database
    }
    
    @IBAction func add(_ sender: UIButton) {
        try! realm?.write {
            realm?.add(inputData(database: ShoppingList()))
        }
    }
    
    @IBAction func deleteData(_ sender: UIButton) {
        do {
            try realm?.write {
                realm?.delete(item!)
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
        print(realm?.objects(ShoppingList.self))
    }
    
}


