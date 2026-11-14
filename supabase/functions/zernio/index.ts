// Supabase Edge Function "zernio"
// Busca contas e métricas das redes sociais no Zernio sem expor a chave da API no site.
// A chave fica guardada como segredo: supabase secrets set ZERNIO_API_KEY=sk_...
// Só usuários logados no sistema conseguem chamar esta função (verificação de JWT do Supabase).

const BASE = "https://zernio.com/api/v1";

const cors = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });

  const key = Deno.env.get("ZERNIO_API_KEY");
  if (!key) {
    return new Response(JSON.stringify({ error: "ZERNIO_API_KEY não configurada" }), {
      status: 500, headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  let body: { acao?: string; page?: number; fromDate?: string } = {};
  try { body = await req.json(); } catch (_) { /* corpo vazio */ }

  let url: string;
  if (body.acao === "contas") {
    url = `${BASE}/accounts?limit=100`;
  } else if (body.acao === "analytics") {
    const p = new URLSearchParams({
      limit: "40",
      page: String(Math.max(1, Math.min(50, Number(body.page) || 1))),
      view: "summary",
    });
    if (body.fromDate && /^\d{4}-\d{2}-\d{2}$/.test(body.fromDate)) p.set("fromDate", body.fromDate);
    url = `${BASE}/analytics?${p}`;
  } else {
    return new Response(JSON.stringify({ error: "ação inválida" }), {
      status: 400, headers: { ...cors, "Content-Type": "application/json" },
    });
  }

  const r = await fetch(url, { headers: { Authorization: `Bearer ${key}` } });
  return new Response(await r.text(), {
    status: r.status,
    headers: { ...cors, "Content-Type": "application/json" },
  });
});
