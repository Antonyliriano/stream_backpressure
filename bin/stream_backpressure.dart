import 'dart:async';
import 'dart:collection';
import 'dart:math';

void main() async {
  print("======================================");
  print(" PROCESADOR DE EVENTOS CON STREAMS");
  print("======================================\n");

  final buffer = Queue<int>();
  const maxBuffer = 5;

  bool producerFinished = false;

  // ===========================
  // CONSUMIDOR
  // ===========================
  Future<void> consumer() async {
    while (!producerFinished || buffer.isNotEmpty) {
      if (buffer.isNotEmpty) {
        final number = buffer.removeFirst();

        print("📤 Sacando $number del buffer");
        print("📦 Buffer restante: ${buffer.length}/$maxBuffer\n");

        await processNumber(number);
      } else {
        // Espera si el buffer está vacío
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }

    print("\n✅ Consumidor finalizado.");
  }

  // Iniciar consumidor
  final consumerTask = consumer();

  // ===========================
  // PRODUCTOR
  // ===========================
  await for (final number in generateNumbers()) {
    if (buffer.length < maxBuffer) {
      buffer.addLast(number);

      print("📥 Número $number agregado al buffer");
      print("📦 Buffer: ${buffer.length}/$maxBuffer\n");
    } else {
      print("❌ Buffer lleno -> Se descarta el número $number\n");
    }
  }

  producerFinished = true;

  // Esperar a que el consumidor termine
  await consumerTask;

  print("\n======================================");
  print(" PROCESO COMPLETADO");
  print("======================================");
}

///
/// STREAM DE NÚMEROS
///
Stream<int> generateNumbers() async* {
  final random = Random();

  for (int i = 1; i <= 20; i++) {
    final delay = 100 + random.nextInt(401);

    await Future.delayed(Duration(milliseconds: delay));

    print("➡️ Emitiendo número $i (delay: ${delay}ms)");

    yield i;
  }
}

///
/// PROCESAMIENTO COSTOSO
///
Future<void> processNumber(int number) async {
  final stopwatch = Stopwatch()..start();

  print("⚙️ Procesando $number...");

  // Simula una tarea pesada
  await Future.delayed(
    Duration(
      milliseconds: 600 + Random().nextInt(500),
    ),
  );

  final result = factorial(number);

  stopwatch.stop();

  print("✅ Factorial de $number = $result");
  print("⏱ Tiempo: ${stopwatch.elapsedMilliseconds} ms\n");
}

///
/// FACTORIAL
///
int factorial(int n) {
  int result = 1;

  for (int i = 1; i <= n; i++) {
    result *= i;
  }

  return result;
}
