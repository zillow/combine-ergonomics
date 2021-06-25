import Combine
import Foundation
import ObjectiveC.runtime

public protocol CancellableStoring: AnyObject {
    var store: Set<AnyCancellable> { get set }
}

extension NSObject: CancellableStoring {

    /// A `Set<AnyCancellable>` used to hold on to cancellable references
    public var store: Set<AnyCancellable> {
        get {
            if let store = objc_getAssociatedObject(self, &NSObject.AssociatedKeys.storeKey) {
                return store as! Set<AnyCancellable>
            } else {
                let store = Set<AnyCancellable>()
                self.store = store
                return store
            }
        }
        set {
            objc_setAssociatedObject(self,
                                     &NSObject.AssociatedKeys.storeKey,
                                     newValue,
                                     objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    // MARK: - Private

    private struct AssociatedKeys {
        static var storeKey = "CombineErgonomics.CancellableStoring.store"
    }
}
