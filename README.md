# Prueba Técnica, Entregable. Facturacion.cl | Desis


## Resultado de Entregable
Bosquejo de entregable

![image](https://github.com/user-attachments/assets/d5313812-ebe7-4fad-acfa-0dc29e1e7deb)

Resultado. (El DataTable es deslizable de manera horizontal)

![image](https://github.com/user-attachments/assets/547eb410-a67b-45f0-b465-a6d219d1b4e7)

Ademas se le agrego la funcionalidad 'delete' para borrar registros.

![image](https://github.com/user-attachments/assets/d350f276-e99b-46ca-a709-05a4131292ca)

![image](https://github.com/user-attachments/assets/4235abaa-5a5d-4703-8de6-6f6c9374d088)

## Documentación Código

Ire desglosando los requerimientos y acorde a eso documentaré lo que hice para abarcar lo que se evaluo

### 1. Definición de comportamiento  

"En caso de presionar registrar y no haya completado algún campo debe arrojar un mensaje con la siguiente estructura   

Título:  Campo Obligatorio  

Mensaje: El campo XXXX es obligatorio"

Para esto se creo la siguiente función:

    void _showFieldError(String fieldName) {
      _showMessage('Campo Obligatorio', 'El campo $fieldName es obligatorio');
    }

Y aca tenemos un ejemplo de como se ejecuta en el campo de texto del Nombre:

                       TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nombre Completo'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            _showFieldError('Nombre Completo');
                            return '';
                          }
                        ...resto del código
                        
Vale decir, si el valor es null o no hay información ejecuta la funcion señalada anteriormente y le entrega el fieldname que en este caso es 'Nombre Completo', y asi para todos los 'TextFormField'


### 2. API

Si presiona el botón de obtener desde api debe consumir y obtener los datos del formulario desde https://randomuser.me/ :

Representado por esta funcion:

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

  Extrae la data de la api requerida y la llena en los form fields que se le señalan. Esto usando el http package, recibiendo json response. Con esta data popula los controller.text que se ven en el código.

### 3. Tabla

"Si se registró de forma exitosa debe visualizarse dicho registro en la tabla del final. "

El proceso va desde que el usuario apreta el botón 'Registrar', ahí se ejecuta el metodo _registerUser

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

Después ocurren las sucesivas validaciones. Si todo va bien esta data se va al objeto que representa al usuario:

    List<Map<String, dynamic>> _users = [];
  
Después en la inserción toma los controllers.text y llena el registro:

     Future<int> insertUser(Map<String, dynamic> user) async {
       Database db = await database;
       return await db.insert('users', user);
     }

Despues de ocurrido todo el proceso, se ejecuta _loadUsers (como se veia en la funcion del principio)

        Future<void> _loadUsers() async {
         final users = await DatabaseHelper().getUsers();
         setState(() {
           _users = users;
         });
       }

También podemos ver la tabla: 

     Future _onCreate(Database db, int version) async {
       await db.execute('''
         CREATE TABLE users (
           id INTEGER PRIMARY KEY,
           name TEXT NOT NULL,
           email TEXT NOT NULL,
           birthdate TEXT NOT NULL,
           address TEXT NOT NULL,
           password TEXT NOT NULL
         )
       ''');
     }
Para la tabla se ocupo de forma predeterminada el usual widget con datacolumn y datacell

### 4. Validaciones


Nombre:  
No debe estar vacío: 

                          if (value == null || value.isEmpty) {
                            _showFieldError('Nombre Completo');
                            return '';
                          }
Puede incluir validaciones adicionales como longitud mínima:

                          if (value.length < 3) {
                            return 'El nombre debe tener al menos 3 caracteres';
                          }

Caracteres permitidos. (como ejemplo, ya que en algunos paises se usan '-' entre nombres o apellidos y otros caracteres atipicos)

                           if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                            return 'El nombre solo puede contener letras y espacios';
                          }

Correo:  

No debe estar vacío:

                          if (value == null || value.isEmpty) {
                            _showFieldError('Correo Electrónico');
                            return '';
                          }

Debe tener un formato válido de correo electrónico:

                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Ingrese un correo válido';
                          }

Fecha de Nacimiento:  

No debe estar vacío:

                          if (value == null || value.isEmpty) {
                            _showFieldError('Fecha Nacimiento');
                            return '';
                          }

Debe tener un formato válido de fecha (Se le puso datepicker pero igualmente agregué validación):

                          if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
                            return 'Ingrese una fecha válida (YYYY-MM-DD)';
                          }
                          
Dirección: 	No debe estar vacío.  

                          if (value == null || value.isEmpty) {
                              _showFieldError('Dirección');
                            return '';
                          }
Contraseña:  

No debe estar vacía:

                          if (value == null || value.isEmpty) {
                            _showFieldError('Contraseña');
                            return '';
                          }

Debe tener al menos 6 caracteres:

                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }

### 5. Organización, MVC.

Se podría haber organizado mejor en carpetas como en lib hacer subcarpetas ( /db, /models, /screens y /widgets) pero decidi hacerlo de esta forma dado que solo llega hasta este punto, dejo la anotación para dar por enterado que consideré eso.

