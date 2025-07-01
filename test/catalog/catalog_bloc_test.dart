import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mini_pos_checkout/src/catalog/bloc/catalog_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CatalogBloc (integration with real JSON)', () {
    late CatalogBloc bloc;

    setUp(() {
      bloc = CatalogBloc();
    });

    blocTest<CatalogBloc, CatalogState>(
      'loads items from assets/catalog.json',
      build: () => bloc,
      act: (b) => b.add(LoadCatalog()),
      expect: () =>
      [
        isA<CatalogLoaded>()
            .having((s) => s.items.length, 'items count', 20),
      ],
    );
    test('initial state is CatalogInitial', () {
      expect(bloc.state, isA<CatalogInitial>());
    });

    blocTest<CatalogBloc, CatalogState>(
      'emits loading and success',
      build: () => bloc,
      act: (b) => b.add(LoadCatalog()),
      expect: () => [
        isA<CatalogLoaded>()
            .having((s) => s.items.length, 'length', 2),
      ],
    );
  });

}