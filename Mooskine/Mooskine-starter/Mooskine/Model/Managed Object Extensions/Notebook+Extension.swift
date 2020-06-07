//
//  Notebook+Extension.swift
//  Mooskine
//
//  Created by Rudy James Jr on 6/6/20.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import CoreData

extension Notebook {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
