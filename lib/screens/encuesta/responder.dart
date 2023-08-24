import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ResponderEncuesta extends StatefulWidget {
  final String code;
  const ResponderEncuesta({required this.code, super.key});

  @override
  State<ResponderEncuesta> createState() => _ResponderEncuestaState();
}

class _ResponderEncuestaState extends State<ResponderEncuesta> {
  late Object encuesta;

  Future<bool> getData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    DataSnapshot snapshot = await ref.child('encuestas/').get();
    bool buscarEncuesta = false;
    if (snapshot.exists) {
      if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> dataMap = snapshot.value as Map;
        dataMap.forEach((key, value) {
          if (value['nombre'] == widget.code) {
            buscarEncuesta = true;
            encuesta = value;
          }
        });
      }
    }
    return buscarEncuesta;
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Encuesta ${widget.code}'),
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: snapshot.data!
                    ? _buildBody()
                    : Container(
                        padding: const EdgeInsets.only(top: 50, bottom: 50),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromARGB(255, 59, 41, 91)
                              .withOpacity(0.08),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning,
                              color: Color.fromARGB(255, 59, 41, 91),
                            ),
                            Text('No se encontro esta encuesta'),
                          ],
                        ),
                      ),
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [],
    );
  }
}
