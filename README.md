# Caderno de Erros — Produção

## Stack
React + Vite + Supabase + Lucide.

## Publicação
1. Crie um projeto no Supabase.
2. Execute `supabase_schema.sql` no SQL Editor.
3. Crie `.env` a partir de `.env.example`.
4. Preencha `VITE_SUPABASE_URL` e `VITE_SUPABASE_ANON_KEY`.
5. `npm install`
6. `npm run build`
7. Suba o repositório para GitHub e importe na Vercel.
8. Na Vercel, cadastre as mesmas variáveis em Settings > Environment Variables.
9. No Supabase, em Authentication > URL Configuration, coloque a URL da Vercel como Site URL.

## Segurança
A aplicação usa somente a chave anon no navegador. As tabelas têm RLS e cada registro é vinculado ao usuário autenticado.
