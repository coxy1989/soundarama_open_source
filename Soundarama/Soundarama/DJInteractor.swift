//
//  DJInteractor.swift
//  Soundarama
//
//  Created by Jamie Cox on 24/01/2016.
//  Copyright © 2016 Touchpress Ltd. All rights reserved.
//

class DJInteractor: DJInput {
    
    weak var djOutput: DJOutput!
    
    let publisher = Publisher()
    
    var adapter: PublisherMessageAdapter!
    
    func start() {
        
        adapter = PublisherMessageAdapter(publisher: publisher)
        publisher.connect()
    }
}