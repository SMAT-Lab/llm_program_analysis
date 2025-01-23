package elements
//TODO: 未完全实现
public class CvTextElement <: ITextElement{
    var textSpans: ArrayList<Object>
    var yOffset: Int64
    var fillColorAnim: Bool
    var strokeColorAnim: Bool
    var strokeWidthAnim: Bool
    var stroke: Bool
    var fill: Bool
    var justifyOffset: Int64
    var currentRender: Option<String>
    var renderType: String
    var values: valuesData
    //TODO comp
    public init(data: Layer, globalData: GlobalData) {
        super(data, globalData)
        this.textSpans = ArrayList<Object>()
        this.yOffset = 0
        this.fillColorAnim = false
        this.strokeColorAnim = false
        this.strokeWidthAnim = false
        this.stroke = false
        this.fill = false
        this.justifyOffset = 0
        this.currentRender = None
        this.renderType = "canvas"
        this.values = valuesData("rgba(0,0,0,0)","rgba(0,0,0,0)", 0.0, "")
        //this.initElement(data, globalData, comp)
    }
    public func tHelper() { }
    public func buildNewText() {
        var documentData = this.textProperty.currentData
        //this.renderedLetters = createSizedArray(documentData.l ? documentData.l.length : 0);
        var hasFill = false
        if (!documentData.fc.isEmpty()) {
            hasFill = true
            this.values.fill = this.buildColor(documentData.fc)
        } else {
            this.values.fill = "rgba(0,0,0,0)"
        }
        this.fill = hasFill
        var hasStroke = false
        if (!documentData.sc.isEmpty()) {
            hasStroke = true
            this.values.stroke = this.buildColor(documentData.sc)
            this.values.sWidth = documentData.sw
        }
        var fontData = this.globalData.fontManager.getFontByName(documentData.f)
        var letters: ArrayList<Letter> = documentData.l
        //mHelper: new Matrix(),
        var matrixHelper: Matrix =  Matrix()
        this.stroke = hasStroke
        this.values.fValue = "${documentData.finalSize}" + "px " + this.globalData.fontManager.getFontByName(documentData.f).fFamily
        var len: Int64 = documentData.finalText.size
        var xPos = 0
        var yPos = 0
        var firstLine = true
        var cnt = 0
        for (i in 0..len) {
            var charData = this.globalData.fontManager.getCharData(documentData.finalText[i], fontData.fStyle, this.globalData.fontManager.getFontByName(documentData.f).fFamily)
            //shapeData = (charData && charData.data) || {};
            var shapeData = charData.data
            matrixHelper.reset()
        }
    }
}
public class valuesData {
    var fill: String
    var stroke: String
    var sWidth: Float64
    var fValue: String
    public init(fill: String, stroke: String, sWidth: Float64, fValue: String) {
        this.fill = fill
        this.stroke = stroke
        this.sWidth = sWidth
        this.fValue = fValue
    }
}