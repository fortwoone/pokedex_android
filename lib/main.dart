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

// region Drawer items
class _MainDrawerHeader extends StatelessWidget{
    @override
    Widget build(BuildContext context){
        AppLocalizations loc = AppLocalizations.of(context)!;
        return const DrawerHeader(
            decoration: BoxDecoration(color: Colors.red),
            child: Text(
                "Menu",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                )
            )
        );
    }
}

class _AboutScreen extends StatelessWidget{
    @override
    Widget build(BuildContext context){
        var loc = AppLocalizations.of(context)!;
        return Scaffold(
            appBar: AppBar(
                leading: BackButton(
                    onPressed: (){
                        Navigator.pop(context);
                    }
                ),
                title: Text(
                    loc.about,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                    )
                ),
                backgroundColor: Colors.red
            ),
            body: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                        Text(
                            loc.appTitle,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                            )
                        ),
                        Text(
                            loc.made_by,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            )
                        ),
                        Text(
                            loc.devs,
                            style: TextStyle(
                                fontSize: 16
                            )
                        ),
                        SizedBox(
                            width: 15,
                            height: 16
                        ),
                        Center(
                            child: Text(
                                loc.pokemon_legal,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold
                                )
                            )
                        )
                    ]
                )
            )
        );
    }
}

class SettingsScreen extends StatelessWidget{
    // TODO: make it impact how the app works, and save the settings.
    @override
    Widget build(BuildContext context) {
        AppLocalizations loc = AppLocalizations.of(context)!;
        return Scaffold(
            appBar: AppBar(
                backgroundColor: Colors.red,
                leading: BackButton(
                    onPressed: (){
                        Navigator.pop(context);
                    }
                ),
                title: Text(
                    loc.settings,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                    )
                )
            )
        );
    }
}

class _SettingsDrawerItem extends StatelessWidget{
    @override
    Widget build(BuildContext context) {
        return ListTile(
            title: Text(
                AppLocalizations.of(context)!.settings
            ),
            onTap: (){
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingsScreen()
                    )
                );
            }
        );
    }
}

class _AboutDrawerItem extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(
            AppLocalizations.of(context)!.about
        ),
        onTap: (){
            Navigator.pop(context);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => _AboutScreen()
                )
            );
        }
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
                drawer: Drawer(
                    child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                            _MainDrawerHeader(),
                            _AboutDrawerItem(),
                            _SettingsDrawerItem()
                        ]
                    )
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
