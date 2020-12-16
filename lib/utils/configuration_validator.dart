import 'dart:io';
import 'package:tuple/tuple.dart';

Tuple2<bool, String> validateAccessKey(String accessKey) {
  if (accessKey == null || accessKey.isEmpty) {
    return Tuple2(false, 'empty / not configured');
  }
  return Tuple2(true, null);
}

Tuple2<bool, String> validateSecretKey(String secretKey) {
  if (secretKey == null || secretKey.isEmpty) {
    return Tuple2(false, 'empty / not configured');
  }
  return Tuple2(true, null);
}

Tuple2<bool, String> validateBucket(String bucket) {
  if (bucket == null || bucket.isEmpty) {
    return Tuple2(false, 'empty / not configured');
  }
  if (_isValidBucketName(bucket)) {
    return Tuple2(true, null);
  }
  return Tuple2(false, 'invalid');
}

Tuple2<bool, String> validateRegion(String region) {
  if (region == null || region.isEmpty) {
    return Tuple2(false, 'empty / not configured');
  }
  return Tuple2(true, null);
}

Tuple2<bool, String> validateEndpoint(String endpoint) {
  if (endpoint == null || endpoint.isEmpty) {
    return Tuple2(false, 'empty / not configured');
  }
  if (_isValidEndpoint(endpoint)) {
    return Tuple2(true, null);
  }
  return Tuple2(false, 'invalid IP address or domain');
}

Tuple2<bool, String> validatePort(int port) {
  if (port == null) {
    return Tuple2(false, 'empty / not configured');
  }
  if (port <= 0) {
    return Tuple2(false, 'must be greater than 0');
  }
  if (port >= 1 && port <= 65535) {
    return Tuple2(true, null);
  }
  return Tuple2(false, 'must be between 1 and 65535');
}

Tuple2<bool, String> validateLogFileDirectory(String logFileDirectoryPath) {
  if (logFileDirectoryPath == null || logFileDirectoryPath.isEmpty) {
    return Tuple2(false, 'empty / not configured');
  }
  if (!Directory(logFileDirectoryPath).existsSync()) {
    return Tuple2(false, 'directory doesn\'t exist');
  }
  try {
    Directory(logFileDirectoryPath).listSync();
    return Tuple2(true, null);
  } on Exception catch (e) {
    return Tuple2(false, e.toString());
  }
}

bool _isValidEndpoint(endpoint) {
  return _isValidDomain(endpoint) || _isValidIPv4(endpoint);
}

bool _isValidIPv4(String ip) {
  if (ip == null) return false;
  return RegExp(r'^(\d{1,3}\.){3,3}\d{1,3}$').hasMatch(ip);
}

bool _isValidDomain(String host) {
  if (host == null) return false;

  if (host.isEmpty || host.length > 255) {
    return false;
  }

  if (host.startsWith('-') || host.endsWith('-')) {
    return false;
  }

  if (host.startsWith('_') || host.endsWith('_')) {
    return false;
  }

  if (host.startsWith('.') || host.endsWith('.')) {
    return false;
  }

  final alphaNumerics = '`~!@#\$%^&*()+={}[]|\\"\';:><?/'.split('');
  for (var char in alphaNumerics) {
    if (host.contains(char)) return false;
  }

  return true;
}

bool _isValidBucketName(String bucket) {
  if (bucket == null) return false;

  if (bucket.length < 3 || bucket.length > 63) {
    return false;
  }
  if (bucket.contains('..')) {
    return false;
  }

  if (RegExp(r'[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+').hasMatch(bucket)) {
    return false;
  }

  if (RegExp(r'^[a-z0-9][a-z0-9.-]+[a-z0-9]$').hasMatch(bucket)) {
    return true;
  }

  return false;
}
