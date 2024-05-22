class Price{
  String? id;
  int? itemCode;
  String? name;
  String? kindName;
  int? kindCode;
  int? rankCode;
  String? rankKind;
  String? unit;
  String? regday;
  String? regday_price;
  String? yesterday;
  String? week;
  String? month;
  String? year;
  String? avg_year;
  double? values;

  Price({required this.id, this.itemCode, this.kindName, this.kindCode, this.rankCode, this.rankKind, this.values,
     this.unit, this.regday, this.regday_price, this.yesterday, this.week, this.month, this.avg_year, this.year});

}