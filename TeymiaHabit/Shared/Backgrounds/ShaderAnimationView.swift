import SwiftUI

struct ShaderAnimationView: View {
    private let startDate = Date()

    var body: some View {
        TimelineView(.animation) { timeline in
            let elapsedTime = timeline.date.timeIntervalSince(startDate)
            GeometryReader { geometry in
                Rectangle().fill(.black)
                    .colorEffect(
                        ShaderLibrary.shaderAnimation(
                            .float2(geometry.size.width, geometry.size.height),
                            .float(Float(elapsedTime))
                        )
                    )
            }
        }.ignoresSafeArea()
    }
}

#Preview {
    ShaderAnimationView()
}
