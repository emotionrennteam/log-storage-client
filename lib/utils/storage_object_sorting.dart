import 'package:log_storage_client/models/storage_object.dart';

/// Custom sorting which sorts a [List] of [StorageObject]s by directories first
/// followed by all files. Within the set of directories and files, all elements
/// are sorted in alphabetically descending order with the exception of the special
/// file `_metadata.json`. This file is sorted so that it is always shown as the
/// very first file.
void sortByDirectoriesFirstThenFiles(List<StorageObject> listToSort) {
  listToSort.sort((StorageObject o1, StorageObject o2) {
    if (o1.isDirectory && o2.isDirectory) {
      return o1
          .getBasename()
          .toLowerCase()
          .compareTo(o2.getBasename().toLowerCase());
    }
    if (o1.isDirectory) {
      return -1;
    }
    if (o2.isDirectory) {
      return 1;
    }
    if (o1.getBasename() == '_metadata.json') {
      return -1;
    }
    if (o2.getBasename() == '_metadata.json') {
      return 1;
    }
    return o1
        .getBasename()
        .toLowerCase()
        .compareTo(o2.getBasename().toLowerCase());
  });
}
