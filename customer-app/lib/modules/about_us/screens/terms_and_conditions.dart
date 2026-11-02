import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:thewasher/core/design/components/k_states.dart';
import 'package:thewasher/core/design/liquid_glass.dart';
import 'package:thewasher/core/design/tokens.dart';
import 'package:thewasher/core/resources/strings_manager.dart';
import 'package:thewasher/modules/about_us/bloc/about_us_bloc.dart';
import 'package:thewasher/shared/components/snack_bar.dart';
import 'package:thewasher/utilties/navigator.dart';

final RegExp _isHtml = RegExp(r'<\/?[a-z][\s\S]*>', caseSensitive: false);

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KColors.of(context).background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: GlassBackButton(onPressed: () => pop(context)),
        title: Text(translate(AppStrings.termsAndConditions)),
      ),
      body: BlocProvider<AboutUsBloc>(
        create: (BuildContext context) =>
            AboutUsBloc()..add(GetTermsAndCondition()),
        child: BlocConsumer<AboutUsBloc, AboutUsState>(
          listener: (BuildContext context, AboutUsState state) {
            if (state.status == AboutUsStateStatus.error) {
              showSnackBar(buildContext: context, message: state.errorMessage!);
            }
          },
          builder: (BuildContext context, AboutUsState state) {
            if (state.status == AboutUsStateStatus.loading) {
              return const KSkeleton.details();
            }

            if (state.status == AboutUsStateStatus.success) {
              // Check if content is empty or null
              if (state.termsContent == null ||
                  state.termsContent!.trim().isEmpty) {
                return KEmptyState(
                  title: translate(AppStrings.noContent),
                  message: translate(AppStrings.termsAndConditionsEmptyMessage),
                  icon: Icons.description_outlined,
                  actionLabel: translate('retry'),
                  onAction: () {
                    context.read<AboutUsBloc>().add(GetTermsAndCondition());
                  },
                );
              }
            }

            final content = state.termsContent ?? '';
            final textStyle = KType.body.copyWith(
              color: KColors.of(context).text,
            );
            final brand = KColors.of(context).brand.toARGB32() & 0xFFFFFF;
            final linkHex = '#${brand.toRadixString(16).padLeft(6, '0')}';
            return SingleChildScrollView(
              padding: const EdgeInsets.all(KSpace.xl),
              // The dashboard saves formatted HTML; older terms are plain text.
              child: _isHtml.hasMatch(content)
                  ? HtmlWidget(
                      content,
                      textStyle: textStyle,
                      onTapUrl: (url) => launchUrl(
                        Uri.parse(url),
                        mode: LaunchMode.externalApplication,
                      ),
                      customStylesBuilder: (element) {
                        switch (element.localName) {
                          case 'h2':
                            return {
                              'font-size': '20px',
                              'font-weight': '600',
                              'margin': '16px 0 8px',
                            };
                          case 'h3':
                            return {
                              'font-size': '17px',
                              'font-weight': '600',
                              'margin': '12px 0 6px',
                            };
                          case 'a':
                            return {'color': linkHex};
                        }
                        return null;
                      },
                    )
                  : Text(content, style: textStyle),
            );
          },
        ),
      ),
    );
  }
}
