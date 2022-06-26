import 'dart:async';
import 'dart:math';

import 'package:bairroseguro_morador/notification_service.dart';
import 'package:bairroseguro_morador/providers/solicitacao.dart';
import 'package:bairroseguro_morador/providers/solicitacoes.dart';
import 'package:bairroseguro_morador/providers/usuario.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/usuarios.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  dynamic _solicitacao = {
    '_id': '',
    'idAgente': '',
    'tipo': '',
    'idConta': '',
    'status': '',
  };
  late DatabaseReference _solicitacoesRef;
  late StreamSubscription<DatabaseEvent> _solicitacoesSubscription;

  var _isLoading = false;
  var usuarioLogado = Usuario(
      nome: '',
      email: '',
      telefone: '',
      rua: '',
      numero: '',
      bairro: '',
      cep: '',
      cidade: '',
      estado: '',
      uf: '',
      nomeUsuario: '',
      senha: '',
      idConta: '');

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    _solicitacoesRef = FirebaseDatabase.instance.ref('solicitacoes');

    try {
      final solicitacoesSnapshot =
          await _solicitacoesRef.child(usuarioLogado.idConta).get();

      if (solicitacoesSnapshot.exists) {
        _solicitacao = solicitacoesSnapshot.value as dynamic;
      }
    } catch (err) {
      debugPrint(err.toString());
    }

    _solicitacoesSubscription =
        _solicitacoesRef.onValue.listen((DatabaseEvent event) {
      setState(() {
        if (event.snapshot.value != null) {
          _solicitacao = (event.snapshot.value as Map)[usuarioLogado.idConta];

          if (_solicitacao['status'] == 'aceita') {
            Provider.of<NotificationService>(context, listen: false)
                .showNotification(CustomNotification(
                    id: 1,
                    title: 'Escolta aceita',
                    body: 'Agente em deslocamento',
                    payload: '/default'));
          }
        }
      });
    });
  }

  solicitarEscolta(_id) async {
    _solicitacoesRef =
        FirebaseDatabase.instance.ref('solicitacoes/${usuarioLogado.idConta}');

    _solicitacao['_id'] = _id;
    _solicitacao['idAgente'] = '';
    _solicitacao['idConta'] = usuarioLogado.idConta;
    _solicitacao['tipo'] = 'escolta';
    _solicitacao['status'] = 'solicitada';

    await _solicitacoesRef.set(_solicitacao);
  }

  void dispose() {
    _solicitacoesSubscription.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    var usuarioLogadoProvided =
        Provider.of<Usuarios>(context).getUsuarioLogado();

    setState(() {
      usuarioLogado = usuarioLogadoProvided;
    });
  }

  _handleSolicitacaoClick() {
    if (_solicitacao['status'] == 'solicitada') {
      _cancelarEscolta();
    } else if (_solicitacao['status'] == 'aceita') {
      _finalizarEscolta();
    } else {
      _novaEscolta();
    }
  }

  Future<void> _novaEscolta() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var novaEscolta = await Provider.of<Usuarios>(context, listen: false)
          .addSolicitacao(
              Solicitacao(idConta: usuarioLogado.idConta, tipo: "escolta"));

      solicitarEscolta(novaEscolta['_id'].toString());
    } catch (e) {
      print(e);
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Algum erro ocorreu ao ciar a solicitacao'),
          content: Text('Tente novamente'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Escolta solicitada com sucesso'),
            content: Text('Aguardando agente'),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      });
    }
  }

  _cancelarEscolta() {
    print('Implementar');
  }

  _finalizarEscolta() {
    print('Implementar');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(top: 50, bottom: 20),
                child: Image.network(
                    "https://icones.pro/wp-content/uploads/2021/02/icone-utilisateur-gris.png"),
              ),
              Text(
                usuarioLogado.nome,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              Container(
                margin: const EdgeInsets.only(top: 30),
                width: double.infinity,
                color: Colors.grey[100],
                child: ListTile(
                  title: const Text("Configurações"),
                  onTap: () => print('Implementar'),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: double.infinity,
                color: Colors.grey[100],
                child: ListTile(
                  title: const Text("Gerenciar Usuários"),
                  onTap: () => print('Implementar'),
                ),
              ),
              Expanded(child: Container()),
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                color: Colors.black87,
                alignment: Alignment.center,
                child: const Text("Sair",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text('Bairro seguro'),
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    child: _solicitacao != null &&
                            _solicitacao['status'] == 'solicitada'
                        ? Text('Escolta solicitada, aguardando agente',
                            style: TextStyle(fontSize: 20))
                        : Text(''),
                  ),
                  Container(
                    child: _solicitacao != null &&
                            _solicitacao['status'] == 'aceita'
                        ? Text('Escolta aceita, agente em deslocamento',
                            style: TextStyle(fontSize: 20))
                        : Text(''),
                  ),
                  // IconButton(
                  //     onPressed: () => solicitarEscolta(1234),
                  //     icon: const Icon(Icons.thumb_up)),
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    width: double.infinity,
                    color: Colors.black87,
                    alignment: Alignment.center,
                    child: ListTile(
                      title: Center(
                          child: Column(
                        children: [
                          if (_solicitacao != null &&
                              _solicitacao['status'] == 'solicitada') ...[
                            const Text("Cancelar solicitação",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))
                          ] else if (_solicitacao != null &&
                              _solicitacao['status'] == 'aceita') ...[
                            const Text("Finalizar solicitação",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))
                          ] else ...[
                            const Text("Solicitar escolta",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))
                          ]
                        ],
                      )),
                      onTap: () => _handleSolicitacaoClick(),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}
