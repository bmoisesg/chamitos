import 'package:encuentas/color.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ResultadosEncuesta extends StatefulWidget {
  final String idEncuesta;
  const ResultadosEncuesta({required this.idEncuesta, super.key});

  @override
  State<ResultadosEncuesta> createState() => _ResultadosEncuestaState();
}

class _ResultadosEncuestaState extends State<ResultadosEncuesta> {
  Future<List<Object>> getData() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    DataSnapshot snapshot =
        await ref.child('encuestas/${widget.idEncuesta}/resultados').get();
    List<Object> listaResultados = [];
    if (snapshot.exists) {
      if (snapshot.value != null && snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> resultados =
            snapshot.value as Map<dynamic, dynamic>;
        resultados.forEach((key, value) {
          listaResultados.add(value);
        });
      }
    }
    return listaResultados;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resuldas'),
      ),
      body: FutureBuilder<List<Object>>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Center(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: snapshot.data!.isNotEmpty
                    ? _buildBody(snapshot.data!)
                    : Container(
                        padding: const EdgeInsets.only(top: 50, bottom: 50),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Mycolor.purple.withOpacity(0.08),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning, color: Mycolor.purple),
                            const Text('Sin respuetas aun...'),
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

  Widget _buildBody(List<Object> resultados) {
    return Column(
      children: [
        const SizedBox(height: 40),
        const Text(
          'Respuestas:',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5),
        ),
        const SizedBox(height: 40),
        const Divider(),
        Expanded(
          child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: resultados.length,
              itemBuilder: (BuildContext context, int index) {
                Map<Object?, Object?> item = resultados[index] as Map;

                List resultado = [];
                item.forEach((key, value) {
                  resultado.add(value);
                });

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var respuesta in resultado) ...{
                      Text(
                        respuesta,
                        overflow: TextOverflow.ellipsis,
                      )
                    },
                    const Divider()
                  ],
                );
              }),
        ),
      ],
    );
  }
}
