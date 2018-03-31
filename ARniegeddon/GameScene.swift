/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import ARKit

class GameScene: SKScene {
  var sceneView: ARSKView {
    return view as! ARSKView
  }
  
  var isWorldSetup = false
}

extension GameScene {
  override func update(_ currentTime: TimeInterval) {
    if !isWorldSetup {
      setUpWorld()
    }
    
    addLightEstimation()
  }
}

private extension GameScene {
  func setUpWorld() {
    guard let currentFrame = sceneView.session.currentFrame else {
      return
    }
    
    let transform = currentFrame.camera.transform * getTranslation()
    let anchor = ARAnchor(transform: transform)
    sceneView.session.add(anchor: anchor)
    
    isWorldSetup = true
  }

  func getTranslation() -> simd_float4x4 {
    var translation = matrix_identity_float4x4
    translation.columns.3.z = -0.3
    return translation
  }
  
  func addLightEstimation() {
    guard let currentFrame = sceneView.session.currentFrame, let lightEstimate = currentFrame.lightEstimate else {
      return
    }
    
    let neutralIntensity: CGFloat = 1000
    let ambientIntensity = min(lightEstimate.ambientIntensity, neutralIntensity)
    let blendFactor = 1 - ambientIntensity / neutralIntensity
    
    for node in children {
      if let bug = node as? SKSpriteNode {
        bug.color = .black
        bug.colorBlendFactor = blendFactor
      }
    }
  }
}
