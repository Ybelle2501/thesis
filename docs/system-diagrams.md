# LeafLens ERD and data flow diagrams

Implementation snapshot: **12 November 2026**. These diagrams describe the current reachable screens and services, including the added modules. They replace the earlier `leaflens_erd` and `leaflens_data_flow_diagram` exports. Older `database_schema` and `app_flowchart` files are historical diagrams.

Open the [complete PDF booklet](leaflens_system_diagrams.pdf) for printing, or the [standalone HTML booklet](leaflens_system_diagrams.html) for browsing. The PDF contains four vector pages with landscape or portrait A3 layouts.

| Diagram | View / print | Image | Editable source |
| --- | --- | --- | --- |
| Physical ERD | [SVG](leaflens_erd.svg) | [PNG](leaflens_erd.png) | [Mermaid](leaflens_erd.mmd) |
| DFD Level 0: system context | [SVG](leaflens_data_flow_context.svg) | [PNG](leaflens_data_flow_context.png) | [Mermaid](leaflens_data_flow_context.mmd) |
| DFD Level 1: application modules | [SVG](leaflens_data_flow_diagram.svg) | [PNG](leaflens_data_flow_diagram.png) | [Mermaid](leaflens_data_flow_diagram.mmd) |
| DFD Level 2: three-stage scanning | [SVG](leaflens_scan_data_flow.svg) | [PNG](leaflens_scan_data_flow.png) | [Mermaid](leaflens_scan_data_flow.mmd) |

## Physical ERD

The implemented database is `scan_history.db`, schema version **2**, with two independent tables:

- `scan_history`: all 13 implemented columns, including `location`, `scan_mode`, and nullable `grid_cell`. `status` has a SQL CHECK allowing `Healthy` and `Infected`. Indexes cover `captured_at DESC` and `status`.
- `app_metadata`: `key TEXT PRIMARY KEY` and `value TEXT NOT NULL`. Current application keys are `language`, `next_report_number`, and `farm_location_options_v1`.

There are **no foreign keys**. The dashed arrow to image files is an application file reference, not a relational association. Crops, diseases, farm locations, users, reports, grid sessions and forecasts have no dedicated SQL tables.

Location choices are a JSON array under `farm_location_options_v1`; each scan independently stores its location text. Renaming or removing a choice leaves saved scans unchanged. Existing scan tags seed the choice list once on upgraded installs. Locations can also be changed on individual history records.

A saved single scan has `grid_cell = NULL`. A 2 x 3 grid can create six independent rows, one for each successful cell the user saves. There is no parent grid/session record or shared capture identifier. Image files are copied into `scan_history_images/`, with the path recorded in `image_path`. A missing file is possible, including when restoring a backup whose original image was unavailable.

SQL types and constraints in the ERD come directly from the current CREATE TABLE statements. Notes such as grid cell range and explicit-save behavior describe application rules, not extra SQL constraints. The integer `captured_at` is the save timestamp assigned by `saveSuccessfulScan`, encoded as UTC epoch milliseconds.

## Data flow notation and scope

The diagrams use rounded processes, rectangular external entities, labeled directional arrows, and blue data stores with a left divider. Repeated IDs in Level 1 refer to the **same** actor or store, repeated to keep the flows readable. Mermaid sources preserve the semantic flows but can use a different layout and datastore shape when rendered.

External entities are E1 (app user / farm scout), E2 (camera/gallery), E3 (OS file services), and E4 (external browser). D1 groups the app's persistent storage at this level; its two SQL tables and file reference are expanded in the ERD.

| Store | Contents | Mutability |
| --- | --- | --- |
| D1 | `scan_history`, `app_metadata`, and saved scan images | Read/write |
| D2 | Stage 1 plant gate, Stage 2 crop gate, Stage 3 MobileNetV2; labels and thresholds | Bundled, read-only |
| D3 | Crop guides, source citations, PAGASA station normals and seasonal rules | Bundled, read-only |
| D4 | Forecast `model.json`, `historical_indicators.json`, and disease-name mapping | Bundled, read-only |

Level 1 groups the implementation into seven processes:

1. **Capture and diagnose:** camera/gallery input; single or six-cell scan; three-stage inference; temporary results; location selection; explicit successful-result saving.
2. **Manage scan history:** browse, search, filter, reopen, edit a record's location, and delete records with their copied images.
3. **Analyze and forecast:** home forecast cards, monthly scan-history series, report-dashboard statistics and filters, and current-month expected logged detections. Forecasts read three prior Manila-calendar months and bundled model/history assets. They are calculated in memory. Missing coverage and unmapped disease labels can suppress numeric forecasts. The current model declares `synthetic_demo` provenance; its values are prototype logged-detection estimates.
4. **Provide crop guidance:** crop/condition or scan-linked treatment and prevention, citations, and qualitative seasonal guidance from a selected station, month, and growing-site type. The seasonal selection is held in a session `ValueNotifier`; it is not persisted. Published reference URLs open in an external browser when requested. Station normals are bundled, without a live weather API.
5. **Export scouting report:** matching saved scans by normalized location, scout name, localized report text, summary counts and available infected-scan images. `next_report_number` increments in a transaction. Android writes the PDF to Downloads; other platforms use native sharing. PDFs and scout names are not inserted into a report table.
6. **Manage preferences:** English/Tagalog language and saved farm-location choices. Both persist in `app_metadata`; scan tags are read only to seed an initially missing location-choice list.
7. **Back up and restore:** Android `.leaflensbackup` ZIP export/import. The archive contains `manifest.json`, `scan_history.json`, `app_metadata.json`, and available image files. Restore validates compatibility and records, copies images to new local paths, and replaces both tables in a transaction. It replaces existing saved data rather than merging it.

Level 2 decomposes process 1.0. Every grid tile passes through the same pipeline as a single scan. Stage 1 requires a confident plant result; Stage 2 requires a confident supported crop; Stage 3 runs the 18-label disease classifier and checks crop agreement. Rejected and low-confidence results remain temporary. Saving requires success, a location and an explicit user action. Partial grid saves can be retried without duplicating cells already saved by that result screen.

## Implementation references

| Diagram topic | Primary source files |
| --- | --- |
| Schema, migration, images, save/delete, counter, restore | [scan_history_database.dart](../lib/services/scan_history_database.dart), [ScanData](../lib/models/models.dart) |
| Capture and pipeline | [scanner_screen.dart](../lib/screens/scanner_screen.dart), [three_stage_scan_service.dart](../lib/services/three_stage_scan_service.dart), [classifier.dart](../lib/services/classifier.dart), [grid_scan_service.dart](../lib/services/grid_scan_service.dart) |
| Save actions and history | [result_screen.dart](../lib/screens/result_screen.dart), [grid_result_screen.dart](../lib/screens/grid_result_screen.dart), [scan_history_screen.dart](../lib/screens/scan_history_screen.dart) |
| Analytics and forecasting | [reports_dashboard_screen.dart](../lib/screens/reports_dashboard_screen.dart), [papusoy_forecasting.dart](../lib/analytics/papusoy_forecasting.dart), [papusoy_scan_history_series.dart](../lib/analytics/papusoy_scan_history_series.dart), [model.json](../assets/analytics/model.json) |
| Guides, citations and seasonal selection | [crop_guides.dart](../lib/data/crop_guides.dart), [seasonal_risk.dart](../lib/services/seasonal_risk.dart), [seasonal_setup_card.dart](../lib/widgets/seasonal_setup_card.dart), [guide_sources.dart](../lib/widgets/guide_sources.dart) |
| PDF export | [report_export_screen.dart](../lib/screens/report_export_screen.dart), [pdf_report_service.dart](../lib/services/pdf_report_service.dart) |
| Settings and recovery | [farm_location_store.dart](../lib/services/farm_location_store.dart), [app_language.dart](../lib/l10n/app_language.dart), [settings_screen.dart](../lib/screens/settings_screen.dart), [data_backup_service.dart](../lib/services/data_backup_service.dart) |

`ReportsScreen.build` delegates to `ReportsDashboardScreen`; the old placeholder body below it is unused. The reachable history screen is `screens/scan_history_screen.dart`. The diagrams follow those active implementations.

## Regenerate

The generator uses Python's standard library. It executes the extracted CREATE TABLE definitions in an in-memory SQLite database to obtain the ERD columns and check that no foreign-key relationships exist. Process grouping, data-flow labels and layout are curated and must be reviewed if behavior changes.

```powershell
python tools/generate_app_diagrams.py
python tools/generate_app_diagrams.py --render
```

The first command writes SVG, Mermaid and standalone HTML. `--render` also exports PNG images and the PDF using installed Chrome/Chromium/Edge. Set `DIAGRAM_BROWSER` to a browser executable if automatic discovery does not find it. Rendering opens only generated local files in an isolated profile under the ignored `build/` directory.
