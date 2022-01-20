import 'package:flutter/material.dart';
import 'dart:io';
import 'package:bancodedados_exemplo/domain/contact.dart';
import 'package:bancodedados_exemplo/helpers/contact_helper.dart';
import 'contact_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contacts = [];

  //carrega a lista de contatos do banco ao iniciar o app
  @override
  void initState() {
    super.initState();

    updateList();
  }

  void updateList() {
    helper.getAllContacts().then((list) {
      //atualizando a lista de contatos na tela
      setState(() {
        contacts = list.cast<Contact>();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Contatos"),
          backgroundColor: Colors.teal,
          centerTitle: true),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          }),
    );
  }

  /// Função para criação de um card de contato para lista.
  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: contacts[index].img != ''
                              ? FileImage(File(contacts[index].img))
                              : AssetImage("images/person.png")
                                  as ImageProvider)),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //se não existe nome, joga vazio
                      Text(
                        contacts[index].name,
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        contacts[index].email,
                        style: TextStyle(fontSize: 18.0),
                      ),
                      Text(
                        contacts[index].phone,
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          _showOptions(context, index);
        });
  }

  //mostra as opções
  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            //onclose obrigatório. Não fará nada
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  //ocupa o mínimo de espaço.
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextButton(
                            child: Text("ligar",
                                style: TextStyle(
                                    color: Colors.teal, fontSize: 20.0)),
                            onPressed: () {
                              launch("tel:${contacts[index].phone}");
                              Navigator.pop(context);
                            })),
                    Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextButton(
                            child: Text("editar",
                                style: TextStyle(
                                    color: Colors.teal, fontSize: 20.0)),
                            onPressed: () {
                              Navigator.pop(context);
                              _showContactPage(contact: contacts[index]);
                            })),
                    Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextButton(
                            child: Text("excluir",
                                style: TextStyle(
                                    color: Colors.teal, fontSize: 20.0)),
                            onPressed: () {
                              helper.deleteContact(contacts[index].id);
                              updateList();
                              Navigator.pop(context);
                            }))
                  ],
                ),
              );
            },
          );
        });
  }

  //mostra o contato. Parâmetro opcional
  void _showContactPage({Contact? contact}) async {
    Contact contatoRet = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));

    if (contatoRet.id == 0) {
      await helper.saveContact(contatoRet);
    } else {
      await helper.updateContact(contatoRet);
    }

    updateList();
  }
}
