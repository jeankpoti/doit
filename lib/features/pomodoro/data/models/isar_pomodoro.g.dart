// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_pomodoro.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPomodoroSessionCollection on Isar {
  IsarCollection<PomodoroSession> get pomodoroSessions => this.collection();
}

const PomodoroSessionSchema = CollectionSchema(
  name: r'PomodoroSession',
  id: -896676171469707021,
  properties: {
    r'breakType': PropertySchema(
      id: 0,
      name: r'breakType',
      type: IsarType.string,
    ),
    r'dateTime': PropertySchema(
      id: 1,
      name: r'dateTime',
      type: IsarType.dateTime,
    ),
    r'duration': PropertySchema(
      id: 2,
      name: r'duration',
      type: IsarType.long,
    ),
    r'isBreak': PropertySchema(
      id: 3,
      name: r'isBreak',
      type: IsarType.bool,
    )
  },
  estimateSize: _pomodoroSessionEstimateSize,
  serialize: _pomodoroSessionSerialize,
  deserialize: _pomodoroSessionDeserialize,
  deserializeProp: _pomodoroSessionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _pomodoroSessionGetId,
  getLinks: _pomodoroSessionGetLinks,
  attach: _pomodoroSessionAttach,
  version: '3.1.0+1',
);

int _pomodoroSessionEstimateSize(
  PomodoroSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.breakType.length * 3;
  return bytesCount;
}

void _pomodoroSessionSerialize(
  PomodoroSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.breakType);
  writer.writeDateTime(offsets[1], object.dateTime);
  writer.writeLong(offsets[2], object.duration);
  writer.writeBool(offsets[3], object.isBreak);
}

PomodoroSession _pomodoroSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = PomodoroSession();
  object.breakType = reader.readString(offsets[0]);
  object.dateTime = reader.readDateTime(offsets[1]);
  object.duration = reader.readLong(offsets[2]);
  object.id = id;
  object.isBreak = reader.readBool(offsets[3]);
  return object;
}

P _pomodoroSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _pomodoroSessionGetId(PomodoroSession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _pomodoroSessionGetLinks(PomodoroSession object) {
  return [];
}

void _pomodoroSessionAttach(
    IsarCollection<dynamic> col, Id id, PomodoroSession object) {
  object.id = id;
}

extension PomodoroSessionQueryWhereSort
    on QueryBuilder<PomodoroSession, PomodoroSession, QWhere> {
  QueryBuilder<PomodoroSession, PomodoroSession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PomodoroSessionQueryWhere
    on QueryBuilder<PomodoroSession, PomodoroSession, QWhereClause> {
  QueryBuilder<PomodoroSession, PomodoroSession, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterWhereClause>
      idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PomodoroSessionQueryFilter
    on QueryBuilder<PomodoroSession, PomodoroSession, QFilterCondition> {
  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      breakTypeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'breakType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      breakTypeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'breakType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      breakTypeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'breakType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      breakTypeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'breakType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      breakTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'breakType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      breakTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'breakType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      breakTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'breakType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      breakTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'breakType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      breakTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'breakType',
        value: '',
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      breakTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'breakType',
        value: '',
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      dateTimeEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      dateTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      dateTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateTime',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      dateTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      durationEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      durationGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      durationLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'duration',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      durationBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'duration',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterFilterCondition>
      isBreakEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isBreak',
        value: value,
      ));
    });
  }
}

extension PomodoroSessionQueryObject
    on QueryBuilder<PomodoroSession, PomodoroSession, QFilterCondition> {}

extension PomodoroSessionQueryLinks
    on QueryBuilder<PomodoroSession, PomodoroSession, QFilterCondition> {}

extension PomodoroSessionQuerySortBy
    on QueryBuilder<PomodoroSession, PomodoroSession, QSortBy> {
  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy>
      sortByBreakType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakType', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy>
      sortByBreakTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakType', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy>
      sortByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy>
      sortByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy>
      sortByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy>
      sortByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy> sortByIsBreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBreak', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy>
      sortByIsBreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBreak', Sort.desc);
    });
  }
}

extension PomodoroSessionQuerySortThenBy
    on QueryBuilder<PomodoroSession, PomodoroSession, QSortThenBy> {
  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy>
      thenByBreakType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakType', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy>
      thenByBreakTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'breakType', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy>
      thenByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy>
      thenByDateTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateTime', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy>
      thenByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy>
      thenByDurationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'duration', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy> thenByIsBreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBreak', Sort.asc);
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QAfterSortBy>
      thenByIsBreakDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isBreak', Sort.desc);
    });
  }
}

extension PomodoroSessionQueryWhereDistinct
    on QueryBuilder<PomodoroSession, PomodoroSession, QDistinct> {
  QueryBuilder<PomodoroSession, PomodoroSession, QDistinct> distinctByBreakType(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'breakType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QDistinct>
      distinctByDateTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateTime');
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QDistinct>
      distinctByDuration() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'duration');
    });
  }

  QueryBuilder<PomodoroSession, PomodoroSession, QDistinct>
      distinctByIsBreak() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isBreak');
    });
  }
}

extension PomodoroSessionQueryProperty
    on QueryBuilder<PomodoroSession, PomodoroSession, QQueryProperty> {
  QueryBuilder<PomodoroSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<PomodoroSession, String, QQueryOperations> breakTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'breakType');
    });
  }

  QueryBuilder<PomodoroSession, DateTime, QQueryOperations> dateTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateTime');
    });
  }

  QueryBuilder<PomodoroSession, int, QQueryOperations> durationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'duration');
    });
  }

  QueryBuilder<PomodoroSession, bool, QQueryOperations> isBreakProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isBreak');
    });
  }
}
