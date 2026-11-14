# Gestão de Mídias · Sicoob Credimepi

Sistema para gerenciar as mídias de marketing: Outdoor, Rádio, Instagram, LinkedIn e Facebook, com calendário, campanhas, alertas de vencimento e painel de investimentos.

- **Site:** GitHub Pages (arquivos estáticos deste repositório)
- **Dados, login e arquivos:** [Supabase](https://supabase.com) (plano gratuito)
- **Métricas das redes sociais:** [Zernio](https://zernio.com), via uma função do Supabase que guarda a chave da API em segredo

## Arquivos

| Arquivo | Para que serve |
|---|---|
| `index.html` | O sistema inteiro |
| `config.js` | URL e chave pública do Supabase |
| `supabase/schema.sql` | Cria a tabela, as regras de acesso e o bucket de arquivos |
| `supabase/functions/zernio/index.ts` | Função que busca contas e métricas no Zernio |

## Configuração (uma vez só)

### 1. Supabase
1. Crie um projeto em supabase.com.
2. Em **SQL Editor → New query**, cole o conteúdo de `supabase/schema.sql` e clique em **Run**.
3. Em **Authentication → Sign In / Providers**, desative **Allow new users to sign up** (só quem você cadastrar entra).
4. Em **Authentication → Users → Add user**, crie o usuário de cada pessoa da equipe (e-mail e senha).
5. Em **Authentication → URL Configuration**, coloque o endereço do GitHub Pages em **Site URL**.
6. Em **Project Settings → API**, copie a **Project URL** e a **anon public key** para o `config.js`.

### 2. Redes sociais (Zernio)
1. No Zernio, crie uma chave de API (de preferência só leitura) em *Dashboard → API keys*.
2. Instale a [Supabase CLI](https://supabase.com/docs/guides/cli) e rode, na pasta do repositório:
   ```bash
   supabase login
   supabase link --project-ref SEU_PROJECT_REF
   supabase secrets set ZERNIO_API_KEY=sk_sua_chave
   supabase functions deploy zernio
   ```
3. No sistema, abra **Integrações → Atualizar dados**.

### 3. GitHub Pages
Em **Settings → Pages**, escolha **Deploy from a branch**, branch `main`, pasta `/ (root)`. O site fica em `https://SEU-USUARIO.github.io/NOME-DO-REPOSITORIO/`.

## Sem Supabase configurado
Com o `config.js` vazio, o sistema abre em **modo demonstração**: funciona, mas os cadastros somem ao recarregar a página.
