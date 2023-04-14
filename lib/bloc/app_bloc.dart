import 'dart:io';
import 'package:bloc_state_management/auth/auth_error.dart';
import 'package:bloc_state_management/bloc/app_event.dart';
import 'package:bloc_state_management/bloc/app_state.dart';
import 'package:bloc_state_management/utils/upload_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc()
      : super(
          const AppStateLoggedOut(
            isLoading: false,
          ),
        ) {
    // handle login event
    on<AppEventLogIn>((event, emit) async {
      // start loading
      emit(
        const AppStateLoggedOut(
          isLoading: true,
        ),
      );
      // log the user in
      try {
        final email = event.email;
        final password = event.password;
        final credentials = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);
        final user = credentials.user;
        final images = await _getImages(user!.uid);
        emit(
          AppStateLoggedIn(
            user: user,
            images: images,
            isLoading: false,
          ),
        );
      } on FirebaseAuthException catch (e) {
        emit(
          AppStateLoggedOut(
            isLoading: false,
            authError: AuthError.from(e),
          ),
        );
      }
    });
    // login and register navigation buttons
    on<AppEventGoToRegistration>((event, emit) {
      emit(
        const AppStateInRegisterationView(
          isLoading: false,
        ),
      );
    });
    on<AppEventGoToLogin>((event, emit) {
      emit(
        const AppStateLoggedOut(
          isLoading: false,
        ),
      );
    });
    // handle reigister event
    on<AppEventRegister>((event, emit) async {
      // start loading process
      emit(
        const AppStateInRegisterationView(
          isLoading: true,
        ),
      );
      final email = event.email;
      final password = event.password;

      try {
        // create the user
        final credentials =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        emit(
          AppStateLoggedIn(
            user: credentials.user!,
            images: const [],
            isLoading: false,
          ),
        );
      } on FirebaseAuthException catch (e) {
        emit(
          AppStateInRegisterationView(
            isLoading: false,
            authError: AuthError.from(e),
          ),
        );
      }
    });
    // handle app initialization
    on<AppEventInitialize>((event, emit) async {
      // get current user
      final user = FirebaseAuth.instance.currentUser;
      // log user out if you don't have valid user.
      if (user == null) {
        emit(
          const AppStateLoggedOut(
            isLoading: false,
          ),
        );
        return;
      } else {
        // start loading images
        emit(
          AppStateLoggedIn(
            user: user,
            images: state.images ?? [],
            isLoading: true,
          ),
        );
        final images = await _getImages(user.uid);
        emit(
          AppStateLoggedIn(
            user: user,
            images: images,
            isLoading: false,
          ),
        );
      }
    });
    // handle uploading images
    on<AppEventUploadImage>(
      (event, emit) async {
        final user = state.user;
        // log user out if you don't have valid user.
        if (user == null) {
          emit(
            const AppStateLoggedOut(
              isLoading: false,
            ),
          );
          return;
        }
        // start the loading process
        emit(
          AppStateLoggedIn(
            isLoading: true,
            user: user,
            images: state.images ?? [],
          ),
        );

        // upload the file
        final file = File(event.filePathToUpload);
        await uploadImage(
          file: file,
          userId: user.uid,
        );

        // after upload is complete, grap the latest file references.
        final images = await _getImages(user.uid);
        emit(
          AppStateLoggedIn(
            user: user,
            images: images,
            isLoading: false,
          ),
        );
      },
    );
    // handle account deletion
    on<AppEventDeleteAccount>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;
        // log the user out if we don't have a current user.
        if (user == null) {
          emit(const AppStateLoggedOut(isLoading: false));
          return;
        }
        // start loading process
        emit(
          AppStateLoggedIn(
            isLoading: true,
            user: user,
            images: state.images ?? [],
          ),
        );
        // delete the user folder.
        try {
          // delete all the items inside the folder one by one.
          final folderContents =
              await FirebaseStorage.instance.ref(user.uid).listAll();
          for (final item in folderContents.items) {
            await item.delete().catchError((_) {}); // maybe handle the error?
          }
          // delete the folder itself.
          await FirebaseStorage.instance
              .ref(user.uid)
              .delete()
              .catchError((_) {});
          // delete the user.
          await user.delete().catchError((_) {});
          // log the user out.
          await FirebaseAuth.instance.signOut();
          // log the user out in the UI as well.
          emit(
            const AppStateLoggedOut(
              isLoading: false,
            ),
          );
        } on FirebaseAuthException catch (e) {
          emit(
            AppStateLoggedIn(
              isLoading: false,
              user: user,
              images: state.images ?? [],
              authError: AuthError.from(e),
            ),
          );
        } on FirebaseException {
          // we might not be able to delete the folder
          // log the user out
          emit(
            const AppStateLoggedOut(
              isLoading: false,
            ),
          );
        }
      },
    );
    // handle log out event
    on<AppEventLogOut>((event, emit) async {
      // start loading process
      emit(
        const AppStateLoggedOut(
          isLoading: true,
        ),
      );
      // log the user out.
      await FirebaseAuth.instance.signOut();
      // log the user out in the UI as well.
      emit(
        const AppStateLoggedOut(
          isLoading: false,
        ),
      );
    });
  }

  Future<Iterable<Reference>> _getImages(String userId) =>
      FirebaseStorage.instance
          .ref(userId)
          .list()
          .then((listResult) => listResult.items);
}
