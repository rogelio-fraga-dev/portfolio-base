# De estudante a palestrante — um bom filho à casa torna

**Palestra:** IMEPAC · 26/10/2026 · 60 minutos
**Palestrante:** Rogélio Claro Fraga
**Slides:** `slides.html` (duplo clique; funciona sem internet, as imagens estão em `img/`)

> Teclas: `→` / `espaço` avança · `←` volta · `N` notas do palestrante · `F` tela cheia · `Home` / `End`.
> No celular: deslize para os lados. Se o computador da sala for fraco, abra `slides.html?estatico` para desligar as animações.
> O layout se ajusta à tela: projetor 16:9 ou 4:3, notebook e celular em pé.

---

## Tempo por bloco

| # | Bloco | Slides | Tempo |
|---|---|---|---|
| 1 | Abertura | 1–2 | 2 min |
| 2 | Quem é o Rogélio · linha do tempo | 3–4 | 4 min |
| 3 | Antes do código · a virada | 5–6 | 5 min |
| 4 | As portas que o curso abriu · o inglês | 7–8 | 5 min |
| 5 | Os 3 pilares | 9–12 | 5 min |
| 6 | A área é competitiva · o relato da UFU | 13–14 | 4 min |
| 7 | InovaLayer e WireArc | 15–20 | 9 min |
| 8 | Sistema de aulas (a maior loucura) | 21–24 | 6 min |
| 9 | Razor, DevFlow, landing pages | 25–28 | 5 min |
| 10 | Desanimar · usar IA · a entrevista | 29–31 | 6 min |
| 11 | Empreendedor · conselhos · desafio | 32–34 | 5 min |
| 12 | Fechamento + perguntas | 35–36 | 4 min |

---

## 1. Quem é o Rogélio

- 25 anos, Araguari/MG.
- Um rapaz preto numa faculdade majoritariamente branca.
- **O primeiro da família a se formar**: Análise e Desenvolvimento de Sistemas, IMEPAC.
- Antes do código: Agente Censitário Supervisor no IBGE (2022–2023).
- Hoje:
  - **Desenvolvedor Full Stack** no InovaLayer3D (UFU, bolsa FAPEMIG).
  - **Professor** de Programação Web no Trilhas do Futuro (duas turmas, 75 alunos no total).
  - Produto próprio: **Razor** (barbearias).
- Para ganhar um lugar de destaque, teve que fazer muito mais que todos. E foi isso que abriu as portas.

## 2. Antes do código e a virada

Facilidade com TI, mas largava tudo pela metade: fotos → vídeos → vídeo de música → manutenção de PCs.
**Quase 2 anos sem mexer no computador.** Voltou para a programação como **última chance**.

A virada: fazer mais do que o curso pedia (todo tempo livre), aceitar a liderança que sempre sobrava, abraçar o lado "surtado" e a fome de vencer.

## 3. As portas que o curso abriu

**Prof. Everton Hipolito** viu talento → **coordenadora Cristiane Lemos** recebe o pedido da UFU → **Prof. Vinicius Lemes** (Engenharia, UFU) precisa de um programador → bolsa FAPEMIG no **InovaLayer3D**.

Hoje os stakeholders do projeto são **Vinicius Lemes, Rafael e Moheb**.

### O inglês
Com o Moheb a reunião é em inglês. Nível B1, e teve que desenrolar. Documentação, mensagens de erro, os melhores cursos e as vagas remotas de fora: tudo em inglês. **Não espere ficar fluente para começar a usar.**

## 4. Os 3 pilares

1. **Proatividade**: pediram um formulário e eu entreguei uma plataforma (portal, central de orçamentos, PDF, e o painel do engenheiro num app desktop separado, por segurança).
2. **Resolução de problemas**: o cliente não sabe do que precisa; a parte técnica é nossa.
3. **Sangue nos olhos**: sem tempo para indecisão.

## 5. A área é competitiva

- Você não concorre com a sua sala: vaga remota recebe currículo do país inteiro.
- E concorre com a IA: escrever código ficou barato; entender o problema e assumir a responsabilidade, não.
- **Relato real:** alunos da UFU deixaram o estágio para o fim do curso e, quando chegou a hora, não tinha mais estágio. Começaram a desanimar, e alguns já se perguntam se valeu a pena investir na área. Não por falta de talento: a área está muito concorrida. A IA já faz as tarefas que iam para o estagiário, e cada vez mais cobram **fundamento** e **individualidade**.
- O último período é tarde. Comece no período em que você está.

## 6. Projetos

### InovaLayer3D (UFU · FAPEMIG)
- **O que é:** impressão 3D de metais, a **manufatura aditiva por deposição a arco (WAAM)**: um robô de solda que constrói a peça camada por camada com arame de metal.
- **Como funciona:** o cliente pede o orçamento no site e manda o arquivo 3D → o engenheiro fatia a peça no **WireArc IL** → o **cálculo do custo** (feito por Rogélio em cima da metodologia dos doutores da UFU) → o engenheiro revisa e aprova no app desktop → proposta em PDF por e-mail.
- **O que entra no preço:** arame de metal + gás de proteção + máquina e energia + chapa base + serviços extras = preço final. Bate com a planilha da UFU em **24 de 24 itens, erro ≤ 0,0024%**.
- **Como foi feito:** Java 21 + Spring Boot + PostgreSQL, Angular 21 + Electron, AWS, GitHub Actions. ~235 commits.
- **Erros:**
  - O custo do gás e da máquina era **multiplicado duas vezes** pelo número de camadas (o fatiador já mandava o total): preço inflado.
  - Dinheiro em `double` → BigDecimal.
  - Um cliente via o endereço de outro trocando um número na URL (IDOR).
  - O **backup nunca rodou**: o agendador não tinha permissão para criar o arquivo de log, então o script nem começava, e sem log ninguém via. À mão, com sudo, funcionava. Depois do conserto, de 0 para 2 cópias no dia.
  - O **alarme de backup tocava** com o backup funcionando (faltava uma permissão para publicar a métrica). "Alarme que toca sozinho é alarme que a gente aprende a ignorar."
  - "A API não respondeu" com a API no ar: o teste de saúde estava fora do CORS.

### WireArc IL: o fatiador da InovaLayer
- **O que faz:** modelo 3D (STL) → fatiamento em camadas → trajetória da tocha em cada camada (zigue-zague, contornos paralelos ou "pixel") → G-code para o robô + os dados que vão direto para o orçamento.
- **Como:** app desktop em Python, PyQt5, PyVista (3D), GPU NVIDIA opcional. Criado pelo Paulo Pinheiro; Rogélio ajuda com melhorias e ligou o fatiador ao orçamento.
- **Erros:** a barra mostrava 100% travado com o cálculo ainda rodando; a GPU não rodava de verdade no Windows; cancelar não parava o cálculo; rotas até 15x mais rápidas limitando o solver.

### Sistema de aulas: a maior loucura
- **48 horas do primeiro commit à primeira aula**, testado ao vivo com os alunos:
  - 06/08: o material da aula 1 (slides e quiz, ainda em arquivo).
  - 10/08, 18h26: primeiro commit do sistema (quiz e editor).
  - 11/08: 21 commits num dia (painel, slides, tarefas).
  - 12/08, 19h: primeira aula, com a turma da noite usando.
  - 13/08: 23 commits, corrigindo entre uma aula e outra.
  - Hoje: estável, versão 102, 75 alunos toda semana, mais de 500 commits somando sistema e material.
- **Como funciona:** aluno (laboratório ou celular) → editor + quiz → Spring Boot + PostgreSQL → painel do professor com ranking ao vivo. Deploy: push → testes → backup do banco → deploy travado em horário de aula.
- **Erros achados com a turma:**
  - A certa era sempre a alternativa mais longa.
  - Aluno colando o código inteiro: 206 caracteres por segundo, contra 0,5 a 1,6 digitando → trava de colagem com código por aluno.
  - A palavra `undefined` virou o gabarito de dois exercícios: 47 entregas presas, sem nenhuma tela dar erro.
  - Um deploy com 20 migrações derrubou o sistema; voltou em 12 minutos.
  - No celular, um botão cobria o "Começar" e o aluno não entrava na atividade.
  - No jogo de revisão, errar até morrer dava mais pontos.

### Razor (antigo BarberBot)
IA que atende, agenda e cobra pelo WhatsApp (texto ou áudio); o dono manda foto da agenda de papel e a IA cadastra. Erros: a IA criava outro agendamento quando o cliente dizia "obrigado"; `agenda.json` corrompendo; estados zumbis; injeção pelo webhook.

### DevFlow Solutions: o último projeto integrador
Gestão de projetos com motor financeiro e timesheets. Rogélio **criou a arquitetura de tudo, fez o code review e ainda fez o backend**. Erros: N+1 e LazyInitializationException; Budget Guard deixando estourar 100%; cliente vendo dado de outro; dados falsos na tela.

### Landing pages: nem todo projeto precisa ser gigante
**Nem todo projeto precisa ser gigante. Precisa ser funcional e corresponder ao que o cliente quer.**
- **O portfólio** (rogeliofraga.com.br): a vitrine, o link de toda conversa.
- **Psicóloga Vanessa Alves**: cliente real, feito para trazer pacientes (SEO, celular primeiro, anúncio no Google).
- As duas em HTML, CSS e JS puros.

## 7. Desanimar no meio do caminho

Vai acontecer; comigo durou 2 anos.
- O que fazia largar: querer resultado rápido, estudar sem objetivo, fazer sozinho sem ninguém esperando.
- O que segurou: ver que estava melhorando de verdade; virar noites, pensando em programação o dia inteiro, sem sossegar enquanto não funcionava; apagar e refazer projetos do zero quando travava, aprendendo com o próprio erro; quebrar o problema grande em partes pequenas; e o motivo maior: ser o primeiro da família a se formar, pelo orgulho dos avós.
- **Desanimar não é desistir. Desiste quem para de aparecer.**

## 8. Um conselho sobre IA

**IA é copiloto. Quem pilota é você.**
- Como usar: no trabalho repetitivo, para explicar erro ou código, como revisor (revisões com agentes acharam falhas de segurança e de cálculo no Razor).
- Como não usar: copiar sem entender, deixar ela decidir a arquitetura, subir sem testar, e no começo do curso pedir a resposta em vez da explicação.
- **A regra: se você não consegue explicar a linha, ela não sobe.**

## 9. Seja melhor que você mesmo

**Na hora da entrevista, você só tem você.** Sem IA, sem o colega do grupo. Só o que você sabe explicar: o que fez, por que fez e o que deu errado. Compare-se com quem você era no semestre passado, não com o colega.

## 10. Empreendedor × funcionário, conselhos e desafio

- Não cruze os braços: o InovaLayer era um formulário e virou produto. O Razor é meu, com preço, roadmap e concorrente.
- **8 conselhos:** constância vence talento · trabalho de faculdade é cliente · mostre o que você faz · comece antes de estar pronto · erro é currículo · IA é ferramenta, não muleta · aceite a responsabilidade · inglês desde já.
- **Desafio da semana:** publicar um projeto no GitHub com README, mostrar a um professor, postar no LinkedIn o que deu errado e como resolveu.

## 11. Fechamento

> "Não quero ser apenas útil. Quero ser **necessário**."

De quem sentou nessas cadeiras a quem está aqui na frente. **Um bom filho à casa torna.**

---

### Para conferir antes do dia
- [ ] Levar a pasta `palestra/` inteira (o `slides.html` e a pasta `img/`).
- [ ] Testar no computador da sala; se travar, usar `slides.html?estatico`.
- [ ] Se tiver internet, mostrar ao vivo inovalayer.com.br.
