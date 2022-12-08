//
//  AddNoteDelegate.swift
//  evosipova_3PW3
//
//  Created by Elizabeth on 22.11.2022.
//

import Foundation

import UIKit

protocol AddNoteDelegate: AnyObject {
    func newNoteAdded(note: ShortNote)
}
