class UserProfile {
  String? uid;
  String? name;
  String? pfpUrl;

  UserProfile({
    required this.uid,
    required this.name,
    required this.pfpUrl,
  });

  UserProfile.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    pfpUrl = json['pfpURL'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['name'] = name;
    data['pfpURL'] = pfpUrl;
    return data;
  }
}
