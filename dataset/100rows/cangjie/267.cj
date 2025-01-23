package phonenumber4cj.libphonenumber.metadata
public class MetadataSourceImpl <: MetadataSource {
    private let phoneMetadataFileNameProvider: PhoneMetadataFileNameProvider
    private let bootstrappingGuard: MetadataBootstrappingGuard<CompositeMetadataContainer>
    public init(phoneMetadataFileNameProvider: PhoneMetadataFileNameProvider,
        bootstrappingGuard: MetadataBootstrappingGuard<CompositeMetadataContainer>) {
        this.phoneMetadataFileNameProvider = phoneMetadataFileNameProvider
        this.bootstrappingGuard = bootstrappingGuard
    }
    public init(phoneMetadataFileNameProvider: PhoneMetadataFileNameProvider, metadataLoader: MetadataLoader,
        metadataParser: MetadataParser) {
        this(phoneMetadataFileNameProvider,
            BlockingMetadataBootstrappingGuard<CompositeMetadataContainer>(metadataLoader, metadataParser,
                CompositeMetadataContainer()))
    }
    public func getMetadataForNonGeographicalRegion(countryCallingCode: Int32): PhonemetadataPhoneMetadata {
        if (GeoEntityUtility.isGeoEntity(countryCallingCode)) {
            throw IllegalArgumentException("${countryCallingCode}" + " calling code belongs to a geo entity")
        }
        return bootstrappingGuard
            .getOrBootstrap(phoneMetadataFileNameProvider.getFor("${countryCallingCode}"))
            .getMetadataBy(countryCallingCode)
    }
    public func getMetadataForRegion(regionCode: String): PhonemetadataPhoneMetadata {
        if (!GeoEntityUtility.isGeoEntity(regionCode)) {
            throw IllegalArgumentException("${regionCode}" + " region code is a non-geo entity")
        }
        return bootstrappingGuard
            .getOrBootstrap(phoneMetadataFileNameProvider.getFor(regionCode))
            .getMetadataBy(regionCode)
    }
}