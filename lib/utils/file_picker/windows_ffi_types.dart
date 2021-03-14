import 'dart:ffi';
import 'package:ffi/ffi.dart';

/// Function from Win32 API to display a dialog box that enables the user to select a Shell folder.
///
/// Reference:
/// https://docs.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shbrowseforfolderw
typedef SHBrowseForFolderW = Pointer Function(
  /// A pointer to a [BROWSEINFOA] structure that contains information used to display the dialog box.
  Pointer lpbi,
);

/// Function from Win32 API to convert an item identifier list to a file system path.
///
/// Returns [true] if successful; otherwise, [false].
///
/// Reference:
/// https://docs.microsoft.com/en-us/windows/win32/api/shlobj_core/nf-shlobj_core-shgetpathfromidlistw
typedef SHGetPathFromIDListW = Int8 Function(
  /// The address of an item identifier list that specifies a file or directory location relative to
  /// the root of the namespace (the desktop).
  Pointer pidl,

  /// The address of a buffer to receive the file system path. This buffer must be at least [MAX_PATH]
  /// characters in size.
  Pointer<Utf16> pszPath,
);

/// Dart equivalent of [SHGetPathFromIDListW].
typedef SHGetPathFromIDListWDart = int Function(
  Pointer pidl,
  Pointer<Utf16> pszPath,
);

/// Struct from Win32 API that contains parameters for the [SHBrowseForFolderW] function and receives
/// information about the folder selected by the user.
///
/// Reference:
/// https://docs.microsoft.com/en-us/windows/win32/api/shlobj_core/ns-shlobj_core-browseinfoa
class BROWSEINFOA extends Struct {
  /// A handle to the owner window for the dialog box.
  Pointer hwndOwner;

  /// A PIDL that specifies the location of the root folder from which to start browsing. Only the
  /// specified folder and its subfolders in the namespace hierarchy appear in the dialog box. This
  /// member can be [null]; in that case, a default location is used.
  Pointer pidlRoot;

  /// Pointer to a buffer to receive the display name of the folder selected by the user. The size
  /// of this buffer is assumed to be [MAX_PATH] characters.
  Pointer<Utf16> pszDisplayName;

  /// Pointer to a null-terminated string that is displayed above the tree view control in the dialog
  /// box. This string can be used to specify instructions to the user.
  Pointer lpszTitle;

  /// Flags that specify the options for the dialog box. This member can be 0 or a combination of the
  /// following values.
  @Uint32()
  int ulFlags;

  /// Pointer to an application-defined function that the dialog box calls when an event occurs. For
  /// more information, see the BrowseCallbackProc function. This member can be [null].
  Pointer lpfn;

  /// An application-defined value that the dialog box passes to the callback function, if one is
  /// specified in [lpfn].
  Pointer lParam;

  /// An [int] value that receives the index of the image associated with the selected folder, stored
  /// in the system image list.
  @Uint32()
  int iImage;
}

/// Only return file system directories. If the user selects folders that are not part of the file
/// system, the OK button is grayed.
const BIF_RETURNONLYFSDIRS = 0x00000001;

/// Include an edit control in the browse dialog box that allows the user to type the name of an item.
const BIF_EDITBOX = 0x00000010;

/// Use the new user interface. Setting this flag provides the user with a larger dialog box that can
/// be resized. The dialog box has several new capabilities, including: drag-and-drop capability within
/// the dialog box, reordering, shortcut menus, new folders, delete, and other shortcut menu commands.
const BIF_NEWDIALOGSTYLE = 0x00000040;

/// In the Windows API, the maximum length for a path is MAX_PATH, which is defined as 260 characters.
const MAX_PATH = 260;
