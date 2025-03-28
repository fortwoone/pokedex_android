import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import "package:pokeapi/model/pokemon/ability.dart";
import "package:pokeapi/pokeapi.dart";
import "package:pokedex/constants.dart";
import "package:pokedex/localisation_utils.dart";

class TalentInfo extends StatefulWidget{
    const TalentInfo({super.key});

    @override
    State<TalentInfo> createState() => _TalentInfoState();
}

class _TalentInfoState extends State<TalentInfo> {
    // TODO: implement the data fetching stuff.
    List<Ability> _abilitiesList = [];
    bool _isLoading = true;

    @override
    void initState(){
        super.initState();
        _fetchAbilityList();
    }

    Future<void> _fetchAbilityList() async{
        try {
            final abilitiesList = await PokeAPI.getObjectList<Ability>(
                1, pokeCountPerPage
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


    @override
    Widget build(BuildContext context){
        return const Center(
            child: Text("DUMMY")
        );
    }
}
