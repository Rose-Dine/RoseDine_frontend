#!/usr/bin/env dart
import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  // Set the output file name
  final outputFileName = 'all.dart';
  final currentDir = Directory.current;
  final outputFilePath = p.join(currentDir.path, outputFileName);
  final outputFile = File(outputFilePath);

  // Remove the existing output file if it exists.
  if (outputFile.existsSync()) {
    outputFile.deleteSync();
  }
  // Create an empty output file.
  outputFile.writeAsStringSync('');

  // Directories to ignore in a typical Flutter project.
  final ignoredDirs = <String>{
    'build',
    '.dart_tool',
    '.git',
    '.idea',
    '.vscode',
    'android',
    'ios',
    'macos',
    'windows',
    'linux',
  };

  // Only include Dart files.
  final allowedExtensions = <String>{'.dart'};

  /// Recursively collects Dart files from [dir], skipping ignored directories
  List<File> collectFiles(Directory dir) {
    List<File> files = [];
    try {
      final entities = dir.listSync(recursive: false);
      for (var entity in entities) {
        if (entity is Directory) {
          final dirName = p.basename(entity.path);
          if (ignoredDirs.contains(dirName)) continue;
          files.addAll(collectFiles(entity));
        } else if (entity is File) {
          final fileName = p.basename(entity.path);
          if (fileName == outputFileName) continue;
          final ext = p.extension(fileName).toLowerCase();
          if (allowedExtensions.contains(ext)) {
            files.add(entity);
          }
        }
      }
    } catch (e) {
      // Optionally log errors or continue.
    }
    return files;
  }

  /// Creates a visual tree string representation of the directory structure.
  String createDirTree(Directory dir, {String prefix = ''}) {
    String treeOutput = '';
    final entities = dir.listSync(recursive: false)
      .where((entity) {
        final name = p.basename(entity.path);
        if (ignoredDirs.contains(name)) return false;
        if (name == outputFileName) return false;
        return true;
      })
      .toList();

    // Sort entries alphabetically.
    entities.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

    for (int i = 0; i < entities.length; i++) {
      final entity = entities[i];
      final isLast = i == entities.length - 1;
      final connector = isLast ? '└── ' : '├── ';
      treeOutput += prefix + connector + p.basename(entity.path) + '\n';
      if (entity is Directory) {
        final newPrefix = prefix + (isLast ? '    ' : '│   ');
        treeOutput += createDirTree(entity, prefix: newPrefix);
      }
    }
    return treeOutput;
  }

  // Collect all Dart files from the project.
  final dartFiles = collectFiles(currentDir);

  // Append each file’s contents with a header comment.
  for (var file in dartFiles) {
    final relativePath = p.relative(file.path, from: currentDir.path);
    outputFile.writeAsStringSync(
        '\n\n// FILE: $relativePath\n', mode: FileMode.append);
    final contents = file.readAsStringSync();
    outputFile.writeAsStringSync(contents, mode: FileMode.append);
  }

  // Append the directory tree at the end.
  final dirTree = createDirTree(currentDir);
  outputFile.writeAsStringSync('\n\n// DIRECTORY TREE\n$dirTree',
      mode: FileMode.append);

  print('All files combined into $outputFileName');
}
