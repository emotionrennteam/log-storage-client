import 'dart:ffi';
import 'package:ffi/ffi.dart';

import 'windows_ffi_types.dart';

/// Opens a dialog to let the user select a directory.
///
/// [dialogTitle] is a string that is displayed above the tree view control in the
/// dialog box. This string can be used to specify instructions to the user.
/// Returns the absolute path which the user selected. Returns [null] if
/// folder path couldn't be resolved.
String pickDirectory(String dialogTitle) {
  try {
    final pathIdPointer = _pickDirectory(dialogTitle);
    return _getPathFromItemIdentifierList(pathIdPointer);
  } on Exception {
    return null;
  }
}

/// Uses the Win32 API to display a dialog box that enables the user to select a folder.
///
/// Returns a PIDL that specifies the location of the selected folder relative to the root of the
/// namespace. Throws an exception, if the user chooses the Cancel button in the dialog box.
Pointer _pickDirectory(String dialogTitle) {
  final shell32 = DynamicLibrary.open('shell32.dll');

  final shBrowseForFolderW =
      shell32.lookupFunction<SHBrowseForFolderW, SHBrowseForFolderW>(
          'SHBrowseForFolderW');

  final Pointer<BROWSEINFOA> browseInfo = calloc<BROWSEINFOA>();
  browseInfo.ref.hwndOwner = nullptr;
  browseInfo.ref.pidlRoot = nullptr;
  browseInfo.ref.pszDisplayName = calloc.allocate<Utf16>(MAX_PATH);
  browseInfo.ref.lpszTitle = dialogTitle.toNativeUtf16();
  browseInfo.ref.ulFlags =
      BIF_EDITBOX | BIF_NEWDIALOGSTYLE | BIF_RETURNONLYFSDIRS;

  final Pointer<NativeType> itemIdentifierList = shBrowseForFolderW(browseInfo);

  calloc.free(browseInfo.ref.pszDisplayName);
  calloc.free(browseInfo.ref.lpszTitle);
  calloc.free(browseInfo);

  if (itemIdentifierList == nullptr) {
    throw Exception('User clicked on the cancel button in the dialog box.');
  }
  return itemIdentifierList;
}

/// Uses the Win32 API to convert an item identifier list to a file system path.
///
/// [lpItem] must contain the address of an item identifier list that specifies a
/// file or directory location relative to the root of the namespace (the desktop).
/// Returns the file system path as a [String]. Throws an exception, if the
/// conversion wasn't successful.
String _getPathFromItemIdentifierList(Pointer lpItem) {
  final shell32 = DynamicLibrary.open('shell32.dll');

  final shGetPathFromIDListW =
      shell32.lookupFunction<SHGetPathFromIDListW, SHGetPathFromIDListWDart>(
          'SHGetPathFromIDListW');

  final Pointer<Utf16> pszPath = calloc.allocate<Utf16>(MAX_PATH);

  final int result = shGetPathFromIDListW(lpItem, pszPath);
  if (result == 0x00000000) {
    throw Exception(
        'Failed to convert item identifier list to a file system path.');
  }

  calloc.free(pszPath);

  return pszPath.toDartString();
}
