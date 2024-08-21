import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';
import 'package:qubic_wallet/components/qubic_amount.dart';
import 'package:qubic_wallet/components/qubic_asset.dart';
import 'package:qubic_wallet/di.dart';
import 'package:qubic_wallet/flutter_flow/theme_paddings.dart';
import 'package:qubic_wallet/helpers/id_validators.dart';
import 'package:qubic_wallet/l10n/l10n.dart';
import 'package:qubic_wallet/models/qubic_list_vm.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/assets.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/explorer/explorer_result_page.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/receive.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/reveal_seed/reveal_seed.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/send.dart';
import 'package:qubic_wallet/pages/main/wallet_contents/transfers/transactions_for_id.dart';
import 'package:qubic_wallet/stores/application_store.dart';

enum CardItem { delete, rename, reveal, viewTransactions, viewInExplorer }

class IdListItem extends StatelessWidget {
  final QubicListVm item;
  final _formKey = GlobalKey<FormBuilderState>();

  IdListItem({super.key, required this.item});

  final ApplicationStore appStore = getIt<ApplicationStore>();

  showRenameDialog(BuildContext context) {
    final l10n = l10nOf(context);
    late BuildContext dialogContext;

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(l10n.generalButtonCancel),
      onPressed: () {
        Navigator.pop(dialogContext);
      },
    );
    Widget continueButton = TextButton(
      child: Text(l10n.generalButtonSave),
      onPressed: () {
        if (_formKey.currentState?.instantValue["accountName"] == item.name) {
          Navigator.pop(dialogContext);
          return;
        }

        _formKey.currentState?.validate();
        if (!_formKey.currentState!.isValid) {
          return;
        }

        appStore.setName(
            item.publicId, _formKey.currentState?.instantValue["accountName"]);

        //appStore.removeID(item.publicId);
        Navigator.pop(dialogContext);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(l10n.renameAccountDialogTitle),
      content: FormBuilder(
          key: _formKey,
          child: SizedBox(
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FormBuilderTextField(
                    name: 'accountName',
                    initialValue: item.name,
                    decoration: InputDecoration(
                      labelText: l10n.renameAccountLabelName,
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(
                          errorText: l10n.generalErrorRequiredField),
                      CustomFormFieldValidators.isNameAvailable(
                          currentQubicIDs: appStore.currentQubicIDs,
                          ignorePublicId: item.name,
                          context: context)
                    ]),
                  ),
                ],
              ))),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    );
  }

  showRemoveDialog(BuildContext context) {
    final l10n = l10nOf(context);

    late BuildContext dialogContext;

    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text(l10n.generalLabelNo),
      onPressed: () {
        Navigator.pop(dialogContext);
      },
    );
    Widget continueButton = TextButton(
      child: Text(l10n.generalLabelYes),
      onPressed: () async {
        await appStore.removeID(item.publicId);
        Navigator.pop(dialogContext);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(l10n.deleteAccountDialogTitle),
      content: Text(l10n.deleteAccountDialogMessage),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return alert;
      },
    );
  }

  Widget getCardMenu(BuildContext context) {
    final l10n = l10nOf(context);

    return PopupMenuButton<CardItem>(
        icon: Icon(Icons.more_vert, color: Theme.of(context).primaryColor),
        // Callback that sets the selected popup menu item.
        onSelected: (CardItem menuItem) async {
          // setState(() {
          //   selectedMenu = item;
          // });
          if (menuItem == CardItem.rename) {
            showRenameDialog(context);
          }

          if (menuItem == CardItem.delete) {
            showRemoveDialog(context);
          }

          if (menuItem == CardItem.viewInExplorer) {
            pushScreen(
              context,
              screen: ExplorerResultPage(
                resultType: ExplorerResultType.publicId,
                qubicId: item.publicId,
              ),
              withNavBar: false,
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          }

          if (menuItem == CardItem.viewTransactions) {
            pushScreen(
              context,
              screen: TransactionsForId(publicQubicId: item.publicId),
              withNavBar: false, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          }

          if (menuItem == CardItem.reveal) {
            pushScreen(
              context,
              screen: RevealSeed(item: item),
              withNavBar: false, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<CardItem>>[
              PopupMenuItem<CardItem>(
                value: CardItem.viewTransactions,
                child: Text(l10n.accountButtonViewTransfer),
              ),
              PopupMenuItem<CardItem>(
                value: CardItem.viewInExplorer,
                child: Text(l10n.accountButtonViewInExplorer),
              ),
              PopupMenuItem<CardItem>(
                value: CardItem.reveal,
                child: Text(l10n.accountButtonRevealPrivateSeed),
              ),
              PopupMenuItem<CardItem>(
                value: CardItem.rename,
                child: Text(l10n.generalButtonRename),
              ),
              PopupMenuItem<CardItem>(
                value: CardItem.delete,
                child: Text(l10n.generalButtonDelete),
              ),
            ]);
  }

  Widget getButtonBar(BuildContext context) {
    final l10n = l10nOf(context);

    return ButtonBar(
      alignment: MainAxisAlignment.spaceEvenly,
      buttonPadding: const EdgeInsets.all(ThemePaddings.miniPadding),
      children: [
        item.amount != null
            ? TextButton(
                onPressed: () {
                  // Perform some action
                  pushScreen(
                    context,
                    screen: Send(item: item),
                    withNavBar: false, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: Text(l10n.accountButtonSend,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        )),
              )
            : Container(),
        TextButton(
          onPressed: () {
            pushScreen(
              context,
              screen: Receive(item: item),
              withNavBar: false, // OPTIONAL VALUE. True by default.
              pageTransitionAnimation: PageTransitionAnimation.cupertino,
            );
          },
          child: Text(l10n.accountButtonReceive,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  )),
        ),
        item.assets.keys.isNotEmpty
            ? TextButton(
                child: Text(l10n.accountButtonAssets,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        )),
                onPressed: () {
                  pushScreen(
                    context,
                    screen: Assets(PublicId: item.publicId),
                    withNavBar: false, // OPTIONAL VALUE. True by default.
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                })
            : Container()
      ],
    );
  }

  List<Widget> getAssets(BuildContext context) {
    List<Widget> shares = [];
    for (var key in item.assets.keys) {
      shares.add(AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          transitionBuilder: (Widget child, Animation<double> animation) {
            //return FadeTransition(opacity: animation, child: child);
            return SizeTransition(sizeFactor: animation, child: child);
            //return ScaleTransition(scale: animation, child: child);
          },
          child: item.assets[key] != null
              ? QubicAsset(
                  key: ValueKey<String>(
                      "qubicAsset${item.publicId}-${key}-${item.assets[key]}"),
                  asset: item.assets[key]!,
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      fontWeight: FontWeight.normal,
                      fontFamily: ThemeFonts.primary))
              : Container()));
    }
    return shares;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints(minWidth: 400, maxWidth: 500),
        child: Card(
            elevation: 5,
            child: Column(children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(
                      ThemePaddings.normalPadding,
                      ThemePaddings.normalPadding,
                      ThemePaddings.normalPadding,
                      ThemePaddings.smallPadding),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(item.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(fontFamily: ThemeFonts.secondary)),
                        FittedBox(
                            child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  //return FadeTransition(opacity: animation, child: child);
                                  return SizeTransition(
                                      sizeFactor: animation, child: child);
                                  //return ScaleTransition(scale: animation, child: child);
                                },
                                child: QubicAmount(
                                    amount: item.amount,
                                    key: ValueKey<String>(
                                        "qubicAmount${item.publicId}-${item.amount}")))),
                        Container(
                            width: double.infinity,
                            alignment: Alignment.centerRight,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: getAssets(context))),
                        FittedBox(
                            child: Text(
                                item
                                    .publicId, // "MYSSHMYSSHMYSSHMYSSH.MYSSHMYSSH....",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                        fontFamily: ThemeFonts.secondary))),
                      ])),
              Container(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                          ThemePaddings.miniPadding,
                          ThemePaddings.miniPadding,
                          ThemePaddings.miniPadding,
                          ThemePaddings.miniPadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [getButtonBar(context), getCardMenu(context)],
                      )))
            ])));
  }
}
