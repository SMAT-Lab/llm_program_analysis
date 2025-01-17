package qrcode.detector
import common.Qrcoder4cjNotFoundException
import common.ResultPointCallback
import common.BitMatrix
from std import collection.*
public class AlignmentPatternFinder {
    private var image: BitMatrix = BitMatrix();
    private var possibleCenters: ArrayList<AlignmentPattern> = ArrayList<AlignmentPattern>();
    private var startX: Int64 = 0;
    private var startY: Int64 = 0;
    private var width: Int64 = 0;
    private var height: Int64 = 0;
    private var moduleSize: Float32 = 0.0f32;
    private var crossCheckStateCount: Array<Int64> = Array<Int64>();
    private var resultPointCallback: ?ResultPointCallback = None
    init(
        image: BitMatrix,
        startX: Int64,
        startY: Int64,
        width: Int64,
        height: Int64,
        moduleSize: Float32,
        resultPointCallback: ?ResultPointCallback
    ) {
        this.image = image
        this.possibleCenters = ArrayList<AlignmentPattern>(5)
        this.startX = startX
        this.startY = startY
        this.width = width
        this.height = height
        this.moduleSize = moduleSize
        this.crossCheckStateCount = Array<Int64>(3, item: 0)
        this.resultPointCallback = resultPointCallback
    }
    func find(): AlignmentPattern {
        let startX: Int64 = this.startX;
        let height: Int64 = this.height;
        let maxJ: Int64 = startX + width
        let middleI: Int64 = startY + (height / 2)
        // We are looking for black/white/black modules in 1:1:1 ratio;
        // this tracks the number of black/white/black modules seen so far
        var stateCount: Array<Int64> = Array<Int64>(3, item: 0);
        for (iGen in 0..height) {
            // Search from middle outwards
            let iGenResult: Int64 = if ((iGen & 0x01) == 0) {
                (iGen + 1) / 2
            } else {
                -(iGen + 1) / 2
            }
            var i: Int64 = middleI + iGenResult
            stateCount[0] = 0
            stateCount[1] = 0
            stateCount[2] = 0
            var j: Int64 = startX
            // Burn off leading white pixels before anything else; if we start in the middle of
            // a white run, it doesn't make sense to count its length, since we don't know if the
            // white run continued to the left of the start point
            while (j < maxJ && !image.get(j, i)) {
                j++
            }
            var currentState: Int64 = 0;
            while (j < maxJ) {
                if (image.get(j, i)) {
                    // Black pixel
                    var res: Option<AlignmentPattern>
                    (currentState, res) = exfind(currentState, stateCount, i, j)
                    if (let Some(con) <- res) {
                        return con
                    }
                } else { // White pixel
                    if (currentState == 1) { // Counting black pixels
                        currentState++
                    }
                    //currentState++
                    stateCount[Int64(currentState)] += 1
                }
                j++
            }
            if (foundPatternCross(stateCount)) {
                let confirmed: Option<AlignmentPattern> = handlePossibleCenter(stateCount, i, maxJ);
                if (let Some(con) <- confirmed) {
                    return con
                }
            }
        }
        // Hmm, nothing we saw was observed and confirmed twice. If we had
        // any guess at all, return it.
        if (!possibleCenters.isEmpty()) {
            return possibleCenters[0]
        }
        throw Qrcoder4cjNotFoundException.getNotFoundInstance();
    }
    func exfind(currentState: Int64, stateCount: Array<Int64>, i: Int64, j: Int64): (Int64, Option<AlignmentPattern>) {
        var currentState_p = currentState
        if (currentState == 1) { // Counting black pixels
            stateCount[1] += 1
        } else {
            if (currentState_p == 2) { // A winner?
                if (foundPatternCross(stateCount)) { // Yes
                    let confirmed: Option<AlignmentPattern> = handlePossibleCenter(stateCount, i, j);
                    if (let Some(con) <- confirmed) {
                        return (0, con)
                    }
                }
                stateCount[0] = stateCount[2]
                stateCount[1] = 1
                stateCount[2] = 0
                currentState_p = 1
            } else {
                currentState_p++
                stateCount[Int64(currentState_p)] += 1
            }
        }
        return (currentState_p, None)
    }
    private static func centerFromEnd(stateCount: Array<Int64>, end: Int64): Float32 {
        return Float32(end - stateCount[2]) - Float32(stateCount[1]) / 2.0f32
    }
    private func foundPatternCross(stateCount: Array<Int64>): Bool {
        let moduleSize: Float32 = this.moduleSize;
        let maxVariance: Float32 = moduleSize / 2.0f32
        for (i in 0..3) {
            if (abs(moduleSize - Float32(stateCount[i])) >= maxVariance) {
                return false;
            }
        }
        return true;
    }
    private func crossCheckVertical(
        startI: Int64,
        centerJ: Int64,
        maxCount: Int64,
        originalStateCountTotal: Int64
    ): Float32 {
        let image: BitMatrix = this.image;
        let maxI: Int64 = image.getHeight();
        let stateCount: Array<Int64> = crossCheckStateCount
        stateCount[0] = 0
        stateCount[1] = 0
        stateCount[2] = 0
        // Start counting up from center
        var i: Int64 = startI
        while (i >= 0 && image.get(centerJ, i) && stateCount[1] <= maxCount) {
            stateCount[1] += 1
            i--
        }
        // If already too many modules in this state or ran off the edge:
        if (i < 0 || stateCount[1] > maxCount) {
            return Float32.NaN;
        }
        while (i >= 0 && !image.get(centerJ, i) && stateCount[0] <= maxCount) {
            stateCount[0] += 1
            i--
        }
        if (stateCount[0] > maxCount) {
            return Float32.NaN;
        }
        // Now also count down from center
        i = startI + 1
        while (i < maxI && image.get(centerJ, i) && stateCount[1] <= maxCount) {
            stateCount[1] += 1
            i++
        }
        if (i == maxI || stateCount[1] > maxCount) {
            return Float32.NaN;
        }
        while (i < maxI && !image.get(centerJ, i) && stateCount[2] <= maxCount) {
            stateCount[2] += 1
            i++
        }
        if (stateCount[2] > maxCount) {
            return Float32.NaN;
        }
        let stateCountTotal: Int64 = stateCount[0] + stateCount[1] + stateCount[2]
        if (5 * abs(stateCountTotal - originalStateCountTotal) >= 2 * originalStateCountTotal) {
            return Float32.NaN;
        }
        return excrossCheckVertical(stateCount, i)
    }
    private func excrossCheckVertical(stateCount: Array<Int64>, i: Int64) {
        if (foundPatternCross(stateCount)) {
            centerFromEnd(stateCount, i)
        } else {
            Float32.NaN
        }
    }
    private func handlePossibleCenter(stateCount: Array<Int64>, i: Int64, j: Int64): Option<AlignmentPattern> {
        let stateCountTotal: Int64 = stateCount[0] + stateCount[1] + stateCount[2]
        let centerJ: Float32 = centerFromEnd(stateCount, j);
        let centerI: Float32 = crossCheckVertical(i, Int64(centerJ), 2 * stateCount[1], stateCountTotal);
        if (!centerI.isNaN()) {
            let estimatedModuleSize: Float32 = Float32(stateCount[0] + stateCount[1] + stateCount[2]) / 3.0f32
            for (i in 0..possibleCenters.size) {
                // Look for about the same center and module size:
                if (possibleCenters[i].aboutEquals(estimatedModuleSize, centerI, centerJ)) {
                    return possibleCenters[i].combineEstimate(centerI, centerJ, estimatedModuleSize);
                }
            }
            // Hadn't found this before; save it
            let point: AlignmentPattern = AlignmentPattern(centerJ, centerI, estimatedModuleSize);
            possibleCenters.append(point);
            if (let Some(res) <- resultPointCallback) {
                res.foundPossibleResultPoint(point);
            }
        }
        return None
    }
}