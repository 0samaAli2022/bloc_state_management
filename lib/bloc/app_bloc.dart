import 'package:bloc/bloc.dart';
import 'package:bloc_state_management/apis/login_api.dart';
import 'package:bloc_state_management/apis/notes_api.dart';
import 'package:bloc_state_management/bloc/actions.dart';
import 'package:bloc_state_management/bloc/app_state.dart';
import 'package:bloc_state_management/models.dart';

class AppBloc extends Bloc<AppAction, AppState> {
  final LoginApiProtocol loginApi;
  final NotesApiProtocol notesApi;

  AppBloc({
    required this.loginApi,
    required this.notesApi,
  }) : super(const AppState.empty()) {
    on<LoginAction>(
      (event, emit) async {
        // start loading
        emit(
          const AppState(
            isLoading: true,
            loginErrors: null,
            loginHandle: null,
            fetchedNotes: null,
          ),
        );
        //log the user in
        final loginHandle = await loginApi.login(
          email: event.email,
          password: event.password,
        );
        emit(
          AppState(
            isLoading: false,
            loginErrors:
                loginHandle == null ? LoginErrors.invalideHandle : null,
            loginHandle: loginHandle,
            fetchedNotes: null,
          ),
        );
      },
    );
    on<LoadNotesAction>(
      (event, emit) async {
        // start loading
        emit(
          AppState(
            isLoading: true,
            loginErrors: null,
            loginHandle: state.loginHandle,
            fetchedNotes: null,
          ),
        );
        // get the login handle
        final loginHandle = state.loginHandle;
        if (loginHandle != const LoginHandle.fooBar()) {
          // invalid login handle, cannot fetch notes
          emit(
            AppState(
              isLoading: false,
              loginErrors: LoginErrors.invalideHandle,
              loginHandle: loginHandle,
              fetchedNotes: null,
            ),
          );
          return;
        }
        // we have a valid loginHandle and we want to fetch notes
        final notes = await notesApi.getNotes(
          loginHandle: state.loginHandle!,
        );

        emit(
          AppState(
            isLoading: false,
            loginErrors: null,
            loginHandle: loginHandle,
            fetchedNotes: notes,
          ),
        );
      },
    );
  }
}
