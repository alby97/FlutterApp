

class Classroom {
  String name, department, building, floor, seatsMax;
  
  Classroom({this.name, this.department, this.building, this.floor, this.seatsMax});

  Classroom.fromJson(Map<String, dynamic> json):
  name = json["name"],
  department = json["department"],
  building = json["building"],
  floor = json["floor"],
  seatsMax = json["seats_max"];

}