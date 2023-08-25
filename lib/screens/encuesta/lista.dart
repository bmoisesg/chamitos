// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:encuentas/screens/encuesta/crear.dart';
import 'package:encuentas/screens/encuesta/resultados.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MostrarEncuestas extends StatefulWidget {
  const MostrarEncuestas({super.key});

  @override
  State<MostrarEncuestas> createState() => _MostrarEncuestasState();
}

class _MostrarEncuestasState extends State<MostrarEncuestas> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: fntCreateEncuesta,
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Encuestas disponibles'),
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: FractionallySizedBox(
                  widthFactor: 0.8, child: _buildBody(snapshot.data!)),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Future<dynamic> getData() async {
    List listaEcuestas = [];
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    DataSnapshot snapshot = await ref.child('encuestas/').get();
    if (snapshot.exists) {
      if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> dataMap = snapshot.value as Map;
        dataMap.forEach((key, value) {
          listaEcuestas.add({"id": key, "value": value['nombre']});
        });

        return listaEcuestas;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontraron encuestas')),
      );
    }
    return [];
  }

  Widget _buildBody(List lista) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text(
          'Lista de encuestas:',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 40),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nombre',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            Text(
              'Acciones',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        const Divider(color: Color.fromARGB(255, 59, 41, 91)),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: lista.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  padding: const EdgeInsets.all(10),
                  color:
                      const Color.fromARGB(255, 59, 41, 91).withOpacity(0.08),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          lista[index]['value'],
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                          onPressed: () =>
                              fntDeleteEncuesta(lista[index]['id']),
                          icon: const Icon(
                            Icons.delete,
                            color: Color.fromARGB(255, 59, 41, 91),
                          )),
                      IconButton(
                          onPressed: () =>
                              fntResultadosEncuesta(lista[index]['id']),
                          icon: const Icon(
                            Icons.view_list,
                            color: Color.fromARGB(255, 59, 41, 91),
                          ))
                    ],
                  ),
                );
              }),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  fntCreateEncuesta() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const CrearEncuesta()),
    );
  }

  fntDeleteEncuesta(String id) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    await ref.child('encuestas/$id').remove();
    setState(() {});
  }

  fntResultadosEncuesta(String id) async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ResultadosEncuesta(idEncuesta: id)),
    );
  }
}
