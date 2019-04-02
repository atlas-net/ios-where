import Foundation

open class PredicateSpecification<T>: CompositeSpecification {
	open let predicate: (T) -> Bool
	
	init(predicate: @escaping (T) -> Bool) {
		self.predicate = predicate
		super.init()
	}
	
	open override func isSatisfiedBy(_ candidate: Any?) -> Bool {
        if let obj = candidate as? T {
            return predicate(obj)
        } else {
            return false
        }
	}
}
