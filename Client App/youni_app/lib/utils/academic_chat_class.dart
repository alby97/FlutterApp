class AcademicChatModel {
  String id, department, courseName, courseType, year, cfu, teaching;

  AcademicChatModel(
      {this.id,
      this.department,
      this.courseName,
      this.courseType,
      this.year,
      this.cfu,
      this.teaching});

  AcademicChatModel.fromJson(Map<String, dynamic> jsonData)
      : id = jsonData["id"],
        department = jsonData["department"],
        courseName = jsonData["course_name"],
        courseType = jsonData["course_type"],
        year = jsonData["year_regulation"],
        cfu = jsonData["cfu"],
        teaching = jsonData["teaching"];

  @override
  String toString() {
    return courseName +
        " " +
        courseType +
        " " +
        year +
        " " +
        cfu +
        " " +
        teaching;
  }

  String chatName() {
    return courseName +
        "_" +
        courseType +
        "_" +
        year +
        "_" +
        cfu +
        "_" +
        teaching;
  }
}
