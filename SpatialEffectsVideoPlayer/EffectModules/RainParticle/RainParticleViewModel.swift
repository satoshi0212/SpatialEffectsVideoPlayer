import RealityKit
import Observation
import RealityKitContent

@MainActor
@Observable
final class RainParticleViewModel: LiveSequenceOperation {

    private var rootEntity: Entity?

    func setup(entity: Entity) {
        rootEntity = entity
        rootEntity?.opacity = 0.0

        let skyBoxEntity = Entity()
        skyBoxEntity.components.set(ModelComponent(
            mesh: .generateSphere(radius: 1000),
            materials: [UnlitMaterial(color: .black)]
        ))
        skyBoxEntity.scale *= .init(x: -1, y: 1, z: 1)
        rootEntity?.addChild(skyBoxEntity)

        Task {
            if let scene = try? await Entity(named: "RainParticle", in: realityKitContentBundle) {
                let particleEntity = scene.findEntity(named: "ParticleEmitter")!
                particleEntity.name = "rainParticle"
                particleEntity.position = [0.0, 3.0, -2.0]
                rootEntity?.addChild(particleEntity)
            }
        }
    }

    func reset() {
        rootEntity?.opacity = 0.0
    }

    func play() {
        rootEntity?.getFirstChildByName(name: "rainParticle")?.isEnabled = true
    }

    func pause() {
        rootEntity?.getFirstChildByName(name: "rainParticle")?.isEnabled = false
    }

    func fadeIn() {
        Task {
            await rootEntity?.setOpacity(1.0, animated: true, duration: 1.4)
        }
    }

    func fadeOut() {
        Task {
            await rootEntity?.setOpacity(0.0, animated: true, duration: 1.4)
        }
    }
}
