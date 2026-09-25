class AppCalculations {
  // Kapas amount: weight × rate
  static double kapasAmount(double weight, double rate) {
    return weight * rate;
  }

  // Paani amount: hours × rate
  static double paaniAmount(double hours, double rate) {
    return hours * rate;
  }

  // Mazdoori amount: days × rate
  static double mazdoorAmount(double days, double rate) {
    return days * rate;
  }

  // Net Balance calculation
  static double netBalance({
    required double toReceive,
    required double toPay,
    required double received,
    required double paid,
  }) {
    return (toReceive - received) - (toPay - paid);
  }
}
