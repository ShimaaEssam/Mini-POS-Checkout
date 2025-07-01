import 'package:equatable/equatable.dart';

class Item extends Equatable {
  final String id;
  final String name;
  final double price;

  const Item({required this.id, required this.name, required this.price});

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'] ,
    name: json['name'],
    price: json['price'].toDouble(),
  );

  @override
  List get props => [id, name, price];
}