import SwiftUI
import RealityKit

struct LineParticleView: View {
    
    static let viewName = "LineParticleView"

    @State var viewModel = LineParticleViewModel()

    var body: some View {
        RealityView { content in
            let entity = Entity()
            content.add(entity)
            viewModel.setup(entity: entity)
        }
    }
}
