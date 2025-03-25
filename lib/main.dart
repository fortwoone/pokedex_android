import 'package:flutter/material.dart';
import 'package:pokedex/pages/pokemon.dart';
import 'package:pokedex/pages/moves.dart';
import 'package:pokedex/pages/talents_abilities.dart';
import 'package:pokedex/pages/history.dart';
import "package:pokedex/poke_ball_icons.dart";

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Pokédex",
      theme: ThemeData(
          fontFamily: "Lato"
      ),
      home: Scaffold(
        appBar: AppBar(
            title: Center(
                child: const Text(
                    "Pokédex",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold
                    )
                )
            ),
            backgroundColor: Colors.red
        ),
        bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index){
                setState(
                    (){
                        _pageIndex = index;
                    }
                );
            },
            indicatorColor: Colors.redAccent,
            selectedIndex: _pageIndex,
            destinations: const <Widget>[
                NavigationDestination(
                    selectedIcon: Icon(PokeBall.icon),
                    icon: Icon(PokeBall.icon),
                    label: 'Pokémon',
                ),
                NavigationDestination(
                    icon: Icon(PokeBall.icon),
                    label: 'Moves',
                ),
                NavigationDestination(
                    icon: Icon(PokeBall.icon),
                    label: 'Abilities',
                ),
                NavigationDestination(
                    icon: Icon(Icons.access_time_rounded),
                    label: "History"
                )
            ]
          ),
          body: <Widget>[
              PokemonList(),
              Moves(),
              TalentInfo(),
              History()
          ][_pageIndex]
      )
    );
  }
}
