String hideData(String data) {
  if (data.contains('@')) {
    // Es un correo electrónico
    int atIndex = data.indexOf('@');
    String prefix = data.substring(0, (atIndex < 2) ? atIndex : 2); // Mostrar las primeras 2 letras o todas si son menos de 2
    String suffix = data.substring(atIndex);
    String maskedPrefix = '*' * (atIndex - 2); // Ocultar el resto del prefijo

    return '$prefix$maskedPrefix$suffix';
  } else {
    // Es un DNI u otra cadena
    if (data.length >= 2) {
      String firstLetter = data[0];
      String lastLetter = data[data.length - 1];
      String maskedPart = '*' * (data.length - 2);

      return '$firstLetter$maskedPart$lastLetter';
    } else {
      // En caso de cadenas muy cortas, se puede manejar de otra manera si es necesario
      return data;
    }
  }
}
