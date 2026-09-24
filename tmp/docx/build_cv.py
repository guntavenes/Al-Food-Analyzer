from pathlib import Path
from PIL import Image, ImageDraw
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.enum.section import WD_SECTION
from docx.enum.style import WD_STYLE_TYPE
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "output/docx/enes_guntav_cv.docx"
PHOTO_IN = ROOT / "tmp/pdfs/source/profile.png"
PHOTO_OUT = ROOT / "tmp/docx/profile_rounded.png"

NAVY = "173B63"
CHARCOAL = "252A31"
MID = "5A6572"
LIGHT = "D9E2EC"
PALE = "F4F7FA"
WHITE = "FFFFFF"


def set_cell_margins(cell, top=80, start=80, bottom=80, end=80):
    tc = cell._tc
    tcPr = tc.get_or_add_tcPr()
    tcMar = tcPr.first_child_found_in("w:tcMar")
    if tcMar is None:
        tcMar = OxmlElement("w:tcMar")
        tcPr.append(tcMar)
    for m, v in (("top", top), ("start", start), ("bottom", bottom), ("end", end)):
        node = tcMar.find(qn(f"w:{m}"))
        if node is None:
            node = OxmlElement(f"w:{m}")
            tcMar.append(node)
        node.set(qn("w:w"), str(v))
        node.set(qn("w:type"), "dxa")


def clear_borders(table):
    tblPr = table._tbl.tblPr
    borders = tblPr.first_child_found_in("w:tblBorders")
    if borders is None:
        borders = OxmlElement("w:tblBorders")
        tblPr.append(borders)
    for edge in ("top", "left", "bottom", "right", "insideH", "insideV"):
        tag = borders.find(qn(f"w:{edge}"))
        if tag is None:
            tag = OxmlElement(f"w:{edge}")
            borders.append(tag)
        tag.set(qn("w:val"), "nil")


def set_repeat_table_header(row):
    trPr = row._tr.get_or_add_trPr()
    tag = OxmlElement("w:tblHeader")
    tag.set(qn("w:val"), "true")
    trPr.append(tag)


def set_keep(paragraph, next_=False):
    pPr = paragraph._p.get_or_add_pPr()
    keep = OxmlElement("w:keepNext" if next_ else "w:keepLines")
    pPr.append(keep)


def add_hyperlink(paragraph, text, url, color=NAVY):
    part = paragraph.part
    rid = part.relate_to(url, "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink", is_external=True)
    link = OxmlElement("w:hyperlink")
    link.set(qn("r:id"), rid)
    run = OxmlElement("w:r")
    rPr = OxmlElement("w:rPr")
    c = OxmlElement("w:color")
    c.set(qn("w:val"), color)
    rPr.append(c)
    u = OxmlElement("w:u")
    u.set(qn("w:val"), "single")
    rPr.append(u)
    run.append(rPr)
    t = OxmlElement("w:t")
    t.text = text
    run.append(t)
    link.append(run)
    paragraph._p.append(link)


def rounded_photo():
    im = Image.open(PHOTO_IN).convert("RGBA")
    bbox = im.getbbox()
    if bbox:
        im = im.crop(bbox)
    s = min(im.size)
    left = (im.width - s) // 2
    top = max(0, (im.height - s) // 2 - 4)
    im = im.crop((left, top, left + s, top + s)).resize((500, 500), Image.Resampling.LANCZOS)
    mask = Image.new("L", im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, 499, 499), radius=48, fill=255)
    bg = Image.new("RGBA", im.size, (255, 255, 255, 0))
    bg.paste(im, (0, 0), mask)
    bg.save(PHOTO_OUT)


doc = Document()
sec = doc.sections[0]
sec.page_width = Inches(8.2677)
sec.page_height = Inches(11.6929)
sec.top_margin = Inches(0.47)
sec.bottom_margin = Inches(0.48)
sec.left_margin = Inches(0.62)
sec.right_margin = Inches(0.62)

styles = doc.styles
normal = styles["Normal"]
normal.font.name = "DejaVu Sans"
normal.font.size = Pt(9.2)
normal.font.color.rgb = RGBColor.from_string(CHARCOAL)
normal.paragraph_format.space_after = Pt(2.7)
normal.paragraph_format.line_spacing = 1.03

for name in ("Title", "Subtitle", "Heading 1", "Heading 2"):
    styles[name].font.name = "DejaVu Sans"
    styles[name].font.color.rgb = RGBColor(0, 0, 0)

