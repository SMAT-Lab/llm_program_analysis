package droplet.droplet
public interface Drawable {
    func getPixelMap(): PixelMap;
    func draw(isErrorPic:Bool): Unit;
    func setDrawFunc(drawFunc: (PixelMap) -> Unit): Unit
    func getType(): Int64
}
public class NoneDrawable <: Drawable {
    public override func getPixelMap(): PixelMap {
        let size: Size = Size(width: 1, height: 1)
        let arr: Array<UInt8> = Array<UInt8>(96, item: 0)
        return createPixelMap(arr, InitializationOptions(size: size))
    }
    public override func draw(isErrorPic:Bool): Unit {}
    public override func setDrawFunc(drawFunc: (PixelMap) -> Unit): Unit {}
    public override func getType(): Int64 {
        return -1
    }
}
public class PixelMapDrawable <: Drawable {
    private let pixelMap: PixelMap
    private var drawFunc: ArrayList<(PixelMap) -> Unit> = ArrayList<(PixelMap) -> Unit>()
    public init(pixelMap: PixelMap) {
        this.pixelMap = pixelMap
    }
    public override func getType(): Int64 {
        return 1
    }
    public override func getPixelMap(): PixelMap {
        return this.pixelMap
    }
    public override func draw(isErrorPic:Bool): Unit {
        if(this.drawFunc.size > 0) {
            for(f in this.drawFunc) {
                f(this.pixelMap)
            }
        }
    }
    public override func setDrawFunc(drawFunc: (PixelMap) -> Unit): Unit {
        this.drawFunc.append(drawFunc)
    }
}
public class CJResourceDrawable <: Drawable {
    private let cjResource: CJResource
    private var drawFunc: ArrayList<(CJResource,Bool) -> Unit> = ArrayList<(CJResource,Bool) -> Unit>()
     func getCJResource(): CJResource {
        return cjResource
    }
    public init(cjResource: CJResource) {
        this.cjResource = cjResource
    }
    public override func getType(): Int64 {
        return 3
    }
    public override func getPixelMap(): PixelMap {
        let size: Size = Size(width: 1, height: 1)
        let arr: Array<UInt8> = Array<UInt8>(96, item: 0)
        return createPixelMap(arr, InitializationOptions(size: size))
    }
    public override func draw(isErrorPic:Bool): Unit {
        if(this.drawFunc.size > 0) {
            for(f in this.drawFunc) {
                f(this.cjResource,isErrorPic)
            }
        }
    }
    public override func setDrawFunc(drawFunc: (PixelMap) -> Unit): Unit {
    }
     func setDrawFuncCJResource(drawFunc: (CJResource,Bool) -> Unit): Unit {
        this.drawFunc.append(drawFunc)
    }
}