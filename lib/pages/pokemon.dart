// a page to display all pokemons or a specific pokemon
// we use the pokeapi package to get the data

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pokeapi/model/pokemon/pokemon-specie.dart';
import 'package:pokeapi/model/pokemon/pokemon.dart';
import 'package:pokeapi/pokeapi.dart';
import "package:pokedex/constants.dart";
import "package:pokedex/localisation_utils.dart";
import '../database_historique.dart';

class PokemonList extends StatefulWidget {
    const PokemonList({super.key});

    @override
    PokemonListState createState() => PokemonListState();
}

class PokemonListState extends State<PokemonList> {
    final List<Pokemon> _pokemonList = [];
    final List<PokemonSpecie> _speciesList = [];
    bool _isLoading = true;
    int _offset = 1;
    int _maxOffsetLoaded = 20;

    @override
    void initState() {
      super.initState();
      _fetchPokemonList();
    }

    Future<void> _fetchPokemonList() async {
      try {
        // Get all pokemon
        final pokemonList = await PokeAPI.getObjectList<Pokemon>(_offset, pokeCountPerPage);
        final speciesList = await PokeAPI.getObjectList<PokemonSpecie>(_offset, pokeCountPerPage);
        setState(() {
          _pokemonList.addAll(pokemonList.cast<Pokemon>());
          _speciesList.addAll(speciesList.cast<PokemonSpecie>());
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
        var prevAndNext = <Widget>[];
        if (_offset > 20){
            prevAndNext.add(
                IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: (){
                        setState(
                            (){
                                _offset -= pokeCountPerPage;
                            }
                        );
                    }
                )
            );
        }
        if (!_isLoading) {
          // Prevent potential breaking by forbidding advance until the current page is loaded.
          prevAndNext.add(
              IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    setState(
                            () {
                          _offset += 20;
                          if (_offset >= _maxOffsetLoaded) {
                            _maxOffsetLoaded += 20;
                            _isLoading = true;
                            _fetchPokemonList();
                          }
                        }
                    );
                  }
              )
          );
        }

        return Scaffold(
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: pokeCountPerPage,
                    itemBuilder: (context, index) {
                      final pokemon = _pokemonList[_offset + index - 1];
                      final species = _speciesList[_offset + index - 1];
                      String? name = getLocalPokemonName(
                          AppLocalizations.of(context)!,
                          species
                      );
                      return ListTile(
                        title: Text(name ?? 'Unknown'),
                        leading: Image.network(pokemon.sprites?.frontDefault ?? ''),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PokemonDetail(
                                  pokemon: pokemon,
                                  specie: species
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
            bottomNavigationBar: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: prevAndNext
            ),
        );
    }
}

class PokemonDetail extends StatelessWidget {
  final Pokemon pokemon;
  final PokemonSpecie specie;

  const PokemonDetail({required this.pokemon, required this.specie, super.key});

  List<Widget> _getPokeChildrenList(AppLocalizations loc) {
    String? name = getLocalPokemonName(loc, specie);

    var statNames = <String>[
      loc.hp,
      loc.attack,
      loc.defence,
      loc.spatk,
      loc.spdef,
      loc.speed
    ];

    var statsTableChildren = <TableRow>[];
    for (int i = 0; i < statNames.length; ++i) {
      statsTableChildren.add(
        TableRow(
          children: [
            Text(
              statNames[i],
              style: statNameTextStyle,
            ),
            Text(
              pokemon.stats![i].baseStat.toString(),
              style: statValueTextStyle,
            ),
          ],
        ),
      );
    }

    var ret = <Widget>[
      Image.network(
        pokemon.sprites?.frontDefault ?? '',
        scale: 0.5,
        filterQuality: FilterQuality.none,
      ),
      Text(
        name ?? 'Unknown',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(32.0),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(4),
            1: FlexColumnWidth(2),
          },
          children: statsTableChildren,
        ),
      ),
    ];

    return ret;
  }

  Future<void> _registerSearchActivity() async {
    await DatabaseHistorique().insert({
      'ressource': 'Looked up info about ${pokemon.name}',
      'dateAjout': DateTime.now().toIso8601String(),
      'contentId': pokemon.id,
    });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    // Register the search activity
    _registerSearchActivity();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.poke_info,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Column(
          children: _getPokeChildrenList(loc),
        ),
      ),
    );
  }

}