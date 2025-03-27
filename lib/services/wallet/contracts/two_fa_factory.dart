import 'dart:async';
import 'dart:typed_data';
import 'package:pay_app/services/config/config.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart';

import 'package:web3dart/web3dart.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

Future<TwoFAFactoryService> twoFAFactoryServiceFromConfig(Config config,
    {String? customTwoFAFactory}) async {
  final primaryTwoFAFactory = config.community.primaryAccountFactory;

  final url = config.getRpcUrl(primaryTwoFAFactory.chainId.toString());
  // final wsurl =
  //     config.chains[primaryAccountFactory.chainId.toString()]!.node.wsUrl;

  final client = Client();

  final ethClient = Web3Client(
    url,
    client,
    // socketConnector: () =>
    //     WebSocketChannel.connect(Uri.parse(wsurl)).cast<String>(),
  );

  final chainId = await ethClient.getChainId();

  return TwoFAFactoryService(chainId.toInt(), ethClient,
      customTwoFAFactory ?? primaryTwoFAFactory.address);
}

class TwoFAFactoryService {
  final int chainId;
  final Web3Client client;
  final String addr;
  late DeployedContract rcontract;

  // StreamSubscription<TransferSingle>? _sub;

  TwoFAFactoryService(this.chainId, this.client, this.addr);

  Future<void> init() async {
    try {
      final abi = await rootBundle
          .loadString('packages/contractforge/abi/TwoFAFactory.json');

      final cabi = ContractAbi.fromJson(abi, 'TwoFAFactory');

      rcontract = DeployedContract(cabi, EthereumAddress.fromHex(addr));
    } catch (e, s) {
      print('error: $e');
      print('stack trace: $s');
    }
  }

  /// Converts a Uint8List to a BigInt
  /// Interprets the bytes as a big-endian integer
  BigInt uint8ListToBigInt(Uint8List data) {
    BigInt result = BigInt.zero;
    for (final byte in data) {
      // Shift left by 8 bits and add the next byte
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  Future<EthereumAddress> getAddress(
    EthereumAddress owner,
    Uint8List salt,
  ) async {
    // Convert salt to BigInt if needed
    BigInt saltAsBigInt = uint8ListToBigInt(salt);

    final function = rcontract.function('getAddress');

    final result = await client.call(
        contract: rcontract, function: function, params: [owner, saltAsBigInt]);

    return result[0] as EthereumAddress;
  }

  void dispose() {
    // _sub?.cancel();
  }
}
