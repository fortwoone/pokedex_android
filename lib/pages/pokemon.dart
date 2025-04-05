// a page to display all pokemons or a specific pokemon
// we use the pokeapi package to get the data

import "dart:math";
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pokeapi/model/pokemon/pokemon-specie.dart';
import 'package:pokeapi/model/pokemon/pokemon.dart';
import 'package:pokeapi/model/move/move.dart';
import "package:pokeapi/model/utils/converter.dart";
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

class PokemonDetail extends StatefulWidget {
  final Pokemon pokemon;
  final PokemonSpecie specie;

  const PokemonDetail({required this.pokemon, required this.specie, super.key});

  @override
  State<PokemonDetail> createState() => _PokemonDetailState();
}

class _PokemonDetailState extends State<PokemonDetail> {
  int _offset = 0;
  int _maxLoadedOffset = 4;
  List<Move> _moves = [];
  bool _isLoading = true;

  String getTypes(AppLocalizations loc){
      var typeNames = {
        "normal": loc.normal,
        "fighting": loc.fighting,
        "ghost": loc.ghost,
        "poison": loc.poison,
        "flying": loc.flying,
        "ground": loc.ground,
        "rock": loc.rock,
        "bug": loc.bug,
        "steel": loc.steel,
        "fire": loc.fire,
        "water": loc.water,
        "grass": loc.grass,
        "electric": loc.electric,
        "psychic": loc.psychic,
        "dark": loc.dark,
        "ice": loc.ice,
        "dragon": loc.dragon,
        "fairy": loc.fairy,
        "stellar": loc.stellar
      };

      var types = <String>[];
      for (final type in widget.pokemon.types!){
          types.add(
              typeNames[type.type!.name!]!
          );
      }
      return types.join(", ");
  }

  @override
  void initState(){
    super.initState();
    _getMoves();
  }

  List<Widget> _getPokeChildrenList(AppLocalizations loc) {
    String? name = getLocalPokemonName(loc, widget.specie);

    var statNames = <String>[
      loc.type,
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
              i > 0 ? widget.pokemon.stats![i - 1].baseStat.toString() : getTypes(loc),
              style: statValueTextStyle,
            ),
          ],
        ),
      );
    }

    var prevAndNext = <Widget>[];
    if (_offset > 4){
        prevAndNext.add(
            IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: (){
                    setState(
                        (){
                            _offset -= 5;
                        }
                    );
                }
            )
        );
    }
    if (_offset < widget.pokemon.moves!.length){
        prevAndNext.add(
            IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: (){
                    setState(
                        (){
                            _offset += 5;
                            if (_offset >= _maxLoadedOffset){
                                setState(
                                    (){
                                        _maxLoadedOffset += 5;
                                        _isLoading = true;
                                        _getMoves();
                                    }
                                );
                            }
                        }
                    );
                }
            )
        );
    }

    var ret = <Widget>[
      Image.network(
        widget.pokemon.sprites?.frontDefault ?? '',
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
      spacingBetweenStatsAndPKMN,
      Text(loc.possible_moves, style: TextStyle(fontWeight: FontWeight.bold)),
      Expanded(
          child: Scaffold(
              body: ListView.builder(
                  itemCount: min(5, _moves.length - _offset),
                  itemBuilder: (context, int index){
                      final move = _moves[_offset + index];
                      return ListTile(
                          title: Text(getLocalisedMoveName(loc, move) ?? "Unknown")
                      );
                  }
              ),
              bottomNavigationBar: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: prevAndNext
              )
          )
      )
    ];

    return ret;
  }

  Future<void> _getMoves() async{
      try{
          for (int i = 0; i < min(5, (widget.pokemon.moves!.length - _offset)); ++i){
              Move? mv = await PokeAPI.getObject<Move>(
                  int.parse(
                      Converter.urlToId(
                          widget.pokemon.moves![_offset + i].move!.url!
                      )
                  )
              );
              if (mv != null) {
                  _moves.add(mv);
              }
          }
          setState(
              (){
                  _isLoading = false;
              }
          );
      }
      catch (e){
          debugPrint(e.toString());
          setState(
              (){
                 _isLoading = false;
              }
          );
      }
  }

  Future<void> _registerSearchActivity() async {
      await DatabaseHistorique().insert({
          "fr_name": getPokemonNameForLang("fr", widget.specie),
          "en_name": getPokemonNameForLang("en", widget.specie),
          'dateAjout': DateTime.now().toIso8601String(),
          'contentId': widget.pokemon.id,
          "content_type": contentTypePokemon
      });
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context)!;

    // Register the search activity
    if (DatabaseHistorique.historyEnabled) {
      _registerSearchActivity();
    }

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
      body: _isLoading ? const Center(
          child: CircularProgressIndicator()
      ): Center(
        child: Column(
          children: _getPokeChildrenList(loc),
        ),
      ),
    );
  }
}