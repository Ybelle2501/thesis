"""Regenerate LeafLens implementation diagrams using only the Python stdlib.

Run from any directory: python tools/generate_app_diagrams.py [--render]
--render uses an installed Chromium browser for PNGs and the PDF booklet.
Layout and flows are curated; SQL columns are read from the current Dart source.
"""

import argparse
from datetime import date
from html import escape
import os
from pathlib import Path
import re
import shutil
import sqlite3
import subprocess
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
DOCS = ROOT / "docs"
GREEN = "#17634c"
INK = "#18392f"
MUTED = "#52685e"
LINE = "#8ea99c"
PALE = "#edf5ef"
BLUE = "#edf3fa"
AMBER = "#fff7e6"


class Diagram:
    def __init__(self, name, width, height, title, subtitle, description):
        self.name, self.width, self.height = name, width, height
        self.parts = [
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
            f'viewBox="0 0 {width} {height}" role="img" aria-labelledby="title desc">',
            f'<title id="title">{escape(title)}</title><desc id="desc">{escape(description)}</desc>',
            '<defs><marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" '
            'markerWidth="8" markerHeight="8" orient="auto-start-reverse">'
            f'<path d="M0 0 L10 5 L0 10 Z" fill="{GREEN}"/></marker></defs>',
            '<style>text{font-family:Arial,Helvetica,sans-serif} '
            '.flowlabel{paint-order:stroke;stroke:white;stroke-width:8px;stroke-linejoin:round}</style>',
            f'<rect width="{width}" height="{height}" fill="white"/>',
        ]
        self.text(65, 57, "LEAFLENS / SYSTEM DOCUMENTATION", 16, GREEN, bold=True)
        self.text(65, 108, title, 36, bold=True)
        self.text(65, 145, subtitle, 19, MUTED)
        self.line([(65, 170), (width - 65, 170)], color=LINE, arrow=False)
        self.text(width - 65, height - 28, f"Implementation snapshot / {date.today().isoformat()}", 15, MUTED, anchor="end")

    def text(self, x, y, value, size=19, color=INK, bold=False, anchor="start", label=False, mono=False):
        values = value if isinstance(value, list) else [value]
        for i, part in enumerate(values):
            attrs = ' class="flowlabel"' if label else ''
            style = ' style="font-family:Consolas,monospace"' if mono else ''
            self.parts.append(
                f'<text x="{x}" y="{y + i * (size + 8)}" font-size="{size}" fill="{color}" '
                f'text-anchor="{anchor}" font-weight="{700 if bold else 400}"{attrs}{style}>{escape(str(part))}</text>'
            )

    def rect(self, x, y, w, h, fill="white", radius=0, dashed=False, color=LINE):
        self.parts.append(
            f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{radius}" fill="{fill}" '
            f'stroke="{color}" stroke-width="2"' + (' stroke-dasharray="9 7"' if dashed else '') + '/>'
        )

    def line(self, points, color=GREEN, arrow=True, dashed=False):
        self.parts.append(
            '<polyline points="' + ' '.join(f"{x},{y}" for x, y in points) +
            f'" fill="none" stroke="{color}" stroke-width="2.4" stroke-linejoin="round"'
            + (' marker-end="url(#arrow)"' if arrow else '')
            + (' stroke-dasharray="8 6"' if dashed else '') + '/>'
        )

    def box(self, x, y, w, h, title, body=(), kind="process"):
        self.rect(x, y, w, h, PALE if kind == "process" else BLUE if kind == "store" else "white",
                  radius=18 if kind == "process" else 0, color=GREEN if kind == "process" else LINE)
        if kind == "store":
            self.line([(x + 17, y), (x + 17, y + h)], color=LINE, arrow=False)
        self.text(x + w / 2, y + 32, title, 21, bold=True, anchor="middle")
        for i, item in enumerate(body):
            self.text(x + w / 2, y + 62 + i * 27, item, 18, MUTED, anchor="middle")

    def note(self, x, y, w, h, title, lines):
        self.rect(x, y, w, h, AMBER, radius=8, color="#d3bb84")
        self.text(x + 22, y + 32, title, 20, bold=True)
        self.text(x + 22, y + 64, lines, 18, MUTED)

    def save(self):
        content = '\n'.join(self.parts + ['</svg>'])
        ET.fromstring(content)
        (DOCS / f"{self.name}.svg").write_text(content, encoding="utf-8")
        return self


