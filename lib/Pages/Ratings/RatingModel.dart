


class RatingInput {
  String? rate;
  String? comment;
  String? publicationId;
  String? orderId;
  String? whoRate;
  String? createdAt;

  RatingInput({this.comment, this.createdAt, this.orderId, this.publicationId, this.rate, this.whoRate});
    Map<String, dynamic> toJSON() {
          final Map<String, dynamic> data = new Map<String, dynamic>();
          data["rate"] = this.rate;
          data["comment"] = this.comment;
          data["publicationId"] = this.publicationId;
          data["orderId"] = this.orderId;
          data["whoRate"] = this.whoRate;
          data["createdAt"] = DateTime.now().toIso8601String();
          return data;
    }

}