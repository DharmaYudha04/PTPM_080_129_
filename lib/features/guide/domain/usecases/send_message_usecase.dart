import '../../data/ai_remote_datasource.dart';

class SendMessageUseCase {
  const SendMessageUseCase(this._dataSource);

  final AiRemoteDataSource _dataSource;

  Stream<String> call({
    required String prompt,
    List<Map<String, String>> history = const [],
  }) {
    return _dataSource.streamReply(
      prompt: prompt,
      history: history,
    );
  }
}
