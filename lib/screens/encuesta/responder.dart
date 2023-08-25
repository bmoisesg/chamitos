// ignore_for_file: use_build_context_synchronously, prefer_typing_uninitialized_variables, avoid_print

import 'dart:async';

import 'package:encuentas/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ResponderEncuesta extends StatefulWidget {
  final String code;
  const ResponderEncuesta({required this.code, super.key});

  @override
  State<ResponderEncuesta> createState() => _ResponderEncuestaState();
}

class _ResponderEncuestaState extends State<ResponderEncuesta> {
  var encuesta;
  DateTime selectedDate = DateTime.now();
  List<TextEditingController> textControllers = [];
  late String idEncuesta;

  Future<bool> getData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    DataSnapshot snapshot = await ref.child('encuestas/').get();
    bool buscarEncuesta = false;
    if (snapshot.exists) {
      if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> dataMap = snapshot.value as Map;
        dataMap.forEach((key, value) {
          if (value['nombre'] == widget.code) {
            idEncuesta = key;
            buscarEncuesta = true;
            encuesta = value;
            textControllers = List.generate(
                encuesta['campos'].length, (_) => TextEditingController());
          }
        });
      }
    }

    return buscarEncuesta;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encuesta'),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Text(
          encuesta['nombre'],
          textAlign: TextAlign.center,
          style:
              const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 20),
        Text(
          encuesta['descripcion'],
          style: const TextStyle(letterSpacing: 1.25),
        ),
        const SizedBox(height: 20),
        const Divider(),
        if (encuesta['campos'] != null)
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: encuesta['campos'].length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromARGB(255, 59, 41, 91)
                              .withOpacity(0.08)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (encuesta['campos'][index]['requerido']) ...{
                            const Text(
                              'Obligatorio*',
                              style: TextStyle(color: Colors.red, fontSize: 10),
                            )
                          },
                          Text(
                            encuesta['campos'][index]['titulo'],
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 10),
                          if (encuesta['campos'][index]['tipo'] == 'Text') ...{
                            TextFormField(
                              controller: textControllers[index],
                              keyboardType: TextInputType.text,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "",
                                fillColor: Colors.transparent,
                                filled: true,
                                isDense: true,
                              ),
                            )
                          },
                          if (encuesta['campos'][index]['tipo'] ==
                              'Numero') ...{
                            TextFormField(
                              controller: textControllers[index],
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "",
                                fillColor: Colors.transparent,
                                filled: true,
                                isDense: true,
                              ),
                            )
                          },
                          if (encuesta['campos'][index]['tipo'] == 'Fecha') ...{
                            StatefulBuilder(builder:
                                (BuildContext context, StateSetter setState) {
                              return Column(
                                children: [
                                  TextFormField(
                                    enabled: false,
                                    controller: textControllers[index],
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "",
                                      fillColor: Colors.transparent,
                                      filled: true,
                                      isDense: true,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      final DateTime? picked =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: selectedDate,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime(2101),
                                      );
                                      if (picked != null &&
                                          picked != selectedDate) {
                                        setState(() {
                                          textControllers[index].text =
                                              picked.toString();
                                        });
                                      }
                                    },
                                    child: const Text(
                                      'Seleccionar Fecha',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            })
                          },
                        ],
                      ),
                    );
                  }),
            ),
          ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: fntEnviarRespuestas,
          child: const Text('Enviar respuestas'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  fntEnviarRespuestas() async {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Row(
              children: [
                Text("Enviando respuestas..."),
                CircularProgressIndicator()
              ],
            ),
          );
        });
    var listaResultados = <String, String>{};
    int contador = 1;
    for (var element in textControllers) {
      var newEntrie = <String, String>{
        "respuesta${(++contador).toString()}": element.text
      };
      listaResultados.addEntries(newEntrie.entries);
    }

    DatabaseReference ref = FirebaseDatabase.instance.ref();
    await ref
        .child('encuestas/$idEncuesta/resultados')
        .push()
        .set(listaResultados);
    Navigator.pop(context);
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Respuestas Enviadas"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                );
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
