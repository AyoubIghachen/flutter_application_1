class Construction {
  String? id;
  String contact;
  String type;
  String jsonData;
  String idPoint;

  Construction(
      {this.id,
      required this.contact,
      required this.type,
      required this.jsonData,
      required this.idPoint});

  factory Construction.fromMap(Map<String, dynamic> map) => Construction(
      id: map['_id'].toString(),
      contact: map['contact'],
      type: map['type'],
      jsonData: map['jsonData'],
      idPoint: map['idPoint']);

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'contact': contact,
      'type': type,
      'jsonData': jsonData,
      'idPoint': idPoint,
    };
  }
}
