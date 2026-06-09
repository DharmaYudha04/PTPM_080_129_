import '../../../shared/models/destination.dart';
import 'destinations_remote_datasource.dart';

class ExploreRepositoryImpl {
  ExploreRepositoryImpl(this._remoteDataSource);

  final DestinationsRemoteDataSource _remoteDataSource;

  Future<List<DestinationModel>> all() async {
    return _remoteDataSource.fetchDestinations();
  }
}
