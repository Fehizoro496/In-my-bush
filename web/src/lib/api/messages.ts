/** messages — /conversations?context= · POST /conversations · /conversations/{id}/messages · /conversations/{id}/read */
import type { Conversation, Message, MessageContext, Page } from "@/lib/types";
import { apiFetch } from "./client";

export const messagesApi = {
  conversations: (context: MessageContext) => apiFetch<Page<Conversation>>("/conversations", { query: { context } }),
  start: (input: { shopId: string; productId?: string; orderId?: string; body: string }) =>
    apiFetch<Conversation>("/conversations", { method: "POST", body: input }),
  messages: (conversationId: string) => apiFetch<Page<Message>>(`/conversations/${conversationId}/messages`),
  send: (conversationId: string, body: string) =>
    apiFetch<Message>(`/conversations/${conversationId}/messages`, { method: "POST", body: { body } }),
  markRead: (conversationId: string) => apiFetch<void>(`/conversations/${conversationId}/read`, { method: "POST" }),
};
