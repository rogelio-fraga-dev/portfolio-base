# build-docx.py
# Gera a versao DOCX do curriculo a partir do mesmo HTML que gera o PDF,
# para o texto nunca divergir entre os dois formatos.
#
# Uso:  python build-docx.py            # curriculo.html -> curriculo.docx e en/resume.html -> en/resume.docx
# Requer: pip install python-docx
#
# O DOCX segue as mesmas regras do PDF: coluna unica, sem tabela, sem imagem,
# sem caixa de texto, fonte Arial, contato no corpo do documento.

from html.parser import HTMLParser
from pathlib import Path

from docx import Document
from docx.shared import Mm, Pt, RGBColor

REPO = Path(__file__).resolve().parent
ALVOS = [("curriculo.html", "curriculo.docx"), ("en/resume.html", "en/resume.docx")]

FONTE = "Arial"
COR_TEXTO = RGBColor(0x1F, 0x24, 0x30)
COR_TITULO = RGBColor(0x5D, 0x3F, 0x6A)
COR_META = RGBColor(0x5B, 0x62, 0x74)

# classe do <p> -> (tamanho em pt, negrito, cor, espaco antes em pt)
ESTILOS = {
    "h1": (20, True, COR_TEXTO, 0),
    "role": (11, True, COR_TITULO, 0),
    "h2": (12.5, True, COR_TITULO, 8),
    "entry-title": (10.5, True, COR_TEXTO, 5),
    "entry-meta": (9.5, False, COR_META, 0),
    "stack": (9.5, False, COR_META, 0),
    "li": (10, False, COR_TEXTO, 0),
    "p": (10, False, COR_TEXTO, 0),
}


class Leitor(HTMLParser):
    """Extrai os blocos de texto do <body> na ordem do documento.

    Cada bloco e (tipo, [(texto, negrito), ...]).
    """

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.blocos = []
        self.no_body = False
        self.tipo = None
        self.trechos = []
        self.negrito = 0

    def handle_starttag(self, tag, attrs):
        if tag == "body":
            self.no_body = True
            return
        if not self.no_body:
            return
        if tag in ("h1", "h2", "li", "p"):
            classe = dict(attrs).get("class", "")
            self.tipo = classe if tag == "p" and classe in ESTILOS else tag
            self.trechos = []
        elif tag == "strong" or (tag == "span" and dict(attrs).get("class") in ("skill-label", "dates")):
            self.negrito += 1

    def handle_endtag(self, tag):
        if tag in ("h1", "h2", "li", "p") and self.tipo:
            if any(texto.strip() for texto, _ in self.trechos):
                self.blocos.append((self.tipo, self.trechos))
            self.tipo = None
        elif tag in ("strong", "span") and self.negrito:
            self.negrito -= 1

    def handle_data(self, data):
        if self.tipo:
            texto = " ".join(data.replace("\xa0", " ").split())
            if not texto:
                # so espaco entre duas tags (ex.: "</strong> <a>"): preservar um espaco
                if self.trechos and not self.trechos[-1][0].endswith(" "):
                    anterior, forte = self.trechos[-1]
                    self.trechos[-1] = (anterior + " ", forte)
                return
            # recoloca o espaco que a quebra de linha do HTML representava
            if data[0].isspace() or data[0] == "\xa0":
                texto = " " + texto
            if data[-1].isspace() or data[-1] == "\xa0":
                texto = texto + " "
            self.trechos.append((texto, self.negrito > 0))


def gerar(html: Path, docx: Path) -> None:
    leitor = Leitor()
    leitor.feed(html.read_text(encoding="utf-8"))
    if not leitor.blocos:
        raise SystemExit(f"Nenhum texto encontrado em {html}")

    doc = Document()
    secao = doc.sections[0]
    secao.page_width, secao.page_height = Mm(210), Mm(297)
    secao.left_margin = secao.right_margin = Mm(14)
    secao.top_margin = secao.bottom_margin = Mm(13)
    doc.styles["Normal"].font.name = FONTE

    for tipo, trechos in leitor.blocos:
        tamanho, negrito, cor, antes = ESTILOS[tipo]
        par = doc.add_paragraph(style="List Bullet" if tipo == "li" else None)
        par.paragraph_format.space_before = Pt(antes)
        par.paragraph_format.space_after = Pt(1)
        par.paragraph_format.keep_with_next = tipo in ("h2", "entry-title", "entry-meta")
        primeiro = True
        for texto, forte in trechos:
            if primeiro:
                texto = texto.lstrip()
                primeiro = False
            run = par.add_run(texto)
            run.font.name = FONTE
            run.font.size = Pt(tamanho)
            run.font.bold = negrito or forte
            run.font.color.rgb = cor

    doc.core_properties.author = "Rogelio Claro Fraga"
    doc.core_properties.title = leitor.blocos[0][1][0][0].strip()
    doc.save(str(docx))
    print(f"DOCX gerado: {docx}")


if __name__ == "__main__":
    for origem, destino in ALVOS:
        gerar(REPO / origem, REPO / destino)
