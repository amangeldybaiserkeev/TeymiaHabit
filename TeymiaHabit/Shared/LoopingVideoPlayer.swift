import AVFoundation
import SwiftUI

struct LoopingVideoPlayer: UIViewRepresentable {
    let videoName: String

    func makeUIView(context: Context) -> LoopingVideoView {
        LoopingVideoView(videoName: videoName)
    }

    func updateUIView(_ uiView: LoopingVideoView, context: Context) {}

    static func dismantleUIView(_ uiView: LoopingVideoView, coordinator: ()) {
        uiView.stop()
    }
}

final class LoopingVideoView: UIView {
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    private var player: AVQueuePlayer?
    private var isStopped = false

    init(videoName: String) {
        super.init(frame: .zero)
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else { return }
            let item = AVPlayerItem(url: url)
            item.preferredMaximumResolution = CGSize(width: 480, height: 854)
            let queuePlayer = AVQueuePlayer()
            queuePlayer.automaticallyWaitsToMinimizeStalling = false
            queuePlayer.isMuted = true
            let looper = AVPlayerLooper(player: queuePlayer, templateItem: item)

            DispatchQueue.main.async { [weak self] in
                guard let self, !self.isStopped else {
                    looper.disableLooping()
                    queuePlayer.pause()
                    return
                }
                self.player = queuePlayer
                self.playerLooper = looper
                self.playerLayer.player = queuePlayer
                queuePlayer.play()
            }
        }
    }

    func stop() {
        isStopped = true
        playerLayer.player = nil
        let looper = playerLooper
        let capturedPlayer = player
        playerLooper = nil
        player = nil
        DispatchQueue.global(qos: .utility).async {
            looper?.disableLooping()
            capturedPlayer?.pause()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    required init?(coder: NSCoder) { fatalError() }
}
