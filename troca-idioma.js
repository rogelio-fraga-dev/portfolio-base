// Troca de idioma sem tranco.
//
// PT e EN sao paginas separadas, entao trocar de idioma era abrir outra pagina
// do zero: tela piscando e o visitante jogado de volta ao topo. Aqui:
//   1. antes de sair, guarda em que secao a pessoa estava (e quanto dela ja leu);
//   2. a pagina nova abre nesse mesmo trecho;
//   3. a troca e um esmaecimento curto. Chrome, Edge e Safari fazem isso
//      sozinhos pelo @view-transition do CSS; nos outros, este arquivo esmaece
//      a pagina na mao com as classes .troca-saindo e .troca-entrando.
//
// Carregado no <head>, sem defer: a classe de chegada precisa estar no <html>
// antes da primeira pintura, senao a pagina aparece e so depois esmaece.
(function () {
  "use strict";

  const CHAVE = "troca-idioma:posicao";
  const SAIDA_MS = 180;
  const raiz = document.documentElement;
  const transicaoNativa = "CSSViewTransitionRule" in window;
  const menosMovimento = window.matchMedia(
    "(prefers-reduced-motion: reduce)"
  ).matches;

  // sessionStorage pode nao existir (aba anonima, bloqueio de cookies):
  // nesse caso a troca so nao lembra a posicao, e nada quebra.
  function lerPosicao() {
    try {
      const valor = sessionStorage.getItem(CHAVE);
      sessionStorage.removeItem(CHAVE);
      return valor ? JSON.parse(valor) : null;
    } catch (erro) {
      return null;
    }
  }

  function gravarPosicao(posicao) {
    try {
      sessionStorage.setItem(CHAVE, JSON.stringify(posicao));
    } catch (erro) {
      // sem armazenamento a pagina nova so abre no topo
    }
  }

  // A secao que esta no alto da tela e a fracao dela que ja passou. Fracao, e
  // nao pixels, porque o texto em ingles tem outro tamanho que o portugues.
  function posicaoAtual() {
    let atual = null;
    document.querySelectorAll("section[id]").forEach((secao) => {
      if (secao.getBoundingClientRect().top <= 1) atual = secao;
    });
    if (!atual) return { id: null, fracao: 0, y: window.scrollY };
    const caixa = atual.getBoundingClientRect();
    return { id: atual.id, fracao: -caixa.top / caixa.height, y: 0 };
  }

  function restaurar(posicao) {
    const alvo = posicao.id && document.getElementById(posicao.id);
    let y = posicao.y;
    if (alvo) {
      const caixa = alvo.getBoundingClientRect();
      y = caixa.top + window.scrollY + posicao.fracao * caixa.height;
    }
    // "instant" passa por cima do scroll-behavior: smooth do html
    window.scrollTo({ top: y, behavior: "instant" });
  }

  // ---------- chegada ----------
  const chegada = lerPosicao();
  if (chegada) {
    // o script principal le esta classe para nao rodar a animacao de entrada,
    // que esconderia de novo o que a pessoa ja estava lendo
    raiz.classList.add("veio-da-troca");
    if (!transicaoNativa && !menosMovimento) raiz.classList.add("troca-entrando");

    const aplicar = () => restaurar(chegada);
    // pagereveal roda antes da primeira pintura da pagina nova (com transicao
    // nativa); o DOMContentLoaded garante quando ele nao existe ou chega cedo
    window.addEventListener("pagereveal", aplicar, { once: true });
    document.addEventListener("DOMContentLoaded", aplicar, { once: true });

    // imagens que carregam depois podem empurrar o conteudo: reaplica uma vez
    // no load, a menos que a pessoa ja tenha rolado por conta propria
    let mexeu = false;
    const marcar = () => (mexeu = true);
    ["wheel", "touchstart", "keydown"].forEach((tipo) =>
      window.addEventListener(tipo, marcar, { once: true, passive: true })
    );
    window.addEventListener("load", () => !mexeu && aplicar(), { once: true });
  }

  // ---------- saida ----------
  document.addEventListener("click", (evento) => {
    const link = evento.target.closest("a.nav-idioma");
    if (!link) return;
    // ctrl/cmd/shift + clique abre em outra aba: deixa o navegador cuidar
    if (evento.button !== 0 || evento.ctrlKey || evento.metaKey || evento.shiftKey) return;

    gravarPosicao(posicaoAtual());
    if (transicaoNativa || menosMovimento) return;

    evento.preventDefault();
    raiz.classList.add("troca-saindo");
    window.setTimeout(() => {
      window.location.href = link.href;
    }, SAIDA_MS);
  });

  // Voltar pelo navegador pode trazer esta pagina do cache ainda apagada.
  window.addEventListener("pageshow", (evento) => {
    if (evento.persisted) raiz.classList.remove("troca-saindo", "troca-entrando");
  });
})();
