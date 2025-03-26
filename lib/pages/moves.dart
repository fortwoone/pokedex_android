import 'package:flutter/material.dart';
import 'package:pokeapi/model/move/move.dart';
import 'package:pokeapi/model/pokemon/pokemon.dart';
import 'package:pokeapi/pokeapi.dart';

class Moves extends StatefulWidget {
  const Moves({super.key});

  @override
  MovesState createState() => MovesState();
}

class MovesState extends State<Moves> {
  List<Move> _movesList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMovesList();
  }

  Future<void> _fetchMovesList() async {
    try {
      final movesList = await PokeAPI.getObjectList<Move>(
          1, 20); // Fetch first 100 moves
      setState(() {
        _movesList = movesList.cast<Move>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        debugPrint(e.toString());
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Moves"),
        backgroundColor: Colors.red,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _movesList.length,
        itemBuilder: (context, index) {
          final move = _movesList[index];
          return ListTile(
            title: Text(move.name ?? 'Unknown'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MoveDetail(move: move),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MoveDetail extends StatefulWidget {
  final Move move;

  const MoveDetail({required this.move, super.key});

  @override
  MoveDetailState createState() => MoveDetailState();
}

class MoveDetailState extends State<MoveDetail> {
  List<Pokemon> _pokemonList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPokemonList();
  }

  Future<void> _fetchPokemonList() async {
    try {
      // Fetch the first 5 Pokémon
      final pokemonList = await PokeAPI.getObjectList<Pokemon>(1, 5);
      setState(() {
        _pokemonList = pokemonList.cast<Pokemon>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        debugPrint(e.toString());
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.move.name ?? 'Unknown'),
        backgroundColor: Colors.red,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  children: [
                    const Text('Name:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.move.name ?? 'Unknown'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('Accuracy:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.move.accuracy?.toString() ?? 'Unknown'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('Power:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.move.power?.toString() ?? 'Unknown'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('PP:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.move.pp?.toString() ?? 'Unknown'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('Priority:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.move.priority?.toString() ?? 'Unknown'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('Damage Class:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.move.damageClass?.name ?? 'Unknown'),
                  ],
                ),
                TableRow(
                  children: [
                    const Text('Effect:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(widget.move.effectEntries?.first.shortEffect ?? 'Unknown'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Pokémon that can learn this move:', style: TextStyle(fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _pokemonList.length,
                itemBuilder: (context, index) {
                  final pokemon = _pokemonList[index];
                  return ListTile(
                    title: Text(pokemon.name ?? 'Unknown'),
                    leading: Image.network(pokemon.sprites?.frontDefault ?? ''),
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
