class PersonDetails {
  final int? age;
  final String? gender;
  final List<String> interests;
  final String? occasion;
  final String? budget;
  final String? relationship;
  final String? additionalNotes;

  PersonDetails({
    this.age,
    this.gender,
    this.interests = const [],
    this.occasion,
    this.budget,
    this.relationship,
    this.additionalNotes,
  });

  Map<String, dynamic> toJson() => {
        'age': age,
        'gender': gender,
        'interests': interests,
        'occasion': occasion,
        'budget': budget,
        'relationship': relationship,
        'additional_notes': additionalNotes,
      };
}

class GiftSuggestionRequest {
  final PersonDetails personDetails;

  GiftSuggestionRequest({required this.personDetails});

  Map<String, dynamic> toJson() => {
        'person_details': personDetails.toJson(),
      };
}

class GiftSuggestionResponse {
  final List<String> giftSuggestions;

  GiftSuggestionResponse({required this.giftSuggestions});

  factory GiftSuggestionResponse.fromJson(Map<String, dynamic> json) {
    return GiftSuggestionResponse(
      giftSuggestions: List<String>.from(json['gift_suggestions']),
    );
  }
}