def schema():
    source = (ROOT / "lib/services/scan_history_database.dart").read_text(encoding="utf-8")
    version = int(re.search(r"schemaVersion = (\d+)", source)[1])
    scan_sql = re.search(r"CREATE TABLE \$_tableName \((.*?)\n\s*\)", source, re.S)[1]
    meta_sql = re.search(r"CREATE TABLE IF NOT EXISTS app_metadata \((.*?)\n\s*\)", source, re.S)[1]
    connection = sqlite3.connect(":memory:")
    connection.execute(f"CREATE TABLE scan_history ({scan_sql})")
    connection.execute(f"CREATE TABLE app_metadata ({meta_sql})")
    tables = {name: connection.execute(f"PRAGMA table_info({name})").fetchall()
              for name in ("scan_history", "app_metadata")}
    assert not connection.execute("PRAGMA foreign_key_list(scan_history)").fetchall()
    assert not connection.execute("PRAGMA foreign_key_list(app_metadata)").fetchall()
    connection.close()
    return version, tables


def erd(version, tables):
    d = Diagram("leaflens_erd", 1800, 1320, "Entity relationship diagram",
                f"Physical schema / scan_history.db / schema version {version} / two independent tables",
                "Physical ERD showing all implemented SQLite fields, metadata keys, and the external image reference. No foreign keys exist.")
    x, y, w, row_h = 65, 225, 1040, 49
    d.rect(x, y, w, 108 + len(tables['scan_history']) * row_h, radius=6)
    d.rect(x, y, w, 55, GREEN, color=GREEN)
    d.text(x + 24, y + 37, "scan_history", 25, "white", bold=True)
    for col, label in [(x + 22, "KEY"), (x + 92, "COLUMN"), (x + 350, "SQL TYPE / CONSTRAINT")]:
        d.text(col, y + 88, label, 16, MUTED, bold=True)
    d.line([(x, y + 108), (x + w, y + 108)], color=LINE, arrow=False)
    for i, (_, name, typ, required, default, pk) in enumerate(tables['scan_history']):
        yy = y + 108 + row_h * i
        if i % 2 == 0:
            d.parts.append(f'<rect x="{x + 1}" y="{yy + 1}" width="{w - 2}" height="{row_h - 1}" fill="#f5f8f6"/>')
        constraint = typ
        if pk:
            constraint += " PRIMARY KEY AUTOINCREMENT"
        elif required:
            constraint += " NOT NULL"
        else:
            constraint += " (nullable)"
        if default is not None:
            constraint += f" DEFAULT {default}"
        if name == "status":
            constraint += " CHECK: Healthy | Infected"
        if name == "captured_at":
            constraint += " / UTC epoch ms"
        d.text(x + 22, yy + 32, "PK" if pk else "", 17, GREEN, bold=True)
        d.text(x + 92, yy + 32, name, 21, mono=True)
        d.text(x + 350, yy + 32, constraint, 19, mono=True)
    d.box(1190, 225, 545, 185, "app_metadata", kind="store")
    d.text(1215, 305, "PK   key      TEXT PRIMARY KEY", 21, mono=True)
    d.text(1215, 357, "     value    TEXT NOT NULL", 21, mono=True)
    d.note(1190, 450, 545, 253, "Implemented metadata keys", [
        "language  ->  en | tl",
        "next_report_number  ->  integer as text",
        "farm_location_options_v1",
        '  -> JSON array, e.g. ["Greenhouse 1"]',
        "Independent settings; no relationship to scan IDs.",
    ])
    d.rect(1190, 800, 545, 165, dashed=True)
    d.text(1215, 838, "Scan image files / outside SQLite", 23, bold=True)
    d.text(1215, 875, ["scan_history_images/", "One copied image per saved scan or grid cell.", "Path reference only; no database foreign key."], 18, MUTED)
    # image_path is the sixth field, at the center of its SQL row.
    image_y = y + 108 + 5 * row_h + row_h / 2
    d.line([(1105, image_y), (1147, image_y), (1147, 878), (1190, 878)], dashed=True)
    d.text(1150, 764, "file", 16, MUTED, label=True)
    d.note(65, 1020, 1670, 225, "Persistence and relationship rules", [
        "No foreign keys, join tables, user accounts, crop tables, report tables, or forecast tables are implemented.",
        "location stores a text snapshot; editing the saved choice list does not rename existing scan tags.",
        "Single scans have grid_cell = NULL; a saved 2 x 3 grid produces up to six independent scan rows (cells 1-6).",
        "Only successful classifications are saved after the user supplies a location and chooses Save. Other results remain temporary.",
        "Indexes: scan_history_captured_at (captured_at DESC) and scan_history_status (status).",
    ])
    lines = ["%% Physical SQLite schema; deliberately no FK edges.", "erDiagram"]
    for name, rows in tables.items():
        lines.append(f"    {name} {{")
        for _, column, typ, required, default, pk in rows:
            comment = "primary key" if pk else "required" if required else "nullable"
            if default is not None:
                comment += f"; default {default}"
            lines.append(f'        {typ} {column}' + (' PK' if pk else '') + f' "{comment}"')
        lines.append("    }")
    (DOCS / "leaflens_erd.mmd").write_text('\n'.join(lines) + '\n', encoding="utf-8")
    return d.save()


def context():
    d = Diagram("leaflens_data_flow_context", 1800, 1250, "Data flow / context diagram",
                "Level 0 / LeafLens as one process / external inputs and outputs",
                "Context DFD with user, camera/gallery, operating-system file services, and an external browser for reference links.")
    d.box(65, 450, 250, 140, "E1  App user", ["Farmer / farm scout"], kind="entity")
    d.box(630, 440, 530, 180, "0  LeafLens application", ["Capture and diagnose crops", "History, guidance, forecasts and reports", "Settings and recovery"])
    d.box(630, 215, 530, 100, "E2  Camera / gallery", ["Device image source"], kind="entity")
    d.box(1440, 450, 295, 150, "E3  OS file services", ["Downloads / file picker", "Share service"], kind="entity")
    d.box(630, 855, 530, 110, "E4  External browser", ["Published reference websites"], kind="entity")
    d.line([(315, 472), (630, 472)])
    d.text(468, 375, ["Scan mode; save / edit / delete requests", "Location; crop / label; station / month", "Report details; settings; recovery requests"], 17, anchor="middle", label=True)
    d.line([(630, 585), (315, 585)])
    d.text(468, 660, ["Diagnosis and confidence; saved history", "Treatment / prevention; seasonal outlook", "Detection forecasts; charts; export status"], 17, anchor="middle", label=True)
    d.line([(805, 440), (805, 315)])
    d.text(785, 355, "Capture / image selection request", 17, anchor="end", label=True)
    d.line([(1040, 315), (1040, 440)])
    d.text(1062, 360, "Photo bytes / image path", 17, label=True)
    d.line([(1160, 480), (1440, 480)])
    d.text(1300, 390, ["PDF bytes; backup archive", "Backup-file selection request"], 17, anchor="middle", label=True)
    d.line([(1440, 575), (1160, 575)])
    d.text(1300, 647, ["Selected backup bytes", "Save path / operation status"], 17, anchor="middle", label=True)
    d.line([(895, 620), (895, 855)])
    d.text(916, 780, ["Reference URL", "(user chooses Open reference)"], 18, label=True)
    d.note(65, 1030, 1670, 135, "System boundary", [
        "Inference, scan storage, forecasting and seasonal guidance run locally. PAGASA normals are bundled data, not a live weather feed.",
        "Backup file import/export is Android-only. Android saves PDFs to Downloads; other platforms use the native sharing service.",
    ])
    (DOCS / f"{d.name}.mmd").write_text('''flowchart LR
    U["E1 App user"] -->|"Scan mode; location; filters; seasonal inputs; report details; settings; recovery requests"| P("0 LeafLens application")
    P -->|"Diagnosis; history; guides; seasonal outlook; forecasts; charts; operation status"| U
    P -->|"Capture or image selection request"| C["E2 Camera / gallery"]
    C -->|"Image bytes / path"| P
    P -->|"PDF; backup archive; file selection request"| F["E3 OS file services"]
    F -->|"Selected backup bytes; saved path; operation status"| P
    P -->|"User-selected reference URL"| B["E4 External browser"]
''', encoding="utf-8")
    return d.save()


