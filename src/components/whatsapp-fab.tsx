import { useState } from "react";
import { MessageCircle, Send, X } from "lucide-react";
import { motion } from "framer-motion";
import { supabase } from "@/integrations/supabase/client";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Button } from "@/components/ui/button";
import { Label } from "@/components/ui/label";
import { toast } from "sonner";

export function WhatsAppFab({
  storeId,
  storeName,
  message,
}: {
  phone?: string | null;
  storeId?: string | null;
  storeName?: string | null;
  message?: string;
}) {
  const [open, setOpen] = useState(false);
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [email, setEmail] = useState("");
  const [body, setBody] = useState(message ?? "");
  const [sending, setSending] = useState(false);

  if (!storeId) return null;

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!body.trim()) return toast.error("Please write a message");
    setSending(true);
    const { error } = await supabase.from("store_messages").insert({
      store_id: storeId,
      customer_name: name.trim() || null,
      customer_phone: phone.trim() || null,
      customer_email: email.trim() || null,
      message: body.trim(),
      source: "storefront",
    });
    setSending(false);
    if (error) return toast.error(error.message);
    toast.success("Message sent");
    setOpen(false);
    setName("");
    setPhone("");
    setEmail("");
    setBody(message ?? "");
  };

  return (
    <>
      <motion.button
        type="button"
        onClick={() => setOpen(true)}
        aria-label="Send message"
        initial={{ scale: 0, opacity: 0 }} animate={{ scale: 1, opacity: 1 }}
        transition={{ delay: 0.4, type: "spring", stiffness: 200, damping: 15 }}
        whileHover={{ scale: 1.1 }} whileTap={{ scale: 0.95 }}
        className="fixed bottom-6 right-6 z-50 grid h-14 w-14 place-items-center rounded-full text-white shadow-2xl"
        style={{ background: "#2563EB", boxShadow: "0 10px 30px -5px rgba(37, 99, 235, 0.55)" }}
      >
        <span className="absolute inline-flex h-full w-full animate-ping rounded-full opacity-25" style={{ background: "#2563EB" }} />
        <MessageCircle className="relative h-6 w-6" />
      </motion.button>

      {open && (
        <div className="fixed inset-0 z-[60] grid place-items-end bg-black/45 p-4 sm:place-items-center" onClick={() => setOpen(false)}>
          <form onSubmit={submit} className="w-full max-w-md rounded-2xl bg-card p-5 shadow-2xl" onClick={(e) => e.stopPropagation()}>
            <div className="flex items-start justify-between gap-3">
              <div>
                <h2 className="text-lg font-bold">Message {storeName ?? "store"}</h2>
                <p className="text-xs text-muted-foreground">Your message will go to the store dashboard.</p>
              </div>
              <button type="button" onClick={() => setOpen(false)} className="rounded-full p-1 text-muted-foreground hover:bg-muted" aria-label="Close">
                <X className="h-4 w-4" />
              </button>
            </div>
            <div className="mt-4 grid gap-3">
              <div><Label>Name</Label><Input value={name} onChange={(e) => setName(e.target.value)} placeholder="Your name" /></div>
              <div><Label>Phone</Label><Input value={phone} onChange={(e) => setPhone(e.target.value)} placeholder="01XXXXXXXXX" /></div>
              <div><Label>Email</Label><Input type="email" value={email} onChange={(e) => setEmail(e.target.value)} placeholder="you@example.com" /></div>
              <div><Label>Message *</Label><Textarea rows={4} value={body} onChange={(e) => setBody(e.target.value)} required /></div>
              <Button type="submit" disabled={sending} className="w-full">
                <Send className="mr-2 h-4 w-4" /> {sending ? "Sending…" : "Send message"}
              </Button>
            </div>
          </form>
        </div>
      )}
    </>
  );
}