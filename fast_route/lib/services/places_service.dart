import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/place_suggestion_model.dart';

class PlaceService {
  Future<List<PlaceSuggestion>> getSuggestions(String query) async {

    if (query.length < 3) return[];
    
      try {
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&countrycodes=br',
        );

        final response = await http.get(
          url,
          headers: {
            'User-Agent': 'FastRouteApp/1.0 (com.example.fast_route)',
          }
        );

        if (response.statusCode == 200) {
          final List data = json.decode(response.body);

        return data.map((item) {
            return PlaceSuggestion(
              address: item['display_name'] as String,
              // As coordenadas são strings no JSON do Nominatim, então usamos double.parse
              latitude: double.parse(item['lat']), 
              longitude: double.parse(item['lon']), 
            );
          }).toList();
        } else {
          print("Erro ao buscar no OpenStreetMap. Status: ${response.statusCode}");
        }

        return [];
      } catch (e) {
        print("Erro de Conexão no OpenStreetMap: $e");
        return[];
      }
  }
}