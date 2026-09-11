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

### 9. ✅ Versão em inglês (11/09/2026)

- **Onde**: `en/index.html` e `en/resume.html` (+ `en/resume.pdf`).
- **Como é gerada**: a partir das páginas em português, com os textos
  traduzidos e os caminhos ajustados. O seletor **PT / EN** fica no menu, e as
  duas páginas declaram `hreflang` uma para a outra.
- **Ao editar o português, reveja o inglês**: as duas são arquivos separados e
  nada sincroniza sozinho.
- O CSS é compartilhado (`styles.css` + `styles-portfolio.css`), então mudança
  de estilo vale para as duas.

### 10. ✅ Cartão de compartilhamento (og:image)

- **Arquivo**: `imagens/og-card.png`, em **1200×630** (o formato que LinkedIn e
  WhatsApp esperam). Antes o `og:image` era o avatar, em 1024×1036, que os dois
  cortavam.
- **Para refazer**: é uma captura de tela de uma página HTML simples com nome,
  cargo e os três números, tirada em 1200×630.

### 11. ✅ Bibliotecas com versão fixa

- Font Awesome **6.7.2**, devicon **v2.16.0** e lightbox2 **2.11.4** (o pacote
  `lightbox-plus-jquery`, que já traz o jQuery).
- Saíram: o jQuery avulso, o ScrollReveal vindo do unpkg **sem versão** e os
  domínios correspondentes na CSP.
- A rolagem suave passou a ser do CSS (`scroll-behavior` + `scroll-margin-top`).

### 12. ✅ Animação de entrada que não esconde conteúdo

- O conteúdo nasce **visível** no CSS. O JavaScript só liga a animação quando há
  suporte e o visitante não pediu menos movimento, e há uma trava de 3 segundos
  que mostra tudo mesmo sem rolagem.
- **Por quê**: o ScrollReveal deixava a seção em branco para robôs de busca,
  prévias de link e capturas de tela, que não rolam a página.

### 13. ✅ Preload de Fontes

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
