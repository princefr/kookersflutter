// Supabase Edge Function: send-push-notification
//
// Called by Postgres webhooks (Database → Webhooks) when a row is
// inserted into `messages`, `orders`, or `ratings`. Looks up the
// recipient's FCM token in `profiles` and dispatches a Firebase
// Cloud Messaging push.
//
// Deploy with:
//   supabase functions deploy send-push-notification --no-verify-jwt
//
// Then in the Supabase dashboard create a webhook on:
//   table: messages, event: INSERT →
//   webhook url: https://<project>.functions.supabase.co/send-push-notification
//   secret: <your FCM server key, stored as SEND_PUSH_FCM_KEY>
//
// Same for orders (INSERT) and ratings (INSERT).

// @ts-nocheck — Deno runtime; we don't have @types here.
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const FCM_SERVER_KEY = Deno.env.get("SEND_PUSH_FCM_KEY")!;

const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY, {
  auth: { persistSession: false },
});

const EVENT_LABELS = {
  new_message: {
    fr: { title: "Message", body: "Vous avez reçu un nouveau message." },
    en: { title: "Message", body: "You received a new message." },
    it: { title: "Messaggio", body: "Hai ricevuto un nuovo messaggio." },
    de: { title: "Nachricht", body: "Du hast eine neue Nachricht." },
    es: { title: "Mensaje", body: "Has recibido un nuevo mensaje." },
    tr: { title: "Mesaj", body: "Yeni bir mesaj aldın." },
  },
  new_order: {
    fr: { title: "Commande", body: "Vous avez une nouvelle commande." },
    en: { title: "Order", body: "You have a new order." },
    it: { title: "Ordine", body: "Hai un nuovo ordine." },
    de: { title: "Bestellung", body: "Du hast eine neue Bestellung." },
    es: { title: "Pedido", body: "Tienes un nuevo pedido." },
    tr: { title: "Sipariş", body: "Yeni siparişin var." },
  },
  order_accepted: {
    fr: { title: "Commande acceptée", body: "Votre commande a été acceptée par le chef." },
    en: { title: "Order accepted", body: "Your order has been accepted by the chef." },
    it: { title: "Ordine accettato", body: "Il tuo ordine è stato accettato dallo chef." },
    de: { title: "Bestellung angenommen", body: "Deine Bestellung wurde vom Koch angenommen." },
    es: { title: "Pedido aceptado", body: "Tu pedido ha sido aceptado por el chef." },
    tr: { title: "Sipariş kabul edildi", body: "Siparişin şef tarafından kabul edildi." },
  },
  order_cancelled: {
    fr: { title: "Commande annulée", body: "Une commande a été annulée." },
    en: { title: "Order cancelled", body: "An order has been cancelled." },
    it: { title: "Ordine annullato", body: "Un ordine è stato annullato." },
    de: { title: "Bestellung abgebrochen", body: "Eine Bestellung wurde abgebrochen." },
    es: { title: "Pedido cancelado", body: "Un pedido ha sido cancelado." },
    tr: { title: "Sipariş iptal edildi", body: "Bir sipariş iptal edildi." },
  },
};

async function sendFcm(token: string, title: string, body: string, data: Record<string, string>) {
  const res = await fetch("https://fcm.googleapis.com/fcm/send", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `key=${FCM_SERVER_KEY}`,
    },
    body: JSON.stringify({
      to: token,
      notification: { title, body },
      data,
      priority: "high",
    }),
  });
  if (!res.ok) {
    console.error("FCM error", res.status, await res.text());
  }
}

async function getUserLocaleAndToken(userId: string) {
  const { data, error } = await supabase
    .from("profiles")
    .select("fcm_token, country, settings")
    .eq("id", userId)
    .single();
  if (error || !data) return null;
  const locale = (data.settings?.locale as string) || (data.country || "FR").toLowerCase();
  return { token: data.fcm_token, locale: ["fr", "en", "it", "de", "es", "tr"].includes(locale) ? locale : "fr" };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method Not Allowed", { status: 405 });
  }
  const payload = await req.json();
  const { table, type, record } = payload;
  if (type !== "INSERT" || !record) {
    return new Response("OK");
  }

  try {
    if (table === "messages") {
      const { data: room } = await supabase
        .from("rooms")
        .select("buyer_id, seller_id")
        .eq("id", record.room_id)
        .single();
      if (!room) return new Response("OK");
      const recipientId = record.user_id === room.buyer_id ? room.seller_id : room.buyer_id;
      const recipient = await getUserLocaleAndToken(recipientId);
      if (recipient?.token) {
        const label = EVENT_LABELS.new_message[recipient.locale] || EVENT_LABELS.new_message.fr;
        await sendFcm(recipient.token, label.title, label.body, {
          type: "new_message",
          roomId: record.room_id,
          senderName: record.user_id,
        });
      }
    } else if (table === "orders") {
      const isBuyerEvent = record.order_state === "NOT_ACCEPTED";
      const recipientId = isBuyerEvent ? record.seller_id : record.buyer_id;
      const recipient = await getUserLocaleAndToken(recipientId);
      if (!recipient?.token) return new Response("OK");
      const eventKey = isBuyerEvent ? "new_order"
        : record.order_state === "ACCEPTED" ? "order_accepted"
        : record.order_state === "CANCELLED" ? "order_cancelled"
        : null;
      if (!eventKey) return new Response("OK");
      const label = EVENT_LABELS[eventKey][recipient.locale] || EVENT_LABELS[eventKey].fr;
      await sendFcm(recipient.token, label.title, label.body, {
        type: eventKey,
        orderId: record.id,
        side: isBuyerEvent ? "order_seller" : "order_buyer",
      });
    }
  } catch (err) {
    console.error("send-push-notification error", err);
  }

  return new Response("OK");
});
