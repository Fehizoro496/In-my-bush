import type { Metadata } from "next";
import { Container } from "@/components/layout/Container";
import { MessagesView } from "@/components/messages/MessagesView";
import { getConversations } from "@/lib/data/account";

export const metadata: Metadata = { title: "Messages" };

/** W-Messages: full-width 3-column layout (no account sidebar). Protected by src/proxy.ts. */
export default async function MessagesPage() {
  const { conversations, messages } = await getConversations();
  return (
    <main className="pt-4 pb-8 lg:pt-6">
      <Container>
        <MessagesView conversations={conversations} messages={messages} />
      </Container>
    </main>
  );
}
