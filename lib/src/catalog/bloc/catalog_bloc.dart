import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/item.dart';

part '../bloc/catalog_event.dart';
part '../bloc/catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc() : super(CatalogInitial()) {
    on(_onLoadCatalog);
  }

  Future _onLoadCatalog(
      LoadCatalog event, Emitter emit) async {
    try {
      final data = await rootBundle.loadString('assets/catalog.json');
      final list = (json.decode(data) as List)
          .map((e) => Item.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(CatalogLoaded(list));
    } catch (e) {
      emit(CatalogError(e.toString()));
    }
  }
}