styles["Title"].font.size = Pt(26)
styles["Title"].font.bold = True
styles["Title"].paragraph_format.space_after = Pt(1)
styles["Subtitle"].font.size = Pt(11.2)
styles["Subtitle"].font.bold = True
styles["Subtitle"].paragraph_format.space_after = Pt(5)
styles["Heading 1"].font.size = Pt(11.4)
styles["Heading 1"].font.bold = True
styles["Heading 1"].paragraph_format.space_before = Pt(7)
styles["Heading 1"].paragraph_format.space_after = Pt(4)
styles["Heading 1"].paragraph_format.keep_with_next = True
styles["Heading 2"].font.size = Pt(10.2)
styles["Heading 2"].font.bold = True
styles["Heading 2"].paragraph_format.space_before = Pt(4)
styles["Heading 2"].paragraph_format.space_after = Pt(1)
styles["Heading 2"].paragraph_format.keep_with_next = True

if "CV Bullet" not in styles:
    bullet = styles.add_style("CV Bullet", WD_STYLE_TYPE.PARAGRAPH)
else:
    bullet = styles["CV Bullet"]
bullet.font.name = "DejaVu Sans"
bullet.font.size = Pt(8.9)
bullet.font.color.rgb = RGBColor.from_string(CHARCOAL)
bullet.paragraph_format.left_indent = Inches(0.16)
bullet.paragraph_format.first_line_indent = Inches(-0.12)
bullet.paragraph_format.space_after = Pt(1.4)
bullet.paragraph_format.line_spacing = 1.01


def accent_rule():
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(0)
    p.paragraph_format.space_after = Pt(3)
    pPr = p._p.get_or_add_pPr()
    pbdr = OxmlElement("w:pBdr")
    bottom = OxmlElement("w:bottom")
    bottom.set(qn("w:val"), "single")
    bottom.set(qn("w:sz"), "10")
    bottom.set(qn("w:space"), "1")
    bottom.set(qn("w:color"), NAVY)
    pbdr.append(bottom)
    pPr.append(pbdr)


def section_title(text):
    p = doc.add_paragraph(text, style="Heading 1")
    p.runs[0].font.color.rgb = RGBColor.from_string(NAVY)
    p.runs[0].font.letter_spacing = Pt(0.5) if hasattr(p.runs[0].font, "letter_spacing") else None
    return p


def bullet_line(text):
    p = doc.add_paragraph(style="CV Bullet")
    p.add_run("• ").font.color.rgb = RGBColor.from_string(NAVY)
    p.add_run(text)
    set_keep(p)
    return p


def role(title, company, location, dates, department=None):
    t = doc.add_table(rows=1, cols=2)
    t.alignment = WD_TABLE_ALIGNMENT.CENTER
    t.autofit = False
    clear_borders(t)
    t.columns[0].width = Inches(5.0)
    t.columns[1].width = Inches(2.0)
    left, right = t.rows[0].cells
    set_cell_margins(left, 0, 0, 20, 50)
    set_cell_margins(right, 0, 0, 20, 0)
    left.vertical_alignment = right.vertical_alignment = WD_CELL_VERTICAL_ALIGNMENT.CENTER
    p = left.paragraphs[0]
    p.paragraph_format.space_after = Pt(0)
    r = p.add_run(title)
    r.bold = True; r.font.size = Pt(10.3); r.font.color.rgb = RGBColor.from_string(CHARCOAL)
    r = p.add_run(f"  |  {company}")
    r.bold = True; r.font.size = Pt(9.8); r.font.color.rgb = RGBColor.from_string(NAVY)
    p = right.paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    p.paragraph_format.space_after = Pt(0)
    r = p.add_run(dates)
    r.bold = True; r.font.size = Pt(8.7); r.font.color.rgb = RGBColor.from_string(MID)
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(2)
    r = p.add_run(location)
    r.italic = True; r.font.size = Pt(8.8); r.font.color.rgb = RGBColor.from_string(MID)
    if department:
        r = p.add_run(f"  •  {department}")
        r.font.size = Pt(8.8); r.font.color.rgb = RGBColor.from_string(MID)
    return t


rounded_photo()

