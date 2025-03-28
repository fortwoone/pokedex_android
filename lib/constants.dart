/*
Various constants needed for the app.
 */
import "package:flutter/material.dart";

final pokeCountPerPage = 20;
final pokeCountPerPageInInfo = pokeCountPerPage / 2;

final TextStyle statNameTextStyle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold
);
final TextStyle statValueTextStyle = const TextStyle(
    fontSize: 18
);

final statTableColumnWidths = const{
    0: FlexColumnWidth(1),
    1: FlexColumnWidth(2)
};

final spacingBetweenStatsAndPKMN = const SizedBox(height: 20);
