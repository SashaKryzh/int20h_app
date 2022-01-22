import 'dart:ffi';

import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:injectable/injectable.dart';
import 'package:int20h_app/models/book_types.dart';
import 'package:int20h_app/models/chat_response.dart';

@lazySingleton
class DialogFlowService {
  DialogFlowtter? _dialogFlow;

  Future<DialogFlowtter> get _dialogFlowInstance async {
    _dialogFlow ??= await DialogFlowtter.fromFile();

    return _dialogFlow!;
  }

  Future<ChatResponse> sendIntent(
      String userMessage, bool isQuestionContext) async {
    final response = await (await _dialogFlowInstance).detectIntent(
      queryParams: QueryParameters(
          contexts: isQuestionContext
              ? [
                  Context(name: 'myQuestion', lifespanCount: 1),
                ]
              : null),
      queryInput: QueryInput(
        text: TextInput(text: userMessage, languageCode: 'en'),
      ),
    );

    var textResponse = response.text ?? 'Error';
    if (response.message == null) {
      return ChatResponse(
        message: textResponse,
        parameters: Map.identity(),
        isError: true,
      );
    }

    var parameters = response.queryResult?.parameters ?? Map.identity();
    var sentiment = response.queryResult?.sentimentAnalysisResult
            ?.queryTextSentiment?.magnitude ?? 0;
    var isEnd =
        response.queryResult?.diagnosticInfo?['end_conversation'] ?? false;

    var isError = response.queryResult?.action == 'input.welcome';

    return ChatResponse(
      message: textResponse,
      parameters: parameters,
      sentiment: sentiment,
      isFinal: isEnd,
      isError: isError,
    );
  }
}
