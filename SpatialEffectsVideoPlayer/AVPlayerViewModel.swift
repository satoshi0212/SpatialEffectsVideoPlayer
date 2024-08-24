import AVKit
import SwiftUI
import Observation
import RealityKit

enum VideoAction: String {
    case none
    case c_reset
    case c_on_line_particle
    case c_off_line_particle
    case c_on_rain_particle
    case c_off_rain_particle
    case c_on_fireworks_particle
    case c_off_fireworks_particle
    case c_on_env_01
    case c_off_env_01
}

@Observable
final class AVPlayerViewModel: NSObject {

    private(set) var isPlaying: Bool = false
    private var avPlayerViewController: AVPlayerViewController?
    private var avPlayer = AVPlayer()
    private let videoURL: URL? = {
        URL(string: "https://satoshi0212.github.io/hls/resources/index.m3u8")
        //Bundle.main.url(forResource: "original2_8C325020CB6D090E", withExtension: "movpkg")
    }()

    private(set) var videoAction: VideoAction = .c_reset

    func makePlayerViewController() -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = avPlayer
        controller.delegate = self
        self.avPlayerViewController = controller
        self.avPlayerViewController?.delegate = self
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
    
    func play() {
        guard !isPlaying, let videoURL else { return }

        isPlaying = true

        let item = AVPlayerItem(url: videoURL)
        let metadataOutput = AVPlayerItemMetadataOutput(identifiers: nil)
        metadataOutput.setDelegate(self, queue: DispatchQueue.main)
        item.add(metadataOutput)
        avPlayer.replaceCurrentItem(with: item)

        avPlayer.play()
    }
    
    func reset() {
        guard isPlaying else { return }

        isPlaying = false
        avPlayer.replaceCurrentItem(with: nil)
    }
}

extension AVPlayerViewModel: AVPlayerViewControllerDelegate {

    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        reset()
    }
}

extension AVPlayerViewModel: AVPlayerItemMetadataOutputPushDelegate {

    func metadataOutput(_ output: AVPlayerItemMetadataOutput,
                        didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup],
                        from track: AVPlayerItemTrack?) {
        if let item = groups.first?.items.first,
           let metadataValue = item.value(forKey: "value") as? String {

            print("Metadata value: \(metadataValue)")
            videoAction = VideoAction(rawValue: metadataValue) ?? .none
        }
    }
}
