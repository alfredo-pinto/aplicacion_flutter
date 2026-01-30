import 'package:flutter/material.dart';
import 'ListaTareas.dart';

/// Pantalla de bienvenida de la aplicación.

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Se obtiene el tema actual para reutilizar colores y estilos globales
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // Se usa el color de fondo definido en el tema global
      backgroundColor: colorScheme.surface,

      body: SafeArea(
        child: Padding(
          // Margen general de la pantalla
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              // Ajusta el tamaño del Column al contenido
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 28),

                // Título de la aplicación
                Text(
                  'MyPlanner',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                // Descripción breve del propósito de la aplicación
                Text(
                  'Organiza tus tareas diarias, establece prioridades y marca tu progreso de forma sencilla',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.75),
                    height: 1.35, // Espaciado entre líneas
                  ),
                ),

                const SizedBox(height: 36),

                // Botón principal para avanzar a la aplicación
                SizedBox(
                  width: 400, // Limita el ancho
                  child: FilledButton.icon(
                    onPressed: () {
                      // Navegación a la pantalla de lista de tareas
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => const TaskListScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Empezar'),
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
