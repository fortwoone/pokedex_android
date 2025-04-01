import "dart:convert";
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:pokeapi/model/move/move.dart';
import 'package:pokeapi/model/pokemon/pokemon-specie.dart';
import 'package:pokeapi/model/pokemon/pokemon.dart';
import "package:pokeapi/model/utils/converter.dart";
import 'package:pokeapi/pokeapi.dart';
import "package:pokedex/constants.dart";
import "package:pokedex/localisation_utils.dart";


// Holds the ID and name of the Pokémon so it can be used later on.
// This allows to only lazily load Pokémon as needed when showing the list.
class _PkmnReference{
    late String name;
    late int id;

    _PkmnReference(Map<String, dynamic> obj) {
        this.name = obj["name"];
        this.id = int.parse(Converter.urlToId(obj["url"]));
    }
}


Future<List<_PkmnReference>> _getPokemonForMove(Move move) async{
    List<_PkmnReference> pkmn = [];
    var response = await http.get(Uri.parse("https://pokeapi.co/api/v2/move/${move.id!}"));
    Map<String, dynamic> parsed = json.decode(response.body);
    List<dynamic> obtainedPkmn = parsed["learned_by_pokemon"];
    for (final obj in obtainedPkmn){
        pkmn.add(_PkmnReference(obj));
    }
    return pkmn;
}


class Moves extends StatefulWidget {
    const Moves({super.key});

    @override
    MovesState createState() => MovesState();
}

class MovesState extends State<Moves> {
    List<Move> _movesList = [];
    bool _isLoading = true;
    int _offset = 1;

    @override
    void initState() {
      super.initState();
      _fetchMovesList();
    }

    Future<void> _fetchMovesList() async {
      try {
        final movesList = await PokeAPI.getObjectList<Move>(
            _offset, pokeCountPerPage
        ); // Fetch first 20 moves
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
        var loc = AppLocalizations.of(context);
        var prevAndNext = <Widget>[];
        if (_offset > 20){
          prevAndNext.add(
              IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: (){
                    setState(
                            (){
                          _offset -= 20;
                          _isLoading = true;
                          _fetchMovesList();
                        }
                    );
                  }
              )
          );
        }
        prevAndNext.add(
            IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed:(){
                  setState(
                          (){
                        _offset += 20;
                        _isLoading = true;
                        _fetchMovesList();
                      }
                  );
                }
            )
        );
        return Scaffold(
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                itemCount: _movesList.length,
                itemBuilder: (context, index) {
                    final move = _movesList[index];
                    return ListTile(
                        title: Text(getLocalisedMoveName(loc!, move) ?? 'Unknown'),
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
            bottomNavigationBar:Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: prevAndNext
            )
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
  Map<int, PokemonSpecie> _speciesMap = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPokemonList();
  }

  Future<void> _fetchPokemonList() async {
    try {
      _speciesMap.clear();
      final List<_PkmnReference> pokemonList = await _getPokemonForMove(widget.move);
      List<Pokemon> currentPage = [];
      for (int i = 0; i < pokeCountPerPageInInfo; ++i){
          Pokemon? pk = await PokeAPI.getObject<Pokemon>(pokemonList[i].id);
          if (pk != null){
              currentPage.add(pk);
              PokemonSpecie? specie = await PokeAPI.getObject<PokemonSpecie>(pokemonList[i].id);
              if (specie != null){
                  _speciesMap[pokemonList[i].id] = specie;
              }
          }
      }
      setState(() {
        _pokemonList = currentPage;
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

  // TODO: show the move's type as well.
  List<TableRow> _getMoveInfo(AppLocalizations loc){
      List<String> propNames = [
          loc.move_name,
          loc.move_accuracy,
          loc.move_power,
          loc.move_pp,
          loc.priority,
          loc.dmg_class,
          loc.effect
      ];

      var dmg_cls_names = {
          "physical": loc.physical,
          "special": loc.special,
          "status": loc.status
      };

      var shownValues = [
          getLocalisedMoveName(loc, widget.move) ?? 'Unknown',
          widget.move.accuracy != null ? "${widget.move.accuracy!}%" : loc.always_hits,
          widget.move.power?.toString() ?? '--',
          widget.move.pp?.toString() ?? 'Unknown',
          widget.move.priority?.toString() ?? 'Unknown',
          widget.move.damageClass?.name != null ?
          dmg_cls_names[widget.move.damageClass?.name]! : 'Unknown',
          getLocalisedMoveEffect(loc, widget.move) ?? 'Unknown'
      ];

      var rows = <TableRow>[];
      for (int i = 0; i < propNames.length; ++i){
          rows.add(
              TableRow(
                  children:[
                      Text(
                          propNames[i],
                          style: statNameTextStyle
                      ),
                      Text(
                          shownValues[i],
                          style: statValueTextStyle
                      )
                  ]
              )
          );
      }
      return rows;
  }

  @override
  Widget build(BuildContext context) {
      var loc = AppLocalizations.of(context)!;

      return Scaffold(
          appBar: AppBar(
              title: Text(
                  loc.move_info,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold
                  )
              ),
              backgroundColor: Colors.red
          ),
          body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                  children: [
                      Table(
                          columnWidths: statTableColumnWidths,
                          children: _getMoveInfo(loc),
                      ),
                      spacingBetweenStatsAndPKMN,
                      Text(loc.can_learn, style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                          child: ListView.builder(
                              itemCount: _pokemonList.length,
                              itemBuilder: (context, index) {
                                  final pokemon = _pokemonList[index];
                                  final specie = _speciesMap[pokemon.id]!;
                                  return ListTile(
                                      title: Text(getLocalPokemonName(loc, specie) ?? 'Unknown'),
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
