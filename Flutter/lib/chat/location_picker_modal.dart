import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerModal extends StatefulWidget {
  final Function(String name, String address, double lat, double lng) onLocationPicked;

  const LocationPickerModal({
    Key? key,
    required this.onLocationPicked,
  }) : super(key: key);

  @override
  _LocationPickerModalState createState() => _LocationPickerModalState();
}

class _LocationPickerModalState extends State<LocationPickerModal> {
  late GoogleMapController mapController;
  LatLng? selectedLocation;
  String? selectedAddress;
  String? selectedName;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => isLoading = true);
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        selectedLocation = LatLng(position.latitude, position.longitude);
        _getAddressFromLatLng(selectedLocation!);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get current location: $e')),
      );
    }
    setState(() => isLoading = false);
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          selectedAddress = '${place.street}, ${place.locality}, ${place.country}';
          selectedName = place.name ?? 'Selected Location';
        });
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          AppBar(
            title: Text('Pick Meeting Location'),
            actions: [
              if (selectedLocation != null)
                TextButton(
                  onPressed: () {
                    if (selectedLocation != null && selectedAddress != null && selectedName != null) {
                      widget.onLocationPicked(
                        selectedName!,
                        selectedAddress!,
                        selectedLocation!.latitude,
                        selectedLocation!.longitude,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text('Confirm', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: selectedLocation ?? LatLng(0, 0),
                          zoom: 15,
                        ),
                        onMapCreated: (controller) => mapController = controller,
                        onTap: (LatLng position) {
                          setState(() {
                            selectedLocation = position;
                            _getAddressFromLatLng(position);
                          });
                        },
                        markers: selectedLocation == null
                            ? {}
                            : {
                                Marker(
                                  markerId: MarkerId('selected'),
                                  position: selectedLocation!,
                                ),
                              },
                      ),
                      if (selectedAddress != null)
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(selectedAddress!),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}