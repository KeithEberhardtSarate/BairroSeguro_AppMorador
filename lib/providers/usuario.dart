import 'package:flutter/material.dart';

class Usuario with ChangeNotifier {
  final String nome;
  final String email;
  final String telefone;
  final String rua;
  final String numero;
  final String bairro;
  final String cep;
  final String cidade;
  final String estado;
  final String uf;
  final String nomeUsuario;
  final String senha;
  String tipo;

  Usuario(
      {required this.nome,
      required this.email,
      required this.telefone,
      required this.rua,
      required this.numero,
      required this.bairro,
      required this.cep,
      required this.cidade,
      required this.estado,
      required this.uf,
      required this.nomeUsuario,
      required this.senha,
      this.tipo = 'morador'});
}
