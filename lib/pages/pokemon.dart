// a page to display all pokemons or a specific pokemon
// we use the pokeapi package to get the data

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pokeapi/model/pokemon/pokemon-specie.dart';
import 'package:pokeapi/model/pokemon/pokemon.dart';
import 'package:pokeapi/pokeapi.dart';

/// Returns the local name for the Pokémon species.
String? _getLocalPokemonName(PokemonSpecie specie){
    return specie.names![Platform.localeName.startsWith('en') ? 8 : 4].name;
}

final POKE_COUNT_PER_PAGE = 20;

class PokemonList extends StatefulWidget {
    const PokemonList({super.key});

    @override
    PokemonListState createState() => PokemonListState();
}

class PokemonListState extends State<PokemonList> {
    List<Pokemon> _pokemonList = [];
    List<PokemonSpecie> _speciesList = [];
    bool _isLoading = true;

    @override
    void initState() {
      super.initState();
      _fetchPokemonList();
    }

    Future<void> _fetchPokemonList() async {
      try {
        // Get all pokemon
        final pokemonList = await PokeAPI.getObjectList<Pokemon>(1, POKE_COUNT_PER_PAGE);
        final speciesList = await PokeAPI.getObjectList<PokemonSpecie>(1, POKE_COUNT_PER_PAGE);
        setState(() {
          _pokemonList = pokemonList.cast<Pokemon>();
          _speciesList = speciesList.cast<PokemonSpecie>();
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
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _pokemonList.length,
                    itemBuilder: (context, index) {
                        final pokemon = _pokemonList[index];
                        final species = _speciesList[index];
                        String? name = _getLocalPokemonName(species);
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
        );
    }
}

class PokemonDetail extends StatelessWidget {
    final Pokemon pokemon;
    final PokemonSpecie specie;

    final TextStyle statNameTextStyle = const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold
    );
    final TextStyle statValueTextStyle = const TextStyle(
        fontSize: 18
    );

    const PokemonDetail({required this.pokemon, required this.specie, super.key});

    List<Widget> _getPokeChildrenList(AppLocalizations loc){
        String? name = _getLocalPokemonName(specie);

        var statNames = [
            loc.hp,
            loc.attack,
            loc.defence,
            loc.spatk,
            loc.spdef,
            loc.speed
        ];

        var statNameColChildren = <Widget>[];
        var statValueColChildren = <Widget>[];

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
                    fontSize: 20
                )
            ),
        ];

        for (int i = 0; i < statNames.length; ++i){
            statNameColChildren.add(
                Text(
                    statNames[i],
                    style: statNameTextStyle
                )
            );
            statValueColChildren.add(
                Text(
                    pokemon.stats![i].baseStat.toString(),
                    style: statValueTextStyle
                )
            );
        }

        ret.add(
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: statNameColChildren
                        )
                    ),
                    Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: statValueColChildren
                        )
                    )
                ]
            )
        );

        return ret;
    }

    @override
    Widget build(BuildContext context) {
        String? name = _getLocalPokemonName(specie);

        AppLocalizations loc = AppLocalizations.of(context)!;
        return Scaffold(
            appBar: AppBar(
                title: Center(
                    child: Text(
                        loc.poke_info,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold
                        )
                    ),
                ),
                backgroundColor: Colors.red,
            ),
            body: Center(
                child: Column(
                    children: _getPokeChildrenList(loc)
                ),
            ),
        );
    }
}