import 'package:fast_route/features/2_agenda/screens/create_appointment_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/scheduler_provider.dart';
import '../../1_auth/providers/auth_provider.dart';
import '../../1_auth/screens/login_screen.dart';
import '../../../models/appointment_model.dart';
import '../../../core/config/theme/app_colors.dart';

class AgendaListScreen extends StatelessWidget {
  const AgendaListScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final agendaProvider = context.read<AgendaProvider>();
    final dateFormat = DateFormat('dd/MM/yy HH:mm');

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPurple,
        title: const Text('Minha Agenda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Sair da Conta',
            onPressed: () {
              context.read<AuthProvider>().login('logout', 'logout');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }, 
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.textPurpleLight,
        child: const Icon(Icons.add),
        tooltip: 'Criar Nova Taréfa',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateAppointmentScreen()),
          );
        },
      ),

      body: StreamBuilder<List<AppointmentModel>>(
        stream: agendaProvider.myAppointmentsStream, 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erro ao caregar: ${snapshot.error}"));
          }

          final Appointments = snapshot.data ?? []; 

          if (Appointments.isEmpty) {
            return const Center(
              child: Text(
                "Nenhum compromisso agendado.\nClique no + para criar um.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppColors.textPurple),
              ),
            );
          }

          return ListView.builder(
            itemCount: Appointments.length,
            itemBuilder: (context, index) {
              final appointment = Appointments[index];

              return Dismissible(
                key: ValueKey(appointment.id),
                direction: DismissDirection.endToStart,

                background: Container(
                  color: AppColors.errorRed,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white, size: 30),
                ),

                confirmDismiss: (direction) {
                  return showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Confirmar Exclusão"),
                      content: const Text("Tem certeza que deseja remover este compromisso?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(false),
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(true),
                          child: const Text("Excluir", style: TextStyle(color: AppColors.errorRed)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  await agendaProvider.deleteAppointment(appointment.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${appointment.title} excluído.")),
                  );
                },
                
                child: Semantics(
                  hint: 'Deslize para a esquerda para excluir o compromisso.',
                  child: Card (
                    color: AppColors.backgroundDark,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_back,
                                  color: AppColors.textPurpleLight.withOpacity(0.6), 
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.delete,
                                  color: AppColors.textPurpleLight.withOpacity(0.6), 
                                  size: 20,
                                )
                              ],
                            ),
                          ),
                        ),

                      ListTile( 
                      leading: CircleAvatar(
                        backgroundColor: AppColors.textPurpleLight,
                        foregroundColor: Colors.white,
                        child: Text(appointment.dateTime.day.toString()),
                      ),

                      title: Text(
                        appointment.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            dateFormat.format(appointment.dateTime),
                            style: const TextStyle(color: AppColors.textPurpleLight),
                          ),
                          Text(
                            appointment.address,
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                        ],
                      ),
                      onTap: () {

                          }
                        ),
                      ],
                    ),
                  )
                )
              );
            }
          );
        }
      ),
    );
  }
}