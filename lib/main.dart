   import 'package:flutter/material.dart';
   import 'database_helper.dart';
   import 'package:http/http.dart' as http;
   import 'dart:convert';

   void main() {
     runApp(const MyApp());
   }

   class MyApp extends StatelessWidget {
     const MyApp({super.key});

     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         title: 'Registro de Usuario',
         theme: ThemeData(
           primarySwatch: Colors.blue,
         ),
         home: const UserForm(),
         debugShowCheckedModeBanner: false, // Remueve el banner
       );
     }
   }

   class UserForm extends StatefulWidget {
     const UserForm({super.key});

     @override
     _UserFormState createState() => _UserFormState();
   }

   class _UserFormState extends State<UserForm> {
     final _formKey = GlobalKey<FormState>();
     final _nameController = TextEditingController();
     final _emailController = TextEditingController();
     final _birthdateController = TextEditingController();
     final _addressController = TextEditingController();
     final _passwordController = TextEditingController();

     List<Map<String, dynamic>> _users = [];

     @override
     void initState() {
       super.initState();
       _loadUsers();
     }

     Future<void> _loadUsers() async {
       final users = await DatabaseHelper().getUsers();
       setState(() {
         _users = users;
       });
     }

     Future<void> _registerUser() async {
       if (_formKey.currentState!.validate()) {
         Map<String, dynamic> user = {
           'name': _nameController.text,
           'email': _emailController.text,
           'birthdate': _birthdateController.text,
           'address': _addressController.text,
           'password': _passwordController.text,
         };
         await DatabaseHelper().insertUser(user);
         _showMessage('Registro Exitoso', 'El usuario ha sido registrado.');
         _clearForm();
         _loadUsers(); // Cargar usuarios después de registrar
       }
     }

     Future<void> _fetchFromApi() async {
       final response = await http.get(Uri.parse('https://randomuser.me/api/'));
       if (response.statusCode == 200) {
         final data = json.decode(response.body);
         setState(() {
           _nameController.text = data['results'][0]['name']['first'];
           _emailController.text = data['results'][0]['email'];
           _birthdateController.text = data['results'][0]['dob']['date'].substring(0, 10);
           _addressController.text = data['results'][0]['location']['street']['name'];
          _passwordController.text = data['results'][0]['login']['password']; // Obtener la contraseña
         });
       } else {
         _showMessage('Error', 'No se pudieron obtener los datos.');
       }
     }

     void _showMessage(String title, String message) {
       showDialog(
         context: context,
         builder: (BuildContext context) {
           return AlertDialog(
             title: Text(title),
             content: Text(message),
             actions: <Widget>[
               TextButton(
                 child: const Text('OK'),
                 onPressed: () {
                   Navigator.of(context).pop();
                 },
               ),
             ],
           );
         },
       );
     }

     void _clearForm() {
       _nameController.clear();
       _emailController.clear();
       _birthdateController.clear();
       _addressController.clear();
       _passwordController.clear();
     }


    void _showFieldError(String fieldName) {
      _showMessage('Campo Obligatorio', 'El campo $fieldName es obligatorio');
    }

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: const Text(
             'Registro de usuario',
             style: TextStyle(color: Colors.white), 
           ),
           backgroundColor: Colors.blue, 
         ),
         body: SingleChildScrollView(
           child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: <Widget>[
                 Form(
                   key: _formKey,
                   child: Column(
                     children: <Widget>[
                       TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nombre Completo'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            _showFieldError('Nombre Completo');
                            return '';
                          }
                          if (value.length < 3) {
                            return 'El nombre debe tener al menos 3 caracteres';
                          }
                          if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                            return 'El nombre solo puede contener letras y espacios';
                          }
                          return null;
                        },
                       ),
                       const SizedBox(height: 10),
                       TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            _showFieldError('Correo Electrónico');
                            return '';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Ingrese un correo válido';
                          }
                          return null;
                        },
                       ),
                       const SizedBox(height: 10),
                       TextFormField(
                        controller: _birthdateController,
                        decoration: const InputDecoration(labelText: 'Fecha Nacimiento'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            _showFieldError('Fecha Nacimiento');
                            return '';
                          }
                          if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                            return 'Ingrese una fecha válida (YYYY-MM-DD)';
                          }
                          return null;
                        },
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              _birthdateController.text = pickedDate.toLocal().toString().split(' ')[0];
                            });
                          }
                        },
                       ),
                       const SizedBox(height: 10),
                       TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: 'Dirección'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                              _showFieldError('Dirección');
                            return '';
                          }
                          return null;
                        },
                       ),
                       const SizedBox(height: 10),
                       TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Contraseña'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            _showFieldError('Contraseña');
                            return '';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                       ),
                     ],
                   ),
                 ),
                 const SizedBox(height: 20),
                 Center(
                   child: Column(
                     children: [
                       ElevatedButton(
                         onPressed: _registerUser,
                         child: const Text(
                           'Registrar',
                           style: TextStyle(color: Colors.white),
                         ),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.blue,
                           padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                         ),
                       ),
                       const SizedBox(height: 10),
                       ElevatedButton(
                         onPressed: _fetchFromApi,
                         child: const Text(
                           'Obtener Desde API',
                           style: TextStyle(color: Colors.white), 
                         ),
                         style: ElevatedButton.styleFrom(
                           backgroundColor: Colors.blue,
                           padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                         ),
                       ),
                     ],
                   ),
                 ),
                 const SizedBox(height: 20),
                 SingleChildScrollView(
                   scrollDirection: Axis.horizontal,
                   child: _buildUserTable(),
                 ),
               ],
             ),
           ),
         ),
       );
     }

  Widget _buildUserTable() {
    return DataTableTheme(
      data: DataTableThemeData(
        headingRowColor: MaterialStateProperty.all(Colors.blue), 
        headingTextStyle: const TextStyle(color: Colors.white), 
      ),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Nombre')),
          DataColumn(label: Text('Correo')),
          DataColumn(label: Text('Fecha Nacimiento')),
          DataColumn(label: Text('Borrar')), 
        ],
        rows: _users.map((user) {
          return DataRow(cells: [
            DataCell(Text(user['name'])),
            DataCell(Text(user['email'])),
            DataCell(Text(user['birthdate'])),
            DataCell(
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteUser(user['id']),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  Future<void> _deleteUser(int id) async {
    await DatabaseHelper().deleteUser(id);
    _showMessage('Usuario Eliminado', 'El usuario ha sido eliminado.');
    _loadUsers(); 
  }
}

