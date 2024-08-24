import RealityKit
import Observation
import RealityKitContent

@MainActor
@Observable
final class LineParticleViewModel: LiveSequenceOperation {

    private var rootEntity: Entity?

    func setup(entity: Entity) {
        rootEntity = entity
        rootEntity?.opacity = 0.0

        Task {
            guard let scene = try? await Entity(named: "LineParticle", in: realityKitContentBundle),
                  let particleEntity = scene.findEntity(named: "ParticleEmitter")
            else { return }

            particleEntity.name = "lineParticle"
            particleEntity.position = [0.0, 1.2, -0.8]
            rootEntity?.addChild(particleEntity)
        }
    }

    func reset() {
        rootEntity?.opacity = 0.0
    }

    func play() {
        rootEntity?.getFirstChildByName(name: "lineParticle")?.isEnabled = true
    }

    func pause() {
        rootEntity?.getFirstChildByName(name: "lineParticle")?.isEnabled = false
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