# Header
header = doc.add_table(rows=1, cols=2)
header.alignment = WD_TABLE_ALIGNMENT.CENTER
header.autofit = False
clear_borders(header)
header.columns[0].width = Inches(6.15)
header.columns[1].width = Inches(0.95)
left, right = header.rows[0].cells
set_cell_margins(left, 0, 0, 0, 120)
set_cell_margins(right, 0, 0, 0, 0)
p = left.paragraphs[0]
p.style = styles["Title"]
p.add_run("ENES GÜNTAV")
p = left.add_paragraph(style="Subtitle")
p.add_run(".NET Developer  |  Backend Developer  |  Full Stack Developer")
p = left.add_paragraph()
p.paragraph_format.space_after = Pt(0)
p.add_run("İstanbul  |  0533 560 11 79  |  guntav.enes@gmail.com  |  ")
add_hyperlink(p, "LinkedIn", "https://www.linkedin.com/in/enes-g%C3%BCntav-85b2051a8")
p.add_run("  |  ")
add_hyperlink(p, "GitHub", "https://github.com/guntavenes")
p = right.paragraphs[0]
p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
p.add_run().add_picture(str(PHOTO_OUT), width=Inches(0.82), height=Inches(0.82))
accent_rule()

section_title("PROFİL")
p = doc.add_paragraph()
p.paragraph_format.space_after = Pt(3)
p.add_run(
    "Bankacılık sektöründe hazine ve dış işlemler uygulamaları geliştiren yazılım uzmanıyım. "
    ".NET, ASP.NET Core, Angular, Oracle ve MSSQL ile uygulama geliştirme; mikroservis mimarisi, "
    "REST API, entegrasyon ve performans optimizasyonu alanlarında çalışıyorum. Scrum Master olarak "
    "6 kişilik ekibin koordinasyonuna, teknik kararlarına ve mentorluk çalışmalarına katkı sağlıyorum."
)

section_title("DENEYİM")
role("BT Uzmanı", "VakıfBank", "İstanbul", "Temmuz 2022 - Günümüz", "Hazine ve Dış İşlemler Uygulama Geliştirme Müdürlüğü")
for item in [
    "Yüksek işlem hacimli bankacılık ve hazine uygulamalarında yazılım geliştirme, entegrasyon ve bakım çalışmalarını yürütüyorum.",
    "Treasury Frontoffice, Treasury Limit Management, Treasury Valuation Engine ve Treasury Backoffice uygulamalarında aktif rol aldım; Valuation Engine geliştirmeleri sürüyor.",
    ".NET 6/8, ASP.NET Core, C#, Angular ve TypeScript ile geliştirme yapıyor; Backoffice dışındaki projelerin mikroservis mimarisi ve REST API entegrasyonları üzerinde çalışıyorum.",
    "Kafka ve Debezium ile gerçek zamanlı veri akışı ve uygulama entegrasyonu süreçlerini geliştiriyorum.",
    "Oracle ve MSSQL ortamlarında PL/SQL prosedürleri, sorgular, indeksler ve tablolar için performans iyileştirmeleri yapıyorum.",
    "Kod inceleme, unit test, loglama ve Azure DevOps CI/CD süreçlerine katkı sağlıyorum; OpenShift, Redis, Amazon S3, Grafana, Prometheus ve Dynamic Trace kullanıyorum.",
    "Limit Management ve Valuation Engine projelerinde Scrum Master olarak 6 kişilik ekibin sprint planlama, daily, review, retrospective ve PBI takip süreçlerini yürütüyorum.",
    "Teknik karar alma, ekip koordinasyonu ve mentorluk faaliyetlerine katkı sağlıyorum."
]: bullet_line(item)

role("Yazılım Uzmanı", "NAVAPP Yazılım ve Danışmanlık", "Ankara", "Aralık 2021 - Temmuz 2022")
for item in [
    "Dynamics 365 Business Central üzerinde Microsoft AL ile müşteriye özel geliştirmeler ve ERP uzantıları hazırladım.",
    "Finans, muhasebe, yemek ve diğer kurumsal süreçler için raporlar geliştirdim; müşteri desteği ve iyileştirme çalışmalarını yürüttüm.",
    "Power Apps ve .NET MAUI ile uygulama geliştirme süreçlerine katkı sağladım."
]: bullet_line(item)

section_title("ÖNE ÇIKAN PROJELER")
p = doc.add_paragraph()
p.paragraph_format.space_after = Pt(2)
r = p.add_run("Kurumsal projeler")
r.bold = True; r.font.size = Pt(9.6); r.font.color.rgb = RGBColor.from_string(NAVY)
p = doc.add_paragraph("VakıfBank Hazine ve Dış İşlemler", style=None)
p.paragraph_format.space_after = Pt(2)
p.runs[0].bold = True
for item in [
    "Treasury Frontoffice Application",
    "Treasury Limit Management System",
    "Treasury Valuation Engine",
    "Treasury Backoffice Application",
]: bullet_line(item)

