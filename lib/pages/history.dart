import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:pokedex/database_historique.dart';
import 'package:pokedex/pages/moves.dart';
import 'package:pokedex/pages/pokemon.dart';
import 'package:pokedex/pages/talents_abilities.dart';
import 'package:pokeapi/pokeapi.dart';
import 'package:pokeapi/model/move/move.dart';
import 'package:pokeapi/model/pokemon/pokemon.dart';
import 'package:pokeapi/model/pokemon/pokemon-specie.dart';
import 'package:pokeapi/model/pokemon/ability.dart';
import "package:pokedex/constants.dart";

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

  Future<void> _navigateToDetail(Map<String, dynamic> item) async{
      int contentID = item["contentId"];
      final contentType = item["content_type"];
      try{
          switch (contentType){
              case 0:  // contentTypePokemon
                  final pokemon = await PokeAPI.getObject<Pokemon>(contentID);
                  final specie = await PokeAPI.getObject<PokemonSpecie>(contentID);
                  if (mounted) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PokemonDetail(pokemon: pokemon!, specie: specie!),
                          ),
                        );
                  }
                  break;
              case 1:  // contentTypeMove
                  final move = await PokeAPI.getObject<Move>(contentID);
                  if (mounted) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MoveDetail(move: move!),
                          ),
                      );
                  }
                  break;
              case 2:
                  final ability = await PokeAPI.getObject<Ability>(contentID);
                  if (mounted) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TalentDetail(ability: ability!),
                          ),
                      );
                  }
                  break;
              default:
                throw UnsupportedError("Invalid content type.");
          }
      }
      catch (e){
          debugPrint(e.toString());
      }
  }

  // Future<void> _navigateToDetail(int contentId, String ressource) async {
  //
  //   try {
  //     if (ressource.startsWith('Looked up info about ')) {
  //       final name = ressource.split(' ').last;
  //       if (await _isPokemon(name)) {
  //         final pokemon = await PokeAPI.getObject<Pokemon>(contentId);
  //         final specie = await PokeAPI.getObject<PokemonSpecie>(contentId);
  //         if (mounted) {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => PokemonDetail(pokemon: pokemon!, specie: specie!),
  //             ),
  //           );
  //         }
  //       } else if (await _isMove(name)) {
  //         final move = await PokeAPI.getObject<Move>(contentId);
  //         if (mounted) {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => MoveDetail(move: move!),
  //             ),
  //           );
  //         }
  //       } else if (await _isAbility(name)) {
  //         final ability = await PokeAPI.getObject<Ability>(contentId);
  //         if (mounted) {
  //           Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //               builder: (context) => TalentDetail(ability: ability!),
  //             ),
  //           );
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //     // Handle error
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _historyList.length,
        itemBuilder: (context, index) {
          final history = _historyList[index];
          final date = DateTime.parse(history["dateAjout"]!);
          return ListTile(
            title: Text(
                loc.looked_up + (loc.localeName.startsWith("fr") ? history["fr_name"] : history["en_name"])
            ),
            subtitle: Text(DateFormat("dd/MM/yyyy").add_Hms().format(date)),
            onTap: () => _navigateToDetail(history),
          );
        },
      ),
    );
  }
}