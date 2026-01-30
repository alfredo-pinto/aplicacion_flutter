import 'package:flutter/material.dart';
import '../models/tarea.dart';

const sectionTitleColor = Color.fromRGBO(0, 0, 0, 1);
const double sectionTitleSize = 16;

/// Pantalla para crear o editar una tarea.
///
/// Si initialTask es null, se crea una tarea nueva.
/// Si initialTask tiene valor, se cargan sus datos en el formulario para editarla.
class CreateTaskScreen extends StatefulWidget {
  // Tarea opcional recibida desde otra pantalla (detalle/lista) para editar
  final Task? initialTask;

  const CreateTaskScreen({super.key, this.initialTask});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  // Llave para validar el formulario (TextFormField validators)
  final _formKey = GlobalKey<FormState>();

  // Controladores para leer/escribir el texto de los campos de formulario
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  // Estado del vencimiento: fecha y hora separadas
  DateTime _dueDate = DateTime.now();
  TimeOfDay _dueTime = const TimeOfDay(hour: 12, minute: 0);

  // Color elegido para la etiqueta (punto de color)
  Color _tagColor = const Color(0xFF3498DB);

  // Categoría elegida y su icono asociado
  IconData _categoryIcon = Icons.school;
  String _category = 'Estudio';

  // Prioridad elegida (baja, media, alta)
  Priority _priority = Priority.media;

  @override
  void initState() {
    super.initState();

    // Si viene una tarea, significa que estamos editando:
    // precargamos los campos con los valores actuales.
    final t = widget.initialTask;
    if (t != null) {
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description;

      _dueDate = t.dueDate;
      _dueTime = t.dueTime;

      _tagColor = t.tagColor;

      _category = t.category;
      _categoryIcon = t.categoryIcon;

      _priority = t.priority;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  /// Convierte un TimeOfDay en texto formato a.m./p.m.
  String _timeText(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final suffix = t.period == DayPeriod.am ? 'a.m.' : 'p.m.';
    return '$hour:$minute $suffix';
  }

  /// Convierte un DateTime en texto dd/mm/yyyy para mostrarlo
  String _dateText(DateTime d) {
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final year = d.year.toString();
    return '$day/$month/$year';
  }

  /// Devuelve el color de la bandera según la prioridad.
  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.baja:
        return const Color.fromARGB(225, 81, 244, 69);
      case Priority.media:
        return const Color.fromARGB(230, 249, 231, 40);
      case Priority.alta:
        return const Color.fromARGB(225, 254, 46, 46);
    }
  }

