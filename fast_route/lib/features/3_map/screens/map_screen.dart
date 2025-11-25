import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../services/location_service.dart';
import '../../2_agenda/providers/scheduler_provider.dart';
import '../../../models/appointment_model.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

Future<void>? _locationFuture;

class _MapScreenState extends State<MapScreen> {
  LatLng _initialCenter = const LatLng(-22.9068, -43.1729);
  double _zoom = 13.0;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _locationFuture = _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    final locationService = context.read<LocationService>();
    final position = await locationService.getCurrentLocation();

    if (position != null) {
      setState(() {
        _currentPosition = position;
        _initialCenter = LatLng(position.latitude, position.longitude);
        _zoom = 15.0;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Não foi possível obter a localização atual.")),
      );
    }
  }

  Marker _buildUserMarker() {
    if (_currentPosition == null) {
      return Marker(point: _initialCenter, child: Container());
    }

    return Marker(
      point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      width: 40,
      height: 40,
      child: const Icon(
        Icons.my_location,
        color: AppColors.textPurple,
        size: 30,
      ),
    );
  }

  List<Marker> _buildAppointmentMarkers(List<AppointmentModel> appointments) {
    return appointments.map((appointment) {
      return Marker(
        point: LatLng(appointment.latitude, appointment.longitude),
        width: 80,
        height: 80,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                appointment.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(
              Icons.location_on,
              color: AppColors.textPurple,
              size: 30,
            ),
          ],
        )
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentsStream = context.watch<AgendaProvider>().myAppointmentsStream;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mapa"),
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPurple,
        actions: [
          IconButton(
            onPressed: _fetchCurrentLocation, 
            tooltip: 'Voltar à sua Localização',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder( // <--- ENVOLVE O CONTEÚDO PARA ESPERAR PELO GPS
        future: _locationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mostra carregando enquanto espera a localização inicial
            return const Center(child: CircularProgressIndicator()); 
          }
          
          // Uma vez que o Future termina, o mapa renderiza (mesmo que o GPS tenha falhado, ele usa o fallback)
          return StreamBuilder<List<AppointmentModel>>( // Seu StreamBuilder existente para compromissos
            stream: appointmentsStream,
            builder: (context, snapshot) {
              final appointments = snapshot.data ?? [];
              
              List<Marker> markers = [];
              markers.add(_buildUserMarker());
              markers.addAll(_buildAppointmentMarkers(appointments));

              return FlutterMap(
                options: MapOptions(
                  initialCenter: _initialCenter,
                  initialZoom: _zoom,
                  maxZoom: 18.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.fast_route',
                  ),
                  
                  MarkerLayer(
                    markers: markers,
                  ),
                ],
              );
            },
          );
        }
      )
    );
  }
}