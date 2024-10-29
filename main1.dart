//memasukkan package yang dibutuhkan oleh aplikasi
import 'package:english_words/english_words.dart'; //bhs inggris
import 'package:flutter/material.dart'; //tampilan UI (material UI)
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart'; //paket untuk interaksi aplikasi

//fungsi main (fungsi utama)
void main() {
  runApp(
      MyApp()); //memanggil fungsi runApp yg menjalankan aplikasi myapp

}

//membuat abstrak aplikasi dari statelessWidget (template aplikasi), aplikasinya bernama MyApp
class MyApp extends StatelessWidget {
  const MyApp(
      {super.key}); //menunjukkan bahwa aplikasi ini akan tetap, tidak berubah setelah di-build

  @override //mengganti nilai lama yg sudah ada di template, dengan nilai-nilai yg baru (replace / overwrite)
  Widget build(BuildContext context) {
    //fungsi yg membangun UI (mengatur posisi widget, dst)
    //ChangeNotifierProvider mendengarkan/mendeteksi interaksi yang terjadi di aplikasi
    return ChangeNotifierProvider(
      create: (context) => MyAppState(), //membuat satu state bernama MyAppState
      child: MaterialApp(
        //menggunakan style desain MaterialUI
        title: 'Namer App', //diberi judul Namer App
        theme: ThemeData(
          //data tema aplikasi, diberi warna deepOrange
          useMaterial3: true, //versi materialUI yang dipakai versi 3
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home:
            MyHomePage(), //nama halaman "MyHomePage" yang menggunakan state "MyAppState".
      ),
    );
  }
}

//mendefinisikan isi MyAppState
class MyAppState extends ChangeNotifier {
  //state MyAppState diisi dengan 2 kata random yang digabung. Kata random tsb disimpan di variable WordPair
  var current = WordPair.random();

  //membuat fungsi getNext untuk mengacak kata
  void getNext() {
    current = WordPair.random(); //acak kata
    notifyListeners(); //kirim kata yg diacak ke listener untuk ditampilkan di layar
  }

  var favorites = <WordPair>[];  //daftar bernama list favorit untuk menyimpan dftar kata yg dilike

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current); //menghapus kata dari list favorit
    } else {
      favorites.add(current); //menambah kata ke list favorit
    }
    notifyListeners(); //menempelkan fungsi ini ke button like supaya button like bisa mengetahui jika dirinya sedang ditekan
  }
}

//membuat layout pada halaman HomePage
// ...

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; 

  @override
  Widget build(BuildContext context) {

    Widget page;
switch (selectedIndex) {
  case 0:
    page = GeneratorPage();
    break;
  case 1:
    page = FavoritesPage();
    break;
  default:
    throw UnimplementedError('no widget for $selectedIndex');
}


    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min, //mengeser posisi tombol ke tengah
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton( //fungsi yg di eksekusi ketika button di tekan
                onPressed: () {
                  appState.getNext(); //menjalankan fungsi getnext
                },
                child: Text('Next'), //menampilkan text next didalam button
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ...

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
      
      color: theme.colorScheme.primary,
      child: Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
          pair.asLowerCase,
          style: style, //menerapkan stylr dgn nama style yg di sudah di buat
          semanticsLabel: "${pair.first} ${pair.second}",

      
      ),
    ),

    );
  }
}

// ...

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text(pair.asLowerCase),
          ),
      ],
    );
  }
}