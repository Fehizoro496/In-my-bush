/// Conversations and messages (`/conversations`).
abstract class MessagesEndpoints {
  static const conversations = '/conversations';

  static String messages(String conversationId) => '/conversations/$conversationId/messages';
  static String read(String conversationId) => '/conversations/$conversationId/read';
}