# Each row is a DFD fragment. Repeated actor/store IDs refer to the same entity/store.
MODULES = [
    ("1.0  Capture and diagnose", ["Single image or six grid cells", "Plant gate > crop gate > disease model"],
     ["Mode; capture / select; location", "Save request; location-choice edits"],
     ["Diagnosis / confidence; grid summary", "Rejection / retry message; save status"],
     [("D1  Local persisted data", "Rows; copied images; location options", "Saved rows / images; location choices", "Location choices"),
      ("D2  Inference assets", "Three TFLite models; labels; thresholds", None, "Models / labels / thresholds")]),
    ("2.0  Manage scan history", ["Browse / search / filter / reopen", "Retag or delete saved records"],
     ["History query / selected scan", "Location edit; delete request"],
     ["Scan list; saved result / image", "Update / delete status"],
     [("D1  Local persisted data", "scan_history + saved image files", "Location updates; row / file deletion", "Saved scan rows / images")]),
    ("3.0  Analyze and forecast", ["Home outlook; report dashboard", "Monthly logged-detection estimates"],
     ["Dashboard request; crop / filters"],
     ["Metrics; monthly history chart", "Forecast / missing-data explanation"],
     [("D1  Local persisted data", "Saved crop / condition / status / time", None, "Saved scan history"),
      ("D4  Forecast assets", "Model JSON + historical indicators", None, "Weights / history; disease aliases")]),
    ("4.0  Provide crop guidance", ["Treatment and disease prevention", "Qualitative seasonal risk rules"],
     ["Crop / condition or scan label", "Station; month; upland choice; link request"],
     ["Treatment / prevention; citations", "Seasonal outlook and evidence notes"],
     [("D3  Guidance / climate assets", "Crop guides; sources; station normals", None, "Guide steps; normals; seasonal rules"),
      ("E4  External browser", "Reference websites / outside app", "User-selected reference URL", None)]),
    ("5.0  Export scouting report", ["Match location-tagged saved scans", "Create localized Papusoy PDF report"],
     ["Location; scout name", "Export request"],
     ["PDF export status / saved path"],
     [("D1  Local persisted data", "Rows; images; language; report counter", "Incremented next_report_number", "Rows / images; language; counter"),
      ("E3  OS file services", "Downloads / native sharing service", "PDF bytes / filename", "Saved path / export status")]),
    ("6.0  Manage preferences", ["English / Tagalog language", "Add / rename / remove location choices"],
     ["Language; location-choice changes"],
     ["Localized interface; saved choices", "Settings update status"],
     [("D1  Local persisted data", "app_metadata; scan tags for initial seed", "Language; JSON location-choice list", "Settings; existing tags (first seed)")]),
    ("7.0  Back up and restore", ["Validate ZIP manifest / JSON / images", "Replace rows and restore image files"],
     ["Backup request / restore selection", "Restore confirmation"],
     ["Backup / recovery status", "Validation / operation error"],
     [("D1  Local persisted data", "Both SQLite tables + saved images", "Restored rows / metadata / images", "Scan rows; metadata; image bytes"),
      ("E3  OS file services", "Android Downloads / document picker", "Backup archive / picker request", "Selected .leaflensbackup bytes")]),
]


def level_one():
    d = Diagram("leaflens_data_flow_diagram", 2100, 2580, "Data flow / application modules",
                "Level 1 / seven implemented processes / repeated actor and store IDs represent the same objects",
                "Modular level 1 DFD covering capture, history, analytics, guidance, PDF export, preferences, and Android backup/recovery.")
    d.text(65, 212, "EXTERNAL ACTOR", 16, MUTED, bold=True)
    d.text(650, 212, "LEAFLENS PROCESS", 16, MUTED, bold=True)
    d.text(1540, 212, "DATA STORE / EXTERNAL SERVICE", 16, MUTED, bold=True)
    d.text(650, 263, "Rounded = process / blue = local store or bundled data / square = external entity", 16, MUTED)
    mmd = ["%% Repeated stores in the SVG use the same IDs here.", "flowchart LR",
           '    U["E1 App user / farm scout"]',
           '    F["E3 OS file services"]', '    B["E4 External browser"]',
           '    C["E2 Camera / gallery"]', '    subgraph APP["LeafLens application"]',
           '    D1[("D1 Local persisted data: SQLite tables and saved images")]',
           '    D2[("D2 Three-stage inference assets")]',
           '    D3[("D3 Bundled crop guidance and station normals")]',
           '    D4[("D4 Forecast model and historical indicators")]']
    for i, (title, body, user_in, user_out, stores) in enumerate(MODULES):
        y = 295 + i * 286
        if i:
            d.line([(65, y - 6), (2025, y - 6)], color="#dce6df", arrow=False)
        d.box(65, y + 82, 230, 105, "E1  App user", ["Same actor in each row"], kind="entity")
        d.box(650, y + 60, 450, 147, title, body)
        d.line([(295, y + 103), (650, y + 103)])
        d.text(472, y + 26, user_in, 17, anchor="middle", label=True)
        d.line([(650, y + 175), (295, y + 175)])
        d.text(472, y + 228, user_out, 17, anchor="middle", label=True)
        for j, (store_title, desc, write, read) in enumerate(stores):
            sy = y + 8 + j * 150 if len(stores) > 1 else y + 66
            d.box(1540, sy, 470, 92, store_title, [desc], kind="entity" if store_title.startswith("E") else "store")
            if write:
                source_y = y + 94 if j == 0 else y + 185
                target_y = sy + 22
                d.line([(1100, source_y), (1170 + j * 60, source_y), (1170 + j * 60, target_y), (1540, target_y)])
                d.text(1360, target_y - 13, write, 16, anchor="middle", label=True)
            if read:
                source_y = sy + 77
                target_y = y + 149 if j == 0 else y + 195
                d.line([(1540, source_y), (1465 - j * 40, source_y), (1465 - j * 40, target_y), (1100, target_y)])
                d.text(1290, target_y - 15 if j == 0 else target_y + 29, read, 16, anchor="middle", label=True)
        pid = f"P{i+1}"
        mmd.append(f'    {pid}("{title}: {"; ".join(body)}")')
    mmd.append("    end")
    for i, (_, _, user_in, user_out, stores) in enumerate(MODULES):
        pid = f"P{i+1}"
        mmd.extend([f'    U -->|"{"; ".join(user_in)}"| {pid}', f'    {pid} -->|"{"; ".join(user_out)}"| U'])
        for store_title, _, write, read in stores:
            sid = store_title.split()[0]
            sid = {"E3": "F", "E4": "B"}.get(sid, sid)
            if write:
                mmd.append(f'    {pid} -->|"{write}"| {sid}')
            if read:
                mmd.append(f'    {sid} -->|"{read}"| {pid}')
    # Compact camera actor under process 1.0, with the same two flows as Level 0/2.
    camera_y = 295 + 230
    d.rect(650, camera_y, 450, 42)
    d.text(875, camera_y + 28, "E2  Camera / gallery", 19, bold=True, anchor="middle")
    d.line([(760, 295 + 207), (760, camera_y)])
    d.text(740, camera_y - 8, "Capture / select", 15, anchor="end", label=True)
    d.line([(1000, camera_y), (1000, 295 + 207)])
    d.text(1020, camera_y - 8, "Image bytes / path", 15, label=True)
    mmd.extend(['    P1 -->|"Capture / image selection request"| C', '    C -->|"Image bytes / path"| P1'])
    d.note(65, 2380, 1960, 130, "Store definitions and runtime behavior", [
        "D1 = scan_history + app_metadata + scan_history_images/. D2-D4 are bundled read-only resources; derived forecasts and PDFs have no SQL tables.",
        "Scan changes refresh the home / analytics views. Seasonal selections are session-only. The bundled forecasting model has synthetic_demo provenance.",
    ])
    (DOCS / f"{d.name}.mmd").write_text('\n'.join(mmd) + '\n', encoding="utf-8")
    return d.save()


