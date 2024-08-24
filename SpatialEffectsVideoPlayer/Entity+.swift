import RealityKit
import Foundation

extension Entity {

    func getFirstChildByName(name: String) -> Entity? {
        self.children.first(where: { $0.name == name })
    }

    var opacity: Float {
        get {
            return components[OpacityComponent.self]?.opacity ?? 1
        }
        set {
            if !components.has(OpacityComponent.self) {
                components[OpacityComponent.self] = OpacityComponent(opacity: newValue)
            } else {
                components[OpacityComponent.self]?.opacity = newValue
            }
        }
    }

    @MainActor
    func setOpacity(_ opacity: Float, animated: Bool, duration: TimeInterval = 0.2, delay: TimeInterval = 0, completion: (() -> Void) = {}) async {
        guard animated, let scene else {
            self.opacity = opacity
            return
        }

        if !components.has(OpacityComponent.self) {
            components[OpacityComponent.self] = OpacityComponent(opacity: 1.0)
        }

        let animation = FromToByAnimation(name: "Entity/setOpacity", to: opacity, duration: duration, timing: .linear, isAdditive: false, bindTarget: .opacity, delay: delay)

        do {
            let animationResource: AnimationResource = try .generate(with: animation)
            let animationPlaybackController = playAnimation(animationResource)
            let filtered = scene.publisher(for: AnimationEvents.PlaybackTerminated.self)
                .filter { $0.playbackController == animationPlaybackController }
            _ = filtered.values.filter { await $0.playbackController.isComplete }
            completion()
        } catch {
            print("Could not generate animation: \(error.localizedDescription)")
        }
    }
}
