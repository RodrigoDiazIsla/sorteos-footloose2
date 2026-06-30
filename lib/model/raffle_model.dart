class RaffleModel {
  final String name;
  final int numberSpecWinners;
  final int countWinners;

  RaffleModel({
    required this.name,
    required this.numberSpecWinners,
    required this.countWinners,
  });

  RaffleModel copyWith({
    String? name,
    int? numberSpecWinners,
    int? countWinners,
  }) {
    return RaffleModel(
      name: name ?? this.name,
      numberSpecWinners: numberSpecWinners ?? this.numberSpecWinners,
      countWinners: countWinners ?? this.countWinners,
    );
  }
}
