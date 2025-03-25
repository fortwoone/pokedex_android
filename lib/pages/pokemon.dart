// a page to display all pokemons or a specific pokemon
// we use the pokeapi package to get the data

import 'package:flutter/material.dart';
import 'package:pokeapi/model/pokemon/pokemon.dart';
import 'package:pokeapi/pokeapi.dart';

class PokemonList extends StatefulWidget {
  const PokemonList({super.key});

  @override
  PokemonListState createState() => PokemonListState();
}

class PokemonListState extends State<PokemonList> {
  List<Pokemon> _pokemonList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPokemonList();
  }

  Future<void> _fetchPokemonList() async {
    try {
      // Get all pokemons
      final pokemonList = await PokeAPI.getObjectList<Pokemon>(1, 1);
      setState(() {
        _pokemonList = pokemonList.cast<Pokemon>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokédex'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _pokemonList.length,
        itemBuilder: (context, index) {
          final pokemon = _pokemonList[index];
          return ListTile(
            title: Text(pokemon.name ?? 'Unknown'),
            leading: Image.network(pokemon.sprites?.frontDefault ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PokemonDetail(pokemon: pokemon),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PokemonDetail extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetail({required this.pokemon, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon.name ?? 'Unknown'),
      ),
      body: Center(
        child: Column(
          children: [
            Image.network(pokemon.sprites?.frontDefault ?? ''),
            Text(pokemon.name ?? 'Unknown'),
          ],
        ),
      ),
    );
  }
}