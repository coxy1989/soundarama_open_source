//
//  Section.swift
//  Soundarama
//
//  Created by Jamie Cox on 21/04/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

struct Section<T where T: Hashable>: Hashable {
    
    let header: String
    let rows: [T]
    
    var hashValue: Int {
        
        return header.hash ^ rows.reduce(0) { $0 ^ $1.hashValue }
    }
}

func ==<T> (lhs: Section<T>, rhs: Section<T>) -> Bool {
    
    let eq_rows = zip(lhs.rows, rhs.rows).map() { $0.0 == $0.1 }.filter() { $0 == false }.count == 0
    let eq_headers = lhs.header == rhs.header
    return eq_rows && eq_headers
}