def scan_detail():
    d = Diagram("leaflens_scan_data_flow", 1800, 1920, "Data flow / three-stage scanning",
                "Level 2 / decomposition of process 1.0 / identical pipeline for a single image and each grid cell",
                "Detailed scan DFD showing image input, optional six-cell split, plant and crop gates, disease inference, temporary results, and explicit persistence.")
    d.box(65, 245, 290, 110, "E1  App user", ["Mode / capture request"], kind="entity")
    d.box(65, 440, 290, 110, "E2  Camera / gallery", ["Capture / select image"], kind="entity")
    d.box(570, 235, 550, 145, "1.1  Prepare scan input", ["Decode and correct orientation", "Single image OR six 2 x 3 JPEG tiles"])
    d.box(570, 490, 550, 130, "1.2  Plant gate / Stage 1", ["Require confident plant classification"])
    d.box(570, 745, 550, 140, "1.3  Crop gate / Stage 2", ["Require confident supported crop", "Banana / lettuce / pineapple / tomato"])
    d.box(570, 1020, 550, 150, "1.4  Disease model / Stage 3", ["MobileNetV2 / 18 condition labels", "Confidence + margin; crop agreement"])
    d.box(1240, 1010, 495, 160, "1.5  Present scan results", ["Label; confidence; alternatives", "Rejected / uncertain / error messages", "Grid summary excludes ignored cells"])
    d.box(570, 1430, 550, 160, "1.6  Save successful result", ["Require location + explicit Save request", "Copy image and insert scan row", "One row per accepted, saved grid cell"])
    d.box(1240, 1430, 495, 155, "D1  Local persisted data", ["scan_history; copied image files", "app_metadata location-choice list"], kind="store")
    d.box(1240, 245, 495, 145, "D2  Inference assets", ["Stage 1 and Stage 2 TFLite gates", "Stage 3 MobileNetV2", "Labels and decision thresholds"], kind="store")
    d.box(65, 1430, 290, 110, "E1  App user", ["Same user / farm scout"], kind="entity")
    d.line([(355, 285), (570, 285)])
    d.text(455, 265, "Mode / request", 17, anchor="middle", label=True)
    d.line([(650, 380), (650, 410), (210, 410), (210, 440)])
    d.text(405, 404, "Capture / select request", 17, anchor="middle", label=True)
    d.line([(355, 495), (420, 495), (420, 340), (570, 340)])
    d.text(439, 462, "Image bytes / path", 17, label=True)
    d.line([(845, 380), (845, 490)])
    d.text(866, 440, "Image / per-cell image", 18, label=True)
    d.line([(845, 620), (845, 745)])
    d.text(866, 689, "Accepted plant image", 18, label=True)
    d.line([(845, 885), (845, 1020)])
    d.text(866, 956, ["Supported crop + image", "Stage 3 labels support the crop"], 17, label=True)
    d.line([(1120, 555), (1460, 555), (1460, 1010)])
    d.text(1265, 530, "Rejected / uncertain", 17, anchor="middle", label=True)
    d.line([(1120, 815), (1350, 815), (1350, 1010)])
    d.text(1265, 792, "Unsupported / uncertain", 17, anchor="middle", label=True)
    d.line([(1120, 1080), (1240, 1080)])
    d.text(1180, 1060, "Result", 17, anchor="middle", label=True)
    d.line([(1240, 1135), (1185, 1135), (1185, 1330), (965, 1330), (965, 1430)])
    d.text(972, 1368, "Successful result + image", 17, label=True)
    d.line([(1735, 1095), (1762, 1095), (1762, 1660), (210, 1660), (210, 1540)])
    d.text(1140, 1646, "Diagnosis / grid summary / retry feedback", 18, anchor="middle", label=True)
    d.line([(355, 1470), (570, 1470)])
    d.text(454, 1394, ["Location; Save request", "Location-choice edits"], 17, anchor="middle", label=True)
    d.line([(570, 1550), (355, 1550)])
    d.text(454, 1594, "Save status", 17, anchor="middle", label=True)
    d.line([(1120, 1460), (1240, 1460)])
    d.text(1190, 1394, ["Scan row / image", "Location choices"], 16, anchor="middle", label=True)
    d.line([(1240, 1545), (1120, 1545)])
    d.text(1370, 1620, "Saved image path / ID; location choices", 17, anchor="middle", label=True)
    # Asset reads use the left outer corridor to avoid the early-rejection flows.
    d.line([(1240, 300), (1180, 300), (1180, 195), (490, 195), (490, 1090), (570, 1090)])
    d.line([(490, 550), (570, 550)])
    d.line([(490, 815), (570, 815)])
    d.text(478, 670, ["D2 stage assets", "Models / labels / thresholds"], 16, anchor="end", label=True)
    d.note(65, 1730, 1670, 115, "Persistence boundary", [
        "Rejected, low-confidence and failed results remain temporary. Stage gates and alternatives are not written as separate database records.",
        "Grid saving can partially succeed; retry skips cells already saved. Saved history has no parent grid-session table or capture-group ID.",
    ])
    (DOCS / f"{d.name}.mmd").write_text('''flowchart TD
    U["E1 App user"] -->|"Mode / capture request"| P11("1.1 Prepare image; optional 2 x 3 split")
    P11 -->|"Capture / selection request"| C["E2 Camera / gallery"]
    C -->|"Image bytes / path"| P11
    P11 -->|"Single image or each of six tiles"| P12("1.2 Stage 1 plant gate")
    P12 -->|"Accepted plant image"| P13("1.3 Stage 2 supported-crop gate")
    P13 -->|"Supported crop + image"| P14("1.4 Stage 3 MobileNetV2 disease model; crop agreement")
    P12 -->|"Rejected / uncertain"| P15("1.5 Present results and grid summary")
    P13 -->|"Unsupported / uncertain"| P15
    P14 -->|"Condition / confidence / alternatives or rejection"| P15
    P15 -->|"Diagnosis / summary / retry feedback"| U
    P15 -->|"Successful result + image"| P16("1.6 Save successful result")
    U -->|"Location; explicit Save request; location-choice changes"| P16
    P16 -->|"Save status"| U
    P16 -->|"Scan row; copied image; location choices"| D1[("D1 Local persisted data")]
    D1 -->|"Saved ID / image path; location choices"| P16
    D2[("D2 Inference models / labels / thresholds")] -->|"Stage 1 assets"| P12
    D2 -->|"Stage 2 assets"| P13
    D2 -->|"Stage 3 assets"| P14
''', encoding="utf-8")
    return d.save()


