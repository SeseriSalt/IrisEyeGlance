//
//  BrinkDiscrimination.swift
//  IrisEyeGlance
//
//  Created by 矢田翔大 on 2023/07/27.
//

import Foundation

extension ViewController {
    func brinkDitect() -> Float {
        let BRINK_IKICHI: Float = brinkIkichi
        
        if (brinkFlag == 0 && frameNum - distBrinkNum > 5 && leftEyelidDiff < BRINK_IKICHI && rightEyelidDiff < BRINK_IKICHI) {
            brinkFlag = 1
            brinkFirstPoint = frameNum
        }
        else if (brinkFlag == 1 && leftEyelidDiff > -BRINK_IKICHI && rightEyelidDiff > -BRINK_IKICHI && frameNum - brinkFirstPoint <= 4) {
            brinkFlag = 2
        }
        
        if (brinkFlag == 2) {
            let inputNumber = 0
            DispatchQueue.main.async {
                self.movementLabel.text = String(inputNumber)
            }
            inputResult = inputNumber
            distBrinkNum = frameNum
            allInit()
        }
        
        // 瞬きが失敗？(長すぎる)した時の初期化
        if (brinkFlag != 0 && frameNum - brinkFirstPoint > 4) {
            brinkFlag = 0
        }
        return BRINK_IKICHI
    }
}