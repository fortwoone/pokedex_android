/*
Localisation utility functions.
 */

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import "package:flutter/material.dart";
import "package:pokeapi/model/utils/converter.dart";
import "package:pokeapi/model/pokemon/ability.dart";
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

class _FlavourTextEntry{
    late int versionGrpId;
    late String content;

    _FlavourTextEntry.fromMFTE(MoveFlavorTextEntry obj){
        content = obj.flavorText!;
        versionGrpId = int.parse(obj.versionGroup!.id!);
    }

    _FlavourTextEntry.fromAFTE(AbilityFlavorTextEntries obj){
        content = obj.flavorText!;
        versionGrpId = int.parse(obj.versionGroup!.id!);
    }
}

int _compareFTE(_FlavourTextEntry a, _FlavourTextEntry b){
    return a.versionGrpId - b.versionGrpId;
}

List<_FlavourTextEntry> _getFlavourTextEntries<T>(String locale, T obj){
    if (T != Move && T != Ability) {
        throw UnsupportedError("Wrong type.");
    }
    List<_FlavourTextEntry> ret = [];
    if (T == Move) {
        for (final flavTxtEntry in (obj as Move).flavorTextEntries!){
            if (flavTxtEntry.language?.name != null && flavTxtEntry.language!.name!.startsWith(locale)){
                ret.add(
                    _FlavourTextEntry.fromMFTE(flavTxtEntry)
                );
            }
        }
    }
    else{
        for (final flavTxtEntry in (obj as Ability).flavorTextEntries!){
            if (flavTxtEntry.language?.name != null && flavTxtEntry.language!.name!.startsWith(locale)){
                ret.add(
                    _FlavourTextEntry.fromAFTE(flavTxtEntry)
                );
            }
        }
    }

    ret.sort(_compareFTE);
    return ret;
}

String? getLocalisedMoveEffect(AppLocalizations loc, Move move){
    // ALGORITHM:
    /*
    1. First, look through move.effect_entries to check for existence of a
        short_effect entry corresponding to the current locale.
    2. If none exist, look for the flavour text entry with the highest version group ID
        corresponding to the current locale, and use that if it exists.
    3. Return null if nothing was found.
     */
    for (final effEntryObj in move.effectEntries!){
        if (effEntryObj.language?.name != null && effEntryObj.language!.name!.startsWith(loc.localeName)){
            return effEntryObj.shortEffect;
        }
    }
    var flavs = _getFlavourTextEntries<Move>(loc.localeName, move);
    try{
        return flavs.last.content;
    }
    catch (e) {
        debugPrint(e.toString());
        return null;
    }
}

/// Returns the translated name for an ability.
String? getLocalisedAbilityName(AppLocalizations loc, Ability ability){
    for (final nameObj in ability.names!){
        if (nameObj.language?.name != null && nameObj.language!.name!.startsWith(loc.localeName)){
            return nameObj.name!;
        }
    }
    return null;
}

String? getLocalisedAbilityEffect(AppLocalizations loc, Ability ability){
    // ALGORITHM:
    /*
    1. First, look through ability.effect_entries to check for existence of a
        short_effect entry corresponding to the current locale.
    2. If none exist, look for the flavour text entry with the highest version group ID
        corresponding to the current locale, and use that if it exists.
    3. Return null if nothing was found.
     */
    for (final effEntryObj in ability.effectEntries!){
        if (effEntryObj.language?.name != null && effEntryObj.language!.name!.startsWith(loc.localeName)){
            return effEntryObj.shortEffect;
        }
    }
    var flavs = _getFlavourTextEntries<Ability>(loc.localeName, ability);
    try{
        return flavs.last.content;
    }
    catch (e) {
        debugPrint(e.toString());
        return null;
    }
}
