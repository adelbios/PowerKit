import UIKit

open class PowerPaginationModel: Hashable {
   
    open var current: Int
    open var last: Int
    open var errorMessage: String = ""
    
    public init(current: Int, last: Int) {
        self.current = current
        self.last = last
    }
    
    public static func == (lhs: PowerPaginationModel, rhs: PowerPaginationModel) -> Bool {
        return lhs.current == rhs.current
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(current)
    }
    
}
