import os
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Preformatted, Spacer, PageBreak
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen.canvas import Canvas

def register_unicode_font():
    """Register a TrueType font for Unicode support."""
    candidates = [
        r"C:\Windows\Fonts\DejaVuSans.ttf",
        r"C:\Windows\Fonts\Arial.ttf",
        r"C:\Windows\Fonts\Calibri.ttf"
    ]
    for path in candidates:
        if os.path.exists(path):
            pdfmetrics.registerFont(TTFont("UniFont", path))
            return "UniFont"
    return "Helvetica"

def collect_files(root_dir):
    """Recursively collect all file paths."""
    for dirpath, _, filenames in os.walk(root_dir):
        for fname in filenames:
            yield os.path.join(dirpath, fname)

def compressed_canvas(filename, pagesize):
    """Canvas maker with PDF stream compression."""
    return Canvas(filename, pagesize=pagesize, pageCompression=1)

def build_pdf_chunk(root_dir, file_paths, output_pdf, font_name):
    """Build a PDF for a subset of files."""
    doc = SimpleDocTemplate(
        output_pdf,
        pagesize=A4,
        leftMargin=20*mm, rightMargin=20*mm,
        topMargin=20*mm, bottomMargin=20*mm,
        title=os.path.basename(output_pdf),
        canvasmaker=compressed_canvas
    )
    styles = getSampleStyleSheet()
    styles.add(ParagraphStyle("TitleUni", parent=styles["Title"], fontName=font_name, fontSize=16))
    styles.add(ParagraphStyle("HeadingUni", parent=styles["Heading2"], fontName=font_name, fontSize=12))
    styles.add(ParagraphStyle("BodyUni", parent=styles["BodyText"], fontName=font_name, fontSize=9))
    styles.add(ParagraphStyle("CodeUni", parent=styles["Code"], fontName=font_name, fontSize=7))
    
    story = []
    # Title
    story.append(Paragraph(f"Archivos (parte) de: {root_dir}", styles["TitleUni"]))
    story.append(Spacer(1, 6))
    
    for path in file_paths:
        display = path.replace("\\", "/")
        story.append(Paragraph(f"<b>Archivo:</b> {display}", styles["HeadingUni"]))
        try:
            with open(path, encoding="utf-8", errors="replace") as f:
                text = f.read()
        except Exception as e:
            text = f"[Error leyendo archivo: {e}]"
        story.append(Preformatted(text, styles["CodeUni"]))
        story.append(PageBreak())
    
    # Footer
    def footer(canvas, doc):
        canvas.saveState()
        canvas.setFont(font_name, 8)
        canvas.drawRightString(A4[0] - 20*mm, 10*mm, f"Página {doc.page}")
        canvas.restoreState()
    
    doc.build(story, onFirstPage=footer, onLaterPages=footer)

def split_and_build(root_dir, output_prefix="ProyectoParte", chunk_size=20):
    """Split files into chunks and build multiple PDFs."""
    all_files = list(collect_files(root_dir))
    font_name = register_unicode_font()
    for i in range(0, len(all_files), chunk_size):
        chunk = all_files[i:i+chunk_size]
        part_num = (i // chunk_size) + 1
        out_pdf = os.path.join(root_dir, f"{output_prefix}_{part_num}.pdf")
        build_pdf_chunk(root_dir, chunk, out_pdf, font_name)
        print(f"Generado: {out_pdf}")

if __name__ == "__main__":
    root = r"C:\MiChinchonWeb"
    split_and_build(root, chunk_size=20)
