import 'dart:io';

import 'package:database/database.dart';
import 'package:database/filter.dart';

main() async {
  var tietokanta = MemoryDatabaseAdapter().database();
  var elokuvat = tietokanta.collection('elokuvat');
  await elokuvat.insert(data: {
    'nimi': 'Tron',
    'katsottu': false
  });
  await elokuvat.insert(data: {
    'nimi': 'Hackers',
    'katsottu': true
  });
  await elokuvat.insert(data: {
    'nimi': 'The Matrix',
    'katsottu': true
  });
  
  poistaKatsotut(elokuvat);
  listaa(elokuvat);
}

kaynnista(kokoelma) async {
  while(true) {
    print('Komennot:');
    print('1: Lisää elokuva');
    print('2: Katso elokuva');
    print('3: Listaa elokuvat');
    print('4: Poista katsotut');
    print('5: Lopeta');
    var komento = stdin.readLineSync();
    if (komento == '5') {
      break;
    }

    if (komento == '1') {
      await lisaa(kokoelma);
    } else if (komento == '2') {
      await katso(kokoelma);
    } else if (komento == '3') {
      await listaa(kokoelma);
    } else if (komento == '4') {
      await poistaKatsotut(kokoelma); 
    }
  }
}

lisaa(kokoelma) async {
  print('Elokuvan nimi?');
  var nimi = stdin.readLineSync();
  await kokoelma.insert(data: {
    'nimi': nimi,
    'katsottu': false
  });
}

katso(kokoelma) async {
  print('Elokuvan nimi?');
  var nimi = stdin.readLineSync();

  var kysely = Query(
    filter: MapFilter({
      'nimi': ValueFilter(nimi)
    })
  );

  var tulos = await kokoelma.search(query: kysely);
  var dokumentit = tulos.snapshots;

  for (var i = 0; i < dokumentit.length; i++) {
    var data = dokumentit[i].data;
    var dokumentti = dokumentit[i].document;
    await dokumentti.update(data: {
      'nimi': data['nimi'],
      'katsottu': true
    });
  }
}

listaa(kokoelma) async {
  var kysely = Query(
    sorter: PropertySorter('nimi', isDescending: false)
  );

  var tulos = await kokoelma.search(query: kysely);
  var dokumentit = tulos.snapshots;

  for (var i = 0; i < dokumentit.length; i++) {
    var data = dokumentit[i].data;
    if (data['katsottu'] = true) {
      print("[X] ${data['nimi']}");
    } else {
      print("[ ] ${data['nimi']}");
    }
  }
}

poistaKatsotut(kokoelma) async {
  var kysely = Query(
    filter: MapFilter({
      'katsottu': ValueFilter(true)
        })
    );
  
  var tulos = await kokoelma.search(query: kysely);
  var dokumentit = tulos.snapshots;
  
  for (var i = 0; i < dokumentit.length; i++) {
    var dokumentti = dokumentit[i].document;
    await dokumentti.delete();
  }
}