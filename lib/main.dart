import 'package:flutter/material.dart';
//letak package folder flutter
import 'package:flutter_web_sqlite/ui/entryform.dart';
import 'package:flutter_web_sqlite/models/contact.dart';
import 'package:flutter_web_sqlite/dbhelper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flushbar/flushbar.dart';

//untuk memanggil fungsi yg terdapat di daftar pustaka sqflite
import 'dart:async';
import 'package:flutter_stetho/flutter_stetho.dart';
//pendukung program asinkron

void main() {
  //Stetho.initialize();
  return runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Kontak App",
    home: Home(),
  ));
}
class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {

  DbHelper dbHelper = DbHelper();
  int count = 0;
  List<Contact> contactList;

  @override
  Widget build(BuildContext context) {
    if (contactList == null) {
      contactList = List<Contact>();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Kontak App'),
      ),
      body: createListView(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        tooltip: 'Tambah Data',
        onPressed: () async {


          var contact = await navigateToEntryForm(context, null);
          if (contact != null) addContact(contact);

        },
      ),
    );
  }

  Future<Contact> navigateToEntryForm(BuildContext context, Contact contact) async {
    var result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) {
              return EntryForm(contact);
            }
        )
    );
    return result;
  }

  ListView createListView() {


    TextStyle textStyle = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int index) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.people),
            ),
            title: Text(this.contactList[index].name, style: textStyle,),
            subtitle: Text(this.contactList[index].phone),
            trailing: GestureDetector(
              child: Icon(Icons.delete_forever),
              onTap: () {
                deleteContact(contactList[index]);
              },
            ),
            onTap: () async {
              var contact = await navigateToEntryForm(context, this.contactList[index]);
              if (contact != null) editContact(contact);
            },
          ),
        );
      },
    );
  }
  //buat contact
  void addContact(Contact object) async {
    int result = await dbHelper.insert(object);
    if (result > 0) {
      updateListView();
    }
  }
  //edit contact
  void editContact(Contact object) async {
    int result = await dbHelper.update(object);
    if (result > 0) {
      updateListView();
    }
  }
  //delete contact
  void deleteContact(Contact object) async {
    int result = await dbHelper.delete(object.id);
    if (result > 0) {
      updateListView();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateListView();
  }
  //update contact
  void updateListView() {
    final Future<Database> dbFuture = dbHelper.initDb();
    dbFuture.then((database) {
      Future<List<Contact>> contactListFuture = dbHelper.getContactList();

      contactListFuture.then((contactList) {
        if(!mounted) return;
        setState(() {
          this.contactList = contactList;
          for(int i=0; i < contactList.length ; i++) {

            print("dapat contact ${contactList[i].name}");
            print("dapat contact ${contactList[i].id}");
          }
          this.count = contactList.length;
        });
      });
    });
  }

}