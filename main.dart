import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const BracesApp());
}

class Treatment {
  final String id;
  final String name;
  final String summary;
  Treatment({required this.id, required this.name, required this.summary});
}

const List<Treatment> treatments = [
  Treatment(id: 'metal', name: 'Metal Braces', summary: 'Reliable stainless steel braces.'),
  Treatment(id: 'ceramic', name: 'Ceramic Braces', summary: 'Tooth-colored aesthetic brackets.'),
  Treatment(id: 'self', name: 'Self-Ligating', summary: 'Lower friction brackets.'),
  Treatment(id: 'lingual', name: 'Lingual Braces', summary: 'Hidden behind teeth.'),
  Treatment(id: 'aligners', name: 'Clear Aligners', summary: 'Removable clear trays.'),
];

class BracesApp extends StatelessWidget {
  const BracesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Braces & Aligners',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Set<String> _favorites = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorites') ?? [];
    setState(() {
      _favorites = favs.toSet();
      _loading = false;
    });
  }

  Future<void> _toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(id)) _favorites.remove(id);
      else _favorites.add(id);
    });
    await prefs.setStringList('favorites', _favorites.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Braces & Aligners'),
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritesPage(favorites: _favorites)));
            },
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: treatments.length,
              itemBuilder: (context, index) {
                final t = treatments[index];
                final isFav = _favorites.contains(t.id);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal:12, vertical:8),
                  child: ListTile(
                    leading: const Icon(Icons.medical_services),
                    title: Text(t.name),
                    subtitle: Text(t.summary),
                    trailing: IconButton(
                      icon: Icon(isFav ? Icons.star : Icons.star_border, color: isFav ? Colors.amber : null),
                      onPressed: () => _toggleFavorite(t.id),
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(t.name),
                        content: Text(t.summary),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  final Set<String> favorites;
  const FavoritesPage({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    final favList = treatments.where((t) => favorites.contains(t.id)).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favList.isEmpty
          ? const Center(child: Text('No favorites yet'))
          : ListView.builder(
              itemCount: favList.length,
              itemBuilder: (context, index) {
                final t = favList[index];
                return ListTile(title: Text(t.name), subtitle: Text(t.summary));
              },
            ),
    );
  }
}
