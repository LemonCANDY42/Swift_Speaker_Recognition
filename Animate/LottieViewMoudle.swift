//
//  LottieView.swift
//  LottieView
//
//  Created by Kenny Zhou on 2021/8/10.
//

import SwiftUI
import Lottie

struct LottieUIView: UIViewRepresentable {
    let animationView = AnimationView()
    var filename = "voice"
    var times = 1
    
    
    func makeUIView(context: UIViewRepresentableContext<LottieUIView>) -> UIView {
        let view = UIView()

        
        let animation = Animation.named(filename)
        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(times), execute: {
            // Put your code which should be executed with a delay here
            animationView.play()
        })
        
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieUIView>) {
        
    }
    
}