def booklet(diagrams):
    pages = []
    for d in diagrams:
        content = (DOCS / f"{d.name}.svg").read_text(encoding="utf-8")
        orientation = "landscape" if d.width > d.height else "portrait"
        pages.append(f'<section class="{orientation}">{content}</section>')
    html = '''<!doctype html><html lang="en"><meta charset="utf-8">
<title>LeafLens - Updated ERD and data flow diagrams</title>
<style>
body{margin:0;background:#e6ece8}section{background:white;margin:24px auto;max-width:1200px}
svg{display:block;width:100%;height:auto}
@page landscape{size:A3 landscape;margin:8mm}
@page portrait{size:A3 portrait;margin:8mm}
@media print{body{background:white}section{margin:0;max-width:none;break-after:page;break-inside:avoid}
section:last-child{break-after:auto}.landscape{page:landscape;width:404mm;height:281mm}
.portrait{page:portrait;width:281mm;height:404mm}svg{width:100%;height:100%;object-fit:contain}}
</style><body>''' + '\n'.join(pages) + '</body></html>'
    (DOCS / "leaflens_system_diagrams.html").write_text(html, encoding="utf-8")


def render(diagrams):
    candidates = [os.environ.get("DIAGRAM_BROWSER", ""), shutil.which("chromium"),
                  shutil.which("google-chrome"), r"C:\Program Files\Google\Chrome\Application\chrome.exe",
                  r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"]
    browser = next((p for p in candidates if p and Path(p).is_file()), None)
    if not browser:
        raise SystemExit("SVG/HTML/Mermaid created. Set DIAGRAM_BROWSER to Chromium to export PNG/PDF.")
    profile = ROOT / "build/diagram_browser"
    # Only trusted, local generated SVG/HTML is opened. The restricted Windows
    # worker cannot launch Chromium's GPU sandbox, even with --disable-gpu.
    flags = [browser, "--headless", "--no-sandbox", "--disable-gpu", "--disable-software-rasterizer", "--no-first-run", "--no-default-browser-check",
             "--disable-extensions", "--disable-background-networking", "--disable-sync", "--hide-scrollbars",
             "--allow-file-access-from-files", f"--user-data-dir={profile}"]
    options = {"creationflags": subprocess.CREATE_NO_WINDOW} if os.name == "nt" else {}
    for d in diagrams:
        target = DOCS / f"{d.name}.png"
        result = subprocess.run(flags + [f"--screenshot={target}", f"--window-size={d.width},{d.height}",
                                        "--force-device-scale-factor=1", (DOCS / f"{d.name}.svg").as_uri()],
                                capture_output=True, timeout=60, **options)
        if result.returncode or not target.is_file():
            raise RuntimeError(f"PNG render failed: {result.stderr.decode(errors='replace')[-1800:]}")
        print(f"Rendered {target.relative_to(ROOT)}", flush=True)
    target = DOCS / "leaflens_system_diagrams.pdf"
    result = subprocess.run(flags + [f"--print-to-pdf={target}", "--no-pdf-header-footer",
                                    (DOCS / "leaflens_system_diagrams.html").as_uri()],
                            capture_output=True, timeout=60, **options)
    if result.returncode or not target.is_file():
        raise RuntimeError(f"PDF render failed: {result.stderr.decode(errors='replace')[-1800:]}")
    print(f"Rendered {target.relative_to(ROOT)}", flush=True)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--render", action="store_true")
    args = parser.parse_args()
    version, tables = schema()
    diagrams = [erd(version, tables), context(), level_one(), scan_detail()]
    booklet(diagrams)
    print("Generated 4 validated SVGs, Mermaid sources and the HTML booklet.", flush=True)
    if args.render:
        render(diagrams)
