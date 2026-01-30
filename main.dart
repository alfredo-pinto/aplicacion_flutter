import 'package:flutter/material.dart';
import 'pantallas/Bienvenida.dart';

void main() {
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Elimina la etiqueta "DEBUG" en la esquina superior derecha
      debugShowCheckedModeBanner: false,

      /// Tema global de la aplicación.
      /// Todo lo definido aquí se aplica automáticamente
      /// a todas las pantallas y widgets.
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, // color base de la aplicación
          surface: const Color.fromARGB(255, 237, 237, 237,), // color de fondo de las pantallas
        ),

        /// Tema global del AppBar.
        /// Evita repetir estilos en cada pantalla.
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromRGBO(237, 237, 237, 0,),
          elevation: 0, // elimina la sombra inferior
          centerTitle: true, // centra el título
          titleTextStyle: TextStyle(
            fontSize: 22, // tamaño del texto del título
            fontWeight: FontWeight.w600, // grosor del texto
            color: Color.fromARGB(255, 0, 0, 0), // color del texto
          ),
        ),

        /// Estilo global para los botones FilledButton.
        /// Se utiliza en acciones principales como "Guardar".
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color.fromARGB(
              255, 3, 87, 176,
            ), // color de fondo del botón
            foregroundColor: Colors.white, // color del texto e iconos
          ),
        ),

        /// Tema global de los Chips.
        /// Se usa en los filtros de estado de tareas.
        chipTheme: ChipThemeData(
          selectedColor: const Color.fromARGB(
            255, 26, 197, 254,
          ), // color del chip seleccionado
          backgroundColor: Colors.white, // color del chip no seleccionado
          labelStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
          secondaryLabelStyle: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // bordes redondeados
          ),
        ),
      ),

      /// Pantalla inicial de la aplicación.
      /// Desde aquí se navega al resto de pantallas.
      home: const WelcomeScreen(),
    );
  }
}