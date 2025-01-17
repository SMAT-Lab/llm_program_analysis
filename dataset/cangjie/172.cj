package drawer
from std import collection.*
from std import objectpool.*
import image.*
import color.*
import internals.model.*
import internals.imageutil.*
let m = UInt32((1 << 16) - 1)
public interface Quantizer {
    func quantize(p: color.Palette, m: Image): color.Palette
}
public enum Op <: Hashable {
    Over | Src
    public func hashCode(): Int64 {
        match (this) {
            case Over => 0
            case Src => 1
        }
    }
    public operator func ==(op: Op): Bool {
        this.hashCode() == op.hashCode()
    }
    public operator func !=(op: Op): Bool {
        !(this == op)
    }
}
public interface Drawer {
    func drawer(dst: ImageI, r: Rectangle, src: Image, sp: Point): (ImageI, Rectangle)
}
public let FloydSteinberg: Drawer = FloydSteinbergClazz()
public class FloydSteinbergClazz <: Drawer {
    public func drawer(dst: ImageI, r: Rectangle, src: Image, sp: Point): (ImageI, Rectangle) {
        var (dst0, rect0) = clip(dst, r, src, sp, nilImage, nilPoint)
        if (rect0.empty()) {
            return (dst0, rect0)
        }
        var mDst: ImageI = dst0
        var mRect: Rectangle = rect0
        return drawPaletted(mDst, mRect, src, sp, true)
    }
}
func clip(dst: ImageI, r: Rectangle, src: Image, sp: Point, mask: Image, mp: Point): (ImageI, Rectangle) {
    let orig = r.min.clone()
    var rect = r.intersect(dst.bounds())
    rect = rect.intersect(src.bounds() + (orig - sp))
    if (!(mask is NilImage)) {
        rect = rect.intersect(mask.bounds() + (orig - mp))
    }
    let dx = rect.min.x - orig.x
    let dy = rect.min.y - orig.y
    if (dx == 0 && dy == 0) {
        return (dst, rect)
    }
    sp.x += dx
    sp.y += dy
    if (!(mp is NilPoint)) {
        mp.x += dx
        mp.y += dy
    }
    return (dst, rect)
}
func processBackward(dst: Image, r: Rectangle, src: Image, sp: Point): Bool {
    dst.eq(src) && r.overlaps(r + (sp - r.min)) && (sp.y < r.min.y || (sp.y == r.min.y && sp.x < r.min.x))
}
public func draw(dst: ImageI, r: Rectangle, src: Image, sp: Point, op: Op): (ImageI, Rectangle) {
    drawMask(dst, r, src, sp, nilImage, Point(), op)
}
public func drawMask(
    dst: ImageI,
    r: Rectangle,
    src: Image,
    sp: Point,
    mask: Image,
    mp: Point,
    op: Op
): (ImageI, Rectangle) {
    var (dst0, rect0) = clip(dst, r, src, sp, mask, mp)
    if (rect0.empty()) {
        return (dst0, rect0)
    }
    var mDst: ImageI = dst0
    var mRect: Rectangle = rect0
    if (mDst is image.RGBA) {
        let dstx = (mDst as image.RGBA).getOrThrow()
        if (op == Over) {
            if (mask is NilImage) {
                if (src is image.Uniform) {
                    let src0 = (src as image.Uniform).getOrThrow()
                    let (sr, sg, sb, sa) = src0.rgba()
                    if (sa == 0xffff) {
                        return drawFillSrc(dstx, mRect, sr, sg, sb, sa)
                    } else {
                        return drawFillOver(dstx, mRect, sr, sg, sb, sa)
                    }
                } else if (src is image.RGBA) {
                    let src0 = (src as image.RGBA).getOrThrow()
                    return drawCopyOver(dstx, mRect, src0, sp)
                } else if (src is image.NRGBA) {
                    let src0 = (src as image.NRGBA).getOrThrow()
                    return drawNRGBAOver(dstx, mRect, src0, sp)
                } else if (src is image.YCbCr) {
                    let src0 = (src as image.YCbCr).getOrThrow()
                    if (drawYCbCr(dstx, mRect, src0, sp)) {
                        return (dstx, mRect)
                    }
                } else if (src is image.Gray) {
                    let src0 = (src as image.Gray).getOrThrow()
                    return drawGray(dstx, mRect, src0, sp)
                } else if (src is image.CMYK) {
                    let src0 = (src as image.CMYK).getOrThrow()
                    return drawCMYK(dstx, mRect, src0, sp)
                }
            } else if (mask is image.Alpha) {
                if (src is image.Uniform) {
                    let mask0 = (mask as image.Alpha).getOrThrow()
                    let src0 = (src as image.Uniform).getOrThrow()
                    return drawGlyphOver(dstx, mRect, src0, mask0, mp)
                }
            }
        } else {
            if (mask is NilImage) {
                if (src is image.Uniform) {
                    let src0 = (src as image.Uniform).getOrThrow()
                    let (sr, sg, sb, sa) = src0.rgba()
                    return drawFillSrc(dstx, mRect, sr, sg, sb, sa)
                } else if (src is image.RGBA) {
                    let src0 = (src as image.RGBA).getOrThrow()
                    return drawCopySrc(dstx, mRect, src0, sp)
                } else if (src is image.NRGBA) {
                    let src0 = (src as image.NRGBA).getOrThrow()
                    return drawNRGBASrc(dstx, mRect, src0, sp)
                } else if (src is image.YCbCr) {
                    let src0 = (src as image.YCbCr).getOrThrow()
                    if (drawYCbCr(dstx, mRect, src0, sp)) {
                        return (dstx, mRect)
                    }
                } else if (src is image.Gray) {
                    let src0 = (src as image.Gray).getOrThrow()
                    return drawGray(dstx, mRect, src0, sp)
                } else if (src is image.CMYK) {
                    let src0 = (src as image.CMYK).getOrThrow()
                    return drawCMYK(dstx, mRect, src0, sp)
                }
            }
        }
        return drawRGBA(dstx, mRect, src, sp, mask, mp, op)
    } else if (mDst is image.Paletted) {
        let dst0 = (mDst as image.Paletted).getOrThrow()
        if (op == Src && mask is NilImage) {
            if (src is image.Uniform) {
                let src0 = (src as image.Uniform).getOrThrow()
                let colorIndex = UInt8(dst0.palette.index(src0.c))
                var i0 = dst0.pixOffset(mRect.min.x, mRect.min.y)
                var i1 = i0 + mRect.dx()
                for (i in i0..i1) {
                    dst0.pix[i] = colorIndex
                }
                let firstRow = dst0.pix[i0..i1]
                for (_ in (mRect.min.y + 1)..mRect.max.y) {
                    i0 += dst0.stride
                    i1 += dst0.stride
                    firstRow.copyTo(dst0.pix, 0, i0, i1 - i0)
                }
                return (dst0, mRect)
            } else if (!processBackward(dst0, mRect, src, sp)) {
                return drawPaletted(dst0, mRect, src, sp, false)
            }
        }
    }
    var x0 = mRect.min.x
    var x1 = mRect.max.x
    var dx = 1
    var y0 = mRect.min.y
    var y1 = mRect.max.y
    var dy = 1
    if (processBackward(mDst, mRect, src, sp)) {
        x0 = x1 - 1
        x1 = x0 - 1
        dx = -1
        y0 = y1 - 1
        y1 = y0 - 1
        dy = -1
    }
    var out: color.RGBA64C = color.RGBA64C()
    var sy = sp.y + y0 - mRect.min.y
    var my = mp.y + y0 - mRect.min.y
    var y = y0
    while (y != y1) {
        var sx = sp.x + x0 - mRect.min.x
        var mx = mp.x + x0 - mRect.min.x
        var x = x0
        while (x != x1) {
            var ma = UInt32(m)
            if (!(mask is NilImage)) {
                let (_, _, _, a) = mask.at(mx, my).rgba()
                ma = a
            }
            if (ma == 0) {
                if (op != Over) {
                    mDst.set(x, y, color.Transparent)
                }
            } else if (ma == m && op == Src) {
                mDst.set(x, y, src.at(sx, sy))
            } else {
                let (sr, sg, sb, sa) = src.at(sx, sy).rgba()
                if (op == Src) {
                    let (dr, dg, db, da) = mDst.at(x, y).rgba()
                    let a = m - (sa * ma / m)
                    out.r = UInt16((dr * a + sr * ma) / m)
                    out.g = UInt16((dg * a + sg * ma) / m)
                    out.b = UInt16((db * a + sb * ma) / m)
                    out.a = UInt16((da * a + sa * ma) / m)
                } else {
                    out.r = UInt16(sr * ma / m)
                    out.g = UInt16(sg * ma / m)
                    out.b = UInt16(sb * ma / m)
                    out.a = UInt16(sa * ma / m)
                }
                mDst.set(x, y, out)
            }
            x += dx
            sx += dx
            mx += dx
        }
        y += dy
        sy += dy
        my += dy
    }
    (mDst, mRect)
}
@OverflowWrapping
func drawFillOver(dst: image.RGBA, r: Rectangle, sr: UInt32, sg: UInt32, sb: UInt32, sa: UInt32): (image.RGBA, Rectangle) {
    // The 0x101 is here for the same reason as in drawRGBA.
    let a = (m - sa) * 0x101
    var i0 = dst.pixOffset(r.min.x, r.min.y)
    var i1 = i0 + r.dx() * 4
    for (_ in r.min.y..r.max.y) {
        for (i in i0..i1 : 4) {
            let dr = dst.pix[i + 0]
            let dg = dst.pix[i + 1]
            let db = dst.pix[i + 2]
            let da = dst.pix[i + 3]
            dst.pix[i + 0] = UInt8((UInt32(dr) * a / m + sr) >> 8)
            dst.pix[i + 1] = UInt8((UInt32(dg) * a / m + sg) >> 8)
            dst.pix[i + 2] = UInt8((UInt32(db) * a / m + sb) >> 8)
            dst.pix[i + 3] = UInt8((UInt32(da) * a / m + sa) >> 8)
        }
        i0 += dst.stride
        i1 += dst.stride
    }
    (dst, r)
}
@OverflowWrapping
func drawFillSrc(dst: image.RGBA, r: Rectangle, sr: UInt32, sg: UInt32, sb: UInt32, sa: UInt32): (image.RGBA, Rectangle) {
    let sr8 = UInt8(sr >> 8)
    let sg8 = UInt8(sg >> 8)
    let sb8 = UInt8(sb >> 8)
    let sa8 = UInt8(sa >> 8)
    // The built-in copy function is faster than a straightforward for loop to fill the destination with
    // the color, but copy requires a slice source. We therefore use a for loop to fill the first row, and
    // then use the first row as the slice source for the remaining rows.
    var i0 = dst.pixOffset(r.min.x, r.min.y)
    var i1 = i0 + r.dx() * 4
    for (i in i0..i1 : 4) {
        dst.pix[i + 0] = sr8
        dst.pix[i + 1] = sg8
        dst.pix[i + 2] = sb8
        dst.pix[i + 3] = sa8
    }
    let firstRow = dst.pix[i0..i1]
    for (_ in (r.min.y + 1)..r.max.y) {
        i0 += dst.stride
        i1 += dst.stride
        firstRow.copyTo(dst.pix, 0, i0, firstRow.size)
    }
    (dst, r)
}
@OverflowWrapping
func drawCopyOver(dst: image.RGBA, r: Rectangle, src: image.RGBA, sp: Point): (image.RGBA, Rectangle) {
    let dx = r.dx()
    var dy = r.dy()
    var d0 = dst.pixOffset(r.min.x, r.min.y)
    var s0 = src.pixOffset(sp.x, sp.y)
    var ddelta = 0
    var sdelta = 0
    var idelta = 0
    var i0 = 0
    var i1 = 0
    if (r.min.y < sp.y || r.min.y == sp.y && r.min.x <= sp.x) {
        ddelta = dst.stride
        sdelta = src.stride
        i0 = 0
        i1 = dx * 4
        idelta = 4
    } else {
        // If the source start point is higher than the destination start point, or equal height but to the left,
        // then we compose the rows in right-to-left, bottom-up order instead of left-to-right, top-down.
        d0 += (dy - 1) * dst.stride
        s0 += (dy - 1) * src.stride
        ddelta = -dst.stride
        sdelta = -src.stride
        i0 = (dx - 1) * 4
        i1 = -4
        idelta = -4
    }
    let dpix = dst.pix
    let spix = src.pix
    while (dy > 0) {
        var i = i0
        while (i != i1) {
            let sr = UInt32(spix[s0 + i + 0]) * 0x101
            let sg = UInt32(spix[s0 + i + 1]) * 0x101
            let sb = UInt32(spix[s0 + i + 2]) * 0x101
            let sa = UInt32(spix[s0 + i + 3]) * 0x101
            let a = (m - sa) * 0x101
            dpix[d0 + i + 0] = UInt8((UInt32(dpix[d0 + i + 0]) * a / m + sr) >> 8)
            dpix[d0 + i + 1] = UInt8((UInt32(dpix[d0 + i + 1]) * a / m + sg) >> 8)
            dpix[d0 + i + 2] = UInt8((UInt32(dpix[d0 + i + 2]) * a / m + sb) >> 8)
            dpix[d0 + i + 3] = UInt8((UInt32(dpix[d0 + i + 3]) * a / m + sa) >> 8)
            i += idelta
        }
        dy--
    }
    (dst, r)
}
func drawCopySrc(dst: image.RGBA, r: Rectangle, src: image.RGBA, sp: Point): (image.RGBA, Rectangle) {
    let n = 4 * r.dx()
    var dy = r.dy()
    var d0 = dst.pixOffset(r.min.x, r.min.y)
    var s0 = src.pixOffset(sp.x, sp.y)
    var ddelta = 0
    var sdelta = 0
    if (r.min.y <= sp.y) {
        ddelta = dst.stride
        sdelta = src.stride
    } else {
        d0 += (dy - 1) * dst.stride
        s0 += (dy - 1) * src.stride
        ddelta = -dst.stride
        sdelta = -src.stride
    }
    while (dy > 0) {
        for (i in 0..n) {
            dst.pix[d0 + i] = src.pix[s0 + i]
        }
        d0 += ddelta
        s0 += sdelta
        dy--
    }
    (dst, r)
}
@OverflowWrapping
func drawNRGBAOver(dst: image.RGBA, r: Rectangle, src: image.NRGBA, sp: Point): (image.RGBA, Rectangle) {
    let i0 = (r.min.x - dst.rect.min.x) * 4
    let i1 = (r.max.x - dst.rect.min.x) * 4
    let si0 = (sp.x - src.rect.min.x) * 4
    let yMax = r.max.y - dst.rect.min.y
    var y = r.min.y - dst.rect.min.y
    var sy = sp.y - src.rect.min.y
    let dpix = dst.pix
    let spix = src.pix
    while (y != yMax) {
        let dpis = y * dst.stride
        let spis = sy * src.stride
        var i = i0
        var si = si0
        while (i < i1) {
            let sa = UInt32(spix[spis + i + 3]) * 0x101
            let sr = UInt32(spix[spis + i + 0]) * sa / 0xff
            let sg = UInt32(spix[spis + i + 1]) * sa / 0xff
            let sb = UInt32(spix[spis + i + 2]) * sa / 0xff
            let a = (m - sa) * 0x101
            dpix[dpis + i + 0] = UInt8((UInt32(dpix[dpis + i + 0]) * a / m + sr) >> 8)
            dpix[dpis + i + 1] = UInt8((UInt32(dpix[dpis + i + 1]) * a / m + sg) >> 8)
            dpix[dpis + i + 2] = UInt8((UInt32(dpix[dpis + i + 2]) * a / m + sb) >> 8)
            dpix[dpis + i + 3] = UInt8((UInt32(dpix[dpis + i + 3]) * a / m + sa) >> 8)
            i += 4
            si += 4
        }
        y++
        sy++
    }
    (dst, r)
}
@OverflowWrapping
func drawNRGBASrc(dst: image.RGBA, r: Rectangle, src: image.NRGBA, sp: Point): (image.RGBA, Rectangle) {
    let i0 = (r.min.x - dst.rect.min.x) * 4
    let i1 = (r.max.x - dst.rect.min.x) * 4
    let si0 = (sp.x - src.rect.min.x) * 4
    let yMax = r.max.y - dst.rect.min.y
    var y = r.min.y - dst.rect.min.y
    var sy = sp.y - src.rect.min.y
    let dpix = dst.pix
    let spix = src.pix
    while (y != yMax) {
        let dpis = y * dst.stride
        let spis = sy * src.stride
        var i = i0
        var si = si0
        while (i < i1) {
            let sa = UInt32(spix[spis + i + 3]) * 0x101
            let sr = UInt32(spix[spis + i + 0]) * sa / 0xff
            let sg = UInt32(spix[spis + i + 1]) * sa / 0xff
            let sb = UInt32(spix[spis + i + 2]) * sa / 0xff
            dpix[dpis + i + 0] = UInt8(sr >> 8)
            dpix[dpis + i + 1] = UInt8(sg >> 8)
            dpix[dpis + i + 2] = UInt8(sb >> 8)
            dpix[dpis + i + 3] = UInt8(sa >> 8)
            i += 4
            si += 4
        }
        y++
        sy++
    }
    (dst, r)
}
func drawGray(dst: image.RGBA, r: Rectangle, src: image.Gray, sp: Point): (image.RGBA, Rectangle) {
    let i0 = (r.min.x - dst.rect.min.x) * 4
    let i1 = (r.max.x - dst.rect.min.x) * 4
    let si0 = (sp.x - src.rect.min.x) * 1
    let yMax = r.max.y - dst.rect.min.y
    var y = r.min.y - dst.rect.min.y
    var sy = sp.y - src.rect.min.y
    let dpix = dst.pix
    let spix = src.pix
    while (y != yMax) {
        let dpis = y * dst.stride
        let spis = sy * src.stride
        var i = i0
        var si = si0
        while (i < i1) {
            let p = spix[spis + i + si]
            dpix[dpis + i + 0] = p
            dpix[dpis + i + 1] = p
            dpix[dpis + i + 2] = p
            dpix[dpis + i + 3] = 255
            i += 4
            si += 4
        }
        y++
        sy++
    }
    (dst, r)
}
func drawCMYK(dst: image.RGBA, r: Rectangle, src: image.CMYK, sp: Point): (image.RGBA, Rectangle) {
    let i0 = (r.min.x - dst.rect.min.x) * 4
    let i1 = (r.max.x - dst.rect.min.x) * 4
    let si0 = (sp.x - src.rect.min.x) * 4
    let yMax = r.max.y - dst.rect.min.y
    var y = r.min.y - dst.rect.min.y
    var sy = sp.y - src.rect.min.y
    let dpix = dst.pix
    let spix = src.pix
    while (y != yMax) {
        let dpis = y * dst.stride
        let spis = sy * src.stride
        var i = i0
        var si = si0
        while (i < i1) {
            let (sr, sg, sb) = color.CMYKToRGB(
                spix[spis + i + 0],
                spix[spis + i + 1],
                spix[spis + i + 2],
                spix[spis + i + 3]
            )
            dpix[dpis + i + 0] = sr
            dpix[dpis + i + 1] = sg
            dpix[dpis + i + 2] = sb
            dpix[dpis + i + 3] = 255
            i += 4
            si += 4
        }
        y++
        sy++
    }
    (dst, r)
}
@OverflowWrapping
func drawGlyphOver(dst: image.RGBA, r: Rectangle, src: image.Uniform, mask: image.Alpha, mp: Point): (image.RGBA,
    Rectangle) {
    var i0 = dst.pixOffset(r.min.y, r.min.y)
    var i1 = i0 + r.dx() * 4
    var mi0 = mask.pixOffset(mp.x, mp.y)
    let (sr, _, _, sa) = src.rgba()
    var y = r.min.y
    var my = mp.y
    let dpix = dst.pix
    while (y != r.max.y) {
        var i = i0
        var mi = mi0
        while (i < i1) {
            var ma = UInt32(mask.pix[mi])
            if (ma == 0) {
                i += 4
                mi++
                continue
            }
            ma |= ma << 8
            let a = (m - (sa * ma / m)) * 0x101
            dpix[i + 0] = UInt8((UInt32(dpix[i + 0]) * a + sr * ma) >> 8)
            dpix[i + 1] = UInt8((UInt32(dpix[i + 1]) * a + sr * ma) >> 8)
            dpix[i + 2] = UInt8((UInt32(dpix[i + 2]) * a + sr * ma) >> 8)
            dpix[i + 3] = UInt8((UInt32(dpix[i + 3]) * a + sr * ma) >> 8)
            i += 4
            mi++
        }
        i0 += dst.stride
        i1 += dst.stride
        mi0 += mask.stride
        y++
        my++
    }
    (dst, r)
}
@OverflowWrapping
func drawRGBA(dst: image.RGBA, r: Rectangle, src: Image, sp: Point, mask: Image, mp: Point, op: Op): (image.RGBA,
    Rectangle) {
    var x0 = r.min.x
    var x1 = r.max.x
    var dx = 1
    var y0 = r.min.y
    var y1 = r.max.y
    var dy = 1
    if (dst.eq(src) && r.overlaps(r + (sp - r.min))) {
        if (sp.y < r.min.y || sp.y == r.min.y && sp.x < r.min.x) {
            x0 = x1 - 1
            x1 = x0 - 1
            dx = -1
            y0 = y1 - 1
            y1 = y0 - 1
            dy = -1
        }
    }
    var sy = sp.y + y0 - r.min.y
    var my = mp.y + y0 - r.min.y
    var sx0 = sp.x + x0 - r.min.x
    var mx0 = mp.x + x0 - r.min.x
    var sx1 = sx0 + (x1 - x0)
    var i0 = dst.pixOffset(x0, y0)
    var di = dx * 4
    var y = y0
    let dpix = dst.pix
    while (y != y1) {
        var i = i0
        var sx = sx0
        var mx = mx0
        while (sx != sx1) {
            var ma = m
            if (!(mask is NilImage)) {
                let (_, _, _, a) = mask.at(mx, my).rgba()
                ma = a
            }
            let (sr, sg, sb, sa) = src.at(sx, sy).rgba()
            if (op == Src) {
                let a = (m - (sa * ma / m)) * 0x101
                dpix[i + 0] = UInt8((UInt32(dpix[i + 0]) * a + sr * ma) / m >> 8)
                dpix[i + 1] = UInt8((UInt32(dpix[i + 1]) * a + sr * ma) / m >> 8)
                dpix[i + 2] = UInt8((UInt32(dpix[i + 2]) * a + sr * ma) / m >> 8)
                dpix[i + 3] = UInt8((UInt32(dpix[i + 3]) * a + sr * ma) / m >> 8)
            } else {
                dpix[i + 0] = UInt8(sr * ma / m >> 8)
                dpix[i + 1] = UInt8(sg * ma / m >> 8)
                dpix[i + 2] = UInt8(sb * ma / m >> 8)
                dpix[i + 3] = UInt8(sa * ma / m >> 8)
            }
            i += di
            sx += dx
            mx += dx
        }
        y += dy
        sy += dy
        my += dy
        i0 += dy * dst.stride
    }
    (dst, r)
}
func clamp(i: Int32): Int32 {
    if (i < 0) {
        0
    } else if (i > 0xffff) {
        0xffff
    } else {
        i
    }
}
@OverflowWrapping
func sqDiff(x: Int32, y: Int32): UInt32 {
    let d = UInt32(x - y)
    (d * d) >> 2
}
func drawPaletted(dst: ImageI, r: Rectangle, src: Image, sp: Point, floydSteinberg: Bool): (ImageI, Rectangle) {
    var palette: ?Array<Array<Int32>> = None
    var pixS = 0
    var stride = 0
    if (dst is image.Paletted) {
        let p = (dst as image.Paletted).getOrThrow()
        let mPalette = Array<Array<Int32>>(p.palette.size(), {_ => Array<Int32>(4, item: 0)})
        let buf = p.palette.buf
        for (i in 0..buf.size) {
            let (rr, g, b, a) = buf[i].rgba()
            mPalette[i][0] = Int32(rr)
            mPalette[i][1] = Int32(g)
            mPalette[i][2] = Int32(b)
            mPalette[i][3] = Int32(a)
        }
        palette = mPalette
        pixS = p.pixOffset(r.min.x, r.min.y)
        stride = p.stride
    } else {
        throw Exception("dst is not image.Paletted type")
    }
    var quantErrorCurr: Array<Array<Int32>>
    var quantErrorNext: Array<Array<Int32>>
    if (floydSteinberg) {
        quantErrorCurr = Array<Array<Int32>>(r.dx() + 2, {_ => Array<Int32>(4, item: 0)})
        quantErrorNext = Array<Array<Int32>>(r.dx() + 2, {_ => Array<Int32>(4, item: 0)})
    } else {
        quantErrorCurr = Array<Array<Int32>>(0, {_ => Array<Int32>(4, item: 0)})
        quantErrorNext = Array<Array<Int32>>(0, {_ => Array<Int32>(4, item: 0)})
    }
    var pxRGBA: (Int64, Int64) -> (UInt32, UInt32, UInt32, UInt32) = {x, y => src.at(x, y).rgba()}
    if (src is image.RGBA) {
        let src0 = (src as image.RGBA).getOrThrow()
        pxRGBA = {x, y => src0.rgbaAt(x, y).rgba()}
    } else if (src is image.NRGBA) {
        let src0 = (src as image.NRGBA).getOrThrow()
        pxRGBA = {x, y => src0.nrgbaAt(x, y).rgba()}
    } else if (src is image.YCbCr) {
        let src0 = (src as image.YCbCr).getOrThrow()
        pxRGBA = {x, y => src0.ycbcrAt(x, y).rgba()}
    }
    // let out = color.RGBA64C(0, 0, 0, 0xffff)
    var y = 0
    let pixd = (dst as image.Paletted).getOrThrow().pix
    while (y != r.dy()) {
        var x = 0
        while (x != r.dx()) {
            var (sr, sg, sb, sa) = pxRGBA(sp.x + x, sp.y + y)
            var (er, eg, eb, ea) = (Int32(sr), Int32(sg), Int32(sb), Int32(sa))
            if (floydSteinberg) {
                er = clamp(er + quantErrorCurr[x + 1][0] / 16)
                eg = clamp(eg + quantErrorCurr[x + 1][1] / 16)
                eb = clamp(eb + quantErrorCurr[x + 1][2] / 16)
                ea = clamp(ea + quantErrorCurr[x + 1][3] / 16)
            }
            if (let Some(mPalette) <- palette) {
                var bestIndex = 0
                var bestSum = UInt32((1 << 32) - 1)
                for (index in 0..mPalette.size) {
                    let p = mPalette[index]
                    let sum = sqDiff(er, p[0]) + sqDiff(eg, p[1]) + sqDiff(eb, p[2]) + sqDiff(ea, p[3])
                    if (sum < bestSum) {
                        bestIndex = index
                        bestSum = sum
                        if (sum == 0) {
                            break
                        }
                    }
                }
                pixd[y * stride + x + pixS] = UInt8(bestIndex)
                if (!floydSteinberg) {
                    x++
                    continue
                }
                er -= mPalette[bestIndex][0]
                eg -= mPalette[bestIndex][1]
                eb -= mPalette[bestIndex][2]
                ea -= mPalette[bestIndex][3]
            }
            quantErrorNext[x + 0][0] += er * 3
            quantErrorNext[x + 0][1] += eg * 3
            quantErrorNext[x + 0][2] += eb * 3
            quantErrorNext[x + 0][3] += ea * 3
            quantErrorNext[x + 1][0] += er * 5
            quantErrorNext[x + 1][1] += eg * 5
            quantErrorNext[x + 1][2] += eb * 5
            quantErrorNext[x + 1][3] += ea * 5
            quantErrorNext[x + 2][0] += er * 1
            quantErrorNext[x + 2][1] += eg * 1
            quantErrorNext[x + 2][2] += eb * 1
            quantErrorNext[x + 2][3] += ea * 1
            quantErrorCurr[x + 2][0] += er * 7
            quantErrorCurr[x + 2][1] += eg * 7
            quantErrorCurr[x + 2][2] += eb * 7
            quantErrorCurr[x + 2][3] += ea * 7
            x++
        }
        if (floydSteinberg) {
            let (qec, qen) = (quantErrorNext, quantErrorCurr)
            quantErrorCurr = qen
            quantErrorNext = qec
            for (i in 0..quantErrorNext.size) {
                quantErrorNext[i] = Array<Int32>(4, item: 0)
            }
        }
        y++
    }
    (dst, r)
}