//
//  PlayerView.swift
//  PoseFinder
//
//  Created by tujing on 2022/09/11.
//  Copyright © 2022 Apple. All rights reserved.
//
import UIKit
import AVFoundation

class PlayerView: UIView {

  var playerLayer:AVPlayerLayer?

  override func layoutSubviews() {
    super.layoutSubviews()
    playerLayer?.frame = self.bounds
  }
}
