import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

validaNull(value) {
  if (value == null || value.isEmpty) {
    return '*Campo Obrigatório!';
  }
  return null;
}

validaNullClean(value) {
  if (value == null || value.isEmpty) {
    return '';
  }
  return null;
}

//Cadastro/Login:
class RegisterUser {
  int id;
  String nome;
  String email;
  String senha;

  RegisterUser(this.id, this.nome, this.email, this.senha);

  Map<String, dynamic> toJson() {
    return {
      'usuario': "user",
      'nome': nome,
      'email': email,
      'senha': senha,
    };
  }

  Map<String, dynamic> updateToJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'senha': senha,
    };
  }
}

Future<int> cadastro(tipo, nome, email, senha, ultimo) async {
  RegisterUser newUser = RegisterUser(tipo, nome, email, senha);

  String jsonUser = jsonEncode(newUser.toJson());

  http.Response response = await http.post(
    Uri.parse("http://localhost:8000/cadastro"),
    headers: {'Content-Type': 'application/json'},
    body: jsonUser,
  );

  if (response.statusCode == 200) {
    print('Cadastro feito com sucesso');
  } else {
    if (response.statusCode == 400) {
      print('erro no cadastro');
    }
  }
  return response.statusCode;
}

Future<int> update(id, nome, email, senha) async {
  RegisterUser newUser = RegisterUser(id, nome, email, senha);

  String jsonUser = jsonEncode(newUser.updateToJson());

  http.Response response = await http.post(
    Uri.parse("http://localhost:8000/update"),
    headers: {'Content-Type': 'application/json'},
    body: jsonUser,
  );

  if (response.statusCode == 200) {
    print('Cadastro feito com sucesso');
  } else {
    if (response.statusCode == 400) {
      print('erro no cadastro');
    }
  }
  return response.statusCode;
}

//Receitas/Inscritos:
class Receita {
  String tituloReceitas;
  String descricao;
  String id = '0';
  String requisitos;
  String preparo;

  Receita(
      {required this.tituloReceitas,
      required this.descricao,
      required this.id,
      required this.requisitos,
      required this.preparo});

  factory Receita.fromJson(Map<String, dynamic> json) {
    return Receita(
      tituloReceitas: json['titulo'],
      descricao: json['descricao'],
      id: json['id_receitas'].toString(),
      requisitos: json['requisitos'],
      preparo: json['preparo'],
    );
  }

  @override
  String toString() {
    return 'Receita: '
        'tituloReceitas=$tituloReceitas, '
        'descricao=$descricao, '
        'id=$id, '
        'requisitos=$requisitos, '
        'preparo=$preparo';
  }

  Map<String, dynamic> toJson(idUser) {
    return {
      "id_usuario": idUser,
      "id_receitas": id,
      "titulo_receitas": tituloReceitas,
      "descricao": descricao,
      "requisitos": requisitos,
      "preparo": preparo
    };
  }
}

void criaReceita(
    tituloReceitas, descricao, id, idUsuario, requisitos, preparo) async {
  Receita novaReceita = Receita(
      tituloReceitas: tituloReceitas,
      descricao: descricao,
      id: 'id',
      requisitos: requisitos,
      preparo: preparo);
  String jsonReceita = jsonEncode(novaReceita.toJson(idUsuario));
  http.Response response = await http.post(
    Uri.parse("http://localhost:8000/receita/cadastro"),
    headers: {'Content-Type': 'application/json'},
    body: jsonReceita,
  );
  print(jsonReceita);
  if (response.statusCode == 200) {
    print('Receita registrada com sucesso');
  } else {
    print('erro ao cadastrar receita!');
    print(response.statusCode);
  }
}

//uri: /receita/update

Future<List<Receita>> listaReceitas() async {
  List<Receita> receitas = [];

  http.Response response = await http.post(
    Uri.parse('http://localhost:8000/receita/read/all'),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    List<dynamic> decodedData = jsonDecode(response.body);
    receitas = decodedData.map((data) => Receita.fromJson(data)).toList();
  } else {
    print(response.statusCode);
  }

  return receitas;
}

