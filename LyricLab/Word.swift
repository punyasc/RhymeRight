//
//  Word.swift
//  LyricLab
//
//  Created by Punya Chatterjee on 10/2/17.
//  Copyright © 2017 Punya Chatterjee. All rights reserved.
//

import Foundation

struct Word {
    var text: String
    var syllables: Int
    init(text: String, syllables: Int) {
        self.text = text
        self.syllables = syllables
    }
}
