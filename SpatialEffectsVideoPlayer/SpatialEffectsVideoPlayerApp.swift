import SwiftUI

@main
struct SpatialEffectsVideoPlayerApp: App {

    @State private var appModel = AppModel()
    @State private var playerViewModel = AVPlayerViewModel()
    @State private var surroundingsEffect: SurroundingsEffect? = .semiDark

    var body: some Scene {
        WindowGroup {
            if playerViewModel.isPlaying {
                AVPlayerView(viewModel: playerViewModel)
            } else {
                ContentView()
                    .environment(appModel)
            }
        }
        .windowResizability(.contentSize)
        .windowStyle(.plain)

        ImmersiveSpace(id: appModel.immersiveSpaceID) {
            ImmersiveView()
                .environment(appModel)
                .environment(playerViewModel)
                .onAppear {
                    appModel.immersiveSpaceState = .open
                }
                .onDisappear {
                    appModel.immersiveSpaceState = .closed
                }
                .preferredSurroundingsEffect(surroundingsEffect)
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
     }
}
