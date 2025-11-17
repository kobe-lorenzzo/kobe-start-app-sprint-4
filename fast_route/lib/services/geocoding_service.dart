import 'package:geocoding/geocoding.dart';

class GeocodingService {
  Future<Location?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        return locations.first;
      }

      return null;
    } catch (e) {
      print("Erro na geocodificação: $e");

      return null;
    }
  }
}
