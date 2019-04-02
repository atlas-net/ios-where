//
//  CareTaker.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 1/29/16.
//  Copyright © 2016 Atlas. All rights reserved.
//

/**
CareTaker

Part of Memento Design Pattern
*/
class CareTaker {
    
    //MARK: - Private Properties
    fileprivate var originator: Originator
    fileprivate var currentStateIndex = 0
    
    fileprivate var savedStates: [Originator.Memento]
    
    
    //MARK: - Initializers
    
    init(state: RecommendationState) {
        originator = Originator(state: state)
        savedStates = []
    }
 
    
    //MARK: - Methods
    
    func snapshot(_ state: RecommendationState) {
        originator.state = state
        savedStates.append(originator.saveToMemento())
        currentStateIndex = savedStates.count - 1

    }
    
    func restore(_ index: Int) -> RecommendationState? {

        if index >= 0 && index < savedStates.count {
            originator.restoreFromMemento(savedStates[index])
            currentStateIndex = index
            return originator.state
        }
        return nil
    }

    func size() -> Int {
        return savedStates.count
    }
    
    func currentIndex() -> Int {
        return currentStateIndex
    }
    
    func removeAll() {
        savedStates.removeAll()
    }
}
