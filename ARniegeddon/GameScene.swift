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
  var sight: SKSpriteNode!
  
  let gameSize = CGSize(width: 2, height: 2)
}

extension GameScene {
  override func update(_ currentTime: TimeInterval) {
    if !isWorldSetup {
      setUpWorld()
    }
    
    addLightEstimation()
  }
  
  override func didMove(to view: SKView) {
    sight = SKSpriteNode(imageNamed: "sight")
    addChild(sight)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let location = sight.position
    let hitNodes = nodes(at: location)
    
    var hitBug: SKNode?
    for node in hitNodes {
      if node.name == "bug" {
        hitBug = node
        break
      }
    }
    
    run(Sounds.fire)
    playActionSequence(forHitBug: hitBug)
  }
}

private extension GameScene {
  func playActionSequence(forHitBug hitBug: SKNode?) {
    if let hitBug = hitBug,
      let anchor = sceneView.anchor(for: hitBug) {
      let action = SKAction.run {
        self.sceneView.session.remove(anchor: anchor)
      }
      
      let group = SKAction.group(
        [
          Sounds.hit,
          action
        ])
      let sequence = [SKAction.wait(forDuration: 0.3), group]
      hitBug.run(SKAction.sequence(sequence))
    }
  }
  
  func setUpWorld() {
    guard let currentFrame = sceneView.session.currentFrame,
      let scene = SKScene(fileNamed: "Level1")
    else {
      return
    }
    
    for node in scene.children {
      if let node = node as? SKSpriteNode {

        let transform = currentFrame.camera.transform * getTranslation(forNode: node, inScene: scene)
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
      }
    }
    
    isWorldSetup = true
  }

  func getTranslation(forNode node: SKSpriteNode, inScene scene: SKScene) -> simd_float4x4 {
    var translation = matrix_identity_float4x4
    let positionX = node.position.x / scene.size.width
    let positionY = node.position.y / scene.size.height
    translation.columns.3.x = Float(positionX * gameSize.width)
    translation.columns.3.z = -Float(positionY * gameSize.height)
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
