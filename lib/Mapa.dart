import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';


class Mapa extends StatefulWidget {
  String? idViagem;

  Mapa({this.idViagem});

  @override
  _MapaState createState() => _MapaState();
}

class _MapaState extends State<Mapa> {

  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _marcadores = {};
  CameraPosition _posicaoCamera = CameraPosition(
    target: LatLng(-23.42087200129373, -51.93719096900213),
    zoom: 18,
  );
   FirebaseFirestore _db = FirebaseFirestore.instance;

  _onMapCreated( GoogleMapController controller ){
    _controller.complete( controller );
  }

  _adicionarMarcador( LatLng latLng) async {

    List <Placemark> listaEnderecos = await GeocodingPlatform.instance
        .placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    if( listaEnderecos.isNotEmpty){
      Placemark endereco = listaEnderecos[0];
      String rua = endereco.thoroughfare!;

      Marker marcador = Marker(
          markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
          position: latLng,
          infoWindow: InfoWindow(
              title: rua
          )
      );

      setState(() {
        _marcadores.add(marcador);

        //salvar no firebase
        Map<String, dynamic> viagem = Map();
        viagem["titulo"] = rua;
        viagem["latitude"] = latLng.latitude;
        viagem["longitude"] = latLng.longitude;
        _db.collection("viagens")
        .add(viagem);
      });

    }
  }

  _movimentarCamera() async {

    GoogleMapController googleMapController = await _controller.future;
    googleMapController.animateCamera(
      CameraUpdate.newCameraPosition(
        _posicaoCamera
      )
    );

  }

  _adicionarListenerLocalizacao() async {

    //-23.425895, -51.938285
    LocationPermission permission;
    await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();

    var locationSetings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10
    );

    var geolocator = Geolocator.getPositionStream(locationSettings: locationSetings)
    .listen((Position position) {

      setState(() {
        _posicaoCamera = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 18,
        );
      });
      _movimentarCamera();
    });

  }

  _recuperaViagemParaId( String? idViagem ) async {

    if( idViagem != null ){

      //exibir marcador para id viagem
      DocumentSnapshot documentSnapshot = await _db
          .collection("viagens")
          .doc(idViagem)
          .get();

      var dados = documentSnapshot;

      String titulo = dados["titulo"];
      LatLng latLng = LatLng(
          dados["latitude"],
          dados["longitude"]
      );

      setState(() {

        Marker marcador = Marker(
            markerId: MarkerId("marcador-${latLng.latitude}-${latLng.longitude}"),
            position: latLng,
            infoWindow: InfoWindow(
                title: titulo
            )
        );

        _marcadores.add( marcador );
        _posicaoCamera = CameraPosition(
            target: latLng,
            zoom: 18
        );
        _movimentarCamera();

      });
    }else{
      _adicionarListenerLocalizacao();
    }

  }

  @override
  void initState() {
    super.initState();

    _recuperaViagemParaId( widget.idViagem );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mapa"),),
      body: Container(
        child: GoogleMap(
          markers: _marcadores,
            mapType: MapType.normal,
            initialCameraPosition: _posicaoCamera,
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
          onLongPress: _adicionarMarcador,
        ),
      ),
    );
  }
}
