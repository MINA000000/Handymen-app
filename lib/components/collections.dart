class HandymanFieldsName {
  static String get category => 'category';
  static String get description => 'description';
  static String get email => 'email';
  static String get explicitSkills => 'explicit_skills';
  static String get fullName => 'full_name';
  static String get implicitSkills => 'implicit_skills';
  static String get latitude => 'latitude';
  static String get longitude => 'longitude';
  static String get phoneNumber => 'phone_number';
  static String get profilePicture => 'profile_picture';
  static String get projectsCount => 'projects_count';
  static String get ratingAverage => 'rating_average';
  static String get ratingCount => 'rating_count';
  static String get timestamp => 'timestamp';
}

class CommentsFieldsName {
  static String get clientName => 'client_name';
  static String get comment => 'comment';
  static String get time => 'time';
  static String get rate => 'rate';
  static String get clientId => 'client_id';
  static String get requestId => 'request_id';
}

class WorkPictures {
  static String get imageUrl => 'image_url';
  static String get timestamp => 'timestamp';
}

class ClientFieldsName {
  static String get email => 'email';
  static String get fullName => 'full_name';
  static String get latitude => 'latitude';
  static String get longitude => 'longitude';
  static String get phoneNumber => 'phone_number';
  static String get timestamp => 'timestamp';
}

class RequestFieldsName {
  static String get assignedHandyman => 'assigned_handyman';
  static String get category => 'category';
  static String get clientWantingHandymen => 'client_wanting_handymen';
  static String get handymenWantingRequest => 'handymen_wanting_request';
  static String get imageURL => 'imageURL';
  static String get request => 'request';
  static String get status => 'status';
  static String get timestamp => 'timestamp';
  static String get uid => 'uid';
  static String get assignedHandymanName => 'assigned_hanyman_name';
}

class CollectionsNames {
  static String get clientsInformation => "client_information";
  static String get handymenInformation => "handymen_information";
  static String get requestInformation => "request_information";
  static String get workPictures => "work_pictures";
  static String get comments => "comments";
  static bool isExit = false;
}
