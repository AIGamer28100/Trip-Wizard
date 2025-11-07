import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class LicenseScreen extends StatelessWidget {
  const LicenseScreen({super.key});

  Future<String> _loadLicense() async {
    try {
      return await rootBundle.loadString('assets/licenses/REPO_LICENSE.txt');
    } catch (e) {
      return 'LICENSE file not found.\n\nAdd your license text at assets/licenses/REPO_LICENSE.txt and ensure it is listed under flutter->assets in pubspec.yaml.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).licenseTitle)),
      body: FutureBuilder<String>(
        future: _loadLicense(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final text = snapshot.data ?? '';
          return FutureBuilder<_BuildMeta>(
            future: _loadBuildMeta(),
            builder: (context, metaSnap) {
              final meta = metaSnap.data;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SelectionArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            text,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'monospace',
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Divider(color: theme.colorScheme.outlineVariant),
                      const SizedBox(height: 8),
                      Text(
                        'Version: ${meta?.version ?? 'unknown'}  •  Commit: ${meta?.shortHash ?? 'unknown'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<_BuildMeta> _loadBuildMeta() async {
    // Version/build from package_info_plus
    final info = await PackageInfo.fromPlatform();
    // Optional commit from environment/asset
    const defineCommit = String.fromEnvironment('GIT_COMMIT');
    String? commit = defineCommit.isNotEmpty ? defineCommit : null;
    if (commit == null) {
      try {
        final json = await rootBundle.loadString('assets/build_info.json');
        // simple parse to extract commit (avoid adding json package)
        final match = RegExp('"commit"\s*:\s*"([^"]+)"').firstMatch(json);
        if (match != null) commit = match.group(1);
      } catch (_) {}
    }
    final short = commit != null && commit.length >= 7
        ? commit.substring(0, 7)
        : null;
    return _BuildMeta(
      version: '${info.version}+${info.buildNumber}',
      shortHash: short,
    );
  }
}

class _BuildMeta {
  final String version;
  final String? shortHash;
  _BuildMeta({required this.version, this.shortHash});
}
