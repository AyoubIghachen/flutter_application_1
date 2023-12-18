class Point {
  String? id;
  String jsonData;
  String? idConstruction;
  String? idAgent;

  Point({this.id, required this.jsonData, this.idConstruction, this.idAgent});

  factory Point.fromMap(Map<String, dynamic> map) => Point(
      id: map['_id'].toString(),
      jsonData: map['jsonData'],
      idConstruction: map['idConstruction'],
      idAgent: map['idAgent']);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'jsonData': jsonData,
      if (idConstruction != null) 'idConstruction': idConstruction,
      if (idAgent != null) 'idAgent': idAgent,
    };
  }
}
