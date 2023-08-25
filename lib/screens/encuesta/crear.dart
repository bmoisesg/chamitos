// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:encuentas/screens/encuesta/lista.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CrearEncuesta extends StatefulWidget {
  const CrearEncuesta({super.key});

  @override
  State<CrearEncuesta> createState() => _CrearEncuestaState();
}

class _CrearEncuestaState extends State<CrearEncuesta> {
  TextEditingController ctrlName = TextEditingController();
  TextEditingController ctrlDescription = TextEditingController();
  TextEditingController ctrlNameCampo = TextEditingController();
  TextEditingController ctrlTitleCampo = TextEditingController();
  bool boolSwitch = false;
  List list = <String>['Text', 'Numero', 'Fecha'];
  String dropdownvalue = 'Text';
  List listaCampos = [];

  @override
  Widget build(BuildContext context) {
    double widthPage = 0.8;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Crear encuesta'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MostrarEncuestas()),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: fntSave,
        label: const Text('Guardar'),
        icon: const Icon(Icons.save),
      ),
      body: Center(
        child: FractionallySizedBox(
          widthFactor: widthPage,
          child: buildBody(),
        ),
      ),
    );
  }

  Widget buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        TextFormField(
          keyboardType: TextInputType.text,
          controller: ctrlName,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Nombre de encuesta*",
            fillColor: Colors.transparent,
            filled: true,
            isDense: true,
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          keyboardType: TextInputType.text,
          controller: ctrlDescription,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: "Descripcion",
            fillColor: Colors.transparent,
            filled: true,
            isDense: true,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          icon: const Icon(Icons.playlist_add),
          onPressed: fntAddCampo,
          label: const Text('Agregar Campo'),
        ),
        const SizedBox(height: 20),
        const Text(
          'Lista de campos:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: listaCampos.isNotEmpty
              ? ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: listaCampos.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                listaCampos[index]['titulo'],
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              listaCampos[index]['tipo'],
                            ),
                          ],
                        ),
                        const Divider()
                      ],
                    );
                  },
                )
              : const Center(child: Text('Sin atributos aun...')),
        )
      ],
    );
  }

  fntAddCampo() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context)
                      .viewInsets
                      .bottom, // Asegura que el teclado no bloquee el contenido
                ),
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      const Text('Ingresar datos del campo:'),
                      const SizedBox(height: 20),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: ctrlNameCampo,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "id del campo*",
                          fillColor: Colors.transparent,
                          filled: true,
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        controller: ctrlTitleCampo,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Titulo*",
                          fillColor: Colors.transparent,
                          filled: true,
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Text('¿Es requerido?*'),
                          Switch(
                            value: boolSwitch,
                            onChanged: (bool value) {
                              setState(() {
                                boolSwitch = value;
                              });
                            },
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      DropdownButton<String>(
                        value: dropdownvalue,
                        items: list.map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            dropdownvalue = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: fntAddCampoOk,
                        child: const Text('Agregar campo'),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  fntAddCampoOk() {
    if (ctrlNameCampo.text == "" || ctrlTitleCampo.text == "") return;

    listaCampos.add({
      "nombre": ctrlNameCampo.text,
      "titulo": ctrlTitleCampo.text,
      "requerido": boolSwitch,
      "tipo": dropdownvalue
    });

    ctrlNameCampo.text = "";
    ctrlTitleCampo.text = "";
    boolSwitch = true;

    setState(() {});
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('campo agregado!'),
      ),
    );
  }

  fntSave() async {
    if (ctrlName.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Necesitas ingresar nombre de la encuesta '),
        ),
      );
      return;
    }
    if (listaCampos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Necesitas ingresar al menos un campo '),
        ),
      );
      return;
    }
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Row(
            children: [
              Text("Ingresando encuesta..."),
              CircularProgressIndicator()
            ],
          ),
        );
      },
    );

    DatabaseReference ref = FirebaseDatabase.instance.ref();
    var data = {
      "nombre": ctrlName.text,
      "descripcion": ctrlDescription.text,
      "campos": listaCampos
    };
    await ref.child('encuestas').push().set(data);
    Navigator.pop(context);

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Encuesta Guardada"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text('Codigo: ${ctrlName.text}')],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                setState(() {
                  ctrlDescription.text = "";
                  listaCampos = [];
                });
                ctrlName.text = "";
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
