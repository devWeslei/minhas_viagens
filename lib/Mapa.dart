import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

class Mapa extends StatefulWidget {
  const Mapa({Key? key}) : super(key: key);

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

  _onMapCreated( GoogleMapController controller ){
    _controller.complete( controller );
  }

  _exibirMarcador( LatLng latLng) async {

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

    var locationSetings = LocationSettings(accuracy: LocationAccuracy.high);

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

  @override
  void initState() {
    super.initState();

    _adicionarListenerLocalizacao();
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
          onLongPress: _exibirMarcador,
        ),
      ),
    );
  }
}
