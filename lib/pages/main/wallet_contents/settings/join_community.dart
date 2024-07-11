import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qubic_wallet/components/change_foreground.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

class JoinCommunity extends StatefulWidget {
  const JoinCommunity({super.key});

  @override
  State<JoinCommunity> createState() => _JoinCommunityState();
}

class _JoinCommunityState extends State<JoinCommunity> {
  Widget getHeader() {
    return Padding(
        padding: const EdgeInsets.only(
            left: ThemePaddings.normalPadding,
            right: ThemePaddings.normalPadding,
            top: ThemePaddings.hugePadding,
            bottom: ThemePaddings.smallPadding),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [Text("Join Community", style: TextStyles.pageTitle)]));
  }

  Future<void> launchQubicURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget getCommunityOptions() {
    var theme = SettingsThemeData(
      settingsSectionBackground: LightThemeColors.cardBackground,
      //Theme.of(context).cardTheme.color,
      settingsListBackground: LightThemeColors.background,
      dividerColor: Colors.transparent,
      titleTextColor: Theme.of(context).colorScheme.onBackground,
    );

    return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: SettingsList(
            shrinkWrap: true,
            applicationType: ApplicationType.material,
            contentPadding: const EdgeInsets.all(0),
            darkTheme: theme,
            lightTheme: theme,
            sections: [
              SettingsSection(
                title: null,
                tiles: <SettingsTile>[
                  SettingsTile.navigation(
                    leading: ChangeForeground(
                        child: const Icon(Icons.discord),
                        color: LightThemeColors.gradient1),
                    title: Text('Discord', style: TextStyles.textNormal),
                    trailing: Container(),
                    onPressed: (context) =>
                        {launchQubicURL("https://discord.com/invite/qubic")},
                  ),
                  SettingsTile.navigation(
                    leading: ChangeForeground(
                        child: const Icon(Icons.telegram),
                        color: LightThemeColors.gradient1),
                    title: Text('Telegram', style: TextStyles.textNormal),
                    trailing: Container(),
                    onPressed: (context) =>
                        {launchQubicURL("https://t.me/qubic_network")},
                  ),
                  SettingsTile.navigation(
                    leading: ChangeForeground(
                        color: LightThemeColors.gradient1,
                        child: Icon(FontAwesomeIcons.xTwitter)),
                    title: Text('Twitter', style: TextStyles.textNormal),
                    trailing: Container(),
                    onPressed: (context) =>
                        {launchQubicURL("https://twitter.com/_Qubic_")},
                  ),
                  SettingsTile.navigation(
                    leading: ChangeForeground(
                        child: const Icon(Icons.reddit),
                        color: LightThemeColors.gradient1),
                    title: Text('Reddit', style: TextStyles.textNormal),
                    trailing: Container(),
                    onPressed: (context) =>
                        {launchQubicURL("https://www.reddit.com/r/Qubic/")},
                  ),
                  SettingsTile.navigation(
                    leading: ChangeForeground(
                        child: const Icon(FontAwesomeIcons.youtube),
                        color: LightThemeColors.gradient1),
                    title: Text('YouTube', style: TextStyles.textNormal),
                    trailing: Container(),
                    onPressed: (context) => {
                      launchQubicURL("https://www.youtube.com/@_qubic_/videos")
                    },
                  ),
                  SettingsTile.navigation(
                    leading: ChangeForeground(
                        child: const Icon(FontAwesomeIcons.github),
                        color: LightThemeColors.gradient1),
                    title: Text('GitHub', style: TextStyles.textNormal),
                    trailing: Container(),
                    onPressed: (context) =>
                        {launchQubicURL("https://github.com/qubic")},
                  ),
                  SettingsTile.navigation(
                    leading: ChangeForeground(
                        child: const Icon(FontAwesomeIcons.linkedin),
                        color: LightThemeColors.gradient1),
                    title: Text('LinkedIn', style: TextStyles.textNormal),
                    trailing: Container(),
                    onPressed: (context) => {
                      launchQubicURL(
                          "https://www.linkedin.com/company/qubicnetwork/")
                    },
                  ),
                ],
              ),
            ]));
  }

  Widget getBody() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [getHeader(), getCommunityOptions()]);
  }

  Widget getSettingsHeader(String text, bool isFirst) {
    return Padding(
        padding: isFirst
            ? const EdgeInsets.fromLTRB(0, 0, 0, ThemePaddings.smallPadding)
            : const EdgeInsets.fromLTRB(
                0, ThemePaddings.bigPadding, 0, ThemePaddings.smallPadding),
        child: Transform.translate(
            offset: const Offset(-16, 0),
            child: Text(text, style: TextStyles.textBold)));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
          minimum: ThemeEdgeInsets.pageInsets
              .copyWith(left: 0, right: 0, top: 0, bottom: 0),
          child: Column(children: [
            Expanded(
                child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: getBody()))
          ])),
    );
  }
}
