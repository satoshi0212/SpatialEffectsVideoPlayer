import SwiftUI
import RealityKit

struct Env01View: View {

    static let viewName = "Env01View"

    @State var viewModel = Env01ViewModel()

    var body: some View {
        RealityView { content in
            let entity = Entity()
            content.add(entity)
            viewModel.setup(entity: entity)
        }
    }
}
