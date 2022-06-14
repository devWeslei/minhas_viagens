import 'package:flutter/material.dart';
import 'package:minhas_viagens/Mapa.dart';
import 'package:minhas_viagens/SplashScreen.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _listaViagens = [
    "cristo redentor",
    "grande muralha da china",
    "taj mahal",
    "machu picchu",
    "coliseu",
  ];

  _abrirMapa(){

  }

  _excluirViagem(){

  }

  _adicionarLocal(){
    Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Mapa())
    );
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
      body:Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: _listaViagens.length,
                  itemBuilder: (context, index){
                    String titulo = _listaViagens[index];
                    return GestureDetector(
                      onTap: (){
                        _abrirMapa();
                      },
                      child: Card(
                        child: ListTile(
                          title: Text( titulo ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  _excluirViagem();
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
      ),
    );
  }
}
