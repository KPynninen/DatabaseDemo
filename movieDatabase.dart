import 'dart:io';

import 'package:database/database.dart';
import 'package:database/filter.dart';

main() async {

  // test commands for the demo
  
  var database = MemoryDatabaseAdapter().database();
  var movies = database.collection('movies');
  await movies.insert(data: {
    'name': 'Tron',
    'watched': false
  });
  await movies.insert(data: {
    'name': 'Hackers',
    'watched': true
  });
  await movies.insert(data: {
    'name': 'The Matrix',
    'watched': true
  });
  
  removeWatched(movies);
  list(movies);
}

start(collection) async {
  while(true) {
    print('Commands:');
    print('1: Add Movie');
    print('2: Watch Movie');
    print('3: List Movi9es');
    print('4: Remove Watched');
    print('5: End');
    var command = stdin.readLineSync();
    if (command == '5') {
      break;
    }

    if (command == '1') {
      await add(collection);
    } else if (command == '2') {
      await watch(collection);
    } else if (command == '3') {
      await list(collection);
    } else if (command == '4') {
      await removeWatched(collection); 
    }
  }
}

add(collection) async {
  print('Name of Movie?');
  var name = stdin.readLineSync();
  await collection.insert(data: {
    'name': name,
    'watched': false
  });
}

watch(collection) async {
  print('Name of Movie?');
  var name = stdin.readLineSync();

  var query = Query(
    filter: MapFilter({
      'name': ValueFilter(name)
    })
  );

  var result = await collection.search(query: query);
  var documents = result.snapshots;

  for (var i = 0; i < documents.length; i++) {
    var data = documents[i].data;
    var document = documents[i].document;
    await document.update(data: {
      'name': data['name'],
      'watched': true
    });
  }
}

list(collection) async {
  var query = Query(
    sorter: PropertySorter('name', isDescending: false)
  );

  var result = await collection.search(query: query);
  var documents = result.snapshots;

  for (var i = 0; i < documents.length; i++) {
    var data = documents[i].data;
    if (data['watched'] = true) {
      print("[X] ${data['name']}");
    } else {
      print("[ ] ${data['name']}");
    }
  }
}

removeWatched(collection) async {
  var query = Query(
    filter: MapFilter({
      'watched': ValueFilter(true)
        })
    );
  
  var result = await collection.search(query: query);
  var documents = result.snapshots;
  
  for (var i = 0; i < documents.length; i++) {
    var document = documents[i].document;
    await document.delete();
  }
}