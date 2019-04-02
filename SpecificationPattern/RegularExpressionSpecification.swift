import Foundation

open class RegularExpressionSpecification: CompositeSpecification {
	open let regularExpression: NSRegularExpression
	
	init(regularExpression: NSRegularExpression) {
		self.regularExpression = regularExpression
		super.init()
	}
	
	convenience init(pattern: String) {
        //var error: NSError?
        let regularExpression: NSRegularExpression?
        do {
            regularExpression = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())
        } catch let error1 as NSError {
            //error = error1
            regularExpression = nil
        }
		self.init(regularExpression: regularExpression!)
	}
	
	open override func isSatisfiedBy(_ candidate: Any?) -> Bool {
        if let s = candidate as? String {
            return regularExpression.numberOfMatches(in: s, options: NSRegularExpression.MatchingOptions(), range: NSMakeRange(0, Array(s.characters).count)) > 0
        } else {
            return false
        }
	}
}
