import 'package:flutter/material.dart';
import "package:pokeapi/model/pokemon/ability.dart";

class TalentInfo extends StatefulWidget{
    const TalentInfo({super.key});

  @override
  State<TalentInfo> createState() => _TalentInfoState();
}

class _TalentInfoState extends State<TalentInfo> {
    // TODO: implement the data fetching stuff.
    @override
    Widget build(BuildContext context){
        return const Center(
            child: Text("DUMMY")
        );
    }
}