import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:pay_app/services/config/config.dart';
import 'package:pay_app/services/config/service.dart';
import 'package:pay_app/services/db/app/db.dart';

class CommunityState with ChangeNotifier {
  Config? community;
  String? alias = dotenv.get('DEFAULT_COMMUNITY_ALIAS');

  final ConfigService _configService = ConfigService();
  final AppDBService _appDBService = AppDBService();

  bool loading = false;

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

  Future<void> fetchCommunity() async {
    if (alias == null) {
      throw Exception('Community alias is not set');
    }

    try {
      loading = true;
      safeNotifyListeners();

      // Get community from local database
      final dbCommunity = await _appDBService.communities.get(alias!);

      if (dbCommunity == null) {
        throw Exception('Community not found in app database');
      }

      // Update state with local data
      final config = Config.fromJson(dbCommunity.config);
      this.community = config;
      safeNotifyListeners();

      // Fetch fresh data from remote
      // final remoteConfig =
      //     await _configService.getRemoteConfig(config.configLocation);

      // if (remoteConfig == null) {
      //   return;
      // }

      //  Update state with remote data & save to local DB
      // this.community = remoteConfig;
      // safeNotifyListeners();
      // _appDBService.communities
      //     .upsert([DBCommunity.fromConfig(remoteConfig)]);

    } catch (e) {
       debugPrint('Error in fetchCommunity: $e');
    } finally {
      loading = false;
      safeNotifyListeners();
    }
  }

  void getCommunityHealth() async {
    if (alias == null) {
      throw Exception('Community alias is not set');
    }

    if (community == null) {
      throw Exception('Community is not set');
    }

    final token = community!.getPrimaryToken();
    final chain = community!.chains[token.chainId.toString()];

    if (chain == null) {
      community!.online = false;
      safeNotifyListeners();
      _appDBService.communities.updateOnlineStatus(alias!, false);
      return;
    }

    _configService.isCommunityOnline(chain.node.url).then((isOnline) {
      community!.online = isOnline;
      safeNotifyListeners();

      _appDBService.communities.updateOnlineStatus(alias!, isOnline);
    });
  }
}
