import 'package:flutter_test/flutter_test.dart';
import 'package:log_storage_client/utils/utils.dart' as utils;
import 'package:path/path.dart' as path;

void main() {
  group('getParentPath()', () {
    test('returns the correct path for a path that ends w/ a slash on Linux',
        () {
      final currentPath = '/home/phil/Downloads/';

      final result = utils.getParentPath(currentPath, path.separator);

      expect(result, '/home/phil');
    }, testOn: 'linux');

    test(
        'returns the correct parent path for a path that ends w/o a slash on Linux',
        () {
      final currentPath = '/home/phil/Downloads';

      final result = utils.getParentPath(currentPath, path.separator);

      expect(result, '/home/phil');
    }, testOn: 'linux');

    test('stops at root on Linux', () {
      final currentPath = '/home';

      final result = utils.getParentPath(currentPath, path.separator);

      expect(result, '/');
    }, testOn: 'linux');

    test('stops at root on Linux', () {
      final currentPath = '/';

      final result = utils.getParentPath(currentPath, path.separator);

      expect(result, '/');
    }, testOn: 'linux');

    test('returns the correct parent path when log root dir is set',
        () {
      final logRootDir = '/etc/logs/telemetry-logs';
      final currentPath = '/etc/logs/telemetry-logs/2020-11-26-workshop-test/part-a';

      final result = utils.getParentPath(
        currentPath,
        path.separator,
        artificialRootDirectory: logRootDir,
      );

      expect(result, '/etc/logs/telemetry-logs/2020-11-26-workshop-test');
    }, testOn: 'linux');

    test('prevents requesting the parent dir when parent dir would be "above" log root log',
        () {
      final logRootDir = '/etc/logs/telemetry-logs';
      final currentPath = '/etc/logs/telemetry-logs';

      final result = utils.getParentPath(
        currentPath,
        path.separator,
        artificialRootDirectory: logRootDir,
      );

      expect(result, logRootDir);
    }, testOn: 'linux');

    test('prevents requesting the parent dir when parent dir would be "above" log root log',
        () {
      final logRootDir = '/etc/logs/telemetry-logs';
      final currentPath = '/etc/logs/';

      final result = utils.getParentPath(
        currentPath,
        path.separator,
        artificialRootDirectory: logRootDir,
      );

      expect(result, logRootDir);
    }, testOn: 'linux');

    test(
        'returns the correct parent path for a path that ends w/ blackslash on Windows',
        () {
      final currentPath = 'C:\\Users\\Phil\\Downloads\\';

      final result = utils.getParentPath(currentPath, path.separator);

      expect(result, 'C:\\Users\\Phil');
    }, testOn: 'windows');

    test(
        'returns the correct parent path for a path that ends w/o blackslash on Windows',
        () {
      final currentPath = 'C:\\Users\\Phil\\Downloads';

      final result = utils.getParentPath(currentPath, path.separator);

      expect(result, 'C:\\Users\\Phil');
    }, testOn: 'windows');
  });
}
