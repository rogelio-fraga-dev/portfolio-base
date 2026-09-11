# 📋 Guia de Configuração - Melhorias Implementadas

Este documento contém instruções para configurar os serviços que foram implementados no portfólio.

## ✅ Melhorias Implementadas

### 1. ✅ Open Graph Tags

- **Status**: Implementado
- **Localização**: `<head>` do `index.html`
- **Nota**: Twitter Cards (`summary_large_image`) adicionados em 01/09/2026.

### 2. ✅ Schema.org JSON-LD

- **Status**: Implementado em 01/09/2026.
- **Correção**: este documento afirmava que o JSON-LD "já estava implementado",
  mas **não havia nenhum bloco `application/ld+json` no `index.html`**. Agora
  existem dois: `ProfilePage` (com um `Person` em `mainEntity`) e `WebSite`.
- **Localização**: `<head>` do `index.html`

### 3. 🗑️ Formulário de contato — REMOVIDO em 11/09/2026

- **Por quê**: o formulário usava EmailJS, mas a chave pública nunca foi
  configurada (`"SUA_PUBLIC_KEY"`), então nenhuma mensagem chegou. Em vez de
  consertar, o contato passou a ser só por canais diretos: WhatsApp (principal),
  e-mail e LinkedIn.
- **O que saiu junto**: o script do EmailJS, `api.emailjs.com` e
  `cdn.jsdelivr.net` do `script-src`/`connect-src` da CSP, o JavaScript de
  validação e o CSS do formulário.
- **Se um dia voltar**: o código antigo está no histórico do Git (commit
  `76bacfb` e anteriores).

### 5. ✅ robots.txt e sitemap.xml

- **Status**: Criados
- **Localização**: Raiz do projeto

### 6. ❌ Google Analytics — NÃO INSTALADO

- **Status**: **não implementado**. Este documento afirmava o contrário, mas não
  existe nenhuma tag `gtag` nem `googletagmanager` no `index.html`. O que existe
  é apenas a permissão para esses domínios na CSP.
- **Nota**: o site usa Vercel Analytics (`/_vercel/insights/script.js`), esse sim
  ativo.

### 7. ✅ Content Security Policy (CSP)

- **Status**: Implementado
- **Localização**: Meta tag no `<head>`

### 8. ✅ Acessibilidade (ARIA)

- **Status**: Implementado
- **Recursos**:
  - Atributos ARIA completos
  - Labels adequados
  - Navegação por teclado
  - Skip links
  - prefer-reduced-motion

### 9. ✅ Preload de Fontes

- **Status**: Implementado e **corrigido** em 01/09/2026.
- **Correção**: havia um `<link rel="preload">` do Google Fonts **sem** o
  `<link rel="stylesheet">` correspondente — a fonte era baixada e nunca
  aplicada. Faltavam também os pesos 800 e 900 do Montserrat, usados no CSS,
  que o navegador vinha sintetizando.
- **Localização**: `<head>` do `index.html`

---

## 🔧 Configurações Necessárias

### 📊 Configurar Google Analytics

1. **Criar propriedade no Google Analytics**

   - Acesse: https://analytics.google.com/
   - Crie uma nova propriedade
   - Obtenha seu **Measurement ID** (formato: `G-XXXXXXXXXX`)

2. **Atualizar o código**
   - Abra `index.html`
   - Procure por `G-XXXXXXXXXX` (linha ~1590 e ~1595)
   - Substitua pelo seu Measurement ID

**Exemplo:**

```javascript
gtag("config", "G-ABC123XYZ", {
  anonymize_ip: true,
  cookie_flags: "SameSite=None;Secure",
});
```

---

## 🎨 Personalizações Opcionais

### Atualizar URL do Site

Se seu site estiver em um domínio diferente, atualize:

1. **Open Graph tags** (linha ~15-22)

   - `og:url`
   - `og:image`

2. **Canonical URL** (linha ~14)

   - `rel="canonical"`

3. **Schema.org** (linha ~49)

   - `"url"`

4. **robots.txt**

   - Substitua `rogeliofraga.dev` pelo seu domínio

5. **sitemap.xml**
   - Substitua todas as ocorrências de `rogeliofraga.dev` pelo seu domínio

---

## ✅ Checklist de Verificação

Após configurar tudo:

- [ ] Google Analytics configurado
- [ ] URLs atualizadas (se necessário)
- [ ] Google Analytics rastreando eventos
- [ ] Testar acessibilidade com leitor de tela
- [ ] Links de WhatsApp, e-mail e LinkedIn abrindo certo
- [ ] Verificar CSP não bloqueando recursos

---

## 🐛 Troubleshooting

### Google Analytics não funciona

- Verifique se o Measurement ID está correto
- Verifique se o CSP permite o Google Analytics
- Use o Google Tag Assistant para debug

### CSP bloqueando recursos

- Ajuste a política CSP no `<head>` se necessário
- Verifique o console do navegador para erros de CSP

---

## 📝 Notas Importantes

1. **Google Analytics**: Configure a privacidade conforme necessário
2. **CSP**: A política atual é restritiva por segurança
3. **Acessibilidade**: Teste com leitores de tela (NVDA, JAWS, VoiceOver)

---

## 🎉 Pronto!

Após configurar tudo, seu portfólio estará completo com todas as melhorias da análise profissional implementadas!
