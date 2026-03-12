import 'package:intl/intl.dart';

extension MoedaFormataExtension on double {
  String emReaisBR() {
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatador.format(this);
  }
}

extension MoedaIntFormataExtension on int {
  String emReaisBR() {
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatador.format(this.toDouble());
  }
}
