import 'package:geocoding/geocoding.dart';

class GeocodingService {
  Future<Location?> getCoordinatesFromAddress(String address) async {
    try {

      String cleanAddress = address.split(',').take(3).join(',');
      print('DEBUG GEOC: Tentando buscar o endereço: $cleanAddress');

      List<Location> locations = await locationFromAddress(cleanAddress);

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
