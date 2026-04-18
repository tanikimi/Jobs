// Jobs/ConfettiView.swift
import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    // 祝福感のある絵文字を複数用意
    let emojis = ["🎉", "🎊", "👏", "🌸", "💮", "💐", "✨", "🙌", "🥳", "🤩", "🏅"]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 60個の絵文字を生成して降らせる
                ForEach(0..<120, id: \.self) { index in
                    ConfettiParticle(
                        emoji: emojis.randomElement()!,
                        geometry: geometry,
                        animate: $animate
                    )
                }
            }
        }
        // 紙吹雪が表示されている間も、後ろのボタンなどをクリックできるようにする
        .allowsHitTesting(false)
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiParticle: View {
    let emoji: String
    let geometry: GeometryProxy
    @Binding var animate: Bool

    // 発生位置、遅延、落下速度、回転、サイズを個別にランダム化
    @State private var xPosition: CGFloat = CGFloat.random(in: 0...1)
    @State private var delay: Double = Double.random(in: 0...3.0)
    @State private var duration: Double = Double.random(in: 1.5...3.5)
    @State private var rotation: Double = Double.random(in: 0...360)
    @State private var size: CGFloat = CGFloat.random(in: 24...48)

    var body: some View {
        Text(emoji)
            .font(.system(size: size))
            // 落下しながら回転させる
            .rotationEffect(.degrees(animate ? rotation + 360 : rotation))
            // 画面の上（見えない位置）から画面の下へ移動
            .position(
                x: xPosition * geometry.size.width,
                y: animate ? geometry.size.height + 100 : -100
            )
            // アニメーションの設定
            .animation(
                Animation.linear(duration: duration).delay(delay),
                value: animate
            )
    }
}
