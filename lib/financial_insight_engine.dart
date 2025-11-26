import 'dart:math';

import 'dart:math';

class FinancialInsightEngine {
  // Input variables
  double incomeTotal;
  double spendingTotal;
  late double surplus;
  late double score;
  double largestTransaction;
  double lastCredit;
  double dailyAverage;
  int spendingSpikes;
  String monthName;

  FinancialInsightEngine({
    required this.incomeTotal,
    required this.spendingTotal,
    required this.largestTransaction,
    required this.lastCredit,
    required this.dailyAverage,
    required this.spendingSpikes,
    required this.monthName,
  }) {
    surplus = incomeTotal - spendingTotal;
    score = max((surplus / incomeTotal) * 100, 0);
  }
  // Determine tier based on score
  String get tier {
    if (score >= 80) return "PRIME";
    if (score >= 60) return "STABLE";
    if (score >= 40) return "FRAGILE";
    return "CRITICAL";
  }

  // Content pools
  static final List<String> OPENINGS_PRIME = [
    "You're in the Prime zone this month, holding a strong financial position overall.",
    "Your finances sit at an Elite level right now, showing excellent control.",
    "You're operating with high-level stability this cycle.",
    "Your profile looks exceptionally strong, barely any pressure showing.",
  ];

  static final List<String> OBS_PRIME = [
    "Your spending stayed consistently low throughout the entire month.",
    "Your income arrivals were spaced out but reliable, keeping your flow smooth.",
    "Your daily average spend stayed controlled with no major spikes.",
    "You maintained a wide gap between earnings and expenses.",
    "Your end-of-month surplus is impressive.",
  ];

  static final List<String> INSIGHTS_PRIME = [
    "Your rhythm shows someone who plans ahead, not someone reacting.",
    "This pattern reflects long-term stability, not short-term luck.",
    "Your spending curve is calm and predictable.",
    "Even big credits didn't destabilize your flow.",
  ];

  static final List<String> SUGGESTIONS_PRIME = [
    "You could channel part of this surplus into long-term reserves.",
    "Try outlining next month's priorities early while you have breathing room.",
    "Automated savings would fit your current flow perfectly.",
    "Allocating a small percentage into goals could boost long-term growth.",
    "Tightening one minor category could push you from Prime to Peak.",
  ];

  // STABLE tier content
  static final List<String> OPENINGS_STABLE = [
    "You're sitting in a Stable range this month — overall things look solid.",
    "Your financial health is balanced and well-controlled.",
    "This cycle places you in a comfortable zone with no major strain.",
    "You're maintaining a steady pattern across the month.",
  ];

  static final List<String> OBS_STABLE = [
    "Your income supported your movement well enough to avoid pressure points.",
    "Some days were heavier, but they didn't break your flow.",
    "You kept a manageable gap between what you earned and spent.",
    "There were spikes, but nothing too severe.",
    "Your surplus is decent despite mid-month jumps.",
    "Your spending curve stayed within healthy limits.",
  ];

  static final List<String> INSIGHTS_STABLE = [
    "Your pattern shows conscious spending and good awareness.",
    "You're balancing comfort and discipline well.",
    "You handled fluctuations without losing stability.",
    "Even with inconsistencies, your core rhythm stayed intact.",
  ];

  static final List<String> SUGGESTIONS_STABLE = [
    "Tighten 1–2 categories to slowly push into Prime.",
    "Try a soft spending boundary around mid-month.",
    "Track one recurring expense to boost your surplus.",
    "A tiny weekly adjustment could lift your score next cycle.",
    "Start building a small emergency reserve if you haven't yet.",
  ];

  // FRAGILE tier content
  static final List<String> OPENINGS_FRAGILE = [
    "Your financial health feels fragile this month — manageable but sensitive.",
    "You're in a tense zone where income and spending are a bit too close.",
    "Your numbers show a pattern that needs gentle correction.",
    "This month sits in a pressure area that can flip easily.",
  ];

  static final List<String> OBS_FRAGILE = [
    "Your expenses closely tracked your income, leaving little buffer.",
    "There were noticeable spikes pushing your limits.",
    "Some days were unusually heavy and shaped your whole month.",
    "Your surplus is thin, giving limited breathing room.",
    "One or two big transactions influenced your score heavily.",
    "Income arrived, but spending kept catching up.",
  ];

  static final List<String> INSIGHTS_FRAGILE = [
    "Your flow shows you're operating without much margin.",
    "This pattern can tilt negative if surprises appear.",
    "It's stable enough to manage but not stable enough to relax.",
    "Your curve suggests awareness but inconsistent control.",
  ];

  static final List<String> SUGGESTIONS_FRAGILE = [
    "Set weekly spending caps to regain structure.",
    "Reduce one major category to lift your next score.",
    "Pause one non-essential subscription next month.",
    "Track where mid-month spikes come from — that's your key.",
    "Hold onto part of any new inflow to rebuild your buffer.",
  ];