doc.add_page_break()
p = doc.add_paragraph()
p.paragraph_format.space_before = Pt(4); p.paragraph_format.space_after = Pt(2)
r = p.add_run("Kişisel ve akademik projeler")
r.bold = True; r.font.size = Pt(9.6); r.font.color.rgb = RGBColor.from_string(NAVY)
for name, desc in [
    ("AI Food Analyzer", "Görüntü analizi ve yapay zekâ ile yiyeceklerin kalori ve besin değerlerini tahmin eden; günlük kalori takibi ve kişisel hedef belirlemeyi destekleyen uygulama."),
    ("Drinkly", "Günlük su tüketimini takip eden ve verileri akıllı saat üzerinden gösteren mobil uygulama."),
    ("Çeyizim", "Çeyiz ihtiyaçlarının ve alışveriş listesinin oluşturulmasını ve takip edilmesini sağlayan uygulama."),
    ("Tespit Drone", "Bitirme projesi. Görüntü işleme ile yasa dışı ekilen bitkileri tespit eden; görüntü ve konum bilgilerini ilgili kolluk birimlerine aktaran drone projesi."),
]:
    p = doc.add_paragraph(style="CV Bullet")
    p.add_run("• ").font.color.rgb = RGBColor.from_string(NAVY)
    r = p.add_run(name + ": "); r.bold = True
    p.add_run(desc)

section_title("TEKNİK YETKİNLİKLER")
skills = [
    ("Backend", "C#, .NET 6/8, ASP.NET Core, Web API"),
    ("Frontend", "Angular, TypeScript"),
    ("Database", "Oracle, MSSQL, PL/SQL, Redis"),
    ("Messaging & Integration", "Kafka, Debezium, Amazon S3"),
    ("DevOps", "Azure DevOps, Git, TFS, OpenShift, CI/CD"),
    ("Monitoring", "Prometheus, Grafana, Elastic, Dynamic Trace"),
    ("Architecture & Engineering", "Microservices, REST API Design, Performance Optimization, Unit Testing, Code Review"),
    ("Other", ".NET MAUI, Power Apps, Dynamics 365 Business Central, Microsoft AL"),
]
t = doc.add_table(rows=0, cols=2)
t.alignment = WD_TABLE_ALIGNMENT.CENTER
t.autofit = False
clear_borders(t)
t.columns[0].width = Inches(1.72)
t.columns[1].width = Inches(5.35)
for label, value in skills:
    cells = t.add_row().cells
    set_cell_margins(cells[0], 35, 0, 35, 100)
    set_cell_margins(cells[1], 35, 0, 35, 0)
    p = cells[0].paragraphs[0]; p.paragraph_format.space_after = Pt(0)
    r = p.add_run(label); r.bold = True; r.font.color.rgb = RGBColor.from_string(NAVY); r.font.size = Pt(8.8)
    p = cells[1].paragraphs[0]; p.paragraph_format.space_after = Pt(0)
    r = p.add_run(value); r.font.size = Pt(8.8)

section_title("EĞİTİM")
p = doc.add_paragraph()
p.paragraph_format.space_after = Pt(2)
r = p.add_run("Bilgisayar Mühendisliği"); r.bold = True
p.add_run("  |  Erciyes Üniversitesi, Kayseri  |  2015 - 2020")

section_title("EK BİLGİLER")
p = doc.add_paragraph()
p.paragraph_format.space_after = Pt(0)
p.add_run("İngilizce: ").bold = True; p.add_run("Temel seviye")
p.add_run("   |   Askerlik: ").bold = True; p.add_run("Tamamlandı")
p.add_run("   |   Ehliyet: ").bold = True; p.add_run("A, B, B1, D")
p = doc.add_paragraph()
p.paragraph_format.space_after = Pt(0)
p.add_run("Çalışma düzeni: ").bold = True; p.add_run("Hibrit / uzaktan çalışmaya uygun")
p.add_run("   |   Seyahat engeli: ").bold = True; p.add_run("Yok")

# Footer
for section in doc.sections:
    fp = section.footer.paragraphs[0]
    fp.alignment = WD_ALIGN_PARAGRAPH.CENTER
    fp.paragraph_format.space_before = Pt(2)
    r = fp.add_run("ENES GÜNTAV  •  SOFTWARE ENGINEER")
    r.font.name = "DejaVu Sans"; r.font.size = Pt(7.2); r.font.color.rgb = RGBColor.from_string(MID)

doc.core_properties.title = "Enes Güntav Yazılım Mühendisi Özgeçmişi"
doc.core_properties.subject = "Senior Backend Developer, .NET Developer ve Full Stack Developer başvuruları"
doc.core_properties.author = "Enes Güntav"
OUT.parent.mkdir(parents=True, exist_ok=True)
doc.save(OUT)
print(OUT)
