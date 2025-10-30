import 'package:flutter/material.dart';

class NotificationsSheet extends StatelessWidget {
  const NotificationsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final notifications = <_NotificationItem>[
      _NotificationItem(
        title: 'Rutina lista',
        body: 'Tu rutina de Pierna para mañana ya está generada y lista para revisar.',
        type: 'Rutinas',
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      _NotificationItem(
        title: 'Nuevo reto social',
        body: 'Dana te invitó al reto de cardio de la comunidad. ¡Acepta y suma XP extra!',
        type: 'Social',
        timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 20)),
      ),
      _NotificationItem(
        title: 'Recordatorio de hidratación',
        body: 'Aún te faltan 600ml para cumplir tu meta diaria.',
        type: 'Salud',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      ),
    ];

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, controller) {
        return Material(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: <Widget>[
              Container(
                width: 56,
                height: 6,
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              ListTile(
                title: Text(
                  'Notificaciones',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text('Configurar'),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(item.type.isNotEmpty ? item.type[0].toUpperCase() : '?'),
                      ),
                      title: Text(item.title),
                      subtitle: Text('${item.body}\n${_relativeTime(item.timestamp)}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.more_horiz),
                        onPressed: () {},
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _relativeTime(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours} h';
    }
    return '${difference.inDays} d';
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
  });

  final String title;
  final String body;
  final String type;
  final DateTime timestamp;
}
