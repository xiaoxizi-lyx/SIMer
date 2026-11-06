import 'package:flutter/material.dart';

import '../../../widgets/feature_toggle_tile.dart';
import '../sim_form_draft.dart';

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key, required this.draft});

  final SimFormDraft draft;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final MapEntry(key: feature, value: item)
            in draft.features.entries)
          FeatureToggleTile(
            key: ValueKey(feature),
            featureName: feature.label,
            featureItem: item,
            onChanged: (updated) =>
                draft.update(() => draft.features[feature] = updated),
          ),
      ],
    );
  }
}
