import SwiftUI

struct MeshGradientBackground: View {
    @State private var appear = false
    @State private var appear2 = false

    private let test1 = Color(.systemBackground)
    private let test2 = Color.main.opacity(0.1)
    private let test3 = Color(.systemBackground)

    private let test4 = Color(#colorLiteral(red: 0.5566375256, green: 0.5883794427, blue: 0.9765579104, alpha: 1)).opacity(0.2)
    private let test5 = Color(.systemBackground)
    private let test6 = Color(#colorLiteral(red: 0.8037104011, green: 0.8237307668, blue: 0.8549799919, alpha: 1))

    private let test7 = Color.indigo.opacity(0.1)
    private let test8 = Color(.systemBackground)
    private let test9 = Color(.systemBackground)

    var body: some View {
        ZStack {
            MeshGradient(
                width: 3,
                height: 3,
                points: [
                    [0.0, 0.0], [appear2 ? 0.5 : 1.0, 0.0], [1.0, 0.0],
                    [0.0, 0.5], appear ? [0.1, 0.5] : [0.8, 0.2], [1.0, -0.5],
                    [0.0, 1.0], [1.0, appear2 ? 2.0 : 1.0], [1.0, 1.0]
                ],
                colors: [
                    appear2 ? test1 : test2, appear2 ? test2 : test4, test3,
                    appear ? test4 : test4, appear ? test4 : .white, appear ? test6 : .indigo,
                    appear ? test7 : test7, appear ? test8 : test8, appear2 ? test9 : test9
                ]
            )
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                appear.toggle()
            }
            withAnimation(.easeInOut(duration: 10).repeatForever(autoreverses: true)) {
                appear2.toggle()
            }
        }
    }
}

#Preview {
    MeshGradientBackground()
}
