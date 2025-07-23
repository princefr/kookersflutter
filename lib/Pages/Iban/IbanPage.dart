import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kookers/Blocs/IbanBloc.dart';
import 'package:kookers/Services/DatabaseProvider.dart';
import 'package:kookers/Widgets/EmptyView.dart';
import 'package:kookers/Widgets/StreamButton.dart';
import 'package:kookers/Widgets/TopBar.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AddIbanPage extends StatefulWidget {
  final User user;
  AddIbanPage({Key? key, required this.user}) : super(key: key);

  @override
  _AddIbanPageState createState() => _AddIbanPageState();
}

class _AddIbanPageState extends State<AddIbanPage> {
  final StreamButtonController _streamButtonController =
      StreamButtonController();

  IbanBloc bloc = IbanBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    this.bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);
    return Scaffold(
      body: SafeArea(
        child: Container(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  height: 7,
                  width: 80),
            ),
            SizedBox(height: 30),
            Text(
              "Ajouter un iban",
              style: GoogleFonts.montserrat(fontSize: 20),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: StreamBuilder<String>(
                  stream: this.bloc.iban$,
                  builder: (context, snapshot) {
                    return Container(
                      height: 54,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey),
                      child: TextField(
                          onChanged: this.bloc.inBan.add,
                          decoration: InputDecoration(
                            hintText: 'Renseignez un iban',
                            fillColor: Colors.grey[200],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                width: 0,
                                style: BorderStyle.none,
                              ),
                            ),
                          )),
                    );
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: Text(
                      "L'iban ajouté est tout de suite definie comme celui par défaut, il est possible de le changer en cliquant sur la liste d'ibans sur la page précédente.",
                      style: GoogleFonts.montserrat(
                          decoration: TextDecoration.none,
                          color: Colors.black,
                          fontSize: 10))),
            ),
            Expanded(child: SizedBox()),
            StreamBuilder<String>(
                stream: this.bloc.iban$,
                builder: (context, snapshot) {
                  return StreamButton(
                      buttonColor: snapshot.data != null
                          ? Color(0xFFF95F5F)
                          : Colors.grey,
                      buttonText: "Ajouter l'iban",
                      errorText: "Une erreur s'est produite, reessayer",
                      loadingText: "Ajout en cours",
                      successText: "Iban ajouté",
                      controller: _streamButtonController,
                      onClick: snapshot.data == null
                          ? () {}
                          : () async {
                              _streamButtonController.isLoading();
                              databaseService
                                  .createBankAccount(snapshot.data ?? '')
                                  .then((bankaccount) async {
                                  await databaseService.loadUserData(this.widget.user.uid);
                                  _streamButtonController.isSuccess();
                                Navigator.pop(context);
                              }).catchError((onError) {
                                print(onError);
                                _streamButtonController.isError();
                              });
                            });
                })
          ],
        )),
      ),
    );
  }
}

class IbanPage extends StatefulWidget {
  final User user;
  const IbanPage({Key? key, required this.user}) : super(key: key);

  @override
  _IbanPageState createState() => _IbanPageState();
}

class _IbanPageState extends State<IbanPage> {


  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  Widget build(BuildContext context) {
    final databaseService =
        Provider.of<DatabaseProviderService>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TopBarWitBackNav(
          title: "Iban",
          rightIcon: CupertinoIcons.plus,
          isRightIcon: true,
          height: 54,
          onTapRight: () {
            showCupertinoModalBottomSheet(
              expand: false,
              context: context,
              builder: (context) => AddIbanPage(user: this.widget.user,),
            );
          } as GestureTapCallback?),
      body: SafeArea(
        child: StreamBuilder<UserDef>(
            stream: databaseService.user$,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return LinearProgressIndicator(
                    backgroundColor: Colors.black,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white));
              if (snapshot.hasError) return Text("i've a bad felling");
              if (snapshot.data?.ibans?.isEmpty ?? true)
                return SmartRefresher(
                    onRefresh: () async {
                      await databaseService.loadUserData(this.widget.user.uid);
                      _refreshController.refreshCompleted();
                    },
                    controller: this._refreshController,
                    enablePullDown: true,
                    enablePullUp: false,
                    child: EmptyViewElse(text: "Vous n'avez pas d'iban."));
              return SmartRefresher(
                onRefresh: () async {
                  await databaseService.loadUserData(this.widget.user.uid);
                  _refreshController.refreshCompleted();
                },
                controller: this._refreshController,
                enablePullDown: true,
                enablePullUp: false,
                child: ListView.builder(
                    itemCount: snapshot.data?.ibans?.length ?? 0,
                    itemBuilder: (ctx, index) {
                      return ListTile(
                        autofocus: false,
                        onTap: () {
                                                        databaseService
                                  .updateIbanDeposit(snapshot.data!.ibans![index].id ?? '');
                          setState(() {
                            databaseService.user.value.defaultIban =
                                snapshot.data!.ibans![index].id;
                          });
                        },
                        title: Text(
                            "*************" + " " + (snapshot.data!.ibans![index].last4 ?? '')),
                        trailing: Visibility(
                            visible: databaseService.user.value.defaultIban ==
                                    snapshot.data!.ibans![index].id
                                ? true
                                : false,
                            child: Icon(CupertinoIcons.checkmark_circle,
                                color: Colors.green)),
                      );
                    }),
              );
            }),
      ),
    );
  }
}
