import 'package:flutter_test/flutter_test.dart';
import 'package:video_toolkit/features/home/domain/queue_completion_action.dart';

void main() {
  test('queue completion actions keep no action as the safe default', () {
    expect(QueueCompletionAction.values, [
      QueueCompletionAction.none,
      QueueCompletionAction.shutdown,
      QueueCompletionAction.restart,
      QueueCompletionAction.sleep,
    ]);
    expect(QueueCompletionAction.values.first, QueueCompletionAction.none);
  });
}
