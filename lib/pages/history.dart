import 'package:flutter/material.dart';
import 'package:pokedex/database_historique.dart';
import 'package:pokedex/pages/moves.dart';
import 'package:pokedex/pages/pokemon.dart';
import 'package:pokedex/pages/talents_abilities.dart';
import 'package:pokeapi/pokeapi.dart';
import 'package:pokeapi/model/move/move.dart';
import 'package:pokeapi/model/pokemon/pokemon.dart';
import 'package:pokeapi/model/pokemon/pokemon-specie.dart';
import 'package:pokeapi/model/pokemon/ability.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  HistoryState createState() => HistoryState();
}

class HistoryState extends State<History> {
  List<Map<String, dynamic>> _historyList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistoryList();
  }

  Future<void> _fetchHistoryList() async {
    try {
      final historyList = await DatabaseHistorique().queryRecentRows();
      setState(() {
        _historyList = historyList;
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

  Future<void> _navigateToDetail(int contentId, String ressource) async {
    try {
      if (ressource.startsWith('Looked up info about ')) {
        final name = ressource.split(' ').last;
        if (await _isPokemon(name)) {
          final pokemon = await PokeAPI.getObject<Pokemon>(contentId);
          final specie = await PokeAPI.getObject<PokemonSpecie>(contentId);
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PokemonDetail(pokemon: pokemon!, specie: specie!),
              ),
            );
          }
        } else if (await _isMove(name)) {
          final move = await PokeAPI.getObject<Move>(contentId);
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MoveDetail(move: move!),
              ),
            );
          }
        } else if (await _isAbility(name)) {
          final ability = await PokeAPI.getObject<Ability>(contentId);
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TalentDetail(ability: ability!),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      // Handle error
    }
  }

  Future<bool> _isPokemon(String name) async {
    try {
      await PokeAPI.getObject<Pokemon>(name as int);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isMove(String name) async {
    try {
      await PokeAPI.getObject<Move>(name as int);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isAbility(String name) async {
    try {
      await PokeAPI.getObject<Ability>(name as int);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.red,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _historyList.length,
        itemBuilder: (context, index) {
          final history = _historyList[index];
          return ListTile(
            title: Text(history['ressource'] ?? 'Unknown'),
            subtitle: Text(history['dateAjout'] ?? 'Unknown'),
            onTap: () => _navigateToDetail(history['contentId'], history['ressource']),
          );
        },
      ),
    );
  }
}