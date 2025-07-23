



class ReportInput {
  String? type;
  String? userReported;
  String? userReporting;
  String? description;

  ReportInput({this.description, this.type,  this.userReported, this.userReporting});

      Map<String, dynamic> toJSON() {
          final Map<String, dynamic> data = new Map<String, dynamic>();
          data["type"] = this.type;
          data["userReported"] = this.userReported;
          data["userReporting"] = this.userReporting;
          data["description"] = this.description;

          return data;
    }
}