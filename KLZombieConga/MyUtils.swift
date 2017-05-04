//
//  MyUtils.swift
//  KLZombieConga
//
//  Created by Leon Kang on 2017/4/25.
//  Copyright © 2017年 LeonKang. All rights reserved.
//

import Foundation
import CoreGraphics
import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func += (left:inout CGPoint, right: CGPoint) {
    left = left + right
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func -= (left:inout CGPoint, right: CGPoint) {
    left = left - right
}

func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

func *= (left:inout CGPoint, right: CGPoint) {
    left = left * right
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func *= (point:inout CGPoint, scalar: CGFloat) {
    point = point * scalar
}

func / (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

func /= (left:inout CGPoint, right: CGPoint) {
    left = left / right
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func /= (point:inout CGPoint, scalar: CGFloat) {
    point = point / scalar
}


#if !(arch(x86_64) || arch(arm64))
    func atan2(y: CGFloat, x:CGFloat) -> CGFloat {
        return CGFloat(atan2f(Float(y), Float(x)))
    }

    func sqrt(a: CGFloat) -> CGFloat {
        return CGFlaot(sqrtf(Float(a)))
    }
#endif

//MARK: CGPoint extenseion
extension CGPoint {
    
    func length() -> CGFloat {
        return sqrt(x * x + y * y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
    
    var angle: CGFloat {
        return atan2(y, x)
    }
}

//MARK: CGFloat extension
extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(UInt32.max))
    }
    
    static func random(min:CGFloat, max: CGFloat) -> CGFloat {
        assert(min < max)
        return CGFloat.random() * (max - min) + min
    }
}

// MARK: Music
func playBackgroundMusic(filename: String) {
    let resourceUrl = Bundle.main.url(forResource: filename, withExtension: nil)
    guard let url = resourceUrl else {
        return
    }
    
    do {
        try backgroundMusicPlayer = AVAudioPlayer(contentsOf: url)
        backgroundMusicPlayer.numberOfLoops = -1
        backgroundMusicPlayer.prepareToPlay()
        backgroundMusicPlayer.play()
    } catch {
        print("Could not create audio player!")
        return
    }
}









