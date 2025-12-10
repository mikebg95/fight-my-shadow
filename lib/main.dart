import 'package:flutter/material.dart';

void main() {
  runApp(const FightMyShadowApp());
}

class FightMyShadowApp extends StatelessWidget {
  const FightMyShadowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fight My Shadow',
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFFFF5722), // Punchy orange-red
        secondary: const Color(0xFFFF6E40),
        surface: const Color(0xFF1A1A1A),
        background: const Color(0xFF0A0A0A),
        error: Colors.red.shade400,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Color(0xFFB0B0B0),
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFF808080),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // UI state for configuration
  int rounds = 3;
  int roundMinutes = 3;
  int roundSeconds = 0;
  int restMinutes = 1;
  int restSeconds = 0;
  Difficulty difficulty = Difficulty.intermediate;
  Intensity intensity = Intensity.medium;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header section with branding
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            // Main content
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 24),
                  _buildConfigurationCard(),
                  const SizedBox(height: 32),
                  _buildStartButton(),
                  const SizedBox(height: 20),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0A0A0A),
            const Color(0xFF0A0A0A).withOpacity(0.0),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App logo/name with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sports_martial_arts,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FIGHT MY SHADOW',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  Text(
                    'Build your session',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WORKOUT SETUP',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    letterSpacing: 1.5,
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 24),

            // Rounds
            _buildRoundsStepper(),
            const SizedBox(height: 24),

            // Round Duration
            _buildDurationPicker(
              label: 'Round Duration',
              minutes: roundMinutes,
              seconds: roundSeconds,
              onMinutesChanged: (value) => setState(() => roundMinutes = value),
              onSecondsChanged: (value) => setState(() => roundSeconds = value),
            ),
            const SizedBox(height: 24),

            // Rest Duration
            _buildDurationPicker(
              label: 'Rest Duration',
              minutes: restMinutes,
              seconds: restSeconds,
              onMinutesChanged: (value) => setState(() => restMinutes = value),
              onSecondsChanged: (value) => setState(() => restSeconds = value),
            ),
            const SizedBox(height: 32),

            // Difficulty
            _buildDifficultySelector(),
            const SizedBox(height: 24),

            // Intensity
            _buildIntensitySelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundsStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rounds',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                color: rounds > 1 ? Colors.white : Colors.white.withOpacity(0.3),
                onPressed: rounds > 1
                    ? () => setState(() => rounds--)
                    : null,
              ),
              Text(
                '$rounds',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 36,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                color: rounds < 12 ? Colors.white : Colors.white.withOpacity(0.3),
                onPressed: rounds < 12
                    ? () => setState(() => rounds++)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationPicker({
    required String label,
    required int minutes,
    required int seconds,
    required Function(int) onMinutesChanged,
    required Function(int) onSecondsChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTimeSelector(
                value: minutes,
                label: 'MIN',
                maxValue: 10,
                onChanged: onMinutesChanged,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeSelector(
                value: seconds,
                label: 'SEC',
                maxValue: 59,
                step: 15,
                onChanged: onSecondsChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSelector({
    required int value,
    required String label,
    required int maxValue,
    int step = 1,
    required Function(int) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 10,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: value > 0 ? () => onChanged((value - step).clamp(0, maxValue)) : null,
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: value > 0 ? Colors.white : Colors.white.withOpacity(0.3),
                  size: 18,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                value.toString().padLeft(2, '0'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: value < maxValue ? () => onChanged((value + step).clamp(0, maxValue)) : null,
                child: Icon(
                  Icons.keyboard_arrow_up,
                  color: value < maxValue ? Colors.white : Colors.white.withOpacity(0.3),
                  size: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Difficulty',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: Difficulty.values.map((diff) {
            final isSelected = difficulty == diff;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildChip(
                  label: diff.label,
                  isSelected: isSelected,
                  onTap: () => setState(() => difficulty = diff),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIntensitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intensity',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: Intensity.values.map((intens) {
            final isSelected = intensity == intens;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _buildChip(
                  label: intens.label,
                  subtitle: intens.subtitle,
                  isSelected: isSelected,
                  onTap: () => setState(() => intensity = intens),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : const Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.white.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Colors.white.withOpacity(0.8)
                      : Colors.white.withOpacity(0.4),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Start workout functionality
          },
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Text(
                'START WORKOUT',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Enums for difficulty and intensity
enum Difficulty {
  beginner('Beginner'),
  intermediate('Intermediate'),
  advanced('Advanced');

  final String label;
  const Difficulty(this.label);
}

enum Intensity {
  low('Low', 'Chill'),
  medium('Medium', 'Focused'),
  high('High', 'Relentless');

  final String label;
  final String subtitle;
  const Intensity(this.label, this.subtitle);
}
