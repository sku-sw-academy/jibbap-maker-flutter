class Shop{
  final String name;
  final String kind;
  final String rank;
  final String unit;
  final String price;
  final String week_price;
  final double values;
  String? image;

  Shop({required this.name, required this.kind, required this.rank,
  required this.unit, required this.price, required this.week_price,
  required this.values, this.image});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
        name: json['name'],
        kind: json['kind'],
        rank: json['rank'],
        unit: json['unit'],
        price: json['price'],
        week_price: json['week_price'],
        values: json['values'],
        image: json['image']
    );
  }
}