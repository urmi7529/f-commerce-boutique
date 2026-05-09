import { useEffect, useState, type ReactNode } from "react";
import { useLocation, useNavigate } from "@tanstack/react-router";
import { supabase } from "@/integrations/supabase/client";

const LOVABLE_HOSTS = [
  "lovable.app",
  "lovableproject.com",
  "localhost",
  "127.0.0.1",
];

function isPlatformHost(host: string) {
  return LOVABLE_HOSTS.some((h) => host === h || host.endsWith(`.${h}`));
}

export function CustomDomainGate({ children }: { children: ReactNode }) {
  const loc = useLocation();
  const navigate = useNavigate();
  const [checked, setChecked] = useState(false);
  const [notConnected, setNotConnected] = useState<string | null>(null);

  useEffect(() => {
    if (typeof window === "undefined") { setChecked(true); return; }
    const host = window.location.hostname.toLowerCase();
    if (isPlatformHost(host)) { setChecked(true); return; }

    // 1) Force HTTPS on connected custom domains (skip localhost / IPs)
    if (
      window.location.protocol === "http:" &&
      host !== "localhost" &&
      host !== "127.0.0.1" &&
      !/^\d+\.\d+\.\d+\.\d+$/.test(host)
    ) {
      window.location.replace(
        "https://" + host + window.location.pathname + window.location.search + window.location.hash,
      );
      return;
    }

    // 2) Build candidate hostnames so www and apex resolve to the same store
    const apex = host.replace(/^www\./, "");
    const candidates = host.startsWith("www.") ? [host, apex] : [host, `www.${host}`];

    let cancel = false;
    (async () => {
      const { data } = await supabase
        .from("stores")
        .select("slug, custom_domain, domain_verified")
        .in("custom_domain", candidates)
        .eq("domain_verified", true)
        .maybeSingle();
      if (cancel) return;
      if (!data) { setNotConnected(host); setChecked(true); return; }

      // 3) Canonical redirect — if the stored domain differs (e.g. apex vs www), normalize the URL
      const stored = data.custom_domain!;
      if (stored !== host) {
        window.location.replace(
          window.location.protocol + "//" + stored + window.location.pathname + window.location.search + window.location.hash,
        );
        return;
      }

      const path = loc.pathname;
      const storeBase = `/store/${data.slug}`;

      // /admin → login (or dashboard if already in /dashboard via login)
      if (path === "/admin" || path.startsWith("/admin/")) {
        navigate({ to: "/login" });
        setChecked(true);
        return;
      }
      // Already on dashboard/login routes → keep them (admin area)
      if (path.startsWith("/dashboard") || path === "/login" || path === "/signup") {
        setChecked(true);
        return;
      }
      // Storefront routes — rewrite root and bare paths into the store
      if (path === "/" || path === "") {
        navigate({ to: "/store/$slug", params: { slug: data.slug }, replace: true });
        setChecked(true);
        return;
      }
      if (!path.startsWith(storeBase)) {
        navigate({ to: "/store/$slug", params: { slug: data.slug }, replace: true });
      }
      setChecked(true);
    })();
    return () => { cancel = true; };
  }, [loc.pathname, navigate]);

  if (!checked) {
    return <div className="grid min-h-screen place-items-center text-muted-foreground">Loading…</div>;
  }

  if (notConnected) {
    return (
      <div className="grid min-h-screen place-items-center bg-background px-4">
        <div className="max-w-lg text-center">
          <h1 className="text-2xl font-bold">Domain not connected</h1>
          <p className="mt-2 text-sm text-muted-foreground">
            <strong>{notConnected}</strong> isn't linked to a verified store yet.
            If you own this domain, add it from your dashboard → Settings → Custom Domain
            and complete DNS verification.
          </p>
        </div>
      </div>
    );
  }

  return <>{children}</>;
}