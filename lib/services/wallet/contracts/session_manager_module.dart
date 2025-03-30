import 'dart:async';
import 'dart:typed_data';
import 'package:pay_app/services/config/config.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart';

import 'package:web3dart/web3dart.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

Future<SessionManagerModuleService> sessionManagerModuleServiceFromConfig(
    Config config,
    {String? customSessionManagerModule}) async {
  // TODO: update when config is updated
  final primarySessionManagerModule = config.community.primaryAccountFactory;

  final url = config.getRpcUrl(primarySessionManagerModule.chainId.toString());
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

  return SessionManagerModuleService(chainId.toInt(), ethClient,
      customSessionManagerModule ?? primarySessionManagerModule.address);
}

class SessionManagerModuleService {
  final int chainId;
  final Web3Client client;
  final String addr;
  late DeployedContract rcontract;

  // StreamSubscription<TransferSingle>? _sub;

  SessionManagerModuleService(this.chainId, this.client, this.addr);

  Future<void> init() async {
    try {
      final abi = await rootBundle
          .loadString('packages/contractforge/abi/SessionManagerModule.json');

      final cabi = ContractAbi.fromJson(abi, 'SessionManagerModule');

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

  Future<bool> isExpired(EthereumAddress account, EthereumAddress owner) async {
    final function = rcontract.function('isExpired');

    final result = await client.call(
        contract: rcontract, function: function, params: [account, owner]);

    return result[0] as bool;
  }

  Uint8List revokeCallData(EthereumAddress signer) {
    final function = rcontract.function('revoke');

    return function.encodeCall([signer]);
  }

  void dispose() {
    // _sub?.cancel();
  }
}
