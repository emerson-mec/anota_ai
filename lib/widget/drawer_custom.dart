import 'package:anota_ai/pages/listas_page.dart';
import 'package:anota_ai/utils/navegacao_custom.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../provider/usuario_provider.dart';

class DrawerCUSTOM extends StatelessWidget {
  final String appVersion;
  DrawerCUSTOM({super.key, this.appVersion = ''});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color:   Theme.of(context).appBarTheme.backgroundColor),
              child: UsuarioProvider.usuarioAtual() != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width:
                              70, // Defina a largura e altura iguais para um círculo perfeito
                          height: 70,

                          child: ClipRRect(
                           borderRadius: BorderRadius.circular(20),
                            child: CachedNetworkImage(
                              imageUrl: UsuarioProvider.usuarioAtual()!.photoURL
                                  .toString(),
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            ),
                          ),
                        ),

                        // CircleAvatar(
                        //   radius: 30,
                        //   backgroundImage: NetworkImage(
                        //     UsuarioProvider.usuarioAtual()!.photoURL ?? '',
                        //   ),
                        // ),
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
                  : Center(
                    child: Text(
                        'ANOTA AÍ!',
                        style: TextStyle(color: Colors.white, fontSize: 20,fontWeight: FontWeight.bold),
                      ),
                  ),
            ),
            ListTile(
              leading: const Icon(Icons.list_alt_rounded),
              title: const Text('Minhas Listas',style: TextStyle(fontWeight: FontWeight.bold),),
              subtitle: const Text('Gerencie suas listas e itens',style: TextStyle(color: Colors.grey),),
              onTap: () {
                NavegacaoCUSTOM.push(context, ListasPAGE());
              },
            ),
            // ListTile(
            //   leading: const Icon(Icons.person_add),
            //   title: const Text('Convidar Colaborador'),
            //   onTap: () {},
            // ),
            // ListTile(
            //   leading: const Icon(Icons.logout),
            //   title: const Text('Sair'),
            //   onTap: () {
            //     Provider.of<UsuarioProvider>(context, listen: false).signOut();
            //   },
            // ),
            Divider(color: const Color.fromARGB(255, 215, 215, 215)),
            Text(
              "Versão do app: $appVersion",
              textAlign: TextAlign.center,
              style: TextStyle(color: const Color.fromARGB(255, 197, 197, 197)),
            ),
          ],
        ),
      ),
    );
  }
}
