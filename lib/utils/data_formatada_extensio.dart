extension DataFormatadaExtension on DateTime {
  
    String diaMesAnoHora( ) {
      return '$day/$month/$year - $hour:$minute';
    }

    String mesPorExtenso() {
      const meses = [
        'Janeiro',
        'Fevereiro',
        'Março',
        'Abril',
        'Maio',
        'Junho',
        'Julho',
        'Agosto',
        'Setembro',
        'Outubro',
        'Novembro',
        'Dezembro',
      ];
      return meses[month - 1];
    }

    String abrMes() {
      const abreviacoes = ['JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN', 'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'];
      return abreviacoes[month - 1];
    }

    String diaMesAno() {
      return '$day/$month/$year';
    }
}