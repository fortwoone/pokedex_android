import "dart:math";
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import "package:pokeapi/model/pokemon/ability.dart";
import "package:pokeapi/model/pokemon/pokemon-specie.dart";
import "package:pokeapi/model/pokemon/pokemon.dart";
import "package:pokeapi/model/utils/converter.dart";
import "package:pokeapi/pokeapi.dart";
import "package:pokedex/constants.dart";
import "package:pokedex/localisation_utils.dart";

class TalentInfo extends StatefulWidget{
    const TalentInfo({super.key});

    @override
    State<TalentInfo> createState() => _TalentInfoState();
}

class _TalentInfoState extends State<TalentInfo> {
    List<Ability> _abilitiesList = [];
    int _offset = 1;
    int _minIndexLoaded = 1;
    int _maxOffsetLoaded = 20;
    bool _isLoading = true;

    @override
    void initState(){
        super.initState();
        _fetchAbilityList();
    }

    Future<void> _fetchAbilityList() async{
        try {
            final abilitiesList = await PokeAPI.getObjectList<Ability>(
                _offset, pokeCountPerPage
            ); // Fetch first 20 abilities
            setState(() {
                _abilitiesList = abilitiesList.cast<Ability>();
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
    Widget build(BuildContext context){
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
                            _offset += pokeCountPerPage;
                            if (_offset >= _maxOffsetLoaded) {
                              _isLoading = true;
                              _maxOffsetLoaded += pokeCountPerPage;
                              _fetchAbilityList();
                            }
                          }
                      );
                    }
                )
            );
        }

        var loc = AppLocalizations.of(context);

        return Scaffold(
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _abilitiesList.length,
                    itemBuilder: (context, int index){
                        final ability = _abilitiesList[index];
                        return ListTile(
                            title: Text(getLocalisedAbilityName(loc!, ability) ?? "Unknown"),
                            onTap: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TalentDetail(
                                            ability: ability
                                        )
                                    )
                                );
                            }
                        );
                    }
                ),
            bottomNavigationBar:Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: prevAndNext
            )
        );
    }
}

class TalentDetail extends StatefulWidget{
    final Ability ability;

    const TalentDetail({required this.ability, super.key});

    @override
    State<TalentDetail> createState() => _TalentDetailState();
}

class _TalentDetailState extends State<TalentDetail>{
    List<Pokemon> _pokemonList = [];
    Map<int, PokemonSpecie> _speciesMap = {};
    bool _isLoading = true;

    @override
    void initState(){
        super.initState();
        _fetchPokemon();
    }

    List<TableRow> _getAbilityDescChildren(AppLocalizations loc){
        var ret = <TableRow>[];

        var colNames = [
            loc.move_name,
            loc.effect
        ];
        var colValues = [
            getLocalisedAbilityName(loc, widget.ability),
            getLocalisedAbilityEffect(loc, widget.ability)
        ];

        for (int i = 0; i < colNames.length; ++i){
            ret.add(
                TableRow(
                    children: [
                        Text(
                            colNames[i],
                            style: statNameTextStyle
                        ),
                        Text(
                            colValues[i] ?? "Unknown",
                            style: statValueTextStyle
                        )
                    ]
                )
            );
        }

        return ret;
    }

    Future<void> _fetchPokemon() async{
        for (int i = 0; i < pokeCountPerPageInInfo; ++i){
            try{
                int id = int.parse(
                    Converter.urlToId(
                        widget.ability.pokemon![i].url!
                    )
                );
                Pokemon? pkmn = await PokeAPI.getObject<Pokemon>(id);
                if (pkmn != null){
                    _pokemonList.add(pkmn);
                    PokemonSpecie? specie = await PokeAPI.getObject<PokemonSpecie>(id);
                    if (specie != null){
                        _speciesMap[id] = specie;
                    }
                }
            } catch (e){
                debugPrint(e.toString());
                setState(
                    (){
                        _isLoading = false;
                    }
                );
            }
        }
        setState(
            (){
                _isLoading = false;
            }
        );
    }

    Padding _getAbilityInfo(AppLocalizations loc){
        return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                children: [
                    Table(
                        columnWidths: statTableColumnWidths,
                        children: _getAbilityDescChildren(loc)
                    ),
                    spacingBetweenStatsAndPKMN,
                    Text(
                        loc.can_use_ability,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    ),
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
                ]
            )
        );
    }

    @override
    Widget build(BuildContext context){
        var loc = AppLocalizations.of(context)!;
        return Scaffold(
            appBar: AppBar(
                title: Text(
                    loc.ability_info,
                    style: TextStyle(
                        color:Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                    )
                ),
                backgroundColor: Colors.red
            ),
            body: _isLoading ? const Center(
                child: CircularProgressIndicator()
            ) : _getAbilityInfo(loc)
        );
    }
}
