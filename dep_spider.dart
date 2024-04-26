import 'dart:io';

// Проверяемые форматы файлов, внимание! только список
List<String> checkFormat = ['.vue', '.css', 'js'];

// Папка с файлами для проверки
String staticFolder = "assets/img";

// Функция для получения списка файлов определенного формата
Future<List> folderMap([String path = "."]) async {
  List result = [];
  Directory myDir = Directory(path);
  
  await for (var entity in myDir.list()) {
    if (entity is Directory) {
      result.addAll(await folderMap(entity.uri.toString()));
      continue;
    }

    List<String> fileSplit = entity.uri.toString().split('.');
    if (checkFormat.contains(fileSplit.last)) {
      result.add(entity.uri);
    }
  }

  return result;
}

// Функция для удаления файлов, не соответствующих форматам
Future<int> removeFile(List formatMap, [String path = ""]) async {
  int fileCount = 0;
  Directory myDir = Directory((path.isEmpty) ? staticFolder : path);
  
  if (!await myDir.exists()) {
    return 0;
  }
  
  await for (var entity in myDir.list()) {
    if (entity is File) {
      List<String> fileSplit = entity.uri.toString().split('/');
      final RegExp fileName = RegExp(fileSplit.sublist(1).join('/'));
      bool fileState = false;
      
      for (var key in formatMap) {
        File templateFile = File(key.toString());

        for (String line in await templateFile.readAsLines()) {
          if (fileName.allMatches(line).isNotEmpty) {
            fileState = true;
            break;
          }
        }
      }

      if (!fileState) {
        print("${entity.uri} - Deleted");
        entity.delete();
        continue;
      }

      fileCount += 1;
    } else {
      fileCount = await removeFile(formatMap, entity.uri.toString());
      if (fileCount == 0) {
        entity.delete();
      }
    }
  }
  
  return fileCount;
}

void main() async {
  // Убедимся, что форматы файлов содержат только расширения без точек
  checkFormat = checkFormat.map((formatFile) => formatFile.replaceAll('.', '')).toList();
  
  // Получаем список файлов в нужных форматах
  List fileFormatMap = await folderMap();
  
  // Удаляем файлы, которые не соответствуют форматам
  await removeFile(fileFormatMap);
}
