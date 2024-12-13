import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokédex & Dog Images',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const PokemonHomePage(),
      routes: {
        '/dog_images': (context) => const DogImagesPage(),
      },
    );
  }
}

class PokemonHomePage extends StatefulWidget {
  const PokemonHomePage({Key? key}) : super(key: key);

  @override
  _PokemonHomePageState createState() => _PokemonHomePageState();
}

class _PokemonHomePageState extends State<PokemonHomePage> {
  String _pokemonName = '';
  Map<String, dynamic>? _pokemonData;

  Future<void> _searchPokemon() async {
    try {
      final data = await fetchPokemon(_pokemonName.toLowerCase());
      setState(() {
        _pokemonData = data;
      });
    } catch (e) {
      setState(() {
        _pokemonData = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pokémon no encontrado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
        centerTitle: true,
      ),
      drawer: const Sidebar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.redAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Buscar Pokémon',
                labelStyle: const TextStyle(color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => _pokemonName = value,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _searchPokemon,
              child: const Text('Buscar', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            if (_pokemonData != null) ...[
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Image.network(
                        _pokemonData!['sprites']['front_default'],
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _pokemonData!['name'].toString().toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text(
                                'Altura',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('${_pokemonData!['height']}'),
                            ],
                          ),
                          Column(
                            children: [
                              const Text(
                                'Peso',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('${_pokemonData!['weight']}'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        children: (_pokemonData!['types'] as List)
                            .map((type) => Chip(
                                  label: Text(
                                    type['type']['name'],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>> fetchPokemon(String name) async {
  final url = 'https://pokeapi.co/api/v2/pokemon/$name';
  final response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load Pokémon');
  }
}

class DogImagesPage extends StatefulWidget {
  const DogImagesPage({Key? key}) : super(key: key);

  @override
  _DogImagesPageState createState() => _DogImagesPageState();
}

class _DogImagesPageState extends State<DogImagesPage> {
  List<String> _dogImages = [];

  Future<void> _getRandomDogImages() async {
    try {
      final images = await fetchRandomDogImages();
      setState(() {
        _dogImages = images;
      });
    } catch (e) {
      setState(() {
        _dogImages = [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getRandomDogImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Dog Images'),
        centerTitle: true,
      ),
      drawer: const Sidebar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.redAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _getRandomDogImages,
              child: const Text('Recargar imágenes', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _dogImages.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.network(
                      _dogImages[index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<List<String>> fetchRandomDogImages() async {
  final url = 'https://dog.ceo/api/breeds/image/random/3';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    List<String> images = List<String>.from(data['message']);
    return images;
  } else {
    throw Exception('Failed to load dog images');
  }
}

class Sidebar extends StatelessWidget {
  const Sidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.red,
            ),
            child: Text(
              'Pokédex & Dog Images',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Pokédex'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Random Dog Images'),
            onTap: () {
              Navigator.pushNamed(context, '/dog_images');
            },
          ),
        ],
      ),
    );
  }
}
