package com.junyi.cjapi.payment.entity
@reflection
@RestSerializable
public class MchInfoDo <: ToString {
    var mchNo: String = ""
    var mchName: String = ""
    //
    // var mchShortName: String = ""
    //
    // var `type`: Int16 = 1
    //
    // var isvNo:String=""
    //
    // var contactName:String = ""
    //
    // var contactTel:String = ""
    //
    // var contactEmail:String = ""
    //
    // var initUserId:String = ""
    public func getMchNo(): String {
        return this.mchNo
    }
    public func setMchNo(mchNo: String) {
        this.mchNo = mchNo
    }
    public func getMchName(): String {
        return this.mchName
    }
    public func setMchName(mchName: String) {
        this.mchName = mchName
    }
    public func toString(): String {
        return "{mchNo:${mchNo}, mchName:${mchName}"
    }
}