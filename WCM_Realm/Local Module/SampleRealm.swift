//
//  SampleRealm.swift
//  WCM_Realm
//
//  Created by Takuji Hori on 2018/08/24.
//Copyright © 2018 Takuji Hori. All rights reserved.
//

import Foundation
import RealmSwift

class SampleRealm: Object {
    @objc dynamic var id:Int = 0
    @objc dynamic var date = Date()
    @objc dynamic var string: String = ""
    
    // Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
