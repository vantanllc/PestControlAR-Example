//
//  GameViewController+ARSKViewDelegate.swift
//  ARniegeddon
//
//  Created by Thinh Luong on 3/31/18.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import ARKit

extension GameViewController: ARSKViewDelegate {
  func session(_ session: ARSession, didFailWithError error: Error) {
    print("Session Failed - probably due to lack of camera access")
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    print("Session interrupted")
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    print("Session resumed")
    sceneView.session.run(session.configuration!, options: [
      .removeExistingAnchors,
      .resetTracking
      ])
  }
}
