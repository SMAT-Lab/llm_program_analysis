package vcard4cj
public enum DeliveryType <: ToString {
    | DOM | INTL | POSTAL | PARCEL | HOME | WORK
    public override func toString() {
        match (this) {
            case DOM => "DOM"
            case INTL => "INTL"
            case POSTAL => "POSTAL"
            case PARCEL => "PARCEL"
            case HOME => "HOME"
            case WORK => "WORK"
        }
    }
}