import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../liquid_glass.dart';
import '../tokens.dart';
import 'k_button.dart';

/// Shown when a list or screen has nothing to show yet.
class KEmptyState extends StatelessWidget {
  const KEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => _StateLayout(
    icon: icon,
    title: title,
    message: message,
    action: actionLabel == null
        ? null
        : KButton(label: actionLabel!, onPressed: onAction, expand: false),
  );
}

/// Shown while content loads.
class KLoadingState extends StatelessWidget {
  const KLoadingState({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(KSpace.xxl),
      child: GlassTokens.useNative
          ? const CupertinoActivityIndicator(radius: 14)
          : const CircularProgressIndicator(),
    ),
  );
}

/// Shown when loading failed; offers a retry.
class KErrorState extends StatelessWidget {
  const KErrorState({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => _StateLayout(
    icon: Icons.wifi_off_rounded,
    title: message,
    action: KButton(
      key: const ValueKey<String>('k-error-retry'),
      label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      variant: KButtonVariant.secondary,
      onPressed: onRetry,
      expand: false,
    ),
  );
}

class _StateLayout extends StatelessWidget {
  const _StateLayout({
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final KColors c = KColors.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 48, color: c.textSecondary),
            const SizedBox(height: KSpace.m),
            Text(
              title,
              textAlign: TextAlign.center,
              style: KType.headline.copyWith(color: c.text),
            ),
            if (message != null) ...<Widget>[
              const SizedBox(height: KSpace.xs),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: KType.subhead.copyWith(color: c.textSecondary),
              ),
            ],
            if (action != null) ...<Widget>[
              const SizedBox(height: KSpace.l),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
