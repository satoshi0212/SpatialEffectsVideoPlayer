import SwiftUI
import RealityKit

struct ImmersiveView: View {

    @Environment(AppModel.self) var appModel
    @Environment(AVPlayerViewModel.self) private var playerViewModel
    @State var immersiveViewModel = ImmersiveViewModel()

    var body: some View {
        ZStack {
            RealityView { content in
                let entity = Entity()
                content.add(entity)
                immersiveViewModel.setup(entity: entity)
            }
            .gesture(SpatialTapGesture().targetedToAnyEntity()
                .onEnded { value in
                    if value.entity.name == "StartButton" {
                        playerViewModel.play()
                    }
                }
            )
            .onChange(of: playerViewModel.videoAction, initial: true) { oldValue, newValue in
                immersiveViewModel.processVideoAction(oldValue: oldValue, newValue: newValue)
            }
            .onChange(of: playerViewModel.isPlaying, initial: false) { _, newValue in
                immersiveViewModel.rootEntity?.getFirstChildByName(name: "StartButton")?.isEnabled = !newValue
            }
            .onDisappear {
                playerViewModel.reset()
            }
            .transition(.opacity)

            // place effect views
            immersiveViewModel.lineParticleView
            immersiveViewModel.rainParticleView
            immersiveViewModel.fireworksParticleView
            immersiveViewModel.env01View
        }
    }
}
