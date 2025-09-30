import 'package:anota_ai/pages/listas_page.dart';
import 'package:anota_ai/utils/navegacao_custom.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/usuario_provider.dart';

class DrawerCUSTOM extends StatelessWidget {
  const DrawerCUSTOM({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.green),
            child: UsuarioProvider.usuarioAtual() != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          UsuarioProvider.usuarioAtual()!.photoURL ?? '',
                        ),
                      ),
                      Text(
                        UsuarioProvider.usuarioAtual()!.displayName ?? '',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                        maxLines: 1,
                      ),
                      Text(
                        UsuarioProvider.usuarioAtual()!.email ?? '',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  )
                : Text(
                    'Usuário não logado',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
          ),
          ListTile(
            leading: const Icon(Icons.list_alt_rounded),
            title: const Text('Gerenciar Listas'),
            onTap: () {
              NavegacaoCUSTOM.push(context, ListasPAGE());
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_add),
            title: const Text('Convidar Colaborador'),
            onTap: () {
         
            },
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {
              Provider.of<UsuarioProvider>(context, listen: false).signOut();
            },
          ),
        ],
      ),
    );
  }
}
