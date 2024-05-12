class Address {
  final String county;
  final String stateDistrict;
  final String state;
  final String postcode;
  final String country;
  final String countryCode;

  Address({
    required this.county,
    required this.stateDistrict,
    required this.state,
    required this.postcode,
    required this.country,
    required this.countryCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      county: json['county'],
      stateDistrict: json['state_district'],
      state: json['state'],
      postcode: json['postcode'],
      country: json['country'],
      countryCode: json['country_code'],
    );
  }
}

class ApiResponse {
  final int placeId;
  final String licence;
  final String poweredBy;
  final String osmType;
  final int osmId;
  final String lat;
  final String lon;
  final String displayName;
  final Address address;
  final List<String> boundingBox;

  ApiResponse({
    required this.placeId,
    required this.licence,
    required this.poweredBy,
    required this.osmType,
    required this.osmId,
    required this.lat,
    required this.lon,
    required this.displayName,
    required this.address,
    required this.boundingBox,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      placeId: json['place_id'],
      licence: json['licence'],
      poweredBy: json['powered_by'],
      osmType: json['osm_type'],
      osmId: json['osm_id'],
      lat: json['lat'],
      lon: json['lon'],
      displayName: json['display_name'],
      address: Address.fromJson(json['address']),
      boundingBox: List<String>.from(json['boundingbox']),
    );
  }
}