  // CRITICAL tier content
  static final List<String> OPENINGS_CRITICAL = [
    "This month falls into a critical zone — your finances were under real strain.",
    "You're currently in a dire range with spending outweighing income.",
    "Your financial health is unstable this cycle.",
    "This was a heavy month, with expenses pushing past safe levels.",
  ];

  static final List<String> OBS_CRITICAL = [
    "Your expenses exceeded your income significantly.",
    "Multiple spikes added pressure across the month.",
    "Your daily average stayed high compared to what you earned.",
    "Spending overtook income quickly after each inflow.",
    "There wasn't enough buffer to maintain stability.",
    "Large transactions heavily shaped your decline.",
  ];

  static final List<String> INSIGHTS_CRITICAL = [
    "Your pattern isn't sustainable long-term.",
    "You're overwhelmed by the inflow/outflow mismatch, not failing.",
    "This curve suggests reactive spending rather than planned.",
    "Recovery is possible, but it needs deliberate steps.",
  ];

  static final List<String> SUGGESTIONS_CRITICAL = [
    "Start by reducing one large recurring category.",
    "Adopt strict weekly limits until things improve.",
    "Keep most of any new income unused to rebuild your buffer.",
    "List your top three expenses — the culprit usually hides there.",
    "Even small weekly cuts can lift you out of the critical zone.",
  ];

  // Helper method to get random element from list
  String _getRandom(List<String> list) {
    final random = Random();
    return list[random.nextInt(list.length)];
  }

  // Generate the complete insight
  String generateInsight() {
    final String tierName = tier;
    
    // Get base components
    String opening = _getRandom(_getOpeningsList(tierName));
    String observation = _getRandom(_getObservationsList(tierName));
    
    // Add second observation 50% of the time
    if (Random().nextBool()) {
      String secondObs = _getRandom(_getObservationsList(tierName));
      // Ensure we don't repeat the same observation
      while (secondObs == observation) {
        secondObs = _getRandom(_getObservationsList(tierName));
      }
      observation += " ${secondObs}";
    }
    
    String insight = _getRandom(_getInsightsList(tierName));
    String suggestion = _getRandom(_getSuggestionsList(tierName));

    // Apply dynamic inserts
    String dynamicInserts = _applyDynamicInserts();

    return "$opening $observation $insight $suggestion$dynamicInserts";
  }

  // Helper methods to get the right content lists
  List<String> _getOpeningsList(String tier) {
    switch (tier) {
      case "PRIME": return OPENINGS_PRIME;
      case "STABLE": return OPENINGS_STABLE;
      case "FRAGILE": return OPENINGS_FRAGILE;
      case "CRITICAL": return OPENINGS_CRITICAL;
      default: return OPENINGS_STABLE;
    }
  }

  List<String> _getObservationsList(String tier) {
    switch (tier) {
      case "PRIME": return OBS_PRIME;
      case "STABLE": return OBS_STABLE;
      case "FRAGILE": return OBS_FRAGILE;
      case "CRITICAL": return OBS_CRITICAL;
      default: return OBS_STABLE;
    }
  }

  List<String> _getInsightsList(String tier) {
    switch (tier) {
      case "PRIME": return INSIGHTS_PRIME;
      case "STABLE": return INSIGHTS_STABLE;
      case "FRAGILE": return INSIGHTS_FRAGILE;
      case "CRITICAL": return INSIGHTS_CRITICAL;
      default: return INSIGHTS_STABLE;
    }
  }

  List<String> _getSuggestionsList(String tier) {
    switch (tier) {
      case "PRIME": return SUGGESTIONS_PRIME;
      case "STABLE": return SUGGESTIONS_STABLE;
      case "FRAGILE": return SUGGESTIONS_FRAGILE;
      case "CRITICAL": return SUGGESTIONS_CRITICAL;
      default: return SUGGESTIONS_STABLE;
    }
  }

  // Apply dynamic inserts based on data
  String _applyDynamicInserts() {
    List<String> inserts = [];

    if (lastCredit > incomeTotal * 0.3) {
      inserts.add(" That ₦${lastCredit.toStringAsFixed(2)} inflow boosted your buffer.");
    }

    if (spendingSpikes > 3) {
      inserts.add(" Your month had multiple spikes that shaped your pattern.");
    }

    if (surplus < 0) {
      inserts.add(" Your negative surplus added pressure this cycle.");
    }

    if (largestTransaction > spendingTotal * 0.4) {
      inserts.add(" One major transaction of ₦${largestTransaction.toStringAsFixed(2)} significantly impacted your flow.");
    }

    // Add month reference
    inserts.add(" Looking at $monthName's patterns:");

    return inserts.join();
  }
}