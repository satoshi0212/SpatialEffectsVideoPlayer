import RealityKit
import Observation
import RealityKitContent

@MainActor
@Observable
final class Env01ViewModel: LiveSequenceOperation {

    private var rootEntity: Entity?

    func setup(entity: Entity) {
        rootEntity = entity
        rootEntity?.opacity = 0.0

        Task {
            guard let scene = try? await Entity(named: "Env_01", in: realityKitContentBundle) else { return }
            scene.name = "env_01"
            rootEntity?.addChild(scene)
        }
    }

    func reset() {
        rootEntity?.opacity = 0.0
    }

    func play() { }

    func pause() { }

    func fadeIn() {
        Task {
            await rootEntity?.setOpacity(1.0, animated: true, duration: 0.4)
        }
    }

    func fadeOut() {
        Task {
            await rootEntity?.setOpacity(0.0, animated: true, duration: 0.4)
        }
    }
}
