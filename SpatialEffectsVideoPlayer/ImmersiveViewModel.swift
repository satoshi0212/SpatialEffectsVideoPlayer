import SwiftUI
import RealityKit
import RealityKitContent
import OSCKit

protocol LiveSequenceOperation {
    func reset() async
    func play() async
    func pause() async
    func fadeIn() async
    func fadeOut() async
}

@MainActor
@Observable
class ImmersiveViewModel {

    private(set) var rootEntity: Entity?

    let lineParticleView: LineParticleView = .init()
    let rainParticleView: RainParticleView = .init()
    let fireworksParticleView: FireworksParticleView = .init()
    let env01View: Env01View = .init()

    private let oscClient = OSCClient()
    private let oscServer = OSCServer(port: 55535)
    private let addressSpace = OSCAddressSpace()

    @ObservationIgnored
    private lazy var effectViewModels: [String : LiveSequenceOperation] = {
        return [
            LineParticleView.viewName : self.lineParticleView.viewModel,
            RainParticleView.viewName : self.rainParticleView.viewModel,
            FireworksParticleView.viewName : self.fireworksParticleView.viewModel,
            Env01View.viewName : self.env01View.viewModel,
        ]
    }()

    func setup(entity: Entity) {
        rootEntity = entity

        let buttonEntity = ModelEntity(
            mesh: .generatePlane(width: 0.32, height: 0.14, cornerRadius: 0.6),
            materials: [UnlitMaterial(color: .white)]
        )
        buttonEntity.name = "StartButton"
        buttonEntity.position = [0.0, 1.2, -0.5]
        buttonEntity.components.set(InputTargetComponent())
        buttonEntity.generateCollisionShapes(recursive: true)
        buttonEntity.addChild(makeText(text: "Start", areaWidth: 0.32, areaHeight: 0.14, areaDepth: 0.02))
        rootEntity?.addChild(buttonEntity)

        setupOSC()
    }

    private func makeText(text: String, areaWidth: Float, areaHeight: Float, areaDepth: Float) -> ModelEntity {
        let fontSize: CGFloat = 0.06

        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.001,
            font: .systemFont(ofSize: fontSize),
            containerFrame: CGRect(origin: .zero, size: CGSize(width: CGFloat(areaWidth), height: CGFloat(areaHeight))),
            alignment: .center
        )

        let entity = ModelEntity(
            mesh: mesh,
            materials: [UnlitMaterial(color: .black)]
            //materials: [UnlitMaterial(color: .init(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5))]
            //materials: [UnlitMaterial(color: .blue)]
        )

        entity.position.x = -(areaWidth / 2)
        entity.position.y = -areaHeight + Float(fontSize / 2) + 0.005
        entity.position.z = areaDepth / 2 + 0.01

        return entity
    }

    // MARK: - Actions

    func processVideoAction(oldValue: VideoAction = .none, newValue: VideoAction = .none) {
        // avoid continuous firing of actions other than reset action
        if newValue != .c_reset && oldValue == newValue {
            return
        }

        switch newValue {
        case .none:
            break
        case .c_reset:
            resetAction()
        case .c_on_line_particle:
            resetAction()
            Task {
                await play(viewName: LineParticleView.viewName)
                await fadeIn(viewName: LineParticleView.viewName)
            }
        case .c_off_line_particle:
            Task {
                await fadeOut(viewName: LineParticleView.viewName)
            }
        case .c_on_rain_particle:
            resetAction()
            Task {
                await play(viewName: RainParticleView.viewName)
                await fadeIn(viewName: RainParticleView.viewName)
            }
        case .c_off_rain_particle:
            Task {
                await fadeOut(viewName: RainParticleView.viewName)
            }
        case .c_on_fireworks_particle:
            resetAction()
            Task {
                await play(viewName: FireworksParticleView.viewName)
                await fadeIn(viewName: FireworksParticleView.viewName)
            }
        case .c_off_fireworks_particle:
            Task {
                await fadeOut(viewName: FireworksParticleView.viewName)
            }
        case .c_on_env_01:
            resetAction()
            Task {
                await fadeIn(viewName: Env01View.viewName)
            }
        case .c_off_env_01:
            Task {
                await fadeOut(viewName: Env01View.viewName)
            }
        }
    }

    private func resetAction() {
        Task {
            await reset(viewName: LineParticleView.viewName)
            await reset(viewName: RainParticleView.viewName)
            await reset(viewName: FireworksParticleView.viewName)
            await reset(viewName: Env01View.viewName)
        }
    }

    func getTargetSequenceComponent(viewName: String) -> LiveSequenceOperation? {
        return effectViewModels[viewName] ?? nil
    }

    func reset(viewName: String) async {
        await getTargetSequenceComponent(viewName: viewName)?.reset()
    }

    func play(viewName: String) async {
        await getTargetSequenceComponent(viewName: viewName)?.play()
    }

    func pause(viewName: String) async {
        await getTargetSequenceComponent(viewName: viewName)?.pause()
    }

    func fadeIn(viewName: String) async {
        await getTargetSequenceComponent(viewName: viewName)?.fadeIn()
    }

    func fadeOut(viewName: String) async {
        await getTargetSequenceComponent(viewName: viewName)?.fadeOut()
    }

    // MARK: - OSC

    private func setupOSC() {

        addressSpace.register(localAddress: "/reset") { [weak self] _ in
            guard let self else { return }
            self.processVideoAction(newValue: .c_reset)
        }

        addressSpace.register(localAddress: "/line_on") { [weak self] _ in
            guard let self else { return }
            self.processVideoAction(newValue: .c_on_line_particle)
        }

        addressSpace.register(localAddress: "/line_off") { [weak self] _ in
            guard let self else { return }
            self.processVideoAction(newValue: .c_off_line_particle)
        }

        addressSpace.register(localAddress: "/rain_on") { [weak self] _ in
            guard let self else { return }
            self.processVideoAction(newValue: .c_on_rain_particle)
        }

        addressSpace.register(localAddress: "/rain_off") { [weak self] _ in
            guard let self else { return }
            self.processVideoAction(newValue: .c_off_rain_particle)
        }

        addressSpace.register(localAddress: "/fireworks_on") { [weak self] _ in
            guard let self else { return }
            self.processVideoAction(newValue: .c_on_fireworks_particle)
        }

        addressSpace.register(localAddress: "/fireworks_off") { [weak self] _ in
            guard let self else { return }
            self.processVideoAction(newValue: .c_off_fireworks_particle)
        }

        addressSpace.register(localAddress: "/env_01_on") { [weak self] _ in
            guard let self else { return }
            self.processVideoAction(newValue: .c_on_env_01)
        }

        addressSpace.register(localAddress: "/env_01_off") { [weak self] _ in
            guard let self else { return }
            self.processVideoAction(newValue: .c_off_env_01)
        }

        oscServer.setHandler { [weak self] message, timeTag in
            guard let self else { return }
            do {
                try self.handle(message: message, timeTag: timeTag)
            } catch {
                print(error)
            }
        }

        do {
            try oscServer.start()
        } catch {
            print(error)
        }
    }

    private func handle(message: OSCMessage, timeTag: OSCTimeTag) throws {
        let methodIDs = addressSpace.dispatch(message)
        if methodIDs.isEmpty {
            print("No method registered for:", message)
        }
    }
}
