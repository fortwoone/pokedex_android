import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pokedex/pages/pokemon.dart';
import 'package:pokedex/pages/moves.dart';
import 'package:pokedex/pages/talents_abilities.dart';
import 'package:pokedex/pages/history.dart';
import "package:pokedex/poke_icons.dart";

void main() {
  runApp(const MainApp());
}

// region Nav items with localisation
// These are needed, because if trying to initialise the text inside the main app state,
// the AppLocalizations class will not have been fully initialised, and so the app will
// crash upon building.
class _MoveNavItem extends StatelessWidget{
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: NavigationDestination(
                icon: Icon(PokeIcons.trainingMachine),
                label: AppLocalizations.of(context)!.moves,
            )
        );
    }
}

class _AbilityNavItem extends StatelessWidget{
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: NavigationDestination(
                icon: Icon(PokeIcons.ability),
                label: AppLocalizations.of(context)!.abilities,
            )
        );
    }
}

class _HistoryNavItem extends StatelessWidget{
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: NavigationDestination(
                icon: Icon(Icons.access_time_rounded),
                label: AppLocalizations.of(context)!.history
            )
        );
    }
}

// endregion

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
    int _pageIndex = 0;

    Widget _getBodyWidget(){
        switch (_pageIndex){
            case 0:
                return PokemonList();
            case 1:
                return Moves();
            case 2:
                return TalentInfo();
            case 3:
                return History();
            default:
                throw UnsupportedError("Invalid page index.");
        }
    }

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: "Pokédex",
            localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate, // Pour traduire les widgets Material
                GlobalWidgetsLocalizations.delegate, // Pour traduire les widgets génériques
                GlobalCupertinoLocalizations.delegate, // Pour traduire les widgets iOS (Cupertino)
            ],
            supportedLocales:[
                Locale("en", "US"),
                Locale("fr", "FR")
            ],
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
                    destinations: <Widget>[
                        NavigationDestination(
                            icon: Icon(PokeIcons.pokeball),
                            label: 'Pokémon',
                        ),
                        _MoveNavItem(),  // these are needed, or else the app will crash when trying to load the translations.
                        _AbilityNavItem(),
                        _HistoryNavItem()
                    ]
                ),
                body: _getBodyWidget()
            )
        );
    }
}
