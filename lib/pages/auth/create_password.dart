import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qubic_wallet/components/copyable_text.dart';
import 'package:qubic_wallet/components/gradient_foreground.dart';
import 'package:qubic_wallet/components/toggleable_qr_code.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/copy_to_clipboard.dart';
import 'package:qubic_wallet/helpers/global_snack_bar.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/helpers/platform_helpers.dart';
import 'package:qubic_wallet/helpers/show_alert_dialog.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/pages/auth/create_password_sheet.dart';
import 'package:qubic_wallet/resources/qubic_cmd.dart';
import 'package:qubic_wallet/resources/qubic_li.dart';

import 'package:qubic_wallet/stores/application_store.dart';
import 'package:qubic_wallet/stores/settings_store.dart';
import 'package:qubic_wallet/styles/edgeInsets.dart';
import 'package:qubic_wallet/styles/inputDecorations.dart';
import 'package:qubic_wallet/styles/textStyles.dart';
import 'package:qubic_wallet/styles/themed_controls.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_platform/universal_platform.dart';

class CreatePassword extends StatefulWidget {
  CreatePassword({super.key, required this.onPasswordCreated});

  Function(String password) onPasswordCreated;

  @override
  // ignore: library_private_types_in_public_api
  _CreatePasswordState createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  bool isLoading = false; //Is the form loading

  final ApplicationStore appStore = getIt<ApplicationStore>();
  bool obscuringTextPass = true; //Hide password text
  bool obscuringTextPassRepeat = true; //Hide password repeat text
  final _formKey = GlobalKey<FormBuilderState>();
  final GlobalSnackBar _globalSnackbar = getIt<GlobalSnackBar>();
  final QubicCmd qubicCmd = getIt<QubicCmd>();
  String? generatedPublicId;

  String currentPassword = "";
  String? signUpError;

  int stepNumber = 1;
  int totalSteps = 1;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Show generic error message (not bound to field)
  Widget getSignUpError() {
    return Container(
        alignment: Alignment.center,
        child: Builder(builder: (context) {
          if (signUpError == null) {
            return const SizedBox(height: ThemePaddings.normalPadding);
          } else {
            return Padding(
                padding:
                    const EdgeInsets.only(bottom: ThemePaddings.smallPadding),
                child: ThemedControls.errorLabel(signUpError!));
          }
        }));
  }

//Gets the sign up form
  List<Widget> getSignUpForm() {
    return [
      getSignUpError(),
      FormBuilderTextField(
        name: "password",
        autofocus: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(
              errorText: "Please fill in your password"),
          FormBuilderValidators.minLength(8,
              errorText: "Password must be at least 8 characters long")
        ]),
        onSubmitted: (value) => handleProceed(),
        onChanged: (value) => currentPassword = value ?? "",
        decoration: ThemeInputDecorations.bigInputbox.copyWith(
          hintText: "Enter password",
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: ThemePaddings.smallPadding),
            child: IconButton(
              icon: obscuringTextPass
                  ? Image.asset("assets/images/eye-open.png")
                  : Image.asset("assets/images/eye-closed.png"),
              onPressed: () {
                setState(() {
                  obscuringTextPass = !obscuringTextPass;
                });
              },
            ),
          ),
        ),
        enabled: !isLoading,
        obscureText: obscuringTextPass,
        autocorrect: false,
        autofillHints: null,
      ),
      ThemedControls.spacerVerticalSmall(),
      FormBuilderTextField(
        name: "passwordRepeat",
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(
              errorText: "Please fill in your password again"),
          (value) {
            if (value == currentPassword) return null;
            return "Passwords do not match";
          }
        ]),
        onSubmitted: (value) => handleProceed(),
        decoration: ThemeInputDecorations.bigInputbox.copyWith(
          hintText: "Repeat password",
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: ThemePaddings.smallPadding),
            child: IconButton(
              icon: obscuringTextPassRepeat
                  ? Image.asset("assets/images/eye-open.png")
                  : Image.asset("assets/images/eye-closed.png"),
              onPressed: () {
                setState(() {
                  obscuringTextPassRepeat = !obscuringTextPassRepeat;
                });
              },
            ),
          ),
        ),
        enabled: !isLoading,
        obscureText: obscuringTextPassRepeat,
        autocorrect: false,
        autofillHints: null,
      ),
    ];
  }

  Future<void> handleProceed() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useRootNavigator: true,
        useSafeArea: true,
        backgroundColor: LightThemeColors.background,
        builder: (BuildContext context) {
          return SafeArea(
              child: CreatePasswordSheet(onAccept: () async {
            setState(() {
              isLoading = true;
            });

            // Navigator.pop(context);
            widget.onPasswordCreated(currentPassword);
          }, onReject: () async {
            setState(() {
              isLoading = false;
            });
            Navigator.pop(context);
          }));
        });
  }

  Widget getGeneratedPublicId() {
    if (generatedPublicId == null) {
      return Container();
    }
    return Column(
      children: [
        ThemedControls.spacerVerticalNormal(),
        Text("Your seed ", style: TextStyles.secondaryText),
        ThemedControls.spacerVerticalSmall(),
        Text(generatedPublicId!, style: TextStyles.inputBoxSmallStyle),
      ],
    );
  }

  List<Widget> getButtons() {
    return [
      Expanded(
          child: ThemedControls.primaryButtonBigWithChild(
              onPressed: () async {
                await handleProceed();
              },
              child: Padding(
                padding: const EdgeInsets.all(ThemePaddings.smallPadding + 3),
                child: Text("Proceed",
                    textAlign: TextAlign.center,
                    style: TextStyles.primaryButtonText),
              )))
    ];
  }

  //Gets the container scroll view
  Widget getScrollView() {
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Row(children: [
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ThemedControls.pageHeader(
                  headerText: "Create Wallet Password", subheaderText: ""),
              Text(
                  "Fill in a password that will be used to unlock your new wallet",
                  style: TextStyles.secondaryText),
              ThemedControls.spacerVerticalHuge(),
              FormBuilder(
                  key: _formKey, child: Column(children: getSignUpForm())),
            ],
          ))
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !isLoading,
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
            ),
            body: Padding(
              padding: ThemeEdgeInsets.pageInsets,
              child: Column(children: [
                Expanded(child: getScrollView()),
                Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: getButtons())
              ]),
            )));
  }
}
