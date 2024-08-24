import SwiftUI
import RealityKit

struct RainParticleView: View {

    static let viewName = "RainParticleView"
    
    @State var viewModel = RainParticleViewModel()

    var body: some View {
        RealityView { content in
            let entity = Entity()
            content.add(entity)
            viewModel.setup(entity: entity)
        }
    }
}