void deletaReceita(idReceita) async {
  Receita receita = Receita(
      tituloReceitas: '',
      descricao: '',
      id: idReceita,
      requisitos: '',
      preparo: '');
  //Map<String, dynamic> receita = {"id_receita": idReceita};
  String json = jsonEncode(receita.toJson(0));

  http.Response response = await http.post(
    Uri.parse("http://localhost:8000/receita/delete"),
    headers: {'Content-Type': 'application/json'},
    body: json,
  );
  if (response.statusCode == 200) {
    print('Receita Deletada com sucesso!');
  } else {
    print(response.statusCode);
    print(response.body);
  }
}

class LoggedUser {
  int tipo;
  String email;
  String senha;
  String nome;
  int id;

  LoggedUser(this.tipo, this.email, this.senha, this.nome, this.id);

  Map<String, dynamic> toJson() {
    switch (tipo) {
      case 1:
        return {
          'usuario': "user",
          'email': email,
          'senha': senha,
        };
      case 3:
        return {
          'usuario': "adm",
          'email': email,
          'senha': senha,
        };
      default:
        return {'default': ''};
    }
  }

  static LoggedUser fromJson(Map<String, dynamic> json, int tipo) {
    return LoggedUser(
      tipo,
      json['email'],
      json['senha'],
      json['nome'],
      json['id'],
    );
  }
}

Future<LoggedUser> login(tipo, email, senha) async {
  LoggedUser user = LoggedUser(tipo, email, senha, '', 0);
  String jsonUser = jsonEncode(user.toJson());
  http.Response response = await http.post(
    Uri.parse("http://localhost:8000/login"),
    headers: {'Content-Type': 'application/json'},
    body: jsonUser,
  );
  if (response.statusCode == 200) {
    final jsonBody = json.decode(response.body);
    print("logou!");
    print(jsonBody);
    LoggedUser logged = LoggedUser.fromJson(jsonBody, tipo);
    return logged;
  } else {
    if (response.statusCode == 204) {
      print("204");
    } else {
      print("outro");
    }
    return LoggedUser(204, 'email', 'senha', 'nome', 0);
  }
}

class Curtida {
  String Nome;
  String id;

  Curtida(this.Nome, this.id);

  Map<String, dynamic> toJson() {
    return {
      'Nome': Nome,
      'id': id,
    };
  }

  static Curtida fromJson(Map<String, dynamic> json) {
    return Curtida(
      json['Nome'],
      json['id'],
    );
  }
}

Future<List<Curtida>> getLiked(id) async {
  List<Curtida> curtidas = [];

  String url = "http://localhost:8000/curtida/all/read/$id";

  http.Response response = await http.get(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
  );

  print(response.body);

  if (response.statusCode == 200) {
    List<dynamic> decodedData = jsonDecode(response.body);
    print(response.statusCode);
    curtidas =
        List<Curtida>.from(decodedData.map((data) => Curtida.fromJson(data)));
  } else {
    print(response.statusCode);
  }

  print(curtidas);

  return curtidas;
}

Future<bool> likedOrNot(idUser, idReceita) async {
  print("entrou  em likedOrNot");
  return false;
}

void toggleLike(idUsuario, idReceita) async {
  print('entrou em curtida');
  Map<String, dynamic> receita = {
    "id_receitas": idReceita,
    "id_usuario": idUsuario
  };
  String json = jsonEncode(receita);

  http.Response response = await http.post(
    Uri.parse("http://localhost:8000/curtida/cadastro"),
    headers: {'Content-Type': 'application/json'},
    body: json,
  );
  if (response.statusCode == 200) {
    print('curtida registrada com sucesso');
  } else {
    print(response.statusCode);
    print(response.body);
  }
}

