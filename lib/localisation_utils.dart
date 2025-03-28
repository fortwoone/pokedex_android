/*
Localisation utility functions.
 */

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pokeapi/model/pokemon/pokemon-specie.dart';
import 'package:pokeapi/model/move/move.dart';

/// Returns the local name for the Pokémon species.
String? getLocalPokemonName(AppLocalizations loc, PokemonSpecie specie){
    for (final name in specie.names!){
        if (name.language?.name != null && name.language!.name!.startsWith(loc.localeName)) {
            return name.name!;
        }
    }
    return null;
}

/// Returns the translated name for a move.
String? getLocalisedMoveName(AppLocalizations loc, Move move){
    for (final name in move.names!){
        if (name.language?.name != null && name.language!.name!.startsWith(loc.localeName)){
            return name.name!;
        }
    }
    return null;
}
