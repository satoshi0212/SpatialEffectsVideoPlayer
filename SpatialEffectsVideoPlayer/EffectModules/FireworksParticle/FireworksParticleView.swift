import SwiftUI
import RealityKit

struct FireworksParticleView: View {

    static let viewName = "FireworksParticleView"

    @State var viewModel = FireworksParticleViewModel()

    var body: some View {
        RealityView { content in
            let entity = Entity()
            content.add(entity)
            viewModel.setup(entity: entity)
        }
    }
}
