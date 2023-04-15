import 'package:bloc_state_management/dialogs/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showDeleteAccountDialog(
  BuildContext context,
) {
  return showGenericDialog(
    context: context,
    title: 'Delete account',
    content:
        'Are you sure you want to delete your account? you cannot undo this operation!',
    optionsBuilder: () => {
      'Cancel': false,
      'Delete Account': true,
    },
  ).then(
    (value) => value ?? false,
  );
}
