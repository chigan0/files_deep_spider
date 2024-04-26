// import 'dart:io';

// // Input Check File Format, WARNIN !!! ONLY LIST
// List<String> checkFormat = ['.vue', '.css', 'js'];
// // Check FIles FOlder
// String staticFolder = "assets/img";


// // Function for creating a path map of files of one format
// Future<List> folderMap([String path = "."]) async{
//   List result = [];
//   Directory myDir = Directory(path);
  
//   await for (var entity in myDir.list()){
//     if (entity is Directory){
//       result..addAll(await folderMap(entity.uri.toString()));
//       continue;
//     }

//     List<String> fileSpeel = entity.uri.toString().split('.');
//     if (checkFormat.indexOf(fileSpeel[fileSpeel.length-1]) > -1) //fileSpeel[fileSpeel.length-1] ==
//       result.add(entity.uri);
//   }

//   return result;
// }


// // Function for checking whether a file is present in files of the specified format
// Future <int> removeFile(List formatMap, [String path = ""]) async{
//   int fileCount = 0;
//   File templateFile;
//   Directory myDir = Directory((path.length == 0) ? staticFolder : path);
//   if (!await myDir.exists())
//     return 0;
  
//   await for (var entity in myDir.list()){
//     if (entity is File){
//       List<String> fileSP = entity.uri.toString().split('/');
//       final RegExp fileName = RegExp(fileSP.sublist(1).join('/'));
//       bool fileState = false;
      
//       for (var key in formatMap){
//           File templateFile = File(key.toString());

//           for (String line in await templateFile.readAsLines()){
//             if (fileName.allMatches(line).length > 0){
//               fileState = true;
//               break;
//             }
//           }
//       }

//       if (!fileState){
//         print("${entity.uri} - Deleted");
//         entity.delete();
//         continue;
//       }

//       fileCount += 1;
//     }

//     else{
//       fileCount = await removeFile(formatMap, entity.uri.toString());
//       if (fileCount == 0)
//         entity.delete();
//     }
//   }
//   return fileCount;
// }


// void main() async{
//   checkFormat = [for (String formatFile in checkFormat) formatFile.replaceAll('.', '')];
//   List fileFormatMap = await folderMap();
//   await removeFile(fileFormatMap);
// }



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
