//
//  CharacterExt.swift
//  AAILiveness
//
//  Created by Joseph Koh on 2024/7/11.
//

import Foundation

public extension Character {
    var isEnglishLetter: Bool {
        isASCII && isLetter
    }

    var isEmailLetter: Bool {
        isASCII && ("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ@.".contains(self))
    }

    var isEnglishLetterPunctuationOrSpace: Bool {
        let allowedCharacterSet = CharacterSet.letters.union(.punctuationCharacters).union(.whitespaces)
        return self.unicodeScalars.allSatisfy { allowedCharacterSet.contains($0) }
    }
}
