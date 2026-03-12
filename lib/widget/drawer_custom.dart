import 'package:anota_ai/pages/listas_page.dart';
import 'package:anota_ai/pages/historico_compras_page.dart';
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
              decoration: BoxDecoration(
                color: Theme.of(context).appBarTheme.backgroundColor,
              ),
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
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            // ListTile(
            //   leading: const Icon(Icons.list_alt_rounded),
            //   title: const Text(
            //     'Minhas Listas',
            //     style: TextStyle(fontWeight: FontWeight.bold),
            //   ),
            //   subtitle: const Text(
            //     'Gerencie suas listas e itens',
            //     style: TextStyle(color: Colors.grey),
            //   ),
            //   onTap: () {
            //     NavegacaoCUSTOM.push(context, ListasPAGE());
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text(
                'Histórico de Compras',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Seu controle de gastos mensal',
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () {
                NavegacaoCUSTOM.push(context, const HistoricoComprasPage());
              },
            ),
            //TODO implementar funcionalidade
            // ListTile(
            //   leading: const Icon(Icons.attach_money_sharp),
            //   title: const Text(
            //     'Contribuir',
            //     style: TextStyle(fontWeight: FontWeight.bold),
            //   ),
            //   subtitle: const Text(
            //     'Contribua com o desenvolvedor',
            //     style: TextStyle(color: Colors.grey),
            //   ),
            //   onTap: () {},
            // ),
            //TODO implementar funcionalidade
    //         ListTile(
    //           leading: const Icon(Icons.rate_review_outlined),
    //           title: const Text(
    //             'Avaliar App',
    //             style: TextStyle(fontWeight: FontWeight.bold),
    //           ),
    //           subtitle: const Text(
    //             'Deixe sua avalição na loja de Apps',
    //             style: TextStyle(color: Colors.grey),
    //           ),
    //           onTap: () {},
    //         ),
    // //TODO implementar funcionalidade
    //          ListTile(
    //           leading: const Icon(Icons.newspaper_rounded),
    //           title: const Text(
    //             'Remover Propagandas',
    //             style: TextStyle(fontWeight: FontWeight.bold),
    //           ),
    //           subtitle: const Text(
    //             'Remova as propagandas do App',
    //             style: TextStyle(color: Colors.grey),
    //           ),
    //           onTap: () {},
    //         ),

    //         ListTile(
    //           leading: Icon(Icons.logout, color: Colors.red[300]),
    //           title: Text(
    //             'Sair',
    //             style: TextStyle(
    //               fontWeight: FontWeight.bold,
    //               color: Colors.red[300],
    //             ),
    //           ),
    //           onTap: () {
    //             Provider.of<UsuarioProvider>(context, listen: false).signOut();
    //           },
    //         ),
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
