from pathlib import Path
import sys
from PIL import Image, ImageDraw
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_CELL_VERTICAL_ALIGNMENT
from docx.enum.style import WD_STYLE_TYPE
from docx.oxml import OxmlElement
from docx.oxml.ns import qn

ROOT = Path(__file__).resolve().parents[2]
PHOTO_IN = ROOT / "output/imagegen/enes_guntav_cv_photo_enhanced.png"
PHOTO = ROOT / "tmp/docx/profile_rounded_en.png"
CV_OUT = ROOT / "output/docx/enes_guntav_cv_english.docx"
LETTER_OUT = ROOT / "output/docx/enes_guntav_cover_letter_english.docx"

NAVY = "163B65"
INK = "242A31"
GRAY = "647180"
PALE = "EEF3F8"
FONT = "DejaVu Sans"


def cell_margins(cell, top=60, start=60, bottom=60, end=60):
    pr = cell._tc.get_or_add_tcPr()
    mar = pr.first_child_found_in("w:tcMar")
    if mar is None:
        mar = OxmlElement("w:tcMar"); pr.append(mar)
    for name, val in (("top", top), ("start", start), ("bottom", bottom), ("end", end)):
        el = mar.find(qn(f"w:{name}"))
        if el is None:
            el = OxmlElement(f"w:{name}"); mar.append(el)
        el.set(qn("w:w"), str(val)); el.set(qn("w:type"), "dxa")


def no_borders(table):
    pr = table._tbl.tblPr
    b = pr.first_child_found_in("w:tblBorders")
    if b is None:
        b = OxmlElement("w:tblBorders"); pr.append(b)
    for edge in ("top", "left", "bottom", "right", "insideH", "insideV"):
        el = b.find(qn(f"w:{edge}"))
        if el is None:
            el = OxmlElement(f"w:{edge}"); b.append(el)
        el.set(qn("w:val"), "nil")


def hyperlink(p, label, url):
    rid = p.part.relate_to(url, "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink", is_external=True)
    link = OxmlElement("w:hyperlink"); link.set(qn("r:id"), rid)
    r = OxmlElement("w:r"); rp = OxmlElement("w:rPr")
    c = OxmlElement("w:color"); c.set(qn("w:val"), NAVY); rp.append(c)
    u = OxmlElement("w:u"); u.set(qn("w:val"), "single"); rp.append(u)
    r.append(rp); t = OxmlElement("w:t"); t.text = label; r.append(t); link.append(r); p._p.append(link)


def rounded_photo():
    im = Image.open(PHOTO_IN).convert("RGB")
    # The image extracted from the supplied PDF is already square and clean.
    # Preserve its full composition and add only a subtle square border.
    im = im.resize((500, 500), Image.Resampling.LANCZOS)
    out = Image.new("RGB", (500, 500), "white")
    out.paste(im, (0, 0))
    ImageDraw.Draw(out).rectangle((2, 2, 497, 497), outline="#D8E0E8", width=3)
    out.save(PHOTO)


def base_doc():
    d = Document(); s = d.sections[0]
    s.page_width = Inches(8.2677); s.page_height = Inches(11.6929)
    s.top_margin = Inches(.36); s.bottom_margin = Inches(.38); s.left_margin = Inches(.55); s.right_margin = Inches(.55)
    st = d.styles
    st["Normal"].font.name = FONT; st["Normal"].font.size = Pt(8.45); st["Normal"].font.color.rgb = RGBColor.from_string(INK)
    st["Normal"].paragraph_format.space_after = Pt(1.7); st["Normal"].paragraph_format.line_spacing = 1.0
    for name in ("Title","Subtitle","Heading 1","Heading 2"):
        st[name].font.name = FONT; st[name].font.color.rgb = RGBColor(0,0,0)
    st["Title"].font.size = Pt(24); st["Title"].font.bold = True; st["Title"].paragraph_format.space_after = Pt(1)
    st["Subtitle"].font.size = Pt(9.5); st["Subtitle"].font.bold = True; st["Subtitle"].paragraph_format.space_after = Pt(3)
    st["Heading 1"].font.size = Pt(10.2); st["Heading 1"].font.bold = True; st["Heading 1"].paragraph_format.space_before = Pt(4); st["Heading 1"].paragraph_format.space_after = Pt(2); st["Heading 1"].paragraph_format.keep_with_next = True
    st["Heading 2"].font.size = Pt(10.2); st["Heading 2"].font.bold = True; st["Heading 2"].paragraph_format.space_before = Pt(4); st["Heading 2"].paragraph_format.space_after = Pt(2); st["Heading 2"].paragraph_format.keep_with_next = True
    if "CV Bullet" not in st: st.add_style("CV Bullet", WD_STYLE_TYPE.PARAGRAPH)
    b = st["CV Bullet"]; b.font.name = FONT; b.font.size = Pt(7.85); b.font.color.rgb = RGBColor.from_string(INK)
    b.paragraph_format.left_indent = Inches(.15); b.paragraph_format.first_line_indent = Inches(-.11); b.paragraph_format.space_after = Pt(.7); b.paragraph_format.line_spacing = 1.0
    return d


def rule(d):
    p=d.add_paragraph(); p.paragraph_format.space_after=Pt(2)
    ppr=p._p.get_or_add_pPr(); pb=OxmlElement("w:pBdr"); bt=OxmlElement("w:bottom")
    bt.set(qn("w:val"),"single"); bt.set(qn("w:sz"),"9"); bt.set(qn("w:space"),"1"); bt.set(qn("w:color"),NAVY); pb.append(bt); ppr.append(pb)


def heading(d, text):
    p=d.add_paragraph(text, style="Heading 1"); p.runs[0].font.color.rgb=RGBColor.from_string(NAVY); return p


def bullet(d, text):
    p=d.add_paragraph(style="CV Bullet"); p.add_run("• ").font.color.rgb=RGBColor.from_string(NAVY); p.add_run(text)
    p._p.get_or_add_pPr().append(OxmlElement("w:keepLines")); return p


def role(d, title, company, place, dates, dept=""):
    t=d.add_table(rows=1,cols=2); t.alignment=WD_TABLE_ALIGNMENT.CENTER; t.autofit=False; no_borders(t)
    t.columns[0].width=Inches(5.15); t.columns[1].width=Inches(1.85)
    a,b=t.rows[0].cells; cell_margins(a,0,0,10,50); cell_margins(b,0,0,10,0)
    p=a.paragraphs[0]; p.paragraph_format.space_after=Pt(0)
    r=p.add_run(title); r.bold=True; r.font.size=Pt(9.2)
    r=p.add_run("  |  "+company); r.bold=True; r.font.size=Pt(8.9); r.font.color.rgb=RGBColor.from_string(NAVY)
    p=b.paragraphs[0]; p.alignment=WD_ALIGN_PARAGRAPH.RIGHT; p.paragraph_format.space_after=Pt(0)
    r=p.add_run(dates); r.bold=True; r.font.size=Pt(7.7); r.font.color.rgb=RGBColor.from_string(GRAY)
    p=d.add_paragraph(); p.paragraph_format.space_after=Pt(1)
    r=p.add_run(place); r.italic=True; r.font.size=Pt(7.8); r.font.color.rgb=RGBColor.from_string(GRAY)
    if dept:
        r=p.add_run("  •  "+dept); r.font.size=Pt(7.8); r.font.color.rgb=RGBColor.from_string(GRAY)


def footer(d, text):
    p=d.sections[0].footer.paragraphs[0]; p.alignment=WD_ALIGN_PARAGRAPH.CENTER
    r=p.add_run(text); r.font.name=FONT; r.font.size=Pt(7.2); r.font.color.rgb=RGBColor.from_string(GRAY)


rounded_photo()
cv=base_doc()

h=cv.add_table(rows=1,cols=2); h.alignment=WD_TABLE_ALIGNMENT.CENTER; h.autofit=False; no_borders(h)
h.columns[0].width=Inches(6.2); h.columns[1].width=Inches(.82)
a,b=h.rows[0].cells; cell_margins(a,0,0,0,100); cell_margins(b,0,0,0,0)
p=a.paragraphs[0]; p.style=cv.styles["Title"]; p.add_run("ENES GÜNTAV")
p=a.add_paragraph(style="Subtitle"); p.add_run("Senior Backend Developer  |  .NET Developer  |  Full Stack Developer")
p=a.add_paragraph(); p.paragraph_format.space_after=Pt(0)
p.add_run("Istanbul, Türkiye  |  +90 533 560 11 79  |  guntav.enes@gmail.com  |  ")
hyperlink(p,"LinkedIn","https://www.linkedin.com/in/enes-g%C3%BCntav-85b2051a8"); p.add_run("  |  "); hyperlink(p,"GitHub","https://github.com/guntavenes")
p=b.paragraphs[0]; p.alignment=WD_ALIGN_PARAGRAPH.CENTER; b.vertical_alignment=WD_CELL_VERTICAL_ALIGNMENT.CENTER; p.add_run().add_picture(str(PHOTO),width=Inches(.70),height=Inches(.70))
rule(cv)

heading(cv,"PROFESSIONAL SUMMARY")
cv.add_paragraph("Software engineer with experience developing banking, treasury, and foreign transactions applications. Hands-on background in C#, .NET 6/8, ASP.NET Core, Angular, Oracle, and MSSQL, with a focus on microservices, REST API design, system integration, performance optimization, and observability. Scrum Master for a six-person team, contributing to technical decisions, team coordination, code quality, and mentoring.")

heading(cv,"PROFESSIONAL EXPERIENCE")
role(cv,"IT Specialist","VakıfBank","Istanbul","July 2022 - Present","Treasury and Foreign Transactions Application Development")
for x in [
    "Develop, integrate, and maintain high-volume banking and treasury applications across front-office, limit management, valuation, and back-office domains.",
    "Contribute to Treasury Frontoffice, Treasury Limit Management, Treasury Valuation Engine, and Treasury Backoffice applications; ongoing development continues on the Valuation Engine.",
    "Build backend and full-stack functionality with C#, .NET 6/8, ASP.NET Core, Angular, and TypeScript; support microservices and REST API integrations across treasury systems.",
    "Implement real-time data flows and application integrations using Kafka and Debezium.",
    "Optimize PL/SQL procedures, SQL queries, indexes, and tables across Oracle and MSSQL environments.",
    "Contribute to unit testing, code review, logging, and Azure DevOps CI/CD; use OpenShift, Redis, Amazon S3, Grafana, Prometheus, and Dynamic Trace for delivery and observability.",
    "Serve as Scrum Master for a six-person team, facilitating Agile ceremonies and supporting technical decisions, coordination, PBI tracking, and mentoring."
]: bullet(cv,x)
role(cv,"Software Specialist","NAVAPP Software and Consulting","Ankara","December 2021 - July 2022")
for x in [
    "Developed customer-specific extensions and ERP functionality for Dynamics 365 Business Central using Microsoft AL.",
    "Built enterprise reports, provided customer support, delivered improvements, and contributed to Power Apps and .NET MAUI development."
]: bullet(cv,x)

heading(cv,"SELECTED PROJECTS")
p=cv.add_paragraph(); p.paragraph_format.space_after=Pt(1)
r=p.add_run("Enterprise: "); r.bold=True; r.font.color.rgb=RGBColor.from_string(NAVY)
p.add_run("Treasury Frontoffice Application • Treasury Limit Management System • Treasury Valuation Engine • Treasury Backoffice Application")
p=cv.add_paragraph(); p.paragraph_format.space_after=Pt(1)
r=p.add_run("Personal and academic: "); r.bold=True; r.font.color.rgb=RGBColor.from_string(NAVY)
p.add_run("AI Food Analyzer (AI-based nutrition estimation) • Drinkly (water tracking) • Çeyizim (shopping-list tracking) • Tespit Drone (image-processing graduation project)")

heading(cv,"TECHNICAL SKILLS")
sp=cv.add_paragraph(); sp.paragraph_format.space_after=Pt(0); sp.paragraph_format.line_spacing=0.2
skills=[
    ("Backend","C#, .NET 6/8, ASP.NET Core, Web API"),("Frontend","Angular, TypeScript"),("Databases","Oracle, MSSQL, PL/SQL, Redis"),
    ("Messaging & Integration","Kafka, Debezium, Amazon S3"),("DevOps","Azure DevOps, Git, TFS, OpenShift, CI/CD"),
    ("Monitoring & Observability","Prometheus, Grafana, Elastic, Dynamic Trace"),
    ("Architecture & Engineering","Microservices, REST API Design, Performance Optimization, Unit Testing, Code Review"),
    ("Additional Technologies",".NET MAUI, Power Apps, Dynamics 365 Business Central, Microsoft AL")]
t=cv.add_table(rows=0,cols=2); t.alignment=WD_TABLE_ALIGNMENT.CENTER; t.autofit=False; no_borders(t); t.columns[0].width=Inches(1.9); t.columns[1].width=Inches(5.0)
for lab,val in skills:
    c=t.add_row().cells; cell_margins(c[0],15,0,15,70); cell_margins(c[1],15,0,15,0)
    p=c[0].paragraphs[0]; p.paragraph_format.space_after=Pt(0); r=p.add_run(lab); r.bold=True; r.font.size=Pt(7.65); r.font.color.rgb=RGBColor.from_string(NAVY)
    p=c[1].paragraphs[0]; p.paragraph_format.space_after=Pt(0); p.add_run(val).font.size=Pt(7.65)

heading(cv,"EDUCATION")
p=cv.add_paragraph(); p.add_run("BSc in Computer Engineering").bold=True; p.add_run("  |  Erciyes University, Kayseri  |  2015 - 2020")
heading(cv,"ADDITIONAL INFORMATION")
p=cv.add_paragraph(); p.add_run("English: ").bold=True; p.add_run("Basic proficiency"); p.add_run("   |   Military service: ").bold=True; p.add_run("Completed"); p.add_run("   |   Driving licences: ").bold=True; p.add_run("A, B, B1, D")
p=cv.add_paragraph(); p.add_run("Work model: ").bold=True; p.add_run("Open to hybrid and remote work"); p.add_run("   |   Travel: ").bold=True; p.add_run("No restrictions")
footer(cv,"ENES GÜNTAV  •  SOFTWARE ENGINEER")
cv.core_properties.title="Enes Güntav English CV"; cv.core_properties.subject="Backend and .NET software engineering applications"; cv.core_properties.author="Enes Güntav"
CV_OUT.parent.mkdir(parents=True,exist_ok=True); cv.save(CV_OUT)

if "--cv-only" in sys.argv:
    print(CV_OUT)
    raise SystemExit(0)

# Cover letter
letter=base_doc(); s=letter.sections[0]; s.top_margin=Inches(.7); s.bottom_margin=Inches(.7); s.left_margin=Inches(.85); s.right_margin=Inches(.85)
p=letter.add_paragraph(style="Title"); p.add_run("ENES GÜNTAV")
p=letter.add_paragraph(style="Subtitle"); p.add_run("Software Engineer  |  .NET  |  Backend  |  Full Stack")
p=letter.add_paragraph(); p.paragraph_format.space_after=Pt(0)
p.add_run("Istanbul, Türkiye  |  +90 533 560 11 79  |  guntav.enes@gmail.com  |  "); hyperlink(p,"LinkedIn","https://www.linkedin.com/in/enes-g%C3%BCntav-85b2051a8"); p.add_run("  |  "); hyperlink(p,"GitHub","https://github.com/guntavenes")
rule(letter)
p=letter.add_paragraph(); p.paragraph_format.space_before=Pt(18); p.paragraph_format.space_after=Pt(18)
r=p.add_run("APPLICATION FOR SENIOR BACKEND AND .NET SOFTWARE ENGINEERING ROLES"); r.bold=True; r.font.size=Pt(12); r.font.color.rgb=RGBColor.from_string(NAVY)
p=letter.add_paragraph("Dear Hiring Manager,"); p.paragraph_format.space_after=Pt(13)
paras=[
    "I am writing to express my interest in senior backend and .NET software engineering opportunities within banking, fintech, and enterprise technology teams. My experience at VakıfBank focuses on treasury and foreign transactions applications, where I contribute to the development, integration, maintenance, and continuous improvement of business-critical systems.",
    "My technical background includes C#, .NET 6/8, ASP.NET Core, Angular, TypeScript, microservices, REST APIs, Kafka, Debezium, Redis, Oracle, MSSQL, and PL/SQL. I also work with OpenShift and Azure DevOps CI/CD processes and use Grafana, Prometheus, Elastic, and Dynamic Trace for monitoring and observability. This combination has given me practical experience across backend development, data integration, database performance, deployment workflows, and production support.",
    "Beyond hands-on development, I serve as Scrum Master for a six-person team on treasury limit management and valuation projects. I facilitate Agile ceremonies, support technical decisions, coordinate delivery, and contribute to mentoring and code quality. I value clear engineering practices, maintainable systems, and close collaboration between technical and business teams.",
    "I would welcome the opportunity to bring my banking domain knowledge and .NET engineering experience to a team building reliable financial or enterprise platforms. Thank you for considering my application. I would be pleased to discuss how my experience could support your software development goals."
]
for text in paras:
    p=letter.add_paragraph(text); p.paragraph_format.space_after=Pt(12); p.paragraph_format.line_spacing=1.14
p=letter.add_paragraph(); p.paragraph_format.space_before=Pt(8); p.add_run("Sincerely,")
p=letter.add_paragraph(); r=p.add_run("Enes Güntav"); r.bold=True; r.font.color.rgb=RGBColor.from_string(NAVY)
footer(letter,"ENES GÜNTAV  •  COVER LETTER")
letter.core_properties.title="Enes Güntav Cover Letter"; letter.core_properties.subject="Senior backend and .NET software engineering roles"; letter.core_properties.author="Enes Güntav"
LETTER_OUT.parent.mkdir(parents=True,exist_ok=True); letter.save(LETTER_OUT)
print(CV_OUT); print(LETTER_OUT)