class Comentario {
  String user_id;
  String id;
  String texto;
  String idReceita;

  Comentario(this.user_id, this.id, this.texto, this.idReceita);

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'texto': texto,
      'idReceita': idReceita,
    };
  }

  static Comentario fromJson(Map<String, dynamic> json) {
    return Comentario(
      json['user_id'],
      json['id'],
      json['texto'],
      json['idReceita'],
    );
  }
}

void avaliar(rating, userId, recipeId) async {
  //alterar a avaliação do usuário
  Map<String, dynamic> like = {
    'id_usuario': userId,
    'id_receitas': recipeId,
    'nota': rating
  };
  String json = jsonEncode(like);
  String url = "http://localhost:8000/avaliacao/cadastro";

  http.Response response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: json,
  );
  if (response.statusCode == 200) {
    print('avaliação registrada com sucesso');
  } else if (response.statusCode == 204) {
    print('Erro ao alterar a avaliação');
    print(response.statusCode);
    print(response.body);
  }
}

void comentar(texto, userId, recipeId) async {
  //guardar um novo comentário do usuário em uma receita
  Comentario newComment = Comentario(userId, '0', texto, recipeId);
  String json = jsonEncode(newComment.toJson());
  String url = "";

  http.Response response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: json,
  );
  if (response.statusCode == 200) {
    print('Erro ao adicionar comentário');
  } else {
    print(response.statusCode);
    print(response.body);
  }
}

class Pesquisa {
  String string;
  String nota;

  Pesquisa(this.string, this.nota);

  Map<String, dynamic> toJson() {
    return {
      'string': string,
      'nota': nota,
    };
  }

  static Pesquisa fromJson(Map<String, dynamic> json) {
    return Pesquisa(
      json['string'],
      json['nota'],
    );
  }
}

Future<List<Receita>> pesquisaComFiltro(texto, filtro) async {
  print('entrou em pesquisaComFiltro');
  String pesquisaString;
  if (texto != null) {
    pesquisaString = texto;
  } else {
    pesquisaString = ' ';
  }

  Pesquisa pesquisa = Pesquisa(pesquisaString, filtro);
  List<Receita> sugestoes = [];
  String url = "http://localhost:8000/filtro/read";
  String jsonSearch = jsonEncode(pesquisa.toJson());

  http.Response response = await http.post(Uri.parse(url),
      headers: {'Content-Type': 'application/json'}, body: jsonSearch);

  if (response.statusCode == 200) {
    List<dynamic> decodedData = jsonDecode(response.body);
    sugestoes = decodedData.map((data) => Receita.fromJson(data)).toList();
  } else {
    print(response.statusCode);
  }

  return sugestoes;
}

Future<double> AvaliacaoRead(id_receitas, id_usuario) async {
  double avaliacao = 0;
  Map<String, dynamic> data = {
    'id_usuario': id_usuario,
    'id_receitas': id_receitas,
  };
  String url = "http://localhost:8000/avaliacao/usuario/read";
  String jsonid = jsonEncode(data);

  http.Response response = await http.post(Uri.parse(url),
      headers: {'Content-Type': 'application/json'}, body: jsonid);

  if (response.statusCode == 200) {
    print(response.body);
    Map<String, dynamic> decodedData = jsonDecode(response.body);
    avaliacao = decodedData['nota'];
  } else if (response.statusCode == 204) {
    avaliacao = 0;
  } else {
    print('AvalicaoRead: ${response.statusCode}');
  }

  return avaliacao;
}

Future<List<Map<String, String>>> fetchComments() async {
  // Your logic to fetch data goes here
  // For example, you can use http package to make an HTTP request
  // and parse the response to get a List<Map<String, String>>
  // Replace the following line with your actual data fetching logic
  // Simulating a delay for demonstration purposes
  return [
    {'name': 'User1', 'message': 'Comment 1'},
    {'name': 'User2', 'message': 'Comment 2'},
    // Add more data as needed
  ];
}
