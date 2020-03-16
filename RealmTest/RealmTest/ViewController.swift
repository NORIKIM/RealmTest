//
//  ViewController.swift
//  RealmTest
//
//  Created by 김지나 on 2020/03/16.
//  Copyright © 2020 김지나. All rights reserved.
//

import UIKit
import RealmSwift

/*class TestModel: Object {
    @objc dynamic var name = ""
    @objc dynamic var number = 0
}*/
class Player: Object {
    @objc dynamic var name = ""
    @objc dynamic var position = ""
    @objc dynamic var age = Int()
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm()
        /*let person = TestModel()
        
        person.name = "Kim"
        person.number = 7
        
        try! realm.write {
            realm.add(person)
        }
        
        //realm 설치 경로를 알려준다.
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        print(documentsDirectory)
        
        let model = realm.objects(TestModel.self)
        /*Results<TestModel> <0x7ffa3bc03de0> (
            [0] TestModel {
                name = Kim;
                number = 7;
            },
            [1] TestModel {
                name = Kim;
                number = 7;
            }
        )*/*/
        
        let park = Player()
        park.name = "Kim"
        park.position = "CF"
        park.age = 33
        
        do {
            try realm.write {
                realm.add(park)
            }
        } catch {
            print("Error Add \(error)")
        }
        
        // realm 데이터베이스를 불러옴, 반환값은 Results<>타입의 값으로 반환
        var player: Results<Player>
        player = realm.objects(Player.self)
        
        var playerList = player
        playerList = playerList.filter("name Contains[cd] %@", "kim").sorted(byKeyPath: "name", ascending: true)
        
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            return documentsDirectory
        }
        print(getDocumentsDirectory())
    }
}
