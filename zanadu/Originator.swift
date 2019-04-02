//
//  Originator.swift
//  Atlas
//
//  Created by Benjamin Lefebvre on 1/28/16.
//  Copyright © 2016 Atlas. All rights reserved.
//

/**
Originator

Part of Memento Design Pattern
*/
class Originator {
    
    //MARK: - Public Properties
    
    var state: RecommendationState// {
//        get {
//         //   return self.state
//        }
//        set(newState) {
//
//           // self.state = newState
//        }
//    }
    
    init(state: RecommendationState) {
        self.state = state
    }

    //MARK: - Methods
    
    func saveToMemento() -> Memento {

        return Memento(stateToSave: state)
    }

    func restoreFromMemento(_ memento: Memento ) {

        self.state = RecommendationState(original: memento.savedState())
    }

    func getState(_ memento: Memento) -> RecommendationState {
        return memento.savedState()
    }
    
    
    class Memento {
        
        fileprivate var state: RecommendationState
        
        init(stateToSave: RecommendationState) {
            self.state = RecommendationState(original: stateToSave)
        }
        
        fileprivate func savedState() -> RecommendationState {
            return state
        }
    }
}
