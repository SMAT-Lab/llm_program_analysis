package maker
// ----
// ip2region database v2.0 structure
//
// +----------------+-------------------+---------------+--------------+
// | header space   | speed up index    |  data payload | block index  |
// +----------------+-------------------+---------------+--------------+
// | 256 bytes      | 512 KiB (fixed)   | dynamic size  | dynamic size |
// +----------------+-------------------+---------------+--------------+
//
// 1. padding space : for header info like block index ptr, version, release date eg ... or any other temporary needs.
// -- 2bytes: version number, different version means structure update, it fixed to 2 for now
// -- 2bytes: index algorithm code.
// -- 4bytes: generate unix timestamp (version)
// -- 4bytes: index block start ptr
// -- 4bytes: index block end ptr
//
//
// 2. data block : region or whatever data info.
// 3. segment index block : binary index block.
// 4. vector index block  : fixed index info for block index search speed up.
// space structure table:
// -- 0   -> | 1rt super block | 2nd super block | 3rd super block | ... | 255th super block
// -- 1   -> | 1rt super block | 2nd super block | 3rd super block | ... | 255th super block
// -- 2   -> | 1rt super block | 2nd super block | 3rd super block | ... | 255th super block
// -- ...
// -- 255 -> | 1rt super block | 2nd super block | 3rd super block | ... | 255th super block
//
//
// super block structure:
// +-----------------------+----------------------+
// | first index block ptr | last index block ptr |
// +-----------------------+----------------------+
//
// data entry structure:
// +--------------------+-----------------------+
// | 2bytes (for desc)	| dynamic length        |
// +--------------------+-----------------------+
//  data length   whatever in bytes
//
// index entry structure
// +------------+-----------+---------------+------------+
// | 4bytes     | 4bytes    | 2bytes        | 4 bytes    |
// +------------+-----------+---------------+------------+
//  start ip 	  end ip	  data length     data ptr
public class Maker {
    let srcHandle: File
    let dstHandle: File
    let indexPolicy: IndexPolicy
    var segments: Array<Segment> = []
    let regionPool: HashMap<String, UInt32> = HashMap<String, UInt32>()
    let vectorIndex: Array<UInt8> = Array<UInt8>(VectorIndexLength, item: 0)
    let header: Header
    public init(indexPolicy: IndexPolicy, srcFile: String, dstFile: String) {
        this.srcHandle = try {
            let f = File(srcFile, OpenOption.Open(true, false))
            if (!f.canRead()) {
                throw Exception("file can not read")
            }
            f
        } catch (e: Exception) {
            throw Exception("open source file `${srcFile}`: ${e.toString()}")
        }
        this.dstHandle = try {
            let f = File(dstFile, OpenOption.CreateOrTruncate(true))
            if (!f.canWrite()) {
                throw Exception("file can not write")
            }
            f
        } catch (e: Exception) {
            throw Exception("open target file `${dstFile}`: ${e.toString()}")
        }
        this.indexPolicy = indexPolicy
        this.header = Header(UInt16(VersionNo), this.indexPolicy, UInt32(DateTime.now().toUnixTimeStamp().toSeconds()),
            0, 0)
        this.initDbHeader()
    }
    func initDbHeader() {
        this.dstHandle.seek(Begin(0))
        this.header.writeTo(this.dstHandle)
    }
    func loadSegments() {
        let segments = ArrayList<Segment>()
        let last: Box<?Segment> = Box<?Segment>(None)
        iterateSegments(
            this.srcHandle,
            None,
            {
                seg =>
                seg.afterCheck(last.value)
                segments.append(seg)
                last.value = seg
            }
        )
        this.segments = segments.toArray()
    }
    func setVectorIndex(ip: UInt32, ptr: UInt32) {
        let il0 = (ip >> 24) & 0xFF
        let il1 = (ip >> 16) & 0xFF
        let idx = Int64(il0 * UInt32(VectorIndexCols) * UInt32(VectorIndexSize) + il1 * UInt32(VectorIndexSize))
        let sPtr = littleEndianUInt32(this.vectorIndex[idx..(idx + 4)])
        if (sPtr == 0) {
            littleEndianPutUInt32(this.vectorIndex[idx..(idx + 4)], ptr)
            littleEndianPutUInt32(this.vectorIndex[(idx + 4)..(idx + 8)], ptr + UInt32(SegmentIndexBlockSize))
        } else {
            littleEndianPutUInt32(this.vectorIndex[(idx + 4)..(idx + 8)], ptr + UInt32(SegmentIndexBlockSize))
        }
    }
    public func start() {
        this.loadSegments()
        if (this.segments.size == 0) {
            throw Exception("empty segment list")
        }
        try {
            this.dstHandle.seek(Begin(HeaderInfoLength + VectorIndexLength))
        } catch (e: Exception) {
            throw Exception("seek to data first ptr: ${e.toString()}")
        }
        for (seg in this.segments) {
            if (this.regionPool.contains(seg.region)) {
                continue
            }
            let region = seg.region.toArray()
            if (region.size > 0xFFFF) {
                throw Exception("too long region info `${seg.region}`: should be less than ${0xFFFF} bytes")
            }
            let pos = try {
                this.dstHandle.seek(Current(0))
            } catch (e: Exception) {
                throw Exception("seek to current ptr: ${e.toString()}")
            }
            try {
                this.dstHandle.write(region)
            } catch (e: Exception) {
                throw Exception("write region '${seg.region}': ${e.toString()}")
            }
            this.regionPool[seg.region] = UInt32(pos)
        }
        let indexBuff = Array<UInt8>(SegmentIndexBlockSize, item: 0)
        var (counter, startIndexPtr, endIndexPtr) = (0, -1, -1)
        for (seg in this.segments) {
            if (!this.regionPool.contains(seg.region)) {
                throw Exception("missing ptr cache for region `${seg.region}`")
            }
            let dataLen = seg.region.size
            if (dataLen == 0) {
                throw Exception("empty region info for segment '${seg}'")
            }
            let dataPtr = this.regionPool[seg.region]
            let segList = seg.split()
            for (s in segList) {
                let pos = try {
                    this.dstHandle.seek(Current(0))
                } catch (e: Exception) {
                    throw Exception("seek to segment index block: ${e.toString()}")
                }
                littleEndianPutUInt32(indexBuff[0..4], s.startIP)
                littleEndianPutUInt32(indexBuff[4..8], s.endIP)
                littleEndianPutUInt16(indexBuff[8..10], UInt16(dataLen))
                littleEndianPutUInt32(indexBuff[10..14], dataPtr)
                try {
                    this.dstHandle.write(indexBuff)
                } catch (e: Exception) {
                    throw Exception("write segment index for '${s}': ${e.toString()}")
                }
                this.setVectorIndex(s.startIP, UInt32(pos))
                counter++
                if (startIndexPtr == -1) {
                    startIndexPtr = pos
                }
                endIndexPtr = pos
            }
        }
        try {
            this.dstHandle.seek(Begin(HeaderInfoLength))
        } catch (e: Exception) {
            throw Exception("seek vector index first ptr: ${e.toString()}")
        }
        try {
            this.dstHandle.write(this.vectorIndex)
        } catch (e: Exception) {
            throw Exception("write vector index: ${e.toString()}")
        }
        try {
            this.dstHandle.seek(Begin(8))
        } catch (e: Exception) {
            throw Exception("seek segment index ptr: ${e.toString()}")
        }
        littleEndianPutUInt32(indexBuff[0..4], UInt32(startIndexPtr))
        littleEndianPutUInt32(indexBuff[4..8], UInt32(endIndexPtr))
        try {
            this.dstHandle.write(indexBuff[0..8])
        } catch (e: Exception) {
            throw Exception("write segment index ptr: ${e.toString()}")
        }
    }
    public func end() {
        this.dstHandle.close()
        this.srcHandle.close()
    }
}