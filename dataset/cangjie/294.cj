package parser
class KeyframeParser {
    static let NAMES: Array<String> = [
        "t",  // 0
        "s",  // 1
        "e",  // 2
        "o",  // 3
        "i",  // 4
        "h",  // 5
        "to", // 6
        "ti"  // 7
    ]
    static let INTERPOLATOR_NAMES: Array<String> = [
        "x",  // 0
        "y"   // 1
    ]
    static func parse<T>(reader: JsonValue, valueParser: ValueParser<T>, animated: Bool):
                            Keyframe<T> where T <: ToString  {
        if (animated) {
            return parseKeyframe<T>(reader, valueParser)
        } else {
            return parseStaticValue<T>(reader, valueParser)
        }
    }
    private static func parseKeyframe<T>(reader: JsonValue, valueParser: ValueParser<T>):
                                            Keyframe<T> where T <: ToString  {
        var cp1: PointF = PointF()
        var cp2: PointF = PointF()
        var startFrame: Float64 = 0.0
        var startValue: Option<T> = Option<T>.None
        var endValue: Option<T> = Option<T>.None
        var hold: Int64 = 0
        // Only used by PathKeyframe
        var pathCp1: Array<Float64> = Array<Float64>()
        var pathCp2: Array<Float64> = Array<Float64>()
        let jo: JsonObject = reader.asObject()
        if (let Some(v) <- jo.get(NAMES[0])) { // t
            startFrame = v.asFloat().getValue()
        }
        if (let Some(v) <- jo.get(NAMES[1])) { // s
            if (equalsJsonKind(v.kind(), JsonKind.JsArray)) {
                let ja: JsonArray = v.asArray()
                let len: Int64 = ja.size()
                if (len > 0) {
                    let jsonValue: JsonValue = ja[0]
                    let jk: JsonKind = jsonValue.kind()
                    if (equalsJsonKind(jk, JsonKind.JsObject)) {
                        startValue = valueParser.parse(ja[0])
                    } else {
                        startValue = valueParser.parse(v)
                    }
                }
            } else {
                startValue = valueParser.parse(v)
            }
        }
        if (let Some(v) <- jo.get(NAMES[2])) { // e
            if (equalsJsonKind(v.kind(), JsonKind.JsArray)) {
                let ja: JsonArray = v.asArray()
                let len: Int64 = ja.size()
                if (len > 0) {
                    let jsonValue: JsonValue = ja[0]
                    let jk: JsonKind = jsonValue.kind()
                    if (equalsJsonKind(jk, JsonKind.JsObject)) {
                        endValue = valueParser.parse(ja[0])
                    } else {
                        endValue = valueParser.parse(v)
                    }
                }
            } else {
                endValue = valueParser.parse(v)
            }
        }
        if (let Some(v) <- jo.get(NAMES[3])) { // o
            cp1 = JsonUtils.jsonToPoint(v)
        }
        if (let Some(v) <- jo.get(NAMES[4])) { // i
            cp2 = JsonUtils.jsonToPoint(v)
        }
        if (let Some(v) <- jo.get(NAMES[5])) { // h
            hold = v.asInt().getValue()
        }
        if (let Some(v) <- jo.get(NAMES[6])) { // to
            pathCp1 = JsonUtils.jsonToColor(v)
        }
        if (let Some(v) <- jo.get(NAMES[7])) { // ti
            pathCp2 = JsonUtils.jsonToColor(v)
        }
        let keyframe: Keyframe<T> = Keyframe<T>(
            t: startFrame,
            s: startValue,
            e: endValue,
            o: cp1,
            i: cp2,
            h: hold,
            to: pathCp1,
            ti: pathCp2
        )
        return keyframe
    }
    private static func parseStaticValue<T>(reader: JsonValue, valueParser: ValueParser<T>):
                                                Keyframe<T> where T <: ToString  {
        let value: T = valueParser.parse(reader)
        return Keyframe<T>(k: value)
    }
}