//
//  ContentView.swift
//  PongGame Watch App
//
//  Created by Andres Frank on 29/12/22.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    
    @State private var scene = GameScene()
    
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
            .navigationBarHidden(true)
            .focusable()
            .digitalCrownRotation($scene.playerPosX)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
