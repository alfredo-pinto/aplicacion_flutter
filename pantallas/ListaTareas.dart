import 'package:flutter/material.dart';
import '/pantallas/CrearTarea.dart';
import '/pantallas/DetalleTarea.dart';
import '/pantallas/Bienvenida.dart';
import '/models/tarea.dart';
import '/widgets/TarjetaTarea.dart';

/// Enum que define los posibles filtros de visualización de tareas.
/// Se utiliza en la barra de chips superior.
enum TaskFilter { todas, pendientes, enProgreso, completadas }

/// Colores usados por los ChoiceChip (configuración visual)
const selectedChipColor = Color(0xFF2BB0ED);
const unselectedChipColor = Colors.white;

/// Pantalla principal de la aplicación.
/// 
/// Funcionalidades principales:
/// - Mostrar la lista de tareas.
/// - Filtrar tareas por estado.
/// - Cambiar el estado de una tarea.
/// - Crear, editar y eliminar tareas.
/// - Navegar a pantalla de detalle.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  /// Lista principal de tareas.
  /// Representa el estado central de esta pantalla.
  final List<Task> _tasks = [
    Task(
      id: 1,
      title: 'Estudiar Flutter',
      category: 'Estudio',
      description: 'Repasar navegación, filtros y estado.',
      dueDate: DateTime(2026, 1, 30),
      dueTime: const TimeOfDay(hour: 12, minute: 30),
      tagColor: const Color(0xFFE74C3C),
      categoryIcon: Icons.school,
      priority: Priority.alta,
    ),
    Task(
      id: 2,
      title: 'Comprar leche',
      category: 'Casa',
      description: '',
      dueDate: DateTime(2026, 1, 29),
      dueTime: const TimeOfDay(hour: 18, minute: 0),
      tagColor: const Color(0xFF3498DB),
      categoryIcon: Icons.shopping_cart,
      priority: Priority.media,
    ),
    Task(
      id: 3,
      title: 'Hacer ejercicio 20 min',
      category: 'Salud',
      description: 'Cardio suave + estiramientos.',
      dueDate: DateTime(2026, 1, 31),
      dueTime: const TimeOfDay(hour: 20, minute: 15),
      tagColor: const Color(0xFF9B59B6),
      categoryIcon: Icons.fitness_center,
      priority: Priority.baja,
    ),
  ];

  /// Filtro actual seleccionado en la barra de chips.
  /// Por defecto se muestran todas las tareas.
  TaskFilter _filter = TaskFilter.todas;

  /// Devuelve la lista de tareas filtrada según el estado seleccionado.
  /// Además, ordena las tareas por prioridad de estado:
  /// Pendiente → En progreso → Completada.
  List<Task> _getFilteredTasks() {
    final filtered = _tasks.where((t) {
      switch (_filter) {
        case TaskFilter.todas:
          return true;
        case TaskFilter.pendientes:
          return t.status == TaskStatus.pendiente;
        case TaskFilter.enProgreso:
          return t.status == TaskStatus.enProgreso;
        case TaskFilter.completadas:
          return t.status == TaskStatus.completada;
      }
    }).toList();

    int order(TaskStatus s) {
      switch (s) {
        case TaskStatus.pendiente:
          return 0;
        case TaskStatus.enProgreso:
          return 1;
        case TaskStatus.completada:
          return 2;
      }
    }

    filtered.sort((a, b) => order(a.status).compareTo(order(b.status)));
    return filtered;
  }

  /// Cambia el estado de una tarea de forma cíclica:
  /// Pendiente → En progreso → Completada → Pendiente.
  void _toggleStatus(Task task) {
    setState(() {
      switch (task.status) {
        case TaskStatus.pendiente:
          task.status = TaskStatus.enProgreso;
          break;
        case TaskStatus.enProgreso:
          task.status = TaskStatus.completada;
          break;
        case TaskStatus.completada:
          task.status = TaskStatus.pendiente;
          break;
      }
    });
  }

  /// Muestra un diálogo de confirmación antes de eliminar una tarea.
  /// Si el usuario confirma, la tarea se elimina de la lista.
  Future<void> _confirmDelete(Task task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: Text('¿Seguro que quieres eliminar "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      setState(() {
        _tasks.removeWhere((t) => t.id == task.id);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tarea eliminada')),
      );
    }
  }

  /// Abre la pantalla de creación de tareas.
  /// Si se recibe una tarea se añade a la lista.
  Future<void> _openCreateTask() async {
    final result = await Navigator.of(context).push<Task>(
      MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
    );

    if (result == null) return;

    final nextId = _tasks.isEmpty
        ? 1
        : (_tasks.map((t) => t.id).reduce((a, b) => a > b ? a : b) + 1);

    setState(() {
      _tasks.add(
        Task(
          id: nextId,
          title: result.title,
          category: result.category,
          description: result.description,
          dueDate: result.dueDate,
          dueTime: result.dueTime,
          tagColor: result.tagColor,
          categoryIcon: result.categoryIcon,
          priority: result.priority,
          status: result.status,
        ),
      );
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarea creada')),
    );
  }

  /// Abre la pantalla de detalle de una tarea.
  /// Si se devuelve una tarea editada, se actualiza en la lista.
  Future<void> _openTaskDetails(Task task) async {
    final updated = await Navigator.of(context).push<Task>(
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );

    if (updated == null) return;

    setState(() {
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        updated.status = _tasks[index].status;
        _tasks[index] = updated;
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarea actualizada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksToShow = _getFilteredTasks();

    final pendientes =
        tasksToShow.where((t) => t.status == TaskStatus.pendiente).toList();
    final enProgreso =
        tasksToShow.where((t) => t.status == TaskStatus.enProgreso).toList();
    final completadas =
        tasksToShow.where((t) => t.status == TaskStatus.completada).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Volver',
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            );
          },
        ),
        title: const Text('Mis Tareas'),
        actions: [
          IconButton(
            tooltip: 'Añadir tarea',
            onPressed: _openCreateTask,
            icon: const Icon(Icons.add),
          ),
        ],
      ),

      /// Cuerpo principal de la pantalla
      body: Column(
        children: [
          /// Barra superior de filtros por estado
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: TaskFilter.values.map((f) {
                  final label = switch (f) {
                    TaskFilter.todas => 'Todas',
                    TaskFilter.pendientes => 'Pendientes',
                    TaskFilter.enProgreso => 'En progreso',
                    TaskFilter.completadas => 'Completadas',
                  };

                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _filter == f,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _filter = f),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          /// Lista de tareas
          Expanded(
            child: tasksToShow.isEmpty
                ? const Center(child: Text('No hay tareas que mostrar'))
                : ListView(
                    children: [
                      if (_filter == TaskFilter.todas) ...[
                        if (enProgreso.isNotEmpty) ...[
                          _statusHeader('En progreso'),
                          ...enProgreso.map(_buildTaskCard),
                        ],
                        if (pendientes.isNotEmpty) ...[
                          _statusHeader('Pendientes'),
                          ...pendientes.map(_buildTaskCard),
                        ],
                        if (completadas.isNotEmpty) ...[
                          _statusHeader('Completadas'),
                          ...completadas.map(_buildTaskCard),
                        ],
                      ] else ...tasksToShow.map(_buildTaskCard),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta de tarea
  Widget _buildTaskCard(Task task) {
    return TarjetaTarea(
      task: task,
      onOpenDetails: () => _openTaskDetails(task),
      onToggleStatus: () => _toggleStatus(task),
      onDelete: () => _confirmDelete(task),
    );
  }

  /// Encabezado visual que separa tareas por estado
  Widget _statusHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Divider(thickness: 3),
        ],
      ),
    );
  }
}
