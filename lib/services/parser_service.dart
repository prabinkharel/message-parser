import 'package:satellite_hex_parsing/models/device_type.dart';
import 'package:satellite_hex_parsing/models/message_type.dart';

class ParserService {
  static Map<String, dynamic> parse({
    required String hex,
    required DeviceType deviceType,
    required String messageType,
  }) {
    final structure = MessageStructure.getStructure(deviceType, messageType);
    if (structure == null) {
      throw ArgumentError(
        'No structure found for device $deviceType and message type $messageType',
      );
    }

    final cleanHex = hex.replaceAll(" ", "").toUpperCase();
    if (cleanHex.isEmpty) {
      throw ArgumentError("Hex string cannot be empty");
    }

    if (!RegExp(r'^[0-9A-F]+$').hasMatch(cleanHex)) {
      throw FormatException('Invalid hex characters in input');
    }

    final binaryString = _hexToBinary(cleanHex);

    final parsedData = <String, dynamic>{};

    structure.forEach((fieldName, bitConfig) {
      final startBit = bitConfig[0];
      final bitLength = bitConfig[1];

      if (startBit + bitLength > binaryString.length) {
        throw RangeError(
          'Field $fieldName requires bits $startBit-${startBit + bitLength} '
          'but message only has ${binaryString.length} bits',
        );
      }

      final fieldBits = binaryString.substring(startBit, startBit + bitLength);
      final intValue = int.parse(fieldBits, radix: 2);

      parsedData[_toTitleCase(fieldName)] = intValue;
    });

    return parsedData;
  }

  static String _hexToBinary(String hexString) {
    final buffer = StringBuffer();
    for (var i = 0; i < hexString.length; i++) {
      final hexChar = hexString[i];
      final decimal = int.parse(hexChar, radix: 16);
      buffer.write(decimal.toRadixString(2).padLeft(4, '0'));
    }
    return buffer.toString();
  }

  static String _toTitleCase(String input) {
    return input
        .split('_')
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '',
        )
        .join(' ');
  }
}
