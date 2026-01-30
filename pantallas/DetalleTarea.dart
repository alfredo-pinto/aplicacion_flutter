import 'package:flutter/material.dart';
import '../models/tarea.dart';
import 'CrearTarea.dart';

const sectionTitleColor = Color.fromRGBO(0, 0, 0, 1);
const double sectionTitleSize = 16;

/// Pantalla de detalle de una tarea.
///
/// Funcionalidades:
/// - Mostrar la información completa de una tarea (título, categoría, descripción, fecha/hora, estado).
/// - Cambiar el estado tocando la etiqueta de estado.
/// - Editar la tarea navegando a la pantalla de crear/editar.
class TaskDetailScreen extends StatefulWidget {
  // Tarea recibida desde la pantalla ListaTareas
  final Task task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  // Copia local de la tarea para poder modificarla dentro del editor
  late Task _task;

  @override
  void initState() {
    super.initState();
    // Se asigna la tarea recibida a la variable local
    _task = widget.task;
  }

  /// Tarjeta reutilizable con el mismo estilo de las tarjetas principales.
  /// Se usa para que todos los apartados del detalle se vean consistentes.
  Widget _card({required Widget child}) {
    return Card(
      elevation: 0,
      color: const Color.fromRGBO(255, 255, 255, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: child,
      ),
    );
  }

  /// Formatea una fecha a dd/mm/yyyy para mostrarla en UI.
  String _formatDate(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    return '$day/$month/$year';
  }

  /// Cambia el estado de la tarea de forma cíclica:
  /// pendiente -> en progreso -> completada -> pendiente
  ///
  /// Este método solo afecta a la copia local (_task).
  /// Cuando se vuelve atrás, se devuelve _task a la pantalla anterior.
  void _toggleStatus() {
    setState(() {
      switch (_task.status) {
        case TaskStatus.pendiente:
          _task.status = TaskStatus.enProgreso;
          break;
        case TaskStatus.enProgreso:
          _task.status = TaskStatus.completada;
          break;
        case TaskStatus.completada:
          _task.status = TaskStatus.pendiente;
          break;
      }
    });
  }

  /// Abre la pantalla de edición (CreateTaskScreen) pasándole la tarea actual.
  /// Si el usuario cancela vuelve sin guardar
  Future<void> _editTask() async {
    final updated = await Navigator.of(context).push<Task>(
      MaterialPageRoute(
        builder: (_) => CreateTaskScreen(initialTask: _task),
      ),
    );

    // Si no vuelve ninguna tarea, no se hacen cambios
    if (updated == null) return;

    setState(() {
      // Conserva el estado actual del detalle (por si se cambió tocando la etiqeuta de estado)
      updated.status = _task.status;

      // Estas asignaciones se mantienen para asegurar que no se pierden datos
      // si CreateTaskScreen no los estaba devolviendo correctamente.
      updated.description = _task.description;
      updated.dueDate = _task.dueDate;

      // Se reemplaza la tarea local por la tarea editada
      _task = updated;
    });

    // SnackBar de confirmación (si el widget sigue montado)
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cambios guardados')),
    );
  }

  /// Devuelve el color del chip según el estado.
  Color _statusColor(TaskStatus s) {
    switch (s) {
      case TaskStatus.pendiente:
        return const Color.fromARGB(225, 254, 46, 46);
      case TaskStatus.enProgreso:
        return const Color.fromARGB(230, 249, 231, 40);
      case TaskStatus.completada:
        return const Color.fromARGB(225, 81, 244, 69);
    }
  }

  /// Devuelve el texto del chip según el estado.
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Detalle de tarea'),

        // Flecha de volver: además de volver
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, _task),
        ),
      ),

      // Contenido principal en lista para permitir scroll si el texto crece
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tarjeta principal: título y categoría
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de la tarea, con tachado si está completada
                  Text(
                    _task.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,

                      // Tachado automático solo cuando el estado es completada
                      decoration: _task.status == TaskStatus.completada
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Fila con icono y texto de categoría
                  Row(
                    children: [
                      Icon(_task.categoryIcon, color: cs.onSurface),
                      const SizedBox(width: 10),
                      Text(
                        _task.category,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Tarjeta apartado descripción
            if (_task.description.trim().isNotEmpty) ...[
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título del apartado
                    Text(
                      'Descripción',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: sectionTitleColor,
                        fontSize: sectionTitleSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Texto de descripción
                    Text(
                      _task.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Tarjeta: fecha y hora de vencimiento
            _card(
              child: Row(
                children: [
                  const Icon(Icons.event),
                  const SizedBox(width: 10),

                  // Fecha formateada manualmente
                  Text(
                    _formatDate(_task.dueDate),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(width: 18),

                  const Icon(Icons.access_time),
                  const SizedBox(width: 10),

                  // Hora usando el formateo propio de TimeOfDay
                  Text(
                    _task.dueTime.format(context),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Tarjeta: estado (etiqueta pulsable)
            _card(
              child: Row(
                children: [
                  // Título del apartado estado
                  Text(
                    'Estado',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: sectionTitleColor,
                      fontSize: sectionTitleSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  // Empuja la etiqueta de estado al final de la fila
                  const Spacer(),

                  // Etiqueta clicable para cambiar estado
                  InkWell(
                    onTap: _toggleStatus,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _statusColor(_task.status),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        _statusText(_task.status),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Botón para editar la tarea
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _editTask,
                icon: const Icon(Icons.edit),
                label: const Text('Editar tarea'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
