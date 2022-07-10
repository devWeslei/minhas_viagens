import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:minhas_viagens/Mapa.dart';
import 'package:minhas_viagens/SplashScreen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  FirebaseFirestore _db = FirebaseFirestore.instance;

  final _controller = StreamController<QuerySnapshot>.broadcast();

  _abrirMapa( String idViagem ){

    Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Mapa( idViagem: idViagem,))
    );

  }

  _excluirViagem( String idViagem ){

    _db.collection("viagens")
        .doc( idViagem )
        .delete();

  }

  _adicionarLocal(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Mapa())
    );
  }

  _adicionarListenerViagens() async {
    final stream = _db.collection("viagens")
        .snapshots();

    stream.listen((dados) {
      _controller.add(dados);
    });
  }

  @override
  void initState() {
    super.initState();
    _adicionarListenerViagens();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Minhas viagens"),),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff0066cc),
          onPressed: () {
            _adicionarLocal();
          },
        child: Icon(Icons.add)
      ),
      body:StreamBuilder<QuerySnapshot>(
          stream: _controller.stream,
          builder: (context, snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.none:
              case ConnectionState.waiting:
              case ConnectionState.active:
              case ConnectionState.done:

              if (!snapshot.hasData) {
                return const Center(
                  child: Text('Loading...'),
                );
              }
              if (snapshot.hasError) {
                return const Center(
                    child: Text('Something went wrong.')
                );
              }
                QuerySnapshot querySnapshot = snapshot.requireData;
                List<DocumentSnapshot> viagens = querySnapshot.docs.toList();

                return Column(
                  children: [
                    Expanded(
                        child: ListView.builder(
                            itemCount: viagens.length,
                            itemBuilder: (context, index){

                              DocumentSnapshot item = viagens[index];
                              String titulo = item ["titulo"];
                              String idViagem = item.id;

                              return GestureDetector(
                                onTap: (){
                                  _abrirMapa( idViagem );
                                },
                                child: Card(
                                  child: ListTile(
                                    title: Text( titulo ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: (){
                                            _excluirViagem( idViagem );
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.all(8),
                                            child: Icon(
                                              Icons.remove_circle,
                                              color: Colors.red,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                        )
                    )
                  ],
                );
                break;
            }
          }
      ),
    );
  }
}