  /// Abre el selector de fecha y guarda el resultado en _dueDate.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    // Si el usuario cancela, picked será null
    if (picked != null) setState(() => _dueDate = picked);
  }

  /// Abre el selector de hora y guarda el resultado en _dueTime.
  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );

    // Si el usuario cancela, picked será null
    if (picked != null) setState(() => _dueTime = picked);
  }

  /// Valida el formulario y devuelve una Task
  void _save() {
    // Ejecuta validaciones de TextFormField
    if (!_formKey.currentState!.validate()) return;

    final newTask = Task(
      // Si se edita, se conserva el id; si se crea, id queda 0
      id: widget.initialTask?.id ?? 0,

      // Campos obligatorios/clave
      title: _titleCtrl.text.trim(),
      category: _category,

      // Campos opcionales o nuevos
      description: _descCtrl.text.trim(),
      dueDate: _dueDate,

      // Resto de propiedades visuales y de control
      dueTime: _dueTime,
      tagColor: _tagColor,
      categoryIcon: _categoryIcon,
      priority: _priority,

      // Si se edita, se conserva el estado; si se crea, empieza pendiente
      status: widget.initialTask?.status ?? TaskStatus.pendiente,
    );

    // Devuelve el objeto a la pantalla anterior
    Navigator.pop(context, newTask);
  }

  /// Crea una tarjeta con el mismo estilo que las tarjetas de tareas.
  /// Se usa para que cada apartado del formulario tenga fondo blanco y bordes redondeados.
  Widget _fieldCard({required Widget child}) {
    return Card(
      elevation: 0,
      color: const Color.fromRGBO(255, 255, 255, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: child,
      ),
    );
  }

  /// Crea una fila clicable tipo "selector", usada en la tarjeta de fecha y hora.
  ///
  /// Muestra:
  /// - Un icono (calendario/reloj)
  /// - Un título (label)
  /// - Un valor (value)
  /// - Una flecha para indicar que se puede pulsar
  Widget _tapRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, color: cs.onSurface),
            const SizedBox(width: 12),

            // Expanded para que el texto ocupe el espacio y la flecha se quede a la derecha
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título del apartado
                  Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: sectionTitleColor,
                      fontSize: sectionTitleSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Valor seleccionado
                  Text(
                    value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            // Indicador visual de que se puede entrar/cambiar
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _dropdownInCard<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required Widget Function(BuildContext, T) selectedBuilder,
  }) {
    final theme = Theme.of(context);

    return _fieldCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Título del apartado del dropdown
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: sectionTitleColor,
              fontSize: sectionTitleSize,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),

          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              items: items,
              onChanged: onChanged,

              selectedItemBuilder: (context) {
                return items.map((it) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: selectedBuilder(context, it.value as T),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Lista de opciones del dropdown de categoría.
    // Cada opción incluye un icono y texto.
    List<DropdownMenuItem<String>> categoryItems() => const [
          DropdownMenuItem(
            value: 'Estudio',
            child: Row(
              children: [Icon(Icons.school), SizedBox(width: 10), Text('Estudio')],
            ),
          ),
          DropdownMenuItem(
            value: 'Casa',
            child: Row(
              children: [Icon(Icons.home), SizedBox(width: 10), Text('Casa')],
            ),
          ),
          DropdownMenuItem(
            value: 'Salud',
            child: Row(
              children: [Icon(Icons.fitness_center), SizedBox(width: 10), Text('Salud')],
            ),
          ),
          DropdownMenuItem(
            value: 'Trabajo',
            child: Row(
              children: [Icon(Icons.work), SizedBox(width: 10), Text('Trabajo')],
            ),
          ),
        ];

    // Lista de opciones del dropdown de prioridad.
    // Cada opción muestra una bandera con su color + texto.
    List<DropdownMenuItem<Priority>> priorityItems() => [
          DropdownMenuItem(
            value: Priority.baja,
            child: Row(
              children: [
                Icon(Icons.flag, color: _priorityColor(Priority.baja)),
                SizedBox(width: 10),
                Text('Baja'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: Priority.media,
            child: Row(
              children: [
                Icon(Icons.flag, color: _priorityColor(Priority.media)),
                SizedBox(width: 10),
                Text('Media'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: Priority.alta,
            child: Row(
              children: [
                Icon(Icons.flag, color: _priorityColor(Priority.alta)),
                SizedBox(width: 10),
                Text('Alta'),
              ],
            ),
          ),
        ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        // Cambia el título dependiendo si es creación o edición
        title: Text(widget.initialTask == null ? 'Crear tarea' : 'Editar tarea'),

        // Botón para volver sin guardar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // campo título
              _fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Título',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: sectionTitleColor,
                        fontSize: sectionTitleSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Estudiar Flutter',
                        border: InputBorder.none,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Escribe un título';
                        if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Tarjeta: campo descripción,, opcional
              _fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descripción',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: sectionTitleColor,
                        fontSize: sectionTitleSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Añade más detalles si lo necesitas…',
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Tarjeta: vencimiento
              _fieldCard(
                child: Column(
                  children: [
                    _tapRow(
                      icon: Icons.calendar_today,
                      label: 'Día de vencimiento',
                      value: _dateText(_dueDate),
                      onTap: _pickDate,
                    ),
                    const Divider(height: 16),
                    _tapRow(
                      icon: Icons.access_time,
                      label: 'Hora de vencimiento',
                      value: _timeText(_dueTime),
                      onTap: _pickTime,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Selector de categoría en tarjeta (dropdown)
              _dropdownInCard<String>(
                label: 'Categoría',
                value: _category,
                items: categoryItems(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() {
                    _category = value;

                    // Se actualiza el icono asociado a esa categoría
                    switch (value) {
                      case 'Casa':
                        _categoryIcon = Icons.home;
                        break;
                      case 'Salud':
                        _categoryIcon = Icons.fitness_center;
                        break;
                      case 'Trabajo':
                        _categoryIcon = Icons.work;
                        break;
                      case 'Estudio':
                      default:
                        _categoryIcon = Icons.school;
                        break;
                    }
                  });
                },

                selectedBuilder: (context, value) {
                  final icon = switch (value) {
                    'Casa' => Icons.home,
                    'Salud' => Icons.fitness_center,
                    'Trabajo' => Icons.work,
                    _ => Icons.school,
                  };

                  return Row(
                    children: [
                      Icon(icon),
                      const SizedBox(width: 10),
                      Text(
                        value,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 12),

              // Tarjeta: selector de color (punto) para tagColor
              _fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Color',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: sectionTitleColor,
                        fontSize: sectionTitleSize,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Wrap permite que los puntos salten a la siguiente línea si no caben
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _ColorDot(
                          color: const Color(0xFF3498DB),
                          selected: _tagColor.value == const Color(0xFF3498DB).value,
                          onTap: () => setState(() => _tagColor = const Color(0xFF3498DB)),
                        ),
                        _ColorDot(
                          color: const Color(0xFFE74C3C),
                          selected: _tagColor.value == const Color(0xFFE74C3C).value,
                          onTap: () => setState(() => _tagColor = const Color(0xFFE74C3C)),
                        ),
                        _ColorDot(
                          color: const Color(0xFFF1C40F),
                          selected: _tagColor.value == const Color(0xFFF1C40F).value,
                          onTap: () => setState(() => _tagColor = const Color(0xFFF1C40F)),
                        ),
                        _ColorDot(
                          color: const Color(0xFF2ECC71),
                          selected: _tagColor.value == const Color(0xFF2ECC71).value,
                          onTap: () => setState(() => _tagColor = const Color(0xFF2ECC71)),
                        ),
                        _ColorDot(
                          color: const Color(0xFF9B59B6),
                          selected: _tagColor.value == const Color(0xFF9B59B6).value,
                          onTap: () => setState(() => _tagColor = const Color(0xFF9B59B6)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Selector de prioridad en tarjeta (dropdown)
              _dropdownInCard<Priority>(
                label: 'Prioridad',
                value: _priority,
                items: priorityItems(),
                onChanged: (p) {
                  if (p == null) return;
                  setState(() => _priority = p);
                },

                // Vista personalizada del valor seleccionado: bandera con color + texto
                selectedBuilder: (context, p) {
                  final text = switch (p) {
                    Priority.baja => 'Baja',
                    Priority.media => 'Media',
                    Priority.alta => 'Alta',
                  };

                  return Row(
                    children: [
                      Icon(Icons.flag, color: _priorityColor(p)),
                      const SizedBox(width: 10),
                      Text(
                        text,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 18),

              // Botón final para guardar o guardar cambios
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.check),
                  label: Text(widget.initialTask == null ? 'Guardar tarea' : 'Guardar cambios'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget que representa un punto de color seleccionable.
/// Se usa para elegir el color de la etiqueta (tagColor) de la tarea.
class _ColorDot extends StatelessWidget {
  final Color color;        // Color del punto
  final bool selected;      // Indica si este punto está seleccionado
  final VoidCallback onTap; // Acción al pulsar (normalmente setState cambiando _tagColor)

  const _ColorDot({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // InkWell permite detectar toques con feedback visual
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,

          // Borde más grueso y oscuro si está seleccionado
          border: Border.all(
            width: selected ? 3 : 1,
            color: selected ? Colors.black : Colors.black26,
          ),
        ),
      ),
    );
  }
}
