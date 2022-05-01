import 'dart:convert';

import 'package:bairroseguro_morador/providers/login.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;

import './usuario.dart';

class Usuarios with ChangeNotifier {
  Future<void> addUsuario(Usuario usuario) async {
    try {
      final response = await http.post(
          Uri.parse('https://bairroseguro.herokuapp.com/usuario'),
          headers: <String, String>{
            'Content-type': 'application/json; charset=UTF-8',
          },
          body: json.encode(<String, String>{
            'nome': usuario.nome,
            'email': usuario.email,
            'telefone': usuario.telefone,
            'rua': usuario.rua,
            'numero': usuario.numero,
            'bairro': usuario.bairro,
            'cep': usuario.cep,
            'cidade': usuario.cidade,
            'estado': usuario.estado,
            'uf': usuario.uf,
            'nomeUsuario': usuario.nomeUsuario,
            'senha': usuario.senha,
            'tipo': usuario.tipo
          }));

      notifyListeners();
    } catch (e) {
      print(e);
      throw e;
    }
  }

  Future<Map<dynamic, String>> autenticaUsuario(Login login) async {
    try {
      final response = await http.post(
          Uri.parse('https://bairroseguro.herokuapp.com/usuario/login'),
          headers: <String, String>{
            'Content-type': 'application/json; charset=UTF-8',
          },
          body: json.encode(<String, String>{
            'email': login.nomeUsuario,
            'senha': login.senha,
          }));

      notifyListeners();

      final data = json.decode(response.body);
      return {
        'isAutenticated': data['isAutenticated'].toString(),
        'isContaAtiva': data['isContaAtiva'].toString()
      };
    } catch (e) {
      print(e);
      throw e;
    }
  }
}
