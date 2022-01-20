import 'dart:io';
import 'package:bancodedados_exemplo/domain/contact.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  Contact? contact;

  //construtor que inicia o contato.
  //Entre chaves porque é opcional.
  ContactPage({this.contact});

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact? _editedContact;
  bool _userEdited = false;

  //para garantir o foco no nome
  final _nomeFocus = FocusNode();

  //controladores
  TextEditingController nomeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    //acessando o contato definido no widget(ContactPage)
    //mostrar se ela for privada
    if (widget.contact == null)
      _editedContact = Contact();
    else {
      _editedContact = widget.contact;

      nomeController.text = _editedContact!.name;
      emailController.text = _editedContact!.email;
      phoneController.text = _editedContact!.phone;
    }
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Abandonar alteração?"),
              content: Text("Os dados serão perdidos."),
              actions: <Widget>[
                TextButton(
                    child: Text("cancelar"),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                TextButton(
                  child: Text("sim"),
                  onPressed: () {
                    //desempilha 2x
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                )
              ],
            );
          });
    } else {
      return Future.value(true);
    }
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    //com popup de confirmação
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.teal,
            title: Text(_editedContact!.name),
            centerTitle: true),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact!.name.isNotEmpty)
              Navigator.pop(context, _editedContact);
            else
              FocusScope.of(context).requestFocus(_nomeFocus);
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.teal,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              GestureDetector(
                child: Container(
                    width: 140.0,
                    height: 140.0,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: _editedContact!.img != ''
                                ? FileImage(File(_editedContact!.img))
                                : AssetImage('images/person.png')
                                    as ImageProvider))),
                onTap: () {
                  ImagePicker()
                      .getImage(source: ImageSource.camera, imageQuality: 50)
                      .then((file) {
                    if (file == null)
                      return;
                    else {
                      setState(() {
                        _editedContact!.img = file.path;
                      });
                    }
                  });
                },
              ),
              TextField(
                controller: nomeController,
                focusNode: _nomeFocus,
                decoration: InputDecoration(labelText: "Nome"),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact!.name = text;
                  });
                },
              ),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(labelText: "E-mail"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact!.email = text;
                },
              ),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Telefone"),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact!.phone = text;
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
