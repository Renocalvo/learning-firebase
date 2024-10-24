import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codelab/app/data/app_color.dart';
import 'package:codelab/app/data/widget_background.dart';
import 'package:codelab/app/modules/task/views/createTask_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final AppColor appColor = AppColor();

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double widthScreen = mediaQueryData.size.width;
    double heightScreen = mediaQueryData.size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi! Ganteng'),
        backgroundColor: appColor.colorPrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Tampilkan konfirmasi sebelum logout
              bool confirmLogout = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Konfirmasi Logout'),
                        content: Text('Apakah Anda yakin ingin logout?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text('Logout'),
                          ),
                        ],
                      );
                    },
                  ) ??
                  false; // Jika null, dianggap false

              if (confirmLogout) {
                // Logout dari Firebase
                await FirebaseAuth.instance.signOut();
                // Kembali ke halaman login atau halaman awal
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      backgroundColor: appColor.colorPrimary,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            WidgetBackground(),
            _buildWidgetListTodo(widthScreen, heightScreen, context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTaskScreen(isEdit: false),
            ),
          );
          if (result != null && result) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Task has been created')),
            );
            setState(() {});
          }
        },
        backgroundColor: appColor.colorTertiary,
      ),
    );
  }

  Container _buildWidgetListTodo(
      double widthScreen, double heightScreen, BuildContext context) {
    return Container(
      width: widthScreen,
      height: heightScreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
            child: Text(
              'Todo List',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('tasks').orderBy('date').snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No tasks available'));
                }

                return ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    Map<String, dynamic>? task =
                        document.data() as Map<String, dynamic>?;

                    if (task == null) {
                      return Center(child: Text('Task data is missing'));
                    }

                    // Mengambil data task dengan null safety
                    String name = task['name'] ?? 'No Name';
                    String description =
                        task['description'] ?? 'No Description';
                    String strDate = task['date'] ?? '1 Januari 2024';

                    // Mengatasi parsing string untuk tanggal
                    List<String> dateParts = strDate.split(' ');
                    String day = dateParts.isNotEmpty ? dateParts[0] : '1';
                    String month =
                        dateParts.length > 1 ? dateParts[1] : 'Januari';

                    return Card(
                      child: ListTile(
                        title: Text(name),
                        subtitle: Text(
                          description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 24.0,
                              height: 24.0,
                              decoration: BoxDecoration(
                                color: appColor.colorSecondary,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(height: 4.0),
                            Text(
                              month,
                              style: TextStyle(fontSize: 12.0),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          itemBuilder: (BuildContext context) {
                            return <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ];
                          },
                          onSelected: (String value) async {
                            if (value == 'edit') {
                              // Fitur Edit Task
                              bool? result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateTaskScreen(
                                    isEdit: true,
                                    documentId: document.id,
                                    name: name,
                                    description: description,
                                    date: strDate,
                                  ),
                                ),
                              );
                              if (result != null && result) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Task has been updated'),
                                  ),
                                );
                              }
                            } else if (value == 'delete') {
                              // Konfirmasi sebelum menghapus task
                              bool confirmDelete = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Konfirmasi Hapus'),
                                        content: Text(
                                            'Apakah Anda yakin ingin menghapus task ini?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: Text('Hapus'),
                                          ),
                                        ],
                                      );
                                    },
                                  ) ??
                                  false; // Jika null, dianggap false

                              if (confirmDelete) {
                                await firestore
                                    .collection('tasks')
                                    .doc(document.id)
                                    .delete();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Task has been deleted'),
                                  ),
                                );
                              }
                            }
                          },
                          child: Icon(Icons.more_vert),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
