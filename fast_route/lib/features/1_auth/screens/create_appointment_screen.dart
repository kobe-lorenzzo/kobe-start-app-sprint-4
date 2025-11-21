import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../providers/scheduler_provider.dart';
import '../../../core/config/theme/app_colors.dart';
import '../../../services/places_service.dart';
import '../../../models/place_suggestion_model.dart';

class CreateAppointmentScreen extends StatefulWidget {
  const CreateAppointmentScreen({super.key});

  @override
  State<CreateAppointmentScreen> createState() => _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();

  double? _selectedLatitude;
  double? _selectedLongitude;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.textPurple,
              onPrimary: Colors.white,
              surface: AppColors.backgroundDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // Função para abrir o seletor de Hora
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.textPurple,
              onPrimary: Colors.white,
              surface: AppColors.backgroundDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate() || _selectedLatitude == null) return;

    final provider = context.read<AgendaProvider>();
    
    // Pega esse endereço -> Geocoding -> Latitude/Longitude -> Salva tudo no Firestore
    final success = await provider.createAppointment(
      title: _titleController.text,
      address: _addressController.text,
      date: _selectedDate,
      time: _selectedTime,
      latitude: _selectedLatitude!,
      longitude: _selectedLongitude!,
    );

    if (success && mounted) {
      Navigator.of(context).pop(); // Volta para a lista
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compromisso agendado com sucesso!")),
      );
    } else if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? "Erro desconhecido"),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  // Estilo padrão para os Inputs desta tela
  InputDecoration _buildInputDecoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white38),
      labelStyle: TextStyle(color: AppColors.textPurpleLight),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white24),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.textPurple),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AgendaProvider>().isLoading;
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Novo Compromisso"),
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: AppColors.backgroundDark,
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Título
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration("Título", hint: "Ex: Dentista"),
                  validator: (v) => v!.isEmpty ? "Informe um título" : null,
                ),
                const SizedBox(height: 16),
                
                // Endereço
                TypeAheadField<PlaceSuggestion>(
                  controller: _addressController, 

                  // 2. O BUILDER: Configura o campo de texto
                  builder: (context, controller, focusNode) => 
                    TextFormField(
                      controller: controller, 
                      focusNode: focusNode,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration(
                        "Endereço",
                        hint: "Ex: Rua, numero, cidade",
                      ).copyWith(
                        suffixIcon: const Icon(Icons.search, color: AppColors.textPurple),
                      ),
                      validator: (v) => v!.isEmpty ? "Informe um Endereço" : null,
                    ),
                  
                  suggestionsCallback: (pattern) async {
                    return await context.read<PlaceService>().getSuggestions(pattern);
                  },
                  
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      leading: const Icon(Icons.location_on, color: AppColors.textPurple),
                      title: Text(
                        suggestion.address,
                        style: const TextStyle(color: Colors.black87),
                      ),
                    );
                  },
                  
                  onSelected: (suggestion) {
                    _addressController.text = suggestion.address; 
                    _selectedLatitude = suggestion.latitude;
                    _selectedLongitude = suggestion.longitude;
                  },

                  decorationBuilder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  
                  emptyBuilder: (context) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Nenhum endereço encontrado", style: TextStyle(color: Colors.grey)),
                  ),
                  
                  loadingBuilder: (context) => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: LinearProgressIndicator(color: AppColors.textPurple),
                  ),
                ),
                const SizedBox(height: 16),

                // Seletores de Data e Hora (Linha única)
                Row(
                  children: [
                    // Data
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: _buildInputDecoration("Data"),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                dateFormat.format(_selectedDate),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const Icon(Icons.calendar_today, color: AppColors.textPurple, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Hora
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        child: InputDecorator(
                          decoration: _buildInputDecoration("Hora"),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedTime.format(context),
                                style: const TextStyle(color: Colors.white),
                              ),
                              const Icon(Icons.access_time, color: AppColors.textPurple, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                // Botão de Salvar
                if (isLoading)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPurple),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _saveForm,
                      child: const Text(
                        "Salvar Compromisso",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}