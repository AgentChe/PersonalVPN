import Foundation
import Swinject

class
    MainContainer {
    static let sharedContainer = MainContainer()

    var container = Container()

    private init() {
        setup()
    }

    private func setup() {

    }
}
