import 'package:bloc_state_management/apis/login_api.dart';
import 'package:bloc_state_management/apis/notes_api.dart';
import 'package:bloc_state_management/bloc/actions.dart';
import 'package:bloc_state_management/bloc/app_bloc.dart';
import 'package:bloc_state_management/bloc/app_state.dart';
import 'package:bloc_state_management/dialogs/generic_dialog.dart';
import 'package:bloc_state_management/dialogs/loading_screen.dart';
import 'package:bloc_state_management/models.dart';
import 'package:bloc_state_management/strings.dart';
import 'package:bloc_state_management/views/iterable_list_view.dart';
import 'package:bloc_state_management/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'bloc_state_management',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AppBloc(
        loginApi: LoginApi(),
        notesApi: NotesApi(),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(kHomePage),
          centerTitle: true,
        ),
        body: BlocConsumer<AppBloc, AppState>(
          listener: (context, appState) {
            // loading screen
            if (appState.isLoading) {
              LoadingScreen.instance().show(
                context: context,
                text: kPleaseWait,
              );
            } else {
              LoadingScreen.instance().hide();
            }
            // display possible errors
            final loginError = appState.loginErrors;
            if (loginError != null) {
              showGenericDialog<bool>(
                context: context,
                title: kLoginErrorDialogTitle,
                content: kLoginErrorDialogContent,
                optionBuilder: () => {kOk: true},
              );
            }
            // if we are logged in but we have no fetched notes, fetch them now!
            if (appState.isLoading == false &&
                appState.loginErrors == null &&
                appState.loginHandle == const LoginHandle.fooBar() &&
                appState.fetchedNotes == null) {
              context.read<AppBloc>().add(const LoadNotesAction());
            }
          },
          builder: (context, appState) {
            final notes = appState.fetchedNotes;
            if (notes == null) {
              return LoginView(
                onLoginTapped: (email, password) {
                  context
                      .read<AppBloc>()
                      .add(LoginAction(email: email, password: password));
                },
              );
            } else {
              return notes.toListView();
            }
          },
        ),
      ),
    );
  }
}
