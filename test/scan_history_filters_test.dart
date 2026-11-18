import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:thesis_app_ediwow/models/models.dart';
import 'package:thesis_app_ediwow/models/scan_history_filter.dart';
import 'package:thesis_app_ediwow/screens/scan_history_screen.dart';
import 'package:thesis_app_ediwow/services/scan_history_database.dart';
import 'package:thesis_app_ediwow/widgets/scan_history_filter_sheet.dart';

void main() {
  final scans = [
    _scan(1, 'Lettuce', 'Fungal', DateTime(2026, 11, 12)),
    _scan(2, 'Lettuce', 'Healthy', DateTime(2026, 11, 12, 23, 59, 59, 999)),
    _scan(3, 'Tomato', 'Leaf Mold', DateTime(2026, 11, 13)),
    _scan(4, 'Lettuce', 'Fungal', DateTime(2026, 11, 11, 23, 59, 59)),
    _scan(5, 'Tomato', 'Healthy', DateTime(2026, 11, 14)),
  ];

  test('date ranges include both complete boundary days', () {
    final filter = ScanHistoryFilter(
      startDate: DateTime(2026, 11, 12),
      endDate: DateTime(2026, 11, 12),
    );
    expect(filter.apply(scans).map((scan) => scan.id), [2, 1]);
  });

  test('date, crop, disease and health status combine', () {
    final filter = ScanHistoryFilter(
      crop: 'Lettuce',
      disease: 'Fungal',
      startDate: DateTime(2026, 11, 12),
      endDate: DateTime(2026, 11, 14),
    );
    expect(filter.apply(scans, status: 'Infected').map((scan) => scan.id), [1]);
    expect(filter.apply(scans, status: 'Healthy'), isEmpty);
    expect(filter.activeFilterCount, 3);
  });

  test('sorting changes direction without modifying saved records', () {
    expect(const ScanHistoryFilter().apply(scans).map((scan) => scan.id), [
      5,
      3,
      2,
      1,
      4,
    ]);
    expect(
      const ScanHistoryFilter(
        sort: ScanHistorySort.oldestFirst,
      ).apply(scans).map((scan) => scan.id),
      [4, 1, 2, 3, 5],
    );
    expect(scans.map((scan) => scan.id), [1, 2, 3, 4, 5]);
  });

  test('equal timestamps have stable sorting by record id', () {
    final tied = [
      _scan(10, 'Tomato', 'Healthy', DateTime(2026)),
      _scan(11, 'Tomato', 'Healthy', DateTime(2026)),
    ];
    expect(const ScanHistoryFilter().apply(tied).map((scan) => scan.id), [
      11,
      10,
    ]);
    expect(
      const ScanHistoryFilter(
        sort: ScanHistorySort.oldestFirst,
      ).apply(tied).map((scan) => scan.id),
      [10, 11],
    );
  });

  testWidgets(
    'applying filters updates records and clearing restores all scans',
    (tester) async {
      await _openHistory(tester, scans);
      expect(find.text('Showing 5 of 5 scans'), findsOneWidget);
      await tester.tap(find.byTooltip('Sort & Filter'));
      await tester.pumpAndSettle();
      await _choose(
        tester,
        find.byKey(const ValueKey('history-crop-null')),
        'Lettuce',
      );
      await _choose(
        tester,
        find.byKey(const ValueKey('history-disease-Lettuce-null')),
        'Fungal',
      );
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();
      expect(find.text('Showing 2 of 5 scans'), findsOneWidget);
      expect(find.text('Leaf Mold'), findsNothing);
      await tester.tap(find.text('Clear filters').first);
      await tester.pumpAndSettle();
      expect(find.text('Showing 5 of 5 scans'), findsOneWidget);
      expect(find.byTooltip('Sort & Filter'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('changing crop clears a disease that does not belong to it', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showScanHistoryFilters(
                context,
                scans: scans,
                initial: const ScanHistoryFilter(
                  crop: 'Lettuce',
                  disease: 'Fungal',
                ),
              ),
              child: const Text('Open filters'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();
    await _choose(
      tester,
      find.byKey(const ValueKey('history-crop-Lettuce')),
      'Tomato',
    );
    expect(
      find.byKey(const ValueKey('history-disease-Tomato-null')),
      findsOneWidget,
    );
    expect(find.text('Fungal'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('history-disease-Tomato-null')));
    await tester.pumpAndSettle();
    expect(find.text('Leaf Mold'), findsOneWidget);
    expect(find.text('Fungal'), findsNothing);
  });

  testWidgets('choosing a single day in the picker includes its late scans', (
    tester,
  ) async {
    await _openHistory(tester, scans);
    await tester.tap(find.byTooltip('Sort & Filter'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('history-date-range')));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    final dateFields = find.byType(TextField);
    expect(dateFields, findsNWidgets(2));
    await tester.enterText(dateFields.first, '11/12/2026');
    await tester.enterText(dateFields.last, '11/12/2026');
    await tester.tap(find.text('Use dates'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();
    expect(find.text('Showing 2 of 5 scans'), findsOneWidget);
    expect(find.text('Leaf Mold'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('date range and sort selections are applied from the sheet', (
    tester,
  ) async {
    ScanHistoryFilter? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                selected = await showScanHistoryFilters(
                  context,
                  scans: scans,
                  initial: ScanHistoryFilter(
                    startDate: DateTime(2026, 11, 12),
                    endDate: DateTime(2026, 11, 12),
                  ),
                );
              },
              child: const Text('Open filters'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open filters'));
    await tester.pumpAndSettle();
    await _choose(
      tester,
      find.byType(DropdownButtonFormField<ScanHistorySort>),
      'Oldest first',
    );
    await tester.tap(find.text('Apply Filters'));
    await tester.pumpAndSettle();
    expect(selected!.apply(scans).map((scan) => scan.id), [1, 2]);
  });

  testWidgets(
    'empty combinations can be cleared and filter changes clear selections',
    (tester) async {
      await _openHistory(tester, scans);
      await tester.longPress(find.text('Leaf Mold'));
      await tester.pumpAndSettle();
      expect(find.text('1 selected'), findsOneWidget);
      await tester.tap(find.byTooltip('Sort & Filter'));
      await tester.pumpAndSettle();
      await _choose(
        tester,
        find.byKey(const ValueKey('history-crop-null')),
        'Lettuce',
      );
      await _choose(
        tester,
        find.byKey(const ValueKey('history-disease-Lettuce-null')),
        'Fungal',
      );
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();
      expect(find.text('0 selected'), findsOneWidget);
      await tester.tap(find.byTooltip('Cancel selection'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('history-status-Healthy')));
      await tester.pumpAndSettle();
      expect(find.text('No matching scans'), findsOneWidget);
      await tester.tap(find.text('Clear filters').first);
      await tester.pumpAndSettle();
      expect(find.text('Showing 5 of 5 scans'), findsOneWidget);
    },
  );

  testWidgets(
    'filter sheet stays above system navigation and reset clears all criteria',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(320, 568));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      ScanHistoryFilter? selected;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: const EdgeInsets.only(bottom: 48),
              viewPadding: const EdgeInsets.only(bottom: 48),
            ),
            child: child!,
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  selected = await showScanHistoryFilters(
                    context,
                    scans: scans,
                    initial: ScanHistoryFilter(
                      crop: 'Lettuce',
                      disease: 'Fungal',
                      startDate: DateTime(2026, 11, 12),
                      endDate: DateTime(2026, 11, 12),
                      sort: ScanHistorySort.oldestFirst,
                    ),
                  );
                },
                child: const Text('Open filters'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open filters'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();
      expect(
        tester.getBottomRight(find.byType(ElevatedButton)).dy,
        lessThanOrEqualTo(568 - 48),
        reason: 'The apply button must stay above the system navigation area.',
      );
      await tester.tap(find.text('Apply Filters'));
      await tester.pumpAndSettle();
      expect(selected!.isDefault, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> _choose(WidgetTester tester, Finder field, String value) async {
  await tester.ensureVisible(field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text(value).last);
  await tester.pumpAndSettle();
}

Future<void> _openHistory(WidgetTester tester, List<ScanData> scans) async {
  final store = ScanHistoryDatabase.withFactory(
    _HistoryFactory(_HistoryDatabase(scans)),
  );
  await tester.pumpWidget(
    MaterialApp(home: ScanHistoryScreen(database: store)),
  );
  await tester.pumpAndSettle();
}

ScanData _scan(int id, String plant, String disease, DateTime captured) =>
    ScanData(
      id: id,
      plant: plant,
      disease: disease,
      status: disease == 'Healthy' ? 'Healthy' : 'Infected',
      confidence: .95,
      imagePath: 'missing_history_test.png',
      rawLabel: 'lettuce_fungal',
      classIndex: 5,
      capturedAt: captured,
      source: 'Camera',
      scanMode: 'Single',
      location: 'Greenhouse 2',
    );

class _HistoryFactory implements DatabaseFactory {
  _HistoryFactory(this.database);
  final Database database;
  @override
  Future<String> getDatabasesPath() async => '.';
  @override
  Future<Database> openDatabase(
    String path, {
    OpenDatabaseOptions? options,
  }) async => database;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _HistoryDatabase implements Database {
  _HistoryDatabase(this.scans);
  final List<ScanData> scans;
  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async => scans.map((scan) => scan.toMap()).toList();
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
