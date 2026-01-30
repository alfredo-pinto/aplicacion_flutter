import 'package:flutter/material.dart';
import '../models/tarea.dart';

class TarjetaTarea extends StatelessWidget {
  final Task task;

  final VoidCallback onDelete;        // long-press para borrar
  final VoidCallback onOpenDetails;   // abrir pantalla detalle (clic en tarjeta)
  final VoidCallback onToggleStatus;  // cambiar estado (clic en chip)

  const TarjetaTarea({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onOpenDetails,  
    required this.onToggleStatus, 
  });

  // color del icono del nivel de prioridad
  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.baja:
        return const Color.fromARGB(225, 81, 244, 69); // verde
      case Priority.media:
        return const Color.fromARGB(230, 249, 231, 40); // amarillo
      case Priority.alta:
        return const Color.fromARGB(225, 254, 46, 46); // rojo
    }
  }

  // Color de la etiqueta según el estado
  Color _statusColor(TaskStatus s) {
    switch (s) {
      case TaskStatus.pendiente:
        return const Color.fromARGB(225, 254, 46, 46); // rojo
      case TaskStatus.enProgreso:
        return const Color.fromARGB(230, 249, 231, 40); // amarillo
      case TaskStatus.completada:
        return const Color.fromARGB(225, 81, 244, 69); // verde
    }
  }

  // Texto del chip según el estado
  String _statusText(TaskStatus s) {
    switch (s) {
      case TaskStatus.pendiente:
        return 'Pendiente';
      case TaskStatus.enProgreso:
        return 'En progreso';
      case TaskStatus.completada:
        return 'Completada';
    }
  }

  // formatear FECHA (dd/mm/yyyy)
  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    return '$day/$month/$year';
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final suffix = t.period == DayPeriod.am ? 'a.m.' : 'p.m.';
    return '$hour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GestureDetector(
      // ✅ CAMBIO: tap en tarjeta abre detalle (ya NO cambia estado)
      onTap: onOpenDetails,

      // ✅ long-press borra
      onLongPress: onDelete,

      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 0,
        color: const Color.fromRGBO(255, 255, 255, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // IZQUIERDA: título + fecha/hora
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        decoration: task.status == TaskStatus.completada
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 28, color: cs.onSurface),
                        const SizedBox(width: 10),

                        // mostrar FECHA + HORA
                        Text(
                          '${_formatDate(task.dueDate)} • ${_formatTime(task.dueTime)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // DERECHA: iconos arriba + estado abajo
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Arriba: círculo, categoría, bandera
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: task.tagColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Icon(task.categoryIcon, size: 32, color: cs.onSurface),
                      const SizedBox(width: 14),
                      Icon(Icons.flag,
                          size: 32, color: _priorityColor(task.priority)),
                    ],
                  ),

                  const SizedBox(height: 14),

                  InkWell(
                    onTap: onToggleStatus,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _statusColor(task.status),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        _statusText(task.status),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
