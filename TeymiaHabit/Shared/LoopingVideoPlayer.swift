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

    init(videoName: String) {
        super.init(frame: .zero)
        guard let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") else { return }

        let item = AVPlayerItem(url: url)
        let player = AVQueuePlayer()
        self.player = player
        playerLooper = AVPlayerLooper(player: player, templateItem: item)

        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)

        player.isMuted = true
        player.play()
    }

    func stop() {
        playerLooper?.disableLooping()
        player?.pause()
        playerLayer.player = nil
        playerLooper = nil
        player = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }

    required init?(coder: NSCoder) { fatalError() }
}
