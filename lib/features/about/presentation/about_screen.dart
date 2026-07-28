import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/l10n/generated/app_localizations.dart';

/// spec.md section 10.2. Version/build come from the real package
/// manifest via `package_info_plus` rather than being hardcoded.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeAboutButton)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.appTitle,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimens.spacingMd),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final info = snapshot.data;
                  if (info == null) return const SizedBox.shrink();
                  return Text(
                    l10n.aboutVersion(info.version, info.buildNumber),
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                },
              ),
              const SizedBox(height: AppDimens.spacingLg),
              Text(
                l10n.aboutDescription,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
