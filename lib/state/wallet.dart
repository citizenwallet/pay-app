import 'package:flutter/cupertino.dart';
import 'package:pay_app/models/wallet.dart';
import 'package:pay_app/services/config/service.dart';
import 'package:pay_app/services/engine/utils.dart';
import 'package:pay_app/services/preferences/preferences.dart';
import 'package:pay_app/services/wallet/contracts/account_factory.dart';
import 'package:pay_app/services/wallet/contracts/erc20.dart';
import 'package:pay_app/services/wallet/models/chain.dart';
import 'package:pay_app/services/wallet/utils.dart';
import 'package:pay_app/services/wallet/wallet.dart';
import 'package:web3dart/web3dart.dart';

class WalletState with ChangeNotifier {
  CWWallet? _wallet;

  final ConfigService _configService = ConfigService();
  final WalletService _walletService = WalletService();
  final PreferencesService _preferencesService = PreferencesService();

// TODO: remove later
  final String _credentialsAddressHexEip55 =
      '09c15615b0a381c8f3ee0af78c14a97d8b8df2c469fa4d6eed346a510be3fa68';
  String get credentialsAddressHexEip55 => _credentialsAddressHexEip55;

// TODO: remove later
  EthereumAddress? _address;
  EthereumAddress? get address => _address;

  bool loading = false;
  bool error = false;

  bool _mounted = true;
  void safeNotifyListeners() {
    if (_mounted) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  Future<String?> createWallet() async {
    loading = true;
    error = false;
    safeNotifyListeners();

    try {
      final config = await _configService.getLocalConfig();

      if (config == null) {
        throw Exception('Community not found in local asset');
      }

      final accFactory = await accountFactoryServiceFromConfig(config);

      EthPrivateKey privateKey =
          EthPrivateKey.fromHex(credentialsAddressHexEip55);

      final address = await accFactory.getAddress(privateKey.address.hexEip55);

      _address = address;
      safeNotifyListeners();

      // final token = config.getPrimaryToken();

      await _preferencesService.setLastWallet(address.hexEip55);
      await _preferencesService.setLastAlias(config.community.alias);

      return address.hexEip55;
    } catch (_) {
      error = true;
      safeNotifyListeners();
    } finally {
      loading = false;
      safeNotifyListeners();
    }
    return null;
  }

  Future<String?> openWallet() async {
    loading = true;
    error = false;
    safeNotifyListeners();

    try {

      final config = await _configService.getLocalConfig();
      final accFactory = await accountFactoryServiceFromConfig(config!);

      EthPrivateKey privateKey =
          EthPrivateKey.fromHex(credentialsAddressHexEip55);


      final address = await accFactory.getAddress(privateKey.address.hexEip55);

  
      // final config = await _configService.getLocalConfig();
      if (config == null) {
        throw Exception('Community not found in local asset');
      }

      final token = config.getPrimaryToken();

      final nativeCurrency = NativeCurrency(
        name: token.name,
        symbol: token.symbol,
        decimals: token.decimals,
      );

      await _walletService.init(address!, privateKey, nativeCurrency, config,
          onFinished: (bool success) {
        debugPrint('wallet service init: $success');
      });

      return address!.hexEip55;
    } catch (e, s) {
      error = true;
      safeNotifyListeners();
      debugPrint('error: $e');
      debugPrint('stack trace: $s');
    } finally {
      loading = false;
      safeNotifyListeners();
    }

    return null;
  }

  Future<bool> accountExists() async {
    try {
      if (address == null) {
        throw Exception('Wallet not created');
      }

      loading = true;
      error = false;
      safeNotifyListeners();

      final exists =
          await _walletService.accountExists(account: address!.hexEip55);
      return exists;
    } catch (e, s) {
      debugPrint('error: $e');
      debugPrint('stack trace: $s');
      error = true;
      safeNotifyListeners();
    } finally {
      loading = false;
      safeNotifyListeners();
    }
    return false;
  }

  Future<bool> createAccount() async {
    try {
      if (address == null) {
        throw Exception('Wallet not created');
      }

      loading = true;
      error = false;
      safeNotifyListeners();

      final exists = await _walletService.createAccount();

      if (!exists) {
        throw Exception('Account not created');
      }

      return true;
    } catch (e, s) {
      debugPrint('error: $e');
      debugPrint('stack trace: $s');
      error = true;
      safeNotifyListeners();
    } finally {
      loading = false;
      safeNotifyListeners();
    }
    return false;
  }

  Future<void> sendTransaction() async {
    final doubleAmount = '0.10'.replaceAll(',', '.');
    final parsedAmount = toUnit(
      doubleAmount,
      decimals: _walletService.currency.decimals,
    );

    final calldata = _walletService.tokenTransferCallData(
        '0x20eC5EAF89C0e06243eE39674844BF77edB43fCc', parsedAmount);

    final (_, userOp) = await _walletService.prepareUserop(
      [_walletService.tokenAddress],
      [calldata],
    );

    final args = {
      'from': _walletService.account.hexEip55,
      'to': '0x20eC5EAF89C0e06243eE39674844BF77edB43fCc',
    };
    if (_walletService.standard == 'erc1155') {
      args['operator'] = _walletService.account.hexEip55;
      args['id'] = '0';
      args['amount'] = parsedAmount.toString();
    } else {
      args['value'] = parsedAmount.toString();
    }

    final eventData = createEventData(
      stringSignature: _walletService.transferEventStringSignature,
      topic: _walletService.transferEventSignature,
      args: args,
    );

// extraDate: formatting message of a transaction
  
    final txHash = await _walletService.submitUserop(userOp, data: eventData, extraData: 'message' != '' ? TransferData('message') : null);

    debugPrint('txHash: $txHash');
  }
}
