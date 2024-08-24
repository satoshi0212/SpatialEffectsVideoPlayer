import RealityKit
import Observation
import RealityKitContent

@MainActor
@Observable
final class FireworksParticleViewModel: LiveSequenceOperation {

    private var rootEntity: Entity?

    func setup(entity: Entity) {
        rootEntity = entity
        rootEntity?.opacity = 0.0

        Task {
            guard let scene = try? await Entity(named: "Fireworks", in: realityKitContentBundle)
            else { return }

            rootEntity?.addChild(scene)
        }
    }

    func reset() {
        rootEntity?.opacity = 0.0
    }

    func play() {
        // 個別制御するEntityがないため何もしない
    }

    func pause() {
        // 個別制御するEntityがないため何もしない
    }

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
