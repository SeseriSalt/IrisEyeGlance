//
//  WinkDiscrimination.swift
//  IrisEyeGlance
//
//  Created by 矢田翔大 on 2023/07/27.
//

import Foundation

extension ViewController {
    func winkDitect() -> (WINK_IKITCH_MAX: Float, WINK_IKITCH_MIN: Float) {
        // 距離から次のフレームの閾値の導出
        winkIkichiMaxNext = -0.01244 * defDepth + 9.524
        winkIkichiMinNext = -winkIkichiMaxNext
        heightIkichiNext = -0.03 * defDepth + 23
        
        // 判別に用いる閾値の決定
        let WINK_IKITCH_MAX: Float = determinedIkichiMax
        let WINK_IKITCH_MIN: Float = determinedIkichiMin
//        let HEIGHT_DIFF_IKICHI: Float = determinedIkichiHeight
        
        // 左目のWink判別
        if (winkFlag == 0 && lrDiff < WINK_IKITCH_MIN && frameNum > 15 && frameNum - distWinkNum > 6 && frameNum - distBrinkNum > 6) {
            winkFlag = 1
            minDiff = lrDiff
            peakPrev = lrDiffPrev
            minPeakFrameNum = frameNum
            firstPoint = frameNum
        }
        else if (winkFlag == 1 && lrDiff < minDiff) {
            minDiff = lrDiff
            peakPrev = lrDiffPrev
            minPeakFrameNum = frameNum
        }
        else if (winkFlag == 1 && lrDiff >= minDiff) {
            if (peakNext == 0.0) {
                peakNext = lrDiff
            }
            if (moveMissjudgeFlag == 0 && peakPrev * minDiff < 0 && peakNext * minDiff < 0) {
                moveMissjudgeFlag = 1   // 他の動作による誤判別の検知
            }
            else if (lrDiff > WINK_IKITCH_MIN) {
                winkFlag = 2
                peakPrev = 0
                peakNext = 0
                moveMissjudgeFlag = 0
            }
            else {
                moveMissjudgeFlag = -1 // wink閾値判定の継続
            }
        }
        // Flagが1のフレームから3フレームで1,2,3と上がる時、2のまま放置する→この現象は閉じた時の反動が出てるだけ。その後ちゃんと反対のピークが来るのでその時判別する。
        else if (winkFlag == 2 && lrDiff > WINK_IKITCH_MAX && frameNum - minPeakFrameNum != 2) {
            winkFlag = 3
            maxDiff = lrDiff
            maxPeakFrameNum = frameNum
        }
        else if (winkFlag == 3 && lrDiff > maxDiff) {
            maxDiff = lrDiff
            maxPeakFrameNum = frameNum
        }
        else if (winkFlag == 3 && lrDiff < WINK_IKITCH_MAX) {
            winkFlag = 4
        }
//            else if (frameNum - distFrameNum > 6 && heightAvg5 < -HEIGHT_DIFF_IKICHI && lrDiff > WINK_IKITCH_MAX) {
//                winkFlag = 4
//                lateWinkFlag = 1
//                DispatchQueue.main.async {
//                    self.lateFlagLabel.text = "Late Left"
//                    self.secondPeak.textColor = UIColor.blue
//                }
//            }
        
        // 右目のWink判別
        if (winkFlag == 0 && lrDiff > WINK_IKITCH_MAX && frameNum > 15 && frameNum - distWinkNum > 6 && frameNum - distBrinkNum > 6) {
            winkFlag = -1
            maxDiff = lrDiff
            peakPrev = lrDiffPrev
            maxPeakFrameNum = frameNum
            firstPoint = frameNum
        }
        else if (winkFlag == -1 && lrDiff > maxDiff) {
            maxDiff = lrDiff
            peakPrev = lrDiffPrev
            maxPeakFrameNum = frameNum
        }
        else if (winkFlag == -1 && lrDiff <= maxDiff) {
            if (peakNext == 0) {
                peakNext = lrDiff
            }
            
            if (moveMissjudgeFlag == 0 && peakPrev * maxDiff < 0 && peakNext * maxDiff < 0) {
                moveMissjudgeFlag = 1   // 他の動作による誤判別の検知
            }
            else if (lrDiff < WINK_IKITCH_MAX) {
                winkFlag = -2
                peakPrev = 0
                peakNext = 0
                moveMissjudgeFlag = 0
            }
            else {
                moveMissjudgeFlag = -1 // wink閾値判定の継続
            }
        }
        // Flagが-1のフレームから3フレームで1,-2,-3と上がる時、-2のまま放置する→この現象は閉じた時の反動が出てるだけ。その後ちゃんと反対のピークが来るのでその時判別する。
        else if (winkFlag == -2 && lrDiff < WINK_IKITCH_MIN && frameNum - maxPeakFrameNum != 2) {
            winkFlag = -3
            minDiff = lrDiff
            minPeakFrameNum = frameNum
        }
        else if (winkFlag == -3 && lrDiff < minDiff) {
            minDiff = lrDiff
            minPeakFrameNum = frameNum
        }
        else if (winkFlag == -3 && lrDiff > WINK_IKITCH_MIN) {
            winkFlag = -4
        }
//            else if (frameNum - distFrameNum > 6 && heightAvg5 > HEIGHT_DIFF_IKICHI && lrDiff < WINK_IKITCH_MIN) {
//                winkFlag = -4
//                lateWinkFlag = 1
//                DispatchQueue.main.async {
//                    self.lateFlagLabel.text = "Late Right"
//                    self.secondPeak.textColor = UIColor.red
//                }
//            }
        
        
        // wink
        if (winkFlag == 4 || winkFlag == -4) {
            // ピーク感覚が5フレーム以上10フレーム以下の時、wink入力判定
            if (abs(maxPeakFrameNum - minPeakFrameNum) >= 4 || lateWinkFlag == 1) {
                //                if (abs(maxPeakFrameNum - minPeakFrameNum) >= 5 && abs(maxPeakFrameNum - minPeakFrameNum) <= 10 || lateWinkFlag == 1) {
                inputLabelFlag = winkFlag == 4 ? 1 : 2
                winkFlag = 0
                lateWinkFlag = 0
                minDiff = 0
                maxDiff = 0
                maxPeakFrameNum = 0
                minPeakFrameNum = 0
                distWinkNum = frameNum
                selectionDiscernment(vowelNumber: 0) //ランドマークによる領域選択
            }
        }
        
        // 他の動作による誤判別の場合の初期化
        if (moveMissjudgeFlag == 1) {
            winkFlag = 0
            lateWinkFlag = 0
            maxDiff = 0
            minDiff = 0
            maxPeakFrameNum = 0
            minPeakFrameNum = 0
            peakPrev = 0
            peakNext = 0
        }
        
        // ピーク感覚が長すぎる時の初期化
        if (winkFlag != 0 && frameNum - firstPoint > 13) {
            winkFlag = 0
            lateWinkFlag = 0
            maxDiff = 0
            minDiff = 0
            maxPeakFrameNum = 0
            minPeakFrameNum = 0
            peakPrev = 0
            peakNext = 0
            moveMissjudgeFlag = 0
        }
        
        // ピーク間隔が短すぎる時の初期化
        if ((winkFlag == 4 || winkFlag == -4) && (frameNum - firstPoint < 5 || abs(maxPeakFrameNum - minPeakFrameNum) < 4)) {
            // frameNum - firstPoint < 5 いる？
            winkFlag = 0
            lateWinkFlag = 0
            maxDiff = 0
            minDiff = 0
            maxPeakFrameNum = 0
            minPeakFrameNum = 0
            peakPrev = 0
            peakNext = 0
            moveMissjudgeFlag = 0
            distInitNum = frameNum
        }
        return(WINK_IKITCH_MAX, WINK_IKITCH_MIN)
    }
}
