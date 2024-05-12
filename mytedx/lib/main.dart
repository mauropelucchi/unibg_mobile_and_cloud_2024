import 'package:flutter/material.dart';
import 'talk_repository.dart';
import 'models/talk.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTEDx',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    this.title = 'MyTEDx'
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  late Future<List<Talk>> _talks;
  int page = 1;
  bool init = true;

  @override
  void initState() {
    super.initState();
    _talks = initEmptyList();
    init = true;
  }

  void _getTalksByTag() async {
    setState(() {
      init = false;
      _talks = getTalksByTag(_controller.text, page);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My TedX App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('My TEDx App'),
        ),
        body: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: (init)
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      controller: _controller,
                      decoration:
                          const InputDecoration(hintText: 'Enter your favorite talk'),
                    ),
                    ElevatedButton(
                      child: const Text('Search by tag'),
                      onPressed: () {
                        page = 1;
                        _getTalksByTag();
                      },
                    ),
                  ],
                )
              : FutureBuilder<List<Talk>>(
                  future: _talks,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Scaffold(
                          appBar: AppBar(
                            title: Text("#${_controller.text}"),
                          ),
                          body: ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                child: ListTile(
                                    subtitle:
                                        Text(snapshot.data![index].mainSpeaker),
                                    title: Text(snapshot.data![index].title)),
                                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(snapshot.data![index].details))),
                              );
                            },
                          ),
                          floatingActionButtonLocation:
                              FloatingActionButtonLocation.centerDocked,
                          floatingActionButton: FloatingActionButton(
                            child: const Icon(Icons.arrow_drop_down),
                            onPressed: () {
                              if (snapshot.data!.length >= 6) {
                                page = page + 1;
                                _getTalksByTag();
                              }
                            },
                          ),
                          bottomNavigationBar: BottomAppBar(
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                IconButton(
                                  icon: const Icon(Icons.home),
                                  onPressed: () {
                                    setState(() {
                                      init = true;
                                      page = 1;
                                      _controller.text = "";
                                    });
                                  },
                                )
                              ],
                            ),
                          ));
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }

                    return const CircularProgressIndicator();
                  },
                ),
        ),
      ),
    );
  }
}