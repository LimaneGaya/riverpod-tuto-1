import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

enum City {
  stockholm,
  paris,
  tokyo,
}

typedef WeatherEmojy = String;

Future<WeatherEmojy> getWeather(City city) {
  return Future.delayed(
    const Duration(seconds: 2),
    () => {
      City.stockholm: '🌧️',
      City.paris: '☀️',
      City.tokyo: '🍃',
    }[city]!,
  );
}

final currentCityProvider = StateProvider<City?>(
  (ref) => null,
);
final weatherProvider = FutureProvider<WeatherEmojy>(
  (ref) {
    final city = ref.watch(currentCityProvider);
    if (city != null) {
      return getWeather(city);
    } else {
      return ' ';
    }
  },
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentWeather = ref.watch(weatherProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Example"),
      ),
      body: Column(
        children: [
          currentWeather.when(
            data: (data) => Text(data, style: const TextStyle(fontSize: 40)),
            error: (error, stackTrace) => Text(error.toString()),
            loading: () => const CircularProgressIndicator(),
          ),
          Expanded(
              child: ListView.builder(
            itemCount: City.values.length,
            itemBuilder: (context, index) {
              final city = City.values[index];
              final isSelected = city == ref.watch(currentCityProvider);
              return ListTile(
                title: Text(city.toString()),
                trailing: isSelected ? Icon(Icons.check) : null,
                onTap: () {
                  ref.read(currentCityProvider.notifier).state = city;
                },
              );
            },
          ))
        ],
      ),
    );
  }
}
