// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, Book> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isbnMeta = const VerificationMeta('isbn');
  @override
  late final GeneratedColumn<String> isbn = GeneratedColumn<String>(
    'isbn',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _seriesMeta = const VerificationMeta('series');
  @override
  late final GeneratedColumn<String> series = GeneratedColumn<String>(
    'series',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _seriesNumberMeta = const VerificationMeta(
    'seriesNumber',
  );
  @override
  late final GeneratedColumn<double> seriesNumber = GeneratedColumn<double>(
    'series_number',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seriesTotalMeta = const VerificationMeta(
    'seriesTotal',
  );
  @override
  late final GeneratedColumn<int> seriesTotal = GeneratedColumn<int>(
    'series_total',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publisherMeta = const VerificationMeta(
    'publisher',
  );
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
    'publisher',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pagesMeta = const VerificationMeta('pages');
  @override
  late final GeneratedColumn<int> pages = GeneratedColumn<int>(
    'pages',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _addedMeta = const VerificationMeta('added');
  @override
  late final GeneratedColumn<DateTime> added = GeneratedColumn<DateTime>(
    'added',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _queuePosMeta = const VerificationMeta(
    'queuePos',
  );
  @override
  late final GeneratedColumn<int> queuePos = GeneratedColumn<int>(
    'queue_pos',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ownedMeta = const VerificationMeta('owned');
  @override
  late final GeneratedColumn<bool> owned = GeneratedColumn<bool>(
    'owned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("owned" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    author,
    isbn,
    coverUrl,
    genre,
    series,
    seriesNumber,
    seriesTotal,
    publisher,
    year,
    pages,
    description,
    tags,
    notes,
    locked,
    added,
    deletedAt,
    queuePos,
    kind,
    owned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<Book> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('isbn')) {
      context.handle(
        _isbnMeta,
        isbn.isAcceptableOrUnknown(data['isbn']!, _isbnMeta),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('series')) {
      context.handle(
        _seriesMeta,
        series.isAcceptableOrUnknown(data['series']!, _seriesMeta),
      );
    }
    if (data.containsKey('series_number')) {
      context.handle(
        _seriesNumberMeta,
        seriesNumber.isAcceptableOrUnknown(
          data['series_number']!,
          _seriesNumberMeta,
        ),
      );
    }
    if (data.containsKey('series_total')) {
      context.handle(
        _seriesTotalMeta,
        seriesTotal.isAcceptableOrUnknown(
          data['series_total']!,
          _seriesTotalMeta,
        ),
      );
    }
    if (data.containsKey('publisher')) {
      context.handle(
        _publisherMeta,
        publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('pages')) {
      context.handle(
        _pagesMeta,
        pages.isAcceptableOrUnknown(data['pages']!, _pagesMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('locked')) {
      context.handle(
        _lockedMeta,
        locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta),
      );
    }
    if (data.containsKey('added')) {
      context.handle(
        _addedMeta,
        added.isAcceptableOrUnknown(data['added']!, _addedMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('queue_pos')) {
      context.handle(
        _queuePosMeta,
        queuePos.isAcceptableOrUnknown(data['queue_pos']!, _queuePosMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('owned')) {
      context.handle(
        _ownedMeta,
        owned.isAcceptableOrUnknown(data['owned']!, _ownedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Book map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Book(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      isbn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isbn'],
      )!,
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      )!,
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      )!,
      series: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}series'],
      )!,
      seriesNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}series_number'],
      ),
      seriesTotal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_total'],
      ),
      publisher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publisher'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      pages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pages'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      )!,
      added: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      queuePos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}queue_pos'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      owned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}owned'],
      )!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class Book extends DataClass implements Insertable<Book> {
  final int id;
  final String title;
  final String author;
  final String isbn;
  final String coverUrl;
  final String genre;
  final String series;
  final double? seriesNumber;
  final int? seriesTotal;
  final String publisher;
  final int? year;
  final int? pages;
  final String description;
  final String tags;
  final String notes;
  final bool locked;
  final DateTime added;
  final DateTime? deletedAt;
  final int? queuePos;
  final String kind;
  final bool owned;
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.coverUrl,
    required this.genre,
    required this.series,
    this.seriesNumber,
    this.seriesTotal,
    required this.publisher,
    this.year,
    this.pages,
    required this.description,
    required this.tags,
    required this.notes,
    required this.locked,
    required this.added,
    this.deletedAt,
    this.queuePos,
    required this.kind,
    required this.owned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['author'] = Variable<String>(author);
    map['isbn'] = Variable<String>(isbn);
    map['cover_url'] = Variable<String>(coverUrl);
    map['genre'] = Variable<String>(genre);
    map['series'] = Variable<String>(series);
    if (!nullToAbsent || seriesNumber != null) {
      map['series_number'] = Variable<double>(seriesNumber);
    }
    if (!nullToAbsent || seriesTotal != null) {
      map['series_total'] = Variable<int>(seriesTotal);
    }
    map['publisher'] = Variable<String>(publisher);
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || pages != null) {
      map['pages'] = Variable<int>(pages);
    }
    map['description'] = Variable<String>(description);
    map['tags'] = Variable<String>(tags);
    map['notes'] = Variable<String>(notes);
    map['locked'] = Variable<bool>(locked);
    map['added'] = Variable<DateTime>(added);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    if (!nullToAbsent || queuePos != null) {
      map['queue_pos'] = Variable<int>(queuePos);
    }
    map['kind'] = Variable<String>(kind);
    map['owned'] = Variable<bool>(owned);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      author: Value(author),
      isbn: Value(isbn),
      coverUrl: Value(coverUrl),
      genre: Value(genre),
      series: Value(series),
      seriesNumber: seriesNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesNumber),
      seriesTotal: seriesTotal == null && nullToAbsent
          ? const Value.absent()
          : Value(seriesTotal),
      publisher: Value(publisher),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      pages: pages == null && nullToAbsent
          ? const Value.absent()
          : Value(pages),
      description: Value(description),
      tags: Value(tags),
      notes: Value(notes),
      locked: Value(locked),
      added: Value(added),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      queuePos: queuePos == null && nullToAbsent
          ? const Value.absent()
          : Value(queuePos),
      kind: Value(kind),
      owned: Value(owned),
    );
  }

  factory Book.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Book(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String>(json['author']),
      isbn: serializer.fromJson<String>(json['isbn']),
      coverUrl: serializer.fromJson<String>(json['coverUrl']),
      genre: serializer.fromJson<String>(json['genre']),
      series: serializer.fromJson<String>(json['series']),
      seriesNumber: serializer.fromJson<double?>(json['seriesNumber']),
      seriesTotal: serializer.fromJson<int?>(json['seriesTotal']),
      publisher: serializer.fromJson<String>(json['publisher']),
      year: serializer.fromJson<int?>(json['year']),
      pages: serializer.fromJson<int?>(json['pages']),
      description: serializer.fromJson<String>(json['description']),
      tags: serializer.fromJson<String>(json['tags']),
      notes: serializer.fromJson<String>(json['notes']),
      locked: serializer.fromJson<bool>(json['locked']),
      added: serializer.fromJson<DateTime>(json['added']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      queuePos: serializer.fromJson<int?>(json['queuePos']),
      kind: serializer.fromJson<String>(json['kind']),
      owned: serializer.fromJson<bool>(json['owned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String>(author),
      'isbn': serializer.toJson<String>(isbn),
      'coverUrl': serializer.toJson<String>(coverUrl),
      'genre': serializer.toJson<String>(genre),
      'series': serializer.toJson<String>(series),
      'seriesNumber': serializer.toJson<double?>(seriesNumber),
      'seriesTotal': serializer.toJson<int?>(seriesTotal),
      'publisher': serializer.toJson<String>(publisher),
      'year': serializer.toJson<int?>(year),
      'pages': serializer.toJson<int?>(pages),
      'description': serializer.toJson<String>(description),
      'tags': serializer.toJson<String>(tags),
      'notes': serializer.toJson<String>(notes),
      'locked': serializer.toJson<bool>(locked),
      'added': serializer.toJson<DateTime>(added),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'queuePos': serializer.toJson<int?>(queuePos),
      'kind': serializer.toJson<String>(kind),
      'owned': serializer.toJson<bool>(owned),
    };
  }

  Book copyWith({
    int? id,
    String? title,
    String? author,
    String? isbn,
    String? coverUrl,
    String? genre,
    String? series,
    Value<double?> seriesNumber = const Value.absent(),
    Value<int?> seriesTotal = const Value.absent(),
    String? publisher,
    Value<int?> year = const Value.absent(),
    Value<int?> pages = const Value.absent(),
    String? description,
    String? tags,
    String? notes,
    bool? locked,
    DateTime? added,
    Value<DateTime?> deletedAt = const Value.absent(),
    Value<int?> queuePos = const Value.absent(),
    String? kind,
    bool? owned,
  }) => Book(
    id: id ?? this.id,
    title: title ?? this.title,
    author: author ?? this.author,
    isbn: isbn ?? this.isbn,
    coverUrl: coverUrl ?? this.coverUrl,
    genre: genre ?? this.genre,
    series: series ?? this.series,
    seriesNumber: seriesNumber.present ? seriesNumber.value : this.seriesNumber,
    seriesTotal: seriesTotal.present ? seriesTotal.value : this.seriesTotal,
    publisher: publisher ?? this.publisher,
    year: year.present ? year.value : this.year,
    pages: pages.present ? pages.value : this.pages,
    description: description ?? this.description,
    tags: tags ?? this.tags,
    notes: notes ?? this.notes,
    locked: locked ?? this.locked,
    added: added ?? this.added,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    queuePos: queuePos.present ? queuePos.value : this.queuePos,
    kind: kind ?? this.kind,
    owned: owned ?? this.owned,
  );
  Book copyWithCompanion(BooksCompanion data) {
    return Book(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      isbn: data.isbn.present ? data.isbn.value : this.isbn,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      genre: data.genre.present ? data.genre.value : this.genre,
      series: data.series.present ? data.series.value : this.series,
      seriesNumber: data.seriesNumber.present
          ? data.seriesNumber.value
          : this.seriesNumber,
      seriesTotal: data.seriesTotal.present
          ? data.seriesTotal.value
          : this.seriesTotal,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      year: data.year.present ? data.year.value : this.year,
      pages: data.pages.present ? data.pages.value : this.pages,
      description: data.description.present
          ? data.description.value
          : this.description,
      tags: data.tags.present ? data.tags.value : this.tags,
      notes: data.notes.present ? data.notes.value : this.notes,
      locked: data.locked.present ? data.locked.value : this.locked,
      added: data.added.present ? data.added.value : this.added,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      queuePos: data.queuePos.present ? data.queuePos.value : this.queuePos,
      kind: data.kind.present ? data.kind.value : this.kind,
      owned: data.owned.present ? data.owned.value : this.owned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Book(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('isbn: $isbn, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('genre: $genre, ')
          ..write('series: $series, ')
          ..write('seriesNumber: $seriesNumber, ')
          ..write('seriesTotal: $seriesTotal, ')
          ..write('publisher: $publisher, ')
          ..write('year: $year, ')
          ..write('pages: $pages, ')
          ..write('description: $description, ')
          ..write('tags: $tags, ')
          ..write('notes: $notes, ')
          ..write('locked: $locked, ')
          ..write('added: $added, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('queuePos: $queuePos, ')
          ..write('kind: $kind, ')
          ..write('owned: $owned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    title,
    author,
    isbn,
    coverUrl,
    genre,
    series,
    seriesNumber,
    seriesTotal,
    publisher,
    year,
    pages,
    description,
    tags,
    notes,
    locked,
    added,
    deletedAt,
    queuePos,
    kind,
    owned,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Book &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.isbn == this.isbn &&
          other.coverUrl == this.coverUrl &&
          other.genre == this.genre &&
          other.series == this.series &&
          other.seriesNumber == this.seriesNumber &&
          other.seriesTotal == this.seriesTotal &&
          other.publisher == this.publisher &&
          other.year == this.year &&
          other.pages == this.pages &&
          other.description == this.description &&
          other.tags == this.tags &&
          other.notes == this.notes &&
          other.locked == this.locked &&
          other.added == this.added &&
          other.deletedAt == this.deletedAt &&
          other.queuePos == this.queuePos &&
          other.kind == this.kind &&
          other.owned == this.owned);
}

class BooksCompanion extends UpdateCompanion<Book> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> author;
  final Value<String> isbn;
  final Value<String> coverUrl;
  final Value<String> genre;
  final Value<String> series;
  final Value<double?> seriesNumber;
  final Value<int?> seriesTotal;
  final Value<String> publisher;
  final Value<int?> year;
  final Value<int?> pages;
  final Value<String> description;
  final Value<String> tags;
  final Value<String> notes;
  final Value<bool> locked;
  final Value<DateTime> added;
  final Value<DateTime?> deletedAt;
  final Value<int?> queuePos;
  final Value<String> kind;
  final Value<bool> owned;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.isbn = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.genre = const Value.absent(),
    this.series = const Value.absent(),
    this.seriesNumber = const Value.absent(),
    this.seriesTotal = const Value.absent(),
    this.publisher = const Value.absent(),
    this.year = const Value.absent(),
    this.pages = const Value.absent(),
    this.description = const Value.absent(),
    this.tags = const Value.absent(),
    this.notes = const Value.absent(),
    this.locked = const Value.absent(),
    this.added = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.queuePos = const Value.absent(),
    this.kind = const Value.absent(),
    this.owned = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.author = const Value.absent(),
    this.isbn = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.genre = const Value.absent(),
    this.series = const Value.absent(),
    this.seriesNumber = const Value.absent(),
    this.seriesTotal = const Value.absent(),
    this.publisher = const Value.absent(),
    this.year = const Value.absent(),
    this.pages = const Value.absent(),
    this.description = const Value.absent(),
    this.tags = const Value.absent(),
    this.notes = const Value.absent(),
    this.locked = const Value.absent(),
    this.added = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.queuePos = const Value.absent(),
    this.kind = const Value.absent(),
    this.owned = const Value.absent(),
  }) : title = Value(title);
  static Insertable<Book> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? isbn,
    Expression<String>? coverUrl,
    Expression<String>? genre,
    Expression<String>? series,
    Expression<double>? seriesNumber,
    Expression<int>? seriesTotal,
    Expression<String>? publisher,
    Expression<int>? year,
    Expression<int>? pages,
    Expression<String>? description,
    Expression<String>? tags,
    Expression<String>? notes,
    Expression<bool>? locked,
    Expression<DateTime>? added,
    Expression<DateTime>? deletedAt,
    Expression<int>? queuePos,
    Expression<String>? kind,
    Expression<bool>? owned,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (isbn != null) 'isbn': isbn,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (genre != null) 'genre': genre,
      if (series != null) 'series': series,
      if (seriesNumber != null) 'series_number': seriesNumber,
      if (seriesTotal != null) 'series_total': seriesTotal,
      if (publisher != null) 'publisher': publisher,
      if (year != null) 'year': year,
      if (pages != null) 'pages': pages,
      if (description != null) 'description': description,
      if (tags != null) 'tags': tags,
      if (notes != null) 'notes': notes,
      if (locked != null) 'locked': locked,
      if (added != null) 'added': added,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (queuePos != null) 'queue_pos': queuePos,
      if (kind != null) 'kind': kind,
      if (owned != null) 'owned': owned,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? author,
    Value<String>? isbn,
    Value<String>? coverUrl,
    Value<String>? genre,
    Value<String>? series,
    Value<double?>? seriesNumber,
    Value<int?>? seriesTotal,
    Value<String>? publisher,
    Value<int?>? year,
    Value<int?>? pages,
    Value<String>? description,
    Value<String>? tags,
    Value<String>? notes,
    Value<bool>? locked,
    Value<DateTime>? added,
    Value<DateTime?>? deletedAt,
    Value<int?>? queuePos,
    Value<String>? kind,
    Value<bool>? owned,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      coverUrl: coverUrl ?? this.coverUrl,
      genre: genre ?? this.genre,
      series: series ?? this.series,
      seriesNumber: seriesNumber ?? this.seriesNumber,
      seriesTotal: seriesTotal ?? this.seriesTotal,
      publisher: publisher ?? this.publisher,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      locked: locked ?? this.locked,
      added: added ?? this.added,
      deletedAt: deletedAt ?? this.deletedAt,
      queuePos: queuePos ?? this.queuePos,
      kind: kind ?? this.kind,
      owned: owned ?? this.owned,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (isbn.present) {
      map['isbn'] = Variable<String>(isbn.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (series.present) {
      map['series'] = Variable<String>(series.value);
    }
    if (seriesNumber.present) {
      map['series_number'] = Variable<double>(seriesNumber.value);
    }
    if (seriesTotal.present) {
      map['series_total'] = Variable<int>(seriesTotal.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (pages.present) {
      map['pages'] = Variable<int>(pages.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    if (added.present) {
      map['added'] = Variable<DateTime>(added.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (queuePos.present) {
      map['queue_pos'] = Variable<int>(queuePos.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (owned.present) {
      map['owned'] = Variable<bool>(owned.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('isbn: $isbn, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('genre: $genre, ')
          ..write('series: $series, ')
          ..write('seriesNumber: $seriesNumber, ')
          ..write('seriesTotal: $seriesTotal, ')
          ..write('publisher: $publisher, ')
          ..write('year: $year, ')
          ..write('pages: $pages, ')
          ..write('description: $description, ')
          ..write('tags: $tags, ')
          ..write('notes: $notes, ')
          ..write('locked: $locked, ')
          ..write('added: $added, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('queuePos: $queuePos, ')
          ..write('kind: $kind, ')
          ..write('owned: $owned')
          ..write(')'))
        .toString();
  }
}

class $ReadsTable extends Reads with TableInfo<$ReadsTable, Read> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('print'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('want'),
  );
  static const VerificationMeta _startedMeta = const VerificationMeta(
    'started',
  );
  @override
  late final GeneratedColumn<DateTime> started = GeneratedColumn<DateTime>(
    'started',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finishedMeta = const VerificationMeta(
    'finished',
  );
  @override
  late final GeneratedColumn<DateTime> finished = GeneratedColumn<DateTime>(
    'finished',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thoughtsMeta = const VerificationMeta(
    'thoughts',
  );
  @override
  late final GeneratedColumn<String> thoughts = GeneratedColumn<String>(
    'thoughts',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _narratorMeta = const VerificationMeta(
    'narrator',
  );
  @override
  late final GeneratedColumn<String> narrator = GeneratedColumn<String>(
    'narrator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _minutesMeta = const VerificationMeta(
    'minutes',
  );
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
    'minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentPageMeta = const VerificationMeta(
    'currentPage',
  );
  @override
  late final GeneratedColumn<int> currentPage = GeneratedColumn<int>(
    'current_page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heatMeta = const VerificationMeta('heat');
  @override
  late final GeneratedColumn<int> heat = GeneratedColumn<int>(
    'heat',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentNotesMeta = const VerificationMeta(
    'contentNotes',
  );
  @override
  late final GeneratedColumn<String> contentNotes = GeneratedColumn<String>(
    'content_notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ratingStoryMeta = const VerificationMeta(
    'ratingStory',
  );
  @override
  late final GeneratedColumn<double> ratingStory = GeneratedColumn<double>(
    'rating_story',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingCharactersMeta = const VerificationMeta(
    'ratingCharacters',
  );
  @override
  late final GeneratedColumn<double> ratingCharacters = GeneratedColumn<double>(
    'rating_characters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingWritingMeta = const VerificationMeta(
    'ratingWriting',
  );
  @override
  late final GeneratedColumn<double> ratingWriting = GeneratedColumn<double>(
    'rating_writing',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingPaceMeta = const VerificationMeta(
    'ratingPace',
  );
  @override
  late final GeneratedColumn<double> ratingPace = GeneratedColumn<double>(
    'rating_pace',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingFeelingMeta = const VerificationMeta(
    'ratingFeeling',
  );
  @override
  late final GeneratedColumn<double> ratingFeeling = GeneratedColumn<double>(
    'rating_feeling',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ratingNarratorMeta = const VerificationMeta(
    'ratingNarrator',
  );
  @override
  late final GeneratedColumn<double> ratingNarrator = GeneratedColumn<double>(
    'rating_narrator',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    format,
    status,
    started,
    finished,
    rating,
    thoughts,
    narrator,
    minutes,
    currentPage,
    heat,
    contentNotes,
    ratingStory,
    ratingCharacters,
    ratingWriting,
    ratingPace,
    ratingFeeling,
    ratingNarrator,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reads';
  @override
  VerificationContext validateIntegrity(
    Insertable<Read> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('started')) {
      context.handle(
        _startedMeta,
        started.isAcceptableOrUnknown(data['started']!, _startedMeta),
      );
    }
    if (data.containsKey('finished')) {
      context.handle(
        _finishedMeta,
        finished.isAcceptableOrUnknown(data['finished']!, _finishedMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('thoughts')) {
      context.handle(
        _thoughtsMeta,
        thoughts.isAcceptableOrUnknown(data['thoughts']!, _thoughtsMeta),
      );
    }
    if (data.containsKey('narrator')) {
      context.handle(
        _narratorMeta,
        narrator.isAcceptableOrUnknown(data['narrator']!, _narratorMeta),
      );
    }
    if (data.containsKey('minutes')) {
      context.handle(
        _minutesMeta,
        minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta),
      );
    }
    if (data.containsKey('current_page')) {
      context.handle(
        _currentPageMeta,
        currentPage.isAcceptableOrUnknown(
          data['current_page']!,
          _currentPageMeta,
        ),
      );
    }
    if (data.containsKey('heat')) {
      context.handle(
        _heatMeta,
        heat.isAcceptableOrUnknown(data['heat']!, _heatMeta),
      );
    }
    if (data.containsKey('content_notes')) {
      context.handle(
        _contentNotesMeta,
        contentNotes.isAcceptableOrUnknown(
          data['content_notes']!,
          _contentNotesMeta,
        ),
      );
    }
    if (data.containsKey('rating_story')) {
      context.handle(
        _ratingStoryMeta,
        ratingStory.isAcceptableOrUnknown(
          data['rating_story']!,
          _ratingStoryMeta,
        ),
      );
    }
    if (data.containsKey('rating_characters')) {
      context.handle(
        _ratingCharactersMeta,
        ratingCharacters.isAcceptableOrUnknown(
          data['rating_characters']!,
          _ratingCharactersMeta,
        ),
      );
    }
    if (data.containsKey('rating_writing')) {
      context.handle(
        _ratingWritingMeta,
        ratingWriting.isAcceptableOrUnknown(
          data['rating_writing']!,
          _ratingWritingMeta,
        ),
      );
    }
    if (data.containsKey('rating_pace')) {
      context.handle(
        _ratingPaceMeta,
        ratingPace.isAcceptableOrUnknown(data['rating_pace']!, _ratingPaceMeta),
      );
    }
    if (data.containsKey('rating_feeling')) {
      context.handle(
        _ratingFeelingMeta,
        ratingFeeling.isAcceptableOrUnknown(
          data['rating_feeling']!,
          _ratingFeelingMeta,
        ),
      );
    }
    if (data.containsKey('rating_narrator')) {
      context.handle(
        _ratingNarratorMeta,
        ratingNarrator.isAcceptableOrUnknown(
          data['rating_narrator']!,
          _ratingNarratorMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Read map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Read(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      started: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started'],
      ),
      finished: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished'],
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      thoughts: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thoughts'],
      )!,
      narrator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}narrator'],
      )!,
      minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes'],
      ),
      currentPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_page'],
      ),
      heat: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}heat'],
      ),
      contentNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_notes'],
      )!,
      ratingStory: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating_story'],
      ),
      ratingCharacters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating_characters'],
      ),
      ratingWriting: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating_writing'],
      ),
      ratingPace: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating_pace'],
      ),
      ratingFeeling: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating_feeling'],
      ),
      ratingNarrator: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating_narrator'],
      ),
    );
  }

  @override
  $ReadsTable createAlias(String alias) {
    return $ReadsTable(attachedDatabase, alias);
  }
}

class Read extends DataClass implements Insertable<Read> {
  final int id;
  final int bookId;
  final String format;
  final String status;
  final DateTime? started;
  final DateTime? finished;
  final double? rating;
  final String thoughts;
  final String narrator;
  final int? minutes;
  final int? currentPage;
  final int? heat;
  final String contentNotes;
  final double? ratingStory;
  final double? ratingCharacters;
  final double? ratingWriting;
  final double? ratingPace;
  final double? ratingFeeling;
  final double? ratingNarrator;
  const Read({
    required this.id,
    required this.bookId,
    required this.format,
    required this.status,
    this.started,
    this.finished,
    this.rating,
    required this.thoughts,
    required this.narrator,
    this.minutes,
    this.currentPage,
    this.heat,
    required this.contentNotes,
    this.ratingStory,
    this.ratingCharacters,
    this.ratingWriting,
    this.ratingPace,
    this.ratingFeeling,
    this.ratingNarrator,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['format'] = Variable<String>(format);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || started != null) {
      map['started'] = Variable<DateTime>(started);
    }
    if (!nullToAbsent || finished != null) {
      map['finished'] = Variable<DateTime>(finished);
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    map['thoughts'] = Variable<String>(thoughts);
    map['narrator'] = Variable<String>(narrator);
    if (!nullToAbsent || minutes != null) {
      map['minutes'] = Variable<int>(minutes);
    }
    if (!nullToAbsent || currentPage != null) {
      map['current_page'] = Variable<int>(currentPage);
    }
    if (!nullToAbsent || heat != null) {
      map['heat'] = Variable<int>(heat);
    }
    map['content_notes'] = Variable<String>(contentNotes);
    if (!nullToAbsent || ratingStory != null) {
      map['rating_story'] = Variable<double>(ratingStory);
    }
    if (!nullToAbsent || ratingCharacters != null) {
      map['rating_characters'] = Variable<double>(ratingCharacters);
    }
    if (!nullToAbsent || ratingWriting != null) {
      map['rating_writing'] = Variable<double>(ratingWriting);
    }
    if (!nullToAbsent || ratingPace != null) {
      map['rating_pace'] = Variable<double>(ratingPace);
    }
    if (!nullToAbsent || ratingFeeling != null) {
      map['rating_feeling'] = Variable<double>(ratingFeeling);
    }
    if (!nullToAbsent || ratingNarrator != null) {
      map['rating_narrator'] = Variable<double>(ratingNarrator);
    }
    return map;
  }

  ReadsCompanion toCompanion(bool nullToAbsent) {
    return ReadsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      format: Value(format),
      status: Value(status),
      started: started == null && nullToAbsent
          ? const Value.absent()
          : Value(started),
      finished: finished == null && nullToAbsent
          ? const Value.absent()
          : Value(finished),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      thoughts: Value(thoughts),
      narrator: Value(narrator),
      minutes: minutes == null && nullToAbsent
          ? const Value.absent()
          : Value(minutes),
      currentPage: currentPage == null && nullToAbsent
          ? const Value.absent()
          : Value(currentPage),
      heat: heat == null && nullToAbsent ? const Value.absent() : Value(heat),
      contentNotes: Value(contentNotes),
      ratingStory: ratingStory == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingStory),
      ratingCharacters: ratingCharacters == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingCharacters),
      ratingWriting: ratingWriting == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingWriting),
      ratingPace: ratingPace == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingPace),
      ratingFeeling: ratingFeeling == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingFeeling),
      ratingNarrator: ratingNarrator == null && nullToAbsent
          ? const Value.absent()
          : Value(ratingNarrator),
    );
  }

  factory Read.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Read(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      format: serializer.fromJson<String>(json['format']),
      status: serializer.fromJson<String>(json['status']),
      started: serializer.fromJson<DateTime?>(json['started']),
      finished: serializer.fromJson<DateTime?>(json['finished']),
      rating: serializer.fromJson<double?>(json['rating']),
      thoughts: serializer.fromJson<String>(json['thoughts']),
      narrator: serializer.fromJson<String>(json['narrator']),
      minutes: serializer.fromJson<int?>(json['minutes']),
      currentPage: serializer.fromJson<int?>(json['currentPage']),
      heat: serializer.fromJson<int?>(json['heat']),
      contentNotes: serializer.fromJson<String>(json['contentNotes']),
      ratingStory: serializer.fromJson<double?>(json['ratingStory']),
      ratingCharacters: serializer.fromJson<double?>(json['ratingCharacters']),
      ratingWriting: serializer.fromJson<double?>(json['ratingWriting']),
      ratingPace: serializer.fromJson<double?>(json['ratingPace']),
      ratingFeeling: serializer.fromJson<double?>(json['ratingFeeling']),
      ratingNarrator: serializer.fromJson<double?>(json['ratingNarrator']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'format': serializer.toJson<String>(format),
      'status': serializer.toJson<String>(status),
      'started': serializer.toJson<DateTime?>(started),
      'finished': serializer.toJson<DateTime?>(finished),
      'rating': serializer.toJson<double?>(rating),
      'thoughts': serializer.toJson<String>(thoughts),
      'narrator': serializer.toJson<String>(narrator),
      'minutes': serializer.toJson<int?>(minutes),
      'currentPage': serializer.toJson<int?>(currentPage),
      'heat': serializer.toJson<int?>(heat),
      'contentNotes': serializer.toJson<String>(contentNotes),
      'ratingStory': serializer.toJson<double?>(ratingStory),
      'ratingCharacters': serializer.toJson<double?>(ratingCharacters),
      'ratingWriting': serializer.toJson<double?>(ratingWriting),
      'ratingPace': serializer.toJson<double?>(ratingPace),
      'ratingFeeling': serializer.toJson<double?>(ratingFeeling),
      'ratingNarrator': serializer.toJson<double?>(ratingNarrator),
    };
  }

  Read copyWith({
    int? id,
    int? bookId,
    String? format,
    String? status,
    Value<DateTime?> started = const Value.absent(),
    Value<DateTime?> finished = const Value.absent(),
    Value<double?> rating = const Value.absent(),
    String? thoughts,
    String? narrator,
    Value<int?> minutes = const Value.absent(),
    Value<int?> currentPage = const Value.absent(),
    Value<int?> heat = const Value.absent(),
    String? contentNotes,
    Value<double?> ratingStory = const Value.absent(),
    Value<double?> ratingCharacters = const Value.absent(),
    Value<double?> ratingWriting = const Value.absent(),
    Value<double?> ratingPace = const Value.absent(),
    Value<double?> ratingFeeling = const Value.absent(),
    Value<double?> ratingNarrator = const Value.absent(),
  }) => Read(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    format: format ?? this.format,
    status: status ?? this.status,
    started: started.present ? started.value : this.started,
    finished: finished.present ? finished.value : this.finished,
    rating: rating.present ? rating.value : this.rating,
    thoughts: thoughts ?? this.thoughts,
    narrator: narrator ?? this.narrator,
    minutes: minutes.present ? minutes.value : this.minutes,
    currentPage: currentPage.present ? currentPage.value : this.currentPage,
    heat: heat.present ? heat.value : this.heat,
    contentNotes: contentNotes ?? this.contentNotes,
    ratingStory: ratingStory.present ? ratingStory.value : this.ratingStory,
    ratingCharacters: ratingCharacters.present
        ? ratingCharacters.value
        : this.ratingCharacters,
    ratingWriting: ratingWriting.present
        ? ratingWriting.value
        : this.ratingWriting,
    ratingPace: ratingPace.present ? ratingPace.value : this.ratingPace,
    ratingFeeling: ratingFeeling.present
        ? ratingFeeling.value
        : this.ratingFeeling,
    ratingNarrator: ratingNarrator.present
        ? ratingNarrator.value
        : this.ratingNarrator,
  );
  Read copyWithCompanion(ReadsCompanion data) {
    return Read(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      format: data.format.present ? data.format.value : this.format,
      status: data.status.present ? data.status.value : this.status,
      started: data.started.present ? data.started.value : this.started,
      finished: data.finished.present ? data.finished.value : this.finished,
      rating: data.rating.present ? data.rating.value : this.rating,
      thoughts: data.thoughts.present ? data.thoughts.value : this.thoughts,
      narrator: data.narrator.present ? data.narrator.value : this.narrator,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
      currentPage: data.currentPage.present
          ? data.currentPage.value
          : this.currentPage,
      heat: data.heat.present ? data.heat.value : this.heat,
      contentNotes: data.contentNotes.present
          ? data.contentNotes.value
          : this.contentNotes,
      ratingStory: data.ratingStory.present
          ? data.ratingStory.value
          : this.ratingStory,
      ratingCharacters: data.ratingCharacters.present
          ? data.ratingCharacters.value
          : this.ratingCharacters,
      ratingWriting: data.ratingWriting.present
          ? data.ratingWriting.value
          : this.ratingWriting,
      ratingPace: data.ratingPace.present
          ? data.ratingPace.value
          : this.ratingPace,
      ratingFeeling: data.ratingFeeling.present
          ? data.ratingFeeling.value
          : this.ratingFeeling,
      ratingNarrator: data.ratingNarrator.present
          ? data.ratingNarrator.value
          : this.ratingNarrator,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Read(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('format: $format, ')
          ..write('status: $status, ')
          ..write('started: $started, ')
          ..write('finished: $finished, ')
          ..write('rating: $rating, ')
          ..write('thoughts: $thoughts, ')
          ..write('narrator: $narrator, ')
          ..write('minutes: $minutes, ')
          ..write('currentPage: $currentPage, ')
          ..write('heat: $heat, ')
          ..write('contentNotes: $contentNotes, ')
          ..write('ratingStory: $ratingStory, ')
          ..write('ratingCharacters: $ratingCharacters, ')
          ..write('ratingWriting: $ratingWriting, ')
          ..write('ratingPace: $ratingPace, ')
          ..write('ratingFeeling: $ratingFeeling, ')
          ..write('ratingNarrator: $ratingNarrator')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bookId,
    format,
    status,
    started,
    finished,
    rating,
    thoughts,
    narrator,
    minutes,
    currentPage,
    heat,
    contentNotes,
    ratingStory,
    ratingCharacters,
    ratingWriting,
    ratingPace,
    ratingFeeling,
    ratingNarrator,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Read &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.format == this.format &&
          other.status == this.status &&
          other.started == this.started &&
          other.finished == this.finished &&
          other.rating == this.rating &&
          other.thoughts == this.thoughts &&
          other.narrator == this.narrator &&
          other.minutes == this.minutes &&
          other.currentPage == this.currentPage &&
          other.heat == this.heat &&
          other.contentNotes == this.contentNotes &&
          other.ratingStory == this.ratingStory &&
          other.ratingCharacters == this.ratingCharacters &&
          other.ratingWriting == this.ratingWriting &&
          other.ratingPace == this.ratingPace &&
          other.ratingFeeling == this.ratingFeeling &&
          other.ratingNarrator == this.ratingNarrator);
}

class ReadsCompanion extends UpdateCompanion<Read> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<String> format;
  final Value<String> status;
  final Value<DateTime?> started;
  final Value<DateTime?> finished;
  final Value<double?> rating;
  final Value<String> thoughts;
  final Value<String> narrator;
  final Value<int?> minutes;
  final Value<int?> currentPage;
  final Value<int?> heat;
  final Value<String> contentNotes;
  final Value<double?> ratingStory;
  final Value<double?> ratingCharacters;
  final Value<double?> ratingWriting;
  final Value<double?> ratingPace;
  final Value<double?> ratingFeeling;
  final Value<double?> ratingNarrator;
  const ReadsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.format = const Value.absent(),
    this.status = const Value.absent(),
    this.started = const Value.absent(),
    this.finished = const Value.absent(),
    this.rating = const Value.absent(),
    this.thoughts = const Value.absent(),
    this.narrator = const Value.absent(),
    this.minutes = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.heat = const Value.absent(),
    this.contentNotes = const Value.absent(),
    this.ratingStory = const Value.absent(),
    this.ratingCharacters = const Value.absent(),
    this.ratingWriting = const Value.absent(),
    this.ratingPace = const Value.absent(),
    this.ratingFeeling = const Value.absent(),
    this.ratingNarrator = const Value.absent(),
  });
  ReadsCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    this.format = const Value.absent(),
    this.status = const Value.absent(),
    this.started = const Value.absent(),
    this.finished = const Value.absent(),
    this.rating = const Value.absent(),
    this.thoughts = const Value.absent(),
    this.narrator = const Value.absent(),
    this.minutes = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.heat = const Value.absent(),
    this.contentNotes = const Value.absent(),
    this.ratingStory = const Value.absent(),
    this.ratingCharacters = const Value.absent(),
    this.ratingWriting = const Value.absent(),
    this.ratingPace = const Value.absent(),
    this.ratingFeeling = const Value.absent(),
    this.ratingNarrator = const Value.absent(),
  }) : bookId = Value(bookId);
  static Insertable<Read> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<String>? format,
    Expression<String>? status,
    Expression<DateTime>? started,
    Expression<DateTime>? finished,
    Expression<double>? rating,
    Expression<String>? thoughts,
    Expression<String>? narrator,
    Expression<int>? minutes,
    Expression<int>? currentPage,
    Expression<int>? heat,
    Expression<String>? contentNotes,
    Expression<double>? ratingStory,
    Expression<double>? ratingCharacters,
    Expression<double>? ratingWriting,
    Expression<double>? ratingPace,
    Expression<double>? ratingFeeling,
    Expression<double>? ratingNarrator,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (format != null) 'format': format,
      if (status != null) 'status': status,
      if (started != null) 'started': started,
      if (finished != null) 'finished': finished,
      if (rating != null) 'rating': rating,
      if (thoughts != null) 'thoughts': thoughts,
      if (narrator != null) 'narrator': narrator,
      if (minutes != null) 'minutes': minutes,
      if (currentPage != null) 'current_page': currentPage,
      if (heat != null) 'heat': heat,
      if (contentNotes != null) 'content_notes': contentNotes,
      if (ratingStory != null) 'rating_story': ratingStory,
      if (ratingCharacters != null) 'rating_characters': ratingCharacters,
      if (ratingWriting != null) 'rating_writing': ratingWriting,
      if (ratingPace != null) 'rating_pace': ratingPace,
      if (ratingFeeling != null) 'rating_feeling': ratingFeeling,
      if (ratingNarrator != null) 'rating_narrator': ratingNarrator,
    });
  }

  ReadsCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<String>? format,
    Value<String>? status,
    Value<DateTime?>? started,
    Value<DateTime?>? finished,
    Value<double?>? rating,
    Value<String>? thoughts,
    Value<String>? narrator,
    Value<int?>? minutes,
    Value<int?>? currentPage,
    Value<int?>? heat,
    Value<String>? contentNotes,
    Value<double?>? ratingStory,
    Value<double?>? ratingCharacters,
    Value<double?>? ratingWriting,
    Value<double?>? ratingPace,
    Value<double?>? ratingFeeling,
    Value<double?>? ratingNarrator,
  }) {
    return ReadsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      format: format ?? this.format,
      status: status ?? this.status,
      started: started ?? this.started,
      finished: finished ?? this.finished,
      rating: rating ?? this.rating,
      thoughts: thoughts ?? this.thoughts,
      narrator: narrator ?? this.narrator,
      minutes: minutes ?? this.minutes,
      currentPage: currentPage ?? this.currentPage,
      heat: heat ?? this.heat,
      contentNotes: contentNotes ?? this.contentNotes,
      ratingStory: ratingStory ?? this.ratingStory,
      ratingCharacters: ratingCharacters ?? this.ratingCharacters,
      ratingWriting: ratingWriting ?? this.ratingWriting,
      ratingPace: ratingPace ?? this.ratingPace,
      ratingFeeling: ratingFeeling ?? this.ratingFeeling,
      ratingNarrator: ratingNarrator ?? this.ratingNarrator,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (started.present) {
      map['started'] = Variable<DateTime>(started.value);
    }
    if (finished.present) {
      map['finished'] = Variable<DateTime>(finished.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (thoughts.present) {
      map['thoughts'] = Variable<String>(thoughts.value);
    }
    if (narrator.present) {
      map['narrator'] = Variable<String>(narrator.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
    }
    if (currentPage.present) {
      map['current_page'] = Variable<int>(currentPage.value);
    }
    if (heat.present) {
      map['heat'] = Variable<int>(heat.value);
    }
    if (contentNotes.present) {
      map['content_notes'] = Variable<String>(contentNotes.value);
    }
    if (ratingStory.present) {
      map['rating_story'] = Variable<double>(ratingStory.value);
    }
    if (ratingCharacters.present) {
      map['rating_characters'] = Variable<double>(ratingCharacters.value);
    }
    if (ratingWriting.present) {
      map['rating_writing'] = Variable<double>(ratingWriting.value);
    }
    if (ratingPace.present) {
      map['rating_pace'] = Variable<double>(ratingPace.value);
    }
    if (ratingFeeling.present) {
      map['rating_feeling'] = Variable<double>(ratingFeeling.value);
    }
    if (ratingNarrator.present) {
      map['rating_narrator'] = Variable<double>(ratingNarrator.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('format: $format, ')
          ..write('status: $status, ')
          ..write('started: $started, ')
          ..write('finished: $finished, ')
          ..write('rating: $rating, ')
          ..write('thoughts: $thoughts, ')
          ..write('narrator: $narrator, ')
          ..write('minutes: $minutes, ')
          ..write('currentPage: $currentPage, ')
          ..write('heat: $heat, ')
          ..write('contentNotes: $contentNotes, ')
          ..write('ratingStory: $ratingStory, ')
          ..write('ratingCharacters: $ratingCharacters, ')
          ..write('ratingWriting: $ratingWriting, ')
          ..write('ratingPace: $ratingPace, ')
          ..write('ratingFeeling: $ratingFeeling, ')
          ..write('ratingNarrator: $ratingNarrator')
          ..write(')'))
        .toString();
  }
}

class $ShelvesTable extends Shelves with TableInfo<$ShelvesTable, Shelf> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShelvesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shelves';
  @override
  VerificationContext validateIntegrity(
    Insertable<Shelf> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Shelf map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Shelf(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $ShelvesTable createAlias(String alias) {
    return $ShelvesTable(attachedDatabase, alias);
  }
}

class Shelf extends DataClass implements Insertable<Shelf> {
  final int id;
  final String name;
  const Shelf({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  ShelvesCompanion toCompanion(bool nullToAbsent) {
    return ShelvesCompanion(id: Value(id), name: Value(name));
  }

  factory Shelf.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Shelf(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Shelf copyWith({int? id, String? name}) =>
      Shelf(id: id ?? this.id, name: name ?? this.name);
  Shelf copyWithCompanion(ShelvesCompanion data) {
    return Shelf(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Shelf(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Shelf && other.id == this.id && other.name == this.name);
}

class ShelvesCompanion extends UpdateCompanion<Shelf> {
  final Value<int> id;
  final Value<String> name;
  const ShelvesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  ShelvesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Shelf> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  ShelvesCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return ShelvesCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShelvesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $BookShelvesTable extends BookShelves
    with TableInfo<$BookShelvesTable, BookShelf> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookShelvesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _shelfIdMeta = const VerificationMeta(
    'shelfId',
  );
  @override
  late final GeneratedColumn<int> shelfId = GeneratedColumn<int>(
    'shelf_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES shelves (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [bookId, shelfId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_shelves';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookShelf> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('shelf_id')) {
      context.handle(
        _shelfIdMeta,
        shelfId.isAcceptableOrUnknown(data['shelf_id']!, _shelfIdMeta),
      );
    } else if (isInserting) {
      context.missing(_shelfIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId, shelfId};
  @override
  BookShelf map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookShelf(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      shelfId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shelf_id'],
      )!,
    );
  }

  @override
  $BookShelvesTable createAlias(String alias) {
    return $BookShelvesTable(attachedDatabase, alias);
  }
}

class BookShelf extends DataClass implements Insertable<BookShelf> {
  final int bookId;
  final int shelfId;
  const BookShelf({required this.bookId, required this.shelfId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<int>(bookId);
    map['shelf_id'] = Variable<int>(shelfId);
    return map;
  }

  BookShelvesCompanion toCompanion(bool nullToAbsent) {
    return BookShelvesCompanion(bookId: Value(bookId), shelfId: Value(shelfId));
  }

  factory BookShelf.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookShelf(
      bookId: serializer.fromJson<int>(json['bookId']),
      shelfId: serializer.fromJson<int>(json['shelfId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<int>(bookId),
      'shelfId': serializer.toJson<int>(shelfId),
    };
  }

  BookShelf copyWith({int? bookId, int? shelfId}) => BookShelf(
    bookId: bookId ?? this.bookId,
    shelfId: shelfId ?? this.shelfId,
  );
  BookShelf copyWithCompanion(BookShelvesCompanion data) {
    return BookShelf(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      shelfId: data.shelfId.present ? data.shelfId.value : this.shelfId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookShelf(')
          ..write('bookId: $bookId, ')
          ..write('shelfId: $shelfId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(bookId, shelfId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookShelf &&
          other.bookId == this.bookId &&
          other.shelfId == this.shelfId);
}

class BookShelvesCompanion extends UpdateCompanion<BookShelf> {
  final Value<int> bookId;
  final Value<int> shelfId;
  final Value<int> rowid;
  const BookShelvesCompanion({
    this.bookId = const Value.absent(),
    this.shelfId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookShelvesCompanion.insert({
    required int bookId,
    required int shelfId,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       shelfId = Value(shelfId);
  static Insertable<BookShelf> custom({
    Expression<int>? bookId,
    Expression<int>? shelfId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (shelfId != null) 'shelf_id': shelfId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookShelvesCompanion copyWith({
    Value<int>? bookId,
    Value<int>? shelfId,
    Value<int>? rowid,
  }) {
    return BookShelvesCompanion(
      bookId: bookId ?? this.bookId,
      shelfId: shelfId ?? this.shelfId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (shelfId.present) {
      map['shelf_id'] = Variable<int>(shelfId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookShelvesCompanion(')
          ..write('bookId: $bookId, ')
          ..write('shelfId: $shelfId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuotesTable extends Quotes with TableInfo<$QuotesTable, Quote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<double> rating = GeneratedColumn<double>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdMeta = const VerificationMeta(
    'created',
  );
  @override
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
    'created',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    body,
    page,
    note,
    rating,
    created,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Quote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('created')) {
      context.handle(
        _createdMeta,
        created.isAcceptableOrUnknown(data['created']!, _createdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Quote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Quote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rating'],
      ),
      created: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created'],
      )!,
    );
  }

  @override
  $QuotesTable createAlias(String alias) {
    return $QuotesTable(attachedDatabase, alias);
  }
}

class Quote extends DataClass implements Insertable<Quote> {
  final int id;
  final int bookId;
  final String body;
  final int? page;
  final String note;
  final double? rating;
  final DateTime created;
  const Quote({
    required this.id,
    required this.bookId,
    required this.body,
    this.page,
    required this.note,
    this.rating,
    required this.created,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || page != null) {
      map['page'] = Variable<int>(page);
    }
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<double>(rating);
    }
    map['created'] = Variable<DateTime>(created);
    return map;
  }

  QuotesCompanion toCompanion(bool nullToAbsent) {
    return QuotesCompanion(
      id: Value(id),
      bookId: Value(bookId),
      body: Value(body),
      page: page == null && nullToAbsent ? const Value.absent() : Value(page),
      note: Value(note),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      created: Value(created),
    );
  }

  factory Quote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Quote(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      body: serializer.fromJson<String>(json['body']),
      page: serializer.fromJson<int?>(json['page']),
      note: serializer.fromJson<String>(json['note']),
      rating: serializer.fromJson<double?>(json['rating']),
      created: serializer.fromJson<DateTime>(json['created']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'body': serializer.toJson<String>(body),
      'page': serializer.toJson<int?>(page),
      'note': serializer.toJson<String>(note),
      'rating': serializer.toJson<double?>(rating),
      'created': serializer.toJson<DateTime>(created),
    };
  }

  Quote copyWith({
    int? id,
    int? bookId,
    String? body,
    Value<int?> page = const Value.absent(),
    String? note,
    Value<double?> rating = const Value.absent(),
    DateTime? created,
  }) => Quote(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    body: body ?? this.body,
    page: page.present ? page.value : this.page,
    note: note ?? this.note,
    rating: rating.present ? rating.value : this.rating,
    created: created ?? this.created,
  );
  Quote copyWithCompanion(QuotesCompanion data) {
    return Quote(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      body: data.body.present ? data.body.value : this.body,
      page: data.page.present ? data.page.value : this.page,
      note: data.note.present ? data.note.value : this.note,
      rating: data.rating.present ? data.rating.value : this.rating,
      created: data.created.present ? data.created.value : this.created,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Quote(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('body: $body, ')
          ..write('page: $page, ')
          ..write('note: $note, ')
          ..write('rating: $rating, ')
          ..write('created: $created')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookId, body, page, note, rating, created);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Quote &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.body == this.body &&
          other.page == this.page &&
          other.note == this.note &&
          other.rating == this.rating &&
          other.created == this.created);
}

class QuotesCompanion extends UpdateCompanion<Quote> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<String> body;
  final Value<int?> page;
  final Value<String> note;
  final Value<double?> rating;
  final Value<DateTime> created;
  const QuotesCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.body = const Value.absent(),
    this.page = const Value.absent(),
    this.note = const Value.absent(),
    this.rating = const Value.absent(),
    this.created = const Value.absent(),
  });
  QuotesCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required String body,
    this.page = const Value.absent(),
    this.note = const Value.absent(),
    this.rating = const Value.absent(),
    this.created = const Value.absent(),
  }) : bookId = Value(bookId),
       body = Value(body);
  static Insertable<Quote> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<String>? body,
    Expression<int>? page,
    Expression<String>? note,
    Expression<double>? rating,
    Expression<DateTime>? created,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (body != null) 'body': body,
      if (page != null) 'page': page,
      if (note != null) 'note': note,
      if (rating != null) 'rating': rating,
      if (created != null) 'created': created,
    });
  }

  QuotesCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<String>? body,
    Value<int?>? page,
    Value<String>? note,
    Value<double?>? rating,
    Value<DateTime>? created,
  }) {
    return QuotesCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      body: body ?? this.body,
      page: page ?? this.page,
      note: note ?? this.note,
      rating: rating ?? this.rating,
      created: created ?? this.created,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rating.present) {
      map['rating'] = Variable<double>(rating.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuotesCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('body: $body, ')
          ..write('page: $page, ')
          ..write('note: $note, ')
          ..write('rating: $rating, ')
          ..write('created: $created')
          ..write(')'))
        .toString();
  }
}

class $ReadingSessionsTable extends ReadingSessions
    with TableInfo<$ReadingSessionsTable, ReadingSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minutesMeta = const VerificationMeta(
    'minutes',
  );
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
    'minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pagesMeta = const VerificationMeta('pages');
  @override
  late final GeneratedColumn<int> pages = GeneratedColumn<int>(
    'pages',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, bookId, day, minutes, pages];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('minutes')) {
      context.handle(
        _minutesMeta,
        minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta),
      );
    } else if (isInserting) {
      context.missing(_minutesMeta);
    }
    if (data.containsKey('pages')) {
      context.handle(
        _pagesMeta,
        pages.isAcceptableOrUnknown(data['pages']!, _pagesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}day'],
      )!,
      minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes'],
      )!,
      pages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pages'],
      ),
    );
  }

  @override
  $ReadingSessionsTable createAlias(String alias) {
    return $ReadingSessionsTable(attachedDatabase, alias);
  }
}

class ReadingSession extends DataClass implements Insertable<ReadingSession> {
  final int id;
  final int bookId;
  final DateTime day;
  final int minutes;
  final int? pages;
  const ReadingSession({
    required this.id,
    required this.bookId,
    required this.day,
    required this.minutes,
    this.pages,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['day'] = Variable<DateTime>(day);
    map['minutes'] = Variable<int>(minutes);
    if (!nullToAbsent || pages != null) {
      map['pages'] = Variable<int>(pages);
    }
    return map;
  }

  ReadingSessionsCompanion toCompanion(bool nullToAbsent) {
    return ReadingSessionsCompanion(
      id: Value(id),
      bookId: Value(bookId),
      day: Value(day),
      minutes: Value(minutes),
      pages: pages == null && nullToAbsent
          ? const Value.absent()
          : Value(pages),
    );
  }

  factory ReadingSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingSession(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      day: serializer.fromJson<DateTime>(json['day']),
      minutes: serializer.fromJson<int>(json['minutes']),
      pages: serializer.fromJson<int?>(json['pages']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'day': serializer.toJson<DateTime>(day),
      'minutes': serializer.toJson<int>(minutes),
      'pages': serializer.toJson<int?>(pages),
    };
  }

  ReadingSession copyWith({
    int? id,
    int? bookId,
    DateTime? day,
    int? minutes,
    Value<int?> pages = const Value.absent(),
  }) => ReadingSession(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    day: day ?? this.day,
    minutes: minutes ?? this.minutes,
    pages: pages.present ? pages.value : this.pages,
  );
  ReadingSession copyWithCompanion(ReadingSessionsCompanion data) {
    return ReadingSession(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      day: data.day.present ? data.day.value : this.day,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
      pages: data.pages.present ? data.pages.value : this.pages,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSession(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('day: $day, ')
          ..write('minutes: $minutes, ')
          ..write('pages: $pages')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bookId, day, minutes, pages);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingSession &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.day == this.day &&
          other.minutes == this.minutes &&
          other.pages == this.pages);
}

class ReadingSessionsCompanion extends UpdateCompanion<ReadingSession> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<DateTime> day;
  final Value<int> minutes;
  final Value<int?> pages;
  const ReadingSessionsCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.day = const Value.absent(),
    this.minutes = const Value.absent(),
    this.pages = const Value.absent(),
  });
  ReadingSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required DateTime day,
    required int minutes,
    this.pages = const Value.absent(),
  }) : bookId = Value(bookId),
       day = Value(day),
       minutes = Value(minutes);
  static Insertable<ReadingSession> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<DateTime>? day,
    Expression<int>? minutes,
    Expression<int>? pages,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (day != null) 'day': day,
      if (minutes != null) 'minutes': minutes,
      if (pages != null) 'pages': pages,
    });
  }

  ReadingSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<DateTime>? day,
    Value<int>? minutes,
    Value<int?>? pages,
  }) {
    return ReadingSessionsCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      day: day ?? this.day,
      minutes: minutes ?? this.minutes,
      pages: pages ?? this.pages,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
    }
    if (pages.present) {
      map['pages'] = Variable<int>(pages.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingSessionsCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('day: $day, ')
          ..write('minutes: $minutes, ')
          ..write('pages: $pages')
          ..write(')'))
        .toString();
  }
}

class $LoansTable extends Loans with TableInfo<$LoansTable, Loan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _personMeta = const VerificationMeta('person');
  @override
  late final GeneratedColumn<String> person = GeneratedColumn<String>(
    'person',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lentOnMeta = const VerificationMeta('lentOn');
  @override
  late final GeneratedColumn<DateTime> lentOn = GeneratedColumn<DateTime>(
    'lent_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _remindOnMeta = const VerificationMeta(
    'remindOn',
  );
  @override
  late final GeneratedColumn<DateTime> remindOn = GeneratedColumn<DateTime>(
    'remind_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _returnedOnMeta = const VerificationMeta(
    'returnedOn',
  );
  @override
  late final GeneratedColumn<DateTime> returnedOn = GeneratedColumn<DateTime>(
    'returned_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bookId,
    person,
    lentOn,
    remindOn,
    returnedOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loans';
  @override
  VerificationContext validateIntegrity(
    Insertable<Loan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('person')) {
      context.handle(
        _personMeta,
        person.isAcceptableOrUnknown(data['person']!, _personMeta),
      );
    } else if (isInserting) {
      context.missing(_personMeta);
    }
    if (data.containsKey('lent_on')) {
      context.handle(
        _lentOnMeta,
        lentOn.isAcceptableOrUnknown(data['lent_on']!, _lentOnMeta),
      );
    } else if (isInserting) {
      context.missing(_lentOnMeta);
    }
    if (data.containsKey('remind_on')) {
      context.handle(
        _remindOnMeta,
        remindOn.isAcceptableOrUnknown(data['remind_on']!, _remindOnMeta),
      );
    }
    if (data.containsKey('returned_on')) {
      context.handle(
        _returnedOnMeta,
        returnedOn.isAcceptableOrUnknown(data['returned_on']!, _returnedOnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Loan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Loan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      )!,
      person: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person'],
      )!,
      lentOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}lent_on'],
      )!,
      remindOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}remind_on'],
      ),
      returnedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}returned_on'],
      ),
    );
  }

  @override
  $LoansTable createAlias(String alias) {
    return $LoansTable(attachedDatabase, alias);
  }
}

class Loan extends DataClass implements Insertable<Loan> {
  final int id;
  final int bookId;
  final String person;
  final DateTime lentOn;
  final DateTime? remindOn;
  final DateTime? returnedOn;
  const Loan({
    required this.id,
    required this.bookId,
    required this.person,
    required this.lentOn,
    this.remindOn,
    this.returnedOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['book_id'] = Variable<int>(bookId);
    map['person'] = Variable<String>(person);
    map['lent_on'] = Variable<DateTime>(lentOn);
    if (!nullToAbsent || remindOn != null) {
      map['remind_on'] = Variable<DateTime>(remindOn);
    }
    if (!nullToAbsent || returnedOn != null) {
      map['returned_on'] = Variable<DateTime>(returnedOn);
    }
    return map;
  }

  LoansCompanion toCompanion(bool nullToAbsent) {
    return LoansCompanion(
      id: Value(id),
      bookId: Value(bookId),
      person: Value(person),
      lentOn: Value(lentOn),
      remindOn: remindOn == null && nullToAbsent
          ? const Value.absent()
          : Value(remindOn),
      returnedOn: returnedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(returnedOn),
    );
  }

  factory Loan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Loan(
      id: serializer.fromJson<int>(json['id']),
      bookId: serializer.fromJson<int>(json['bookId']),
      person: serializer.fromJson<String>(json['person']),
      lentOn: serializer.fromJson<DateTime>(json['lentOn']),
      remindOn: serializer.fromJson<DateTime?>(json['remindOn']),
      returnedOn: serializer.fromJson<DateTime?>(json['returnedOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bookId': serializer.toJson<int>(bookId),
      'person': serializer.toJson<String>(person),
      'lentOn': serializer.toJson<DateTime>(lentOn),
      'remindOn': serializer.toJson<DateTime?>(remindOn),
      'returnedOn': serializer.toJson<DateTime?>(returnedOn),
    };
  }

  Loan copyWith({
    int? id,
    int? bookId,
    String? person,
    DateTime? lentOn,
    Value<DateTime?> remindOn = const Value.absent(),
    Value<DateTime?> returnedOn = const Value.absent(),
  }) => Loan(
    id: id ?? this.id,
    bookId: bookId ?? this.bookId,
    person: person ?? this.person,
    lentOn: lentOn ?? this.lentOn,
    remindOn: remindOn.present ? remindOn.value : this.remindOn,
    returnedOn: returnedOn.present ? returnedOn.value : this.returnedOn,
  );
  Loan copyWithCompanion(LoansCompanion data) {
    return Loan(
      id: data.id.present ? data.id.value : this.id,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      person: data.person.present ? data.person.value : this.person,
      lentOn: data.lentOn.present ? data.lentOn.value : this.lentOn,
      remindOn: data.remindOn.present ? data.remindOn.value : this.remindOn,
      returnedOn: data.returnedOn.present
          ? data.returnedOn.value
          : this.returnedOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Loan(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('person: $person, ')
          ..write('lentOn: $lentOn, ')
          ..write('remindOn: $remindOn, ')
          ..write('returnedOn: $returnedOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, bookId, person, lentOn, remindOn, returnedOn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Loan &&
          other.id == this.id &&
          other.bookId == this.bookId &&
          other.person == this.person &&
          other.lentOn == this.lentOn &&
          other.remindOn == this.remindOn &&
          other.returnedOn == this.returnedOn);
}

class LoansCompanion extends UpdateCompanion<Loan> {
  final Value<int> id;
  final Value<int> bookId;
  final Value<String> person;
  final Value<DateTime> lentOn;
  final Value<DateTime?> remindOn;
  final Value<DateTime?> returnedOn;
  const LoansCompanion({
    this.id = const Value.absent(),
    this.bookId = const Value.absent(),
    this.person = const Value.absent(),
    this.lentOn = const Value.absent(),
    this.remindOn = const Value.absent(),
    this.returnedOn = const Value.absent(),
  });
  LoansCompanion.insert({
    this.id = const Value.absent(),
    required int bookId,
    required String person,
    required DateTime lentOn,
    this.remindOn = const Value.absent(),
    this.returnedOn = const Value.absent(),
  }) : bookId = Value(bookId),
       person = Value(person),
       lentOn = Value(lentOn);
  static Insertable<Loan> custom({
    Expression<int>? id,
    Expression<int>? bookId,
    Expression<String>? person,
    Expression<DateTime>? lentOn,
    Expression<DateTime>? remindOn,
    Expression<DateTime>? returnedOn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bookId != null) 'book_id': bookId,
      if (person != null) 'person': person,
      if (lentOn != null) 'lent_on': lentOn,
      if (remindOn != null) 'remind_on': remindOn,
      if (returnedOn != null) 'returned_on': returnedOn,
    });
  }

  LoansCompanion copyWith({
    Value<int>? id,
    Value<int>? bookId,
    Value<String>? person,
    Value<DateTime>? lentOn,
    Value<DateTime?>? remindOn,
    Value<DateTime?>? returnedOn,
  }) {
    return LoansCompanion(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      person: person ?? this.person,
      lentOn: lentOn ?? this.lentOn,
      remindOn: remindOn ?? this.remindOn,
      returnedOn: returnedOn ?? this.returnedOn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (person.present) {
      map['person'] = Variable<String>(person.value);
    }
    if (lentOn.present) {
      map['lent_on'] = Variable<DateTime>(lentOn.value);
    }
    if (remindOn.present) {
      map['remind_on'] = Variable<DateTime>(remindOn.value);
    }
    if (returnedOn.present) {
      map['returned_on'] = Variable<DateTime>(returnedOn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoansCompanion(')
          ..write('id: $id, ')
          ..write('bookId: $bookId, ')
          ..write('person: $person, ')
          ..write('lentOn: $lentOn, ')
          ..write('remindOn: $remindOn, ')
          ..write('returnedOn: $returnedOn')
          ..write(')'))
        .toString();
  }
}

class $SeriesInfoTable extends SeriesInfo
    with TableInfo<$SeriesInfoTable, SeriesInfoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeriesInfoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameKeyMeta = const VerificationMeta(
    'nameKey',
  );
  @override
  late final GeneratedColumn<String> nameKey = GeneratedColumn<String>(
    'name_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<int> total = GeneratedColumn<int>(
    'total',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nameKey,
    name,
    locked,
    total,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'series_info';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeriesInfoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name_key')) {
      context.handle(
        _nameKeyMeta,
        nameKey.isAcceptableOrUnknown(data['name_key']!, _nameKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_nameKeyMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('locked')) {
      context.handle(
        _lockedMeta,
        locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {nameKey, locked},
  ];
  @override
  SeriesInfoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeriesInfoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nameKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_key'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $SeriesInfoTable createAlias(String alias) {
    return $SeriesInfoTable(attachedDatabase, alias);
  }
}

class SeriesInfoRow extends DataClass implements Insertable<SeriesInfoRow> {
  final int id;
  final String nameKey;
  final String name;
  final bool locked;
  final int? total;
  final String status;
  const SeriesInfoRow({
    required this.id,
    required this.nameKey,
    required this.name,
    required this.locked,
    this.total,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name_key'] = Variable<String>(nameKey);
    map['name'] = Variable<String>(name);
    map['locked'] = Variable<bool>(locked);
    if (!nullToAbsent || total != null) {
      map['total'] = Variable<int>(total);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  SeriesInfoCompanion toCompanion(bool nullToAbsent) {
    return SeriesInfoCompanion(
      id: Value(id),
      nameKey: Value(nameKey),
      name: Value(name),
      locked: Value(locked),
      total: total == null && nullToAbsent
          ? const Value.absent()
          : Value(total),
      status: Value(status),
    );
  }

  factory SeriesInfoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeriesInfoRow(
      id: serializer.fromJson<int>(json['id']),
      nameKey: serializer.fromJson<String>(json['nameKey']),
      name: serializer.fromJson<String>(json['name']),
      locked: serializer.fromJson<bool>(json['locked']),
      total: serializer.fromJson<int?>(json['total']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nameKey': serializer.toJson<String>(nameKey),
      'name': serializer.toJson<String>(name),
      'locked': serializer.toJson<bool>(locked),
      'total': serializer.toJson<int?>(total),
      'status': serializer.toJson<String>(status),
    };
  }

  SeriesInfoRow copyWith({
    int? id,
    String? nameKey,
    String? name,
    bool? locked,
    Value<int?> total = const Value.absent(),
    String? status,
  }) => SeriesInfoRow(
    id: id ?? this.id,
    nameKey: nameKey ?? this.nameKey,
    name: name ?? this.name,
    locked: locked ?? this.locked,
    total: total.present ? total.value : this.total,
    status: status ?? this.status,
  );
  SeriesInfoRow copyWithCompanion(SeriesInfoCompanion data) {
    return SeriesInfoRow(
      id: data.id.present ? data.id.value : this.id,
      nameKey: data.nameKey.present ? data.nameKey.value : this.nameKey,
      name: data.name.present ? data.name.value : this.name,
      locked: data.locked.present ? data.locked.value : this.locked,
      total: data.total.present ? data.total.value : this.total,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeriesInfoRow(')
          ..write('id: $id, ')
          ..write('nameKey: $nameKey, ')
          ..write('name: $name, ')
          ..write('locked: $locked, ')
          ..write('total: $total, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nameKey, name, locked, total, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeriesInfoRow &&
          other.id == this.id &&
          other.nameKey == this.nameKey &&
          other.name == this.name &&
          other.locked == this.locked &&
          other.total == this.total &&
          other.status == this.status);
}

class SeriesInfoCompanion extends UpdateCompanion<SeriesInfoRow> {
  final Value<int> id;
  final Value<String> nameKey;
  final Value<String> name;
  final Value<bool> locked;
  final Value<int?> total;
  final Value<String> status;
  const SeriesInfoCompanion({
    this.id = const Value.absent(),
    this.nameKey = const Value.absent(),
    this.name = const Value.absent(),
    this.locked = const Value.absent(),
    this.total = const Value.absent(),
    this.status = const Value.absent(),
  });
  SeriesInfoCompanion.insert({
    this.id = const Value.absent(),
    required String nameKey,
    required String name,
    this.locked = const Value.absent(),
    this.total = const Value.absent(),
    this.status = const Value.absent(),
  }) : nameKey = Value(nameKey),
       name = Value(name);
  static Insertable<SeriesInfoRow> custom({
    Expression<int>? id,
    Expression<String>? nameKey,
    Expression<String>? name,
    Expression<bool>? locked,
    Expression<int>? total,
    Expression<String>? status,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nameKey != null) 'name_key': nameKey,
      if (name != null) 'name': name,
      if (locked != null) 'locked': locked,
      if (total != null) 'total': total,
      if (status != null) 'status': status,
    });
  }

  SeriesInfoCompanion copyWith({
    Value<int>? id,
    Value<String>? nameKey,
    Value<String>? name,
    Value<bool>? locked,
    Value<int?>? total,
    Value<String>? status,
  }) {
    return SeriesInfoCompanion(
      id: id ?? this.id,
      nameKey: nameKey ?? this.nameKey,
      name: name ?? this.name,
      locked: locked ?? this.locked,
      total: total ?? this.total,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nameKey.present) {
      map['name_key'] = Variable<String>(nameKey.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    if (total.present) {
      map['total'] = Variable<int>(total.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeriesInfoCompanion(')
          ..write('id: $id, ')
          ..write('nameKey: $nameKey, ')
          ..write('name: $name, ')
          ..write('locked: $locked, ')
          ..write('total: $total, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $ReadsTable reads = $ReadsTable(this);
  late final $ShelvesTable shelves = $ShelvesTable(this);
  late final $BookShelvesTable bookShelves = $BookShelvesTable(this);
  late final $QuotesTable quotes = $QuotesTable(this);
  late final $ReadingSessionsTable readingSessions = $ReadingSessionsTable(
    this,
  );
  late final $LoansTable loans = $LoansTable(this);
  late final $SeriesInfoTable seriesInfo = $SeriesInfoTable(this);
  late final Index booksLocked = Index(
    'books_locked',
    'CREATE INDEX books_locked ON books (locked)',
  );
  late final Index booksTitle = Index(
    'books_title',
    'CREATE INDEX books_title ON books (title)',
  );
  late final Index booksSeries = Index(
    'books_series',
    'CREATE INDEX books_series ON books (series)',
  );
  late final Index readsBook = Index(
    'reads_book',
    'CREATE INDEX reads_book ON reads (book_id)',
  );
  late final Index sessionsBook = Index(
    'sessions_book',
    'CREATE INDEX sessions_book ON reading_sessions (book_id)',
  );
  late final Index loansBook = Index(
    'loans_book',
    'CREATE INDEX loans_book ON loans (book_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    books,
    reads,
    shelves,
    bookShelves,
    quotes,
    readingSessions,
    loans,
    seriesInfo,
    booksLocked,
    booksTitle,
    booksSeries,
    readsBook,
    sessionsBook,
    loansBook,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reads', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('book_shelves', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'shelves',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('book_shelves', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quotes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reading_sessions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('loans', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$BooksTableCreateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  required String title,
  Value<String> author,
  Value<String> isbn,
  Value<String> coverUrl,
  Value<String> genre,
  Value<String> series,
  Value<double?> seriesNumber,
  Value<int?> seriesTotal,
  Value<String> publisher,
  Value<int?> year,
  Value<int?> pages,
  Value<String> description,
  Value<String> tags,
  Value<String> notes,
  Value<bool> locked,
  Value<DateTime> added,
  Value<DateTime?> deletedAt,
  Value<int?> queuePos,
  Value<String> kind,
  Value<bool> owned,
});
typedef $$BooksTableUpdateCompanionBuilder = BooksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> author,
  Value<String> isbn,
  Value<String> coverUrl,
  Value<String> genre,
  Value<String> series,
  Value<double?> seriesNumber,
  Value<int?> seriesTotal,
  Value<String> publisher,
  Value<int?> year,
  Value<int?> pages,
  Value<String> description,
  Value<String> tags,
  Value<String> notes,
  Value<bool> locked,
  Value<DateTime> added,
  Value<DateTime?> deletedAt,
  Value<int?> queuePos,
  Value<String> kind,
  Value<bool> owned,
});

final class $$BooksTableReferences
    extends BaseReferences<_$AppDb, $BooksTable, Book> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReadsTable, List<Read>> _readsRefsTable(
    _$AppDb db,
  ) => MultiTypedResultKey.fromTable(
    db.reads,
    aliasName: 'books__id__reads__book_id',
  );

  $$ReadsTableProcessedTableManager get readsRefs {
    final manager = $$ReadsTableTableManager(
      $_db,
      $_db.reads,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_readsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BookShelvesTable, List<BookShelf>>
  _bookShelvesRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.bookShelves,
    aliasName: 'books__id__book_shelves__book_id',
  );

  $$BookShelvesTableProcessedTableManager get bookShelvesRefs {
    final manager = $$BookShelvesTableTableManager(
      $_db,
      $_db.bookShelves,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookShelvesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuotesTable, List<Quote>> _quotesRefsTable(
    _$AppDb db,
  ) => MultiTypedResultKey.fromTable(
    db.quotes,
    aliasName: 'books__id__quotes__book_id',
  );

  $$QuotesTableProcessedTableManager get quotesRefs {
    final manager = $$QuotesTableTableManager(
      $_db,
      $_db.quotes,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_quotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReadingSessionsTable, List<ReadingSession>>
  _readingSessionsRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.readingSessions,
    aliasName: 'books__id__reading_sessions__book_id',
  );

  $$ReadingSessionsTableProcessedTableManager get readingSessionsRefs {
    final manager = $$ReadingSessionsTableTableManager(
      $_db,
      $_db.readingSessions,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _readingSessionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LoansTable, List<Loan>> _loansRefsTable(
    _$AppDb db,
  ) => MultiTypedResultKey.fromTable(
    db.loans,
    aliasName: 'books__id__loans__book_id',
  );

  $$LoansTableProcessedTableManager get loansRefs {
    final manager = $$LoansTableTableManager(
      $_db,
      $_db.loans,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_loansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDb, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get series => $composableBuilder(
    column: $table.series,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get seriesNumber => $composableBuilder(
    column: $table.seriesNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seriesTotal => $composableBuilder(
    column: $table.seriesTotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pages => $composableBuilder(
    column: $table.pages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get added => $composableBuilder(
    column: $table.added,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get queuePos => $composableBuilder(
    column: $table.queuePos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get owned => $composableBuilder(
    column: $table.owned,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> readsRefs(
    Expression<bool> Function($$ReadsTableFilterComposer f) f,
  ) {
    final $$ReadsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reads,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadsTableFilterComposer(
            $db: $db,
            $table: $db.reads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookShelvesRefs(
    Expression<bool> Function($$BookShelvesTableFilterComposer f) f,
  ) {
    final $$BookShelvesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookShelves,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookShelvesTableFilterComposer(
            $db: $db,
            $table: $db.bookShelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> quotesRefs(
    Expression<bool> Function($$QuotesTableFilterComposer f) f,
  ) {
    final $$QuotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableFilterComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readingSessionsRefs(
    Expression<bool> Function($$ReadingSessionsTableFilterComposer f) f,
  ) {
    final $$ReadingSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingSessions,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingSessionsTableFilterComposer(
            $db: $db,
            $table: $db.readingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> loansRefs(
    Expression<bool> Function($$LoansTableFilterComposer f) f,
  ) {
    final $$LoansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loans,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableFilterComposer(
            $db: $db,
            $table: $db.loans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer extends Composer<_$AppDb, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isbn => $composableBuilder(
    column: $table.isbn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get series => $composableBuilder(
    column: $table.series,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get seriesNumber => $composableBuilder(
    column: $table.seriesNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seriesTotal => $composableBuilder(
    column: $table.seriesTotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pages => $composableBuilder(
    column: $table.pages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get added => $composableBuilder(
    column: $table.added,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get queuePos => $composableBuilder(
    column: $table.queuePos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get owned => $composableBuilder(
    column: $table.owned,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer extends Composer<_$AppDb, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get isbn =>
      $composableBuilder(column: $table.isbn, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<String> get series =>
      $composableBuilder(column: $table.series, builder: (column) => column);

  GeneratedColumn<double> get seriesNumber => $composableBuilder(
    column: $table.seriesNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seriesTotal => $composableBuilder(
    column: $table.seriesTotal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get pages =>
      $composableBuilder(column: $table.pages, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);

  GeneratedColumn<DateTime> get added =>
      $composableBuilder(column: $table.added, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get queuePos =>
      $composableBuilder(column: $table.queuePos, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<bool> get owned =>
      $composableBuilder(column: $table.owned, builder: (column) => column);

  Expression<T> readsRefs<T extends Object>(
    Expression<T> Function($$ReadsTableAnnotationComposer a) f,
  ) {
    final $$ReadsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.reads,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadsTableAnnotationComposer(
            $db: $db,
            $table: $db.reads,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookShelvesRefs<T extends Object>(
    Expression<T> Function($$BookShelvesTableAnnotationComposer a) f,
  ) {
    final $$BookShelvesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookShelves,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookShelvesTableAnnotationComposer(
            $db: $db,
            $table: $db.bookShelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> quotesRefs<T extends Object>(
    Expression<T> Function($$QuotesTableAnnotationComposer a) f,
  ) {
    final $$QuotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableAnnotationComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readingSessionsRefs<T extends Object>(
    Expression<T> Function($$ReadingSessionsTableAnnotationComposer a) f,
  ) {
    final $$ReadingSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingSessions,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.readingSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> loansRefs<T extends Object>(
    Expression<T> Function($$LoansTableAnnotationComposer a) f,
  ) {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loans,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableAnnotationComposer(
            $db: $db,
            $table: $db.loans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $BooksTable,
          Book,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (Book, $$BooksTableReferences),
          Book,
          PrefetchHooks Function({
            bool readsRefs,
            bool bookShelvesRefs,
            bool quotesRefs,
            bool readingSessionsRefs,
            bool loansRefs,
          })
        > {
  $$BooksTableTableManager(_$AppDb db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> isbn = const Value.absent(),
                Value<String> coverUrl = const Value.absent(),
                Value<String> genre = const Value.absent(),
                Value<String> series = const Value.absent(),
                Value<double?> seriesNumber = const Value.absent(),
                Value<int?> seriesTotal = const Value.absent(),
                Value<String> publisher = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<int?> pages = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<DateTime> added = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> queuePos = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<bool> owned = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                title: title,
                author: author,
                isbn: isbn,
                coverUrl: coverUrl,
                genre: genre,
                series: series,
                seriesNumber: seriesNumber,
                seriesTotal: seriesTotal,
                publisher: publisher,
                year: year,
                pages: pages,
                description: description,
                tags: tags,
                notes: notes,
                locked: locked,
                added: added,
                deletedAt: deletedAt,
                queuePos: queuePos,
                kind: kind,
                owned: owned,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> author = const Value.absent(),
                Value<String> isbn = const Value.absent(),
                Value<String> coverUrl = const Value.absent(),
                Value<String> genre = const Value.absent(),
                Value<String> series = const Value.absent(),
                Value<double?> seriesNumber = const Value.absent(),
                Value<int?> seriesTotal = const Value.absent(),
                Value<String> publisher = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<int?> pages = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<DateTime> added = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int?> queuePos = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<bool> owned = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                title: title,
                author: author,
                isbn: isbn,
                coverUrl: coverUrl,
                genre: genre,
                series: series,
                seriesNumber: seriesNumber,
                seriesTotal: seriesTotal,
                publisher: publisher,
                year: year,
                pages: pages,
                description: description,
                tags: tags,
                notes: notes,
                locked: locked,
                added: added,
                deletedAt: deletedAt,
                queuePos: queuePos,
                kind: kind,
                owned: owned,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BooksTable, Book>(table),
                  $$BooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                readsRefs = false,
                bookShelvesRefs = false,
                quotesRefs = false,
                readingSessionsRefs = false,
                loansRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (readsRefs) db.reads,
                    if (bookShelvesRefs) db.bookShelves,
                    if (quotesRefs) db.quotes,
                    if (readingSessionsRefs) db.readingSessions,
                    if (loansRefs) db.loans,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (readsRefs)
                        await $_getPrefetchedData<Book, $BooksTable, Read>(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._readsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(db, table, p0).readsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bookShelvesRefs)
                        await $_getPrefetchedData<Book, $BooksTable, BookShelf>(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._bookShelvesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).bookShelvesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (quotesRefs)
                        await $_getPrefetchedData<Book, $BooksTable, Quote>(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._quotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(db, table, p0).quotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readingSessionsRefs)
                        await $_getPrefetchedData<
                          Book,
                          $BooksTable,
                          ReadingSession
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._readingSessionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).readingSessionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (loansRefs)
                        await $_getPrefetchedData<Book, $BooksTable, Loan>(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._loansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(db, table, p0).loansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bookId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $BooksTable,
      Book,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (Book, $$BooksTableReferences),
      Book,
      PrefetchHooks Function({
        bool readsRefs,
        bool bookShelvesRefs,
        bool quotesRefs,
        bool readingSessionsRefs,
        bool loansRefs,
      })
    >;
typedef $$ReadsTableCreateCompanionBuilder = ReadsCompanion Function({
  Value<int> id,
  required int bookId,
  Value<String> format,
  Value<String> status,
  Value<DateTime?> started,
  Value<DateTime?> finished,
  Value<double?> rating,
  Value<String> thoughts,
  Value<String> narrator,
  Value<int?> minutes,
  Value<int?> currentPage,
  Value<int?> heat,
  Value<String> contentNotes,
  Value<double?> ratingStory,
  Value<double?> ratingCharacters,
  Value<double?> ratingWriting,
  Value<double?> ratingPace,
  Value<double?> ratingFeeling,
  Value<double?> ratingNarrator,
});
typedef $$ReadsTableUpdateCompanionBuilder = ReadsCompanion Function({
  Value<int> id,
  Value<int> bookId,
  Value<String> format,
  Value<String> status,
  Value<DateTime?> started,
  Value<DateTime?> finished,
  Value<double?> rating,
  Value<String> thoughts,
  Value<String> narrator,
  Value<int?> minutes,
  Value<int?> currentPage,
  Value<int?> heat,
  Value<String> contentNotes,
  Value<double?> ratingStory,
  Value<double?> ratingCharacters,
  Value<double?> ratingWriting,
  Value<double?> ratingPace,
  Value<double?> ratingFeeling,
  Value<double?> ratingNarrator,
});

final class $$ReadsTableReferences
    extends BaseReferences<_$AppDb, $ReadsTable, Read> {
  $$ReadsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDb db) =>
      db.books.createAlias('reads__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadsTableFilterComposer extends Composer<_$AppDb, $ReadsTable> {
  $$ReadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get started => $composableBuilder(
    column: $table.started,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finished => $composableBuilder(
    column: $table.finished,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thoughts => $composableBuilder(
    column: $table.thoughts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get narrator => $composableBuilder(
    column: $table.narrator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heat => $composableBuilder(
    column: $table.heat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentNotes => $composableBuilder(
    column: $table.contentNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ratingStory => $composableBuilder(
    column: $table.ratingStory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ratingCharacters => $composableBuilder(
    column: $table.ratingCharacters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ratingWriting => $composableBuilder(
    column: $table.ratingWriting,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ratingPace => $composableBuilder(
    column: $table.ratingPace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ratingFeeling => $composableBuilder(
    column: $table.ratingFeeling,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ratingNarrator => $composableBuilder(
    column: $table.ratingNarrator,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadsTableOrderingComposer extends Composer<_$AppDb, $ReadsTable> {
  $$ReadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get started => $composableBuilder(
    column: $table.started,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finished => $composableBuilder(
    column: $table.finished,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thoughts => $composableBuilder(
    column: $table.thoughts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get narrator => $composableBuilder(
    column: $table.narrator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heat => $composableBuilder(
    column: $table.heat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentNotes => $composableBuilder(
    column: $table.contentNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ratingStory => $composableBuilder(
    column: $table.ratingStory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ratingCharacters => $composableBuilder(
    column: $table.ratingCharacters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ratingWriting => $composableBuilder(
    column: $table.ratingWriting,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ratingPace => $composableBuilder(
    column: $table.ratingPace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ratingFeeling => $composableBuilder(
    column: $table.ratingFeeling,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ratingNarrator => $composableBuilder(
    column: $table.ratingNarrator,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadsTableAnnotationComposer extends Composer<_$AppDb, $ReadsTable> {
  $$ReadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get started =>
      $composableBuilder(column: $table.started, builder: (column) => column);

  GeneratedColumn<DateTime> get finished =>
      $composableBuilder(column: $table.finished, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get thoughts =>
      $composableBuilder(column: $table.thoughts, builder: (column) => column);

  GeneratedColumn<String> get narrator =>
      $composableBuilder(column: $table.narrator, builder: (column) => column);

  GeneratedColumn<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);

  GeneratedColumn<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get heat =>
      $composableBuilder(column: $table.heat, builder: (column) => column);

  GeneratedColumn<String> get contentNotes => $composableBuilder(
    column: $table.contentNotes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ratingStory => $composableBuilder(
    column: $table.ratingStory,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ratingCharacters => $composableBuilder(
    column: $table.ratingCharacters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ratingWriting => $composableBuilder(
    column: $table.ratingWriting,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ratingPace => $composableBuilder(
    column: $table.ratingPace,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ratingFeeling => $composableBuilder(
    column: $table.ratingFeeling,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ratingNarrator => $composableBuilder(
    column: $table.ratingNarrator,
    builder: (column) => column,
  );

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ReadsTable,
          Read,
          $$ReadsTableFilterComposer,
          $$ReadsTableOrderingComposer,
          $$ReadsTableAnnotationComposer,
          $$ReadsTableCreateCompanionBuilder,
          $$ReadsTableUpdateCompanionBuilder,
          (Read, $$ReadsTableReferences),
          Read,
          PrefetchHooks Function({bool bookId})
        > {
  $$ReadsTableTableManager(_$AppDb db, $ReadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> started = const Value.absent(),
                Value<DateTime?> finished = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<String> thoughts = const Value.absent(),
                Value<String> narrator = const Value.absent(),
                Value<int?> minutes = const Value.absent(),
                Value<int?> currentPage = const Value.absent(),
                Value<int?> heat = const Value.absent(),
                Value<String> contentNotes = const Value.absent(),
                Value<double?> ratingStory = const Value.absent(),
                Value<double?> ratingCharacters = const Value.absent(),
                Value<double?> ratingWriting = const Value.absent(),
                Value<double?> ratingPace = const Value.absent(),
                Value<double?> ratingFeeling = const Value.absent(),
                Value<double?> ratingNarrator = const Value.absent(),
              }) => ReadsCompanion(
                id: id,
                bookId: bookId,
                format: format,
                status: status,
                started: started,
                finished: finished,
                rating: rating,
                thoughts: thoughts,
                narrator: narrator,
                minutes: minutes,
                currentPage: currentPage,
                heat: heat,
                contentNotes: contentNotes,
                ratingStory: ratingStory,
                ratingCharacters: ratingCharacters,
                ratingWriting: ratingWriting,
                ratingPace: ratingPace,
                ratingFeeling: ratingFeeling,
                ratingNarrator: ratingNarrator,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                Value<String> format = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> started = const Value.absent(),
                Value<DateTime?> finished = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<String> thoughts = const Value.absent(),
                Value<String> narrator = const Value.absent(),
                Value<int?> minutes = const Value.absent(),
                Value<int?> currentPage = const Value.absent(),
                Value<int?> heat = const Value.absent(),
                Value<String> contentNotes = const Value.absent(),
                Value<double?> ratingStory = const Value.absent(),
                Value<double?> ratingCharacters = const Value.absent(),
                Value<double?> ratingWriting = const Value.absent(),
                Value<double?> ratingPace = const Value.absent(),
                Value<double?> ratingFeeling = const Value.absent(),
                Value<double?> ratingNarrator = const Value.absent(),
              }) => ReadsCompanion.insert(
                id: id,
                bookId: bookId,
                format: format,
                status: status,
                started: started,
                finished: finished,
                rating: rating,
                thoughts: thoughts,
                narrator: narrator,
                minutes: minutes,
                currentPage: currentPage,
                heat: heat,
                contentNotes: contentNotes,
                ratingStory: ratingStory,
                ratingCharacters: ratingCharacters,
                ratingWriting: ratingWriting,
                ratingPace: ratingPace,
                ratingFeeling: ratingFeeling,
                ratingNarrator: ratingNarrator,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadsTable, Read>(table),
                  $$ReadsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$ReadsTableReferences._bookIdTable(
                          db,
                        ),
                        referencedColumn: $$ReadsTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ReadsTable,
      Read,
      $$ReadsTableFilterComposer,
      $$ReadsTableOrderingComposer,
      $$ReadsTableAnnotationComposer,
      $$ReadsTableCreateCompanionBuilder,
      $$ReadsTableUpdateCompanionBuilder,
      (Read, $$ReadsTableReferences),
      Read,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$ShelvesTableCreateCompanionBuilder = ShelvesCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$ShelvesTableUpdateCompanionBuilder = ShelvesCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$ShelvesTableReferences
    extends BaseReferences<_$AppDb, $ShelvesTable, Shelf> {
  $$ShelvesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookShelvesTable, List<BookShelf>>
  _bookShelvesRefsTable(_$AppDb db) => MultiTypedResultKey.fromTable(
    db.bookShelves,
    aliasName: 'shelves__id__book_shelves__shelf_id',
  );

  $$BookShelvesTableProcessedTableManager get bookShelvesRefs {
    final manager = $$BookShelvesTableTableManager(
      $_db,
      $_db.bookShelves,
    ).filter((f) => f.shelfId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookShelvesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ShelvesTableFilterComposer extends Composer<_$AppDb, $ShelvesTable> {
  $$ShelvesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookShelvesRefs(
    Expression<bool> Function($$BookShelvesTableFilterComposer f) f,
  ) {
    final $$BookShelvesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookShelves,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookShelvesTableFilterComposer(
            $db: $db,
            $table: $db.bookShelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelvesTableOrderingComposer extends Composer<_$AppDb, $ShelvesTable> {
  $$ShelvesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShelvesTableAnnotationComposer
    extends Composer<_$AppDb, $ShelvesTable> {
  $$ShelvesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> bookShelvesRefs<T extends Object>(
    Expression<T> Function($$BookShelvesTableAnnotationComposer a) f,
  ) {
    final $$BookShelvesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookShelves,
      getReferencedColumn: (t) => t.shelfId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookShelvesTableAnnotationComposer(
            $db: $db,
            $table: $db.bookShelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ShelvesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ShelvesTable,
          Shelf,
          $$ShelvesTableFilterComposer,
          $$ShelvesTableOrderingComposer,
          $$ShelvesTableAnnotationComposer,
          $$ShelvesTableCreateCompanionBuilder,
          $$ShelvesTableUpdateCompanionBuilder,
          (Shelf, $$ShelvesTableReferences),
          Shelf,
          PrefetchHooks Function({bool bookShelvesRefs})
        > {
  $$ShelvesTableTableManager(_$AppDb db, $ShelvesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShelvesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShelvesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShelvesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) => ShelvesCompanion(id: id, name: name),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) => ShelvesCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ShelvesTable, Shelf>(table),
                  $$ShelvesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookShelvesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookShelvesRefs) db.bookShelves],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookShelvesRefs)
                    await $_getPrefetchedData<Shelf, $ShelvesTable, BookShelf>(
                      currentTable: table,
                      referencedTable: $$ShelvesTableReferences
                          ._bookShelvesRefsTable(db),
                      managerFromTypedResult: (p0) => $$ShelvesTableReferences(
                        db,
                        table,
                        p0,
                      ).bookShelvesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.shelfId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ShelvesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ShelvesTable,
      Shelf,
      $$ShelvesTableFilterComposer,
      $$ShelvesTableOrderingComposer,
      $$ShelvesTableAnnotationComposer,
      $$ShelvesTableCreateCompanionBuilder,
      $$ShelvesTableUpdateCompanionBuilder,
      (Shelf, $$ShelvesTableReferences),
      Shelf,
      PrefetchHooks Function({bool bookShelvesRefs})
    >;
typedef $$BookShelvesTableCreateCompanionBuilder =
    BookShelvesCompanion Function({
      required int bookId,
      required int shelfId,
      Value<int> rowid,
    });
typedef $$BookShelvesTableUpdateCompanionBuilder =
    BookShelvesCompanion Function({
      Value<int> bookId,
      Value<int> shelfId,
      Value<int> rowid,
    });

final class $$BookShelvesTableReferences
    extends BaseReferences<_$AppDb, $BookShelvesTable, BookShelf> {
  $$BookShelvesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDb db) =>
      db.books.createAlias('book_shelves__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ShelvesTable _shelfIdTable(_$AppDb db) =>
      db.shelves.createAlias('book_shelves__shelf_id__shelves__id');

  $$ShelvesTableProcessedTableManager get shelfId {
    final $_column = $_itemColumn<int>('shelf_id')!;

    final manager = $$ShelvesTableTableManager(
      $_db,
      $_db.shelves,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_shelfIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookShelvesTableFilterComposer
    extends Composer<_$AppDb, $BookShelvesTable> {
  $$BookShelvesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShelvesTableFilterComposer get shelfId {
    final $$ShelvesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableFilterComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookShelvesTableOrderingComposer
    extends Composer<_$AppDb, $BookShelvesTable> {
  $$BookShelvesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShelvesTableOrderingComposer get shelfId {
    final $$ShelvesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableOrderingComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookShelvesTableAnnotationComposer
    extends Composer<_$AppDb, $BookShelvesTable> {
  $$BookShelvesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ShelvesTableAnnotationComposer get shelfId {
    final $$ShelvesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.shelfId,
      referencedTable: $db.shelves,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ShelvesTableAnnotationComposer(
            $db: $db,
            $table: $db.shelves,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookShelvesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $BookShelvesTable,
          BookShelf,
          $$BookShelvesTableFilterComposer,
          $$BookShelvesTableOrderingComposer,
          $$BookShelvesTableAnnotationComposer,
          $$BookShelvesTableCreateCompanionBuilder,
          $$BookShelvesTableUpdateCompanionBuilder,
          (BookShelf, $$BookShelvesTableReferences),
          BookShelf,
          PrefetchHooks Function({bool bookId, bool shelfId})
        > {
  $$BookShelvesTableTableManager(_$AppDb db, $BookShelvesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookShelvesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookShelvesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookShelvesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> bookId = const Value.absent(),
                Value<int> shelfId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookShelvesCompanion(
                bookId: bookId,
                shelfId: shelfId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int bookId,
                required int shelfId,
                Value<int> rowid = const Value.absent(),
              }) => BookShelvesCompanion.insert(
                bookId: bookId,
                shelfId: shelfId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookShelvesTable, BookShelf>(table),
                  $$BookShelvesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, shelfId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$BookShelvesTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$BookShelvesTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (shelfId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.shelfId,
                        referencedTable: $$BookShelvesTableReferences
                            ._shelfIdTable(db),
                        referencedColumn: $$BookShelvesTableReferences
                            ._shelfIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookShelvesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $BookShelvesTable,
      BookShelf,
      $$BookShelvesTableFilterComposer,
      $$BookShelvesTableOrderingComposer,
      $$BookShelvesTableAnnotationComposer,
      $$BookShelvesTableCreateCompanionBuilder,
      $$BookShelvesTableUpdateCompanionBuilder,
      (BookShelf, $$BookShelvesTableReferences),
      BookShelf,
      PrefetchHooks Function({bool bookId, bool shelfId})
    >;
typedef $$QuotesTableCreateCompanionBuilder = QuotesCompanion Function({
  Value<int> id,
  required int bookId,
  required String body,
  Value<int?> page,
  Value<String> note,
  Value<double?> rating,
  Value<DateTime> created,
});
typedef $$QuotesTableUpdateCompanionBuilder = QuotesCompanion Function({
  Value<int> id,
  Value<int> bookId,
  Value<String> body,
  Value<int?> page,
  Value<String> note,
  Value<double?> rating,
  Value<DateTime> created,
});

final class $$QuotesTableReferences
    extends BaseReferences<_$AppDb, $QuotesTable, Quote> {
  $$QuotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDb db) =>
      db.books.createAlias('quotes__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuotesTableFilterComposer extends Composer<_$AppDb, $QuotesTable> {
  $$QuotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotesTableOrderingComposer extends Composer<_$AppDb, $QuotesTable> {
  $$QuotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotesTableAnnotationComposer extends Composer<_$AppDb, $QuotesTable> {
  $$QuotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<double> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<DateTime> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $QuotesTable,
          Quote,
          $$QuotesTableFilterComposer,
          $$QuotesTableOrderingComposer,
          $$QuotesTableAnnotationComposer,
          $$QuotesTableCreateCompanionBuilder,
          $$QuotesTableUpdateCompanionBuilder,
          (Quote, $$QuotesTableReferences),
          Quote,
          PrefetchHooks Function({bool bookId})
        > {
  $$QuotesTableTableManager(_$AppDb db, $QuotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int?> page = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<DateTime> created = const Value.absent(),
              }) => QuotesCompanion(
                id: id,
                bookId: bookId,
                body: body,
                page: page,
                note: note,
                rating: rating,
                created: created,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required String body,
                Value<int?> page = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<double?> rating = const Value.absent(),
                Value<DateTime> created = const Value.absent(),
              }) => QuotesCompanion.insert(
                id: id,
                bookId: bookId,
                body: body,
                page: page,
                note: note,
                rating: rating,
                created: created,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuotesTable, Quote>(table),
                  $$QuotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$QuotesTableReferences._bookIdTable(
                          db,
                        ),
                        referencedColumn: $$QuotesTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $QuotesTable,
      Quote,
      $$QuotesTableFilterComposer,
      $$QuotesTableOrderingComposer,
      $$QuotesTableAnnotationComposer,
      $$QuotesTableCreateCompanionBuilder,
      $$QuotesTableUpdateCompanionBuilder,
      (Quote, $$QuotesTableReferences),
      Quote,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$ReadingSessionsTableCreateCompanionBuilder =
    ReadingSessionsCompanion Function({
      Value<int> id,
      required int bookId,
      required DateTime day,
      required int minutes,
      Value<int?> pages,
    });
typedef $$ReadingSessionsTableUpdateCompanionBuilder =
    ReadingSessionsCompanion Function({
      Value<int> id,
      Value<int> bookId,
      Value<DateTime> day,
      Value<int> minutes,
      Value<int?> pages,
    });

final class $$ReadingSessionsTableReferences
    extends BaseReferences<_$AppDb, $ReadingSessionsTable, ReadingSession> {
  $$ReadingSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BooksTable _bookIdTable(_$AppDb db) =>
      db.books.createAlias('reading_sessions__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingSessionsTableFilterComposer
    extends Composer<_$AppDb, $ReadingSessionsTable> {
  $$ReadingSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pages => $composableBuilder(
    column: $table.pages,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingSessionsTableOrderingComposer
    extends Composer<_$AppDb, $ReadingSessionsTable> {
  $$ReadingSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pages => $composableBuilder(
    column: $table.pages,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingSessionsTableAnnotationComposer
    extends Composer<_$AppDb, $ReadingSessionsTable> {
  $$ReadingSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);

  GeneratedColumn<int> get pages =>
      $composableBuilder(column: $table.pages, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $ReadingSessionsTable,
          ReadingSession,
          $$ReadingSessionsTableFilterComposer,
          $$ReadingSessionsTableOrderingComposer,
          $$ReadingSessionsTableAnnotationComposer,
          $$ReadingSessionsTableCreateCompanionBuilder,
          $$ReadingSessionsTableUpdateCompanionBuilder,
          (ReadingSession, $$ReadingSessionsTableReferences),
          ReadingSession,
          PrefetchHooks Function({bool bookId})
        > {
  $$ReadingSessionsTableTableManager(_$AppDb db, $ReadingSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<DateTime> day = const Value.absent(),
                Value<int> minutes = const Value.absent(),
                Value<int?> pages = const Value.absent(),
              }) => ReadingSessionsCompanion(
                id: id,
                bookId: bookId,
                day: day,
                minutes: minutes,
                pages: pages,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required DateTime day,
                required int minutes,
                Value<int?> pages = const Value.absent(),
              }) => ReadingSessionsCompanion.insert(
                id: id,
                bookId: bookId,
                day: day,
                minutes: minutes,
                pages: pages,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingSessionsTable, ReadingSession>(table),
                  $$ReadingSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$ReadingSessionsTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$ReadingSessionsTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadingSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $ReadingSessionsTable,
      ReadingSession,
      $$ReadingSessionsTableFilterComposer,
      $$ReadingSessionsTableOrderingComposer,
      $$ReadingSessionsTableAnnotationComposer,
      $$ReadingSessionsTableCreateCompanionBuilder,
      $$ReadingSessionsTableUpdateCompanionBuilder,
      (ReadingSession, $$ReadingSessionsTableReferences),
      ReadingSession,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$LoansTableCreateCompanionBuilder = LoansCompanion Function({
  Value<int> id,
  required int bookId,
  required String person,
  required DateTime lentOn,
  Value<DateTime?> remindOn,
  Value<DateTime?> returnedOn,
});
typedef $$LoansTableUpdateCompanionBuilder = LoansCompanion Function({
  Value<int> id,
  Value<int> bookId,
  Value<String> person,
  Value<DateTime> lentOn,
  Value<DateTime?> remindOn,
  Value<DateTime?> returnedOn,
});

final class $$LoansTableReferences
    extends BaseReferences<_$AppDb, $LoansTable, Loan> {
  $$LoansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDb db) =>
      db.books.createAlias('loans__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<int>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LoansTableFilterComposer extends Composer<_$AppDb, $LoansTable> {
  $$LoansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get person => $composableBuilder(
    column: $table.person,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lentOn => $composableBuilder(
    column: $table.lentOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get remindOn => $composableBuilder(
    column: $table.remindOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get returnedOn => $composableBuilder(
    column: $table.returnedOn,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoansTableOrderingComposer extends Composer<_$AppDb, $LoansTable> {
  $$LoansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get person => $composableBuilder(
    column: $table.person,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lentOn => $composableBuilder(
    column: $table.lentOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get remindOn => $composableBuilder(
    column: $table.remindOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get returnedOn => $composableBuilder(
    column: $table.returnedOn,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoansTableAnnotationComposer extends Composer<_$AppDb, $LoansTable> {
  $$LoansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get person =>
      $composableBuilder(column: $table.person, builder: (column) => column);

  GeneratedColumn<DateTime> get lentOn =>
      $composableBuilder(column: $table.lentOn, builder: (column) => column);

  GeneratedColumn<DateTime> get remindOn =>
      $composableBuilder(column: $table.remindOn, builder: (column) => column);

  GeneratedColumn<DateTime> get returnedOn => $composableBuilder(
    column: $table.returnedOn,
    builder: (column) => column,
  );

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoansTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $LoansTable,
          Loan,
          $$LoansTableFilterComposer,
          $$LoansTableOrderingComposer,
          $$LoansTableAnnotationComposer,
          $$LoansTableCreateCompanionBuilder,
          $$LoansTableUpdateCompanionBuilder,
          (Loan, $$LoansTableReferences),
          Loan,
          PrefetchHooks Function({bool bookId})
        > {
  $$LoansTableTableManager(_$AppDb db, $LoansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bookId = const Value.absent(),
                Value<String> person = const Value.absent(),
                Value<DateTime> lentOn = const Value.absent(),
                Value<DateTime?> remindOn = const Value.absent(),
                Value<DateTime?> returnedOn = const Value.absent(),
              }) => LoansCompanion(
                id: id,
                bookId: bookId,
                person: person,
                lentOn: lentOn,
                remindOn: remindOn,
                returnedOn: returnedOn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bookId,
                required String person,
                required DateTime lentOn,
                Value<DateTime?> remindOn = const Value.absent(),
                Value<DateTime?> returnedOn = const Value.absent(),
              }) => LoansCompanion.insert(
                id: id,
                bookId: bookId,
                person: person,
                lentOn: lentOn,
                remindOn: remindOn,
                returnedOn: returnedOn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LoansTable, Loan>(table),
                  $$LoansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$LoansTableReferences._bookIdTable(
                          db,
                        ),
                        referencedColumn: $$LoansTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LoansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $LoansTable,
      Loan,
      $$LoansTableFilterComposer,
      $$LoansTableOrderingComposer,
      $$LoansTableAnnotationComposer,
      $$LoansTableCreateCompanionBuilder,
      $$LoansTableUpdateCompanionBuilder,
      (Loan, $$LoansTableReferences),
      Loan,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$SeriesInfoTableCreateCompanionBuilder = SeriesInfoCompanion Function({
  Value<int> id,
  required String nameKey,
  required String name,
  Value<bool> locked,
  Value<int?> total,
  Value<String> status,
});
typedef $$SeriesInfoTableUpdateCompanionBuilder = SeriesInfoCompanion Function({
  Value<int> id,
  Value<String> nameKey,
  Value<String> name,
  Value<bool> locked,
  Value<int?> total,
  Value<String> status,
});

class $$SeriesInfoTableFilterComposer
    extends Composer<_$AppDb, $SeriesInfoTable> {
  $$SeriesInfoTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeriesInfoTableOrderingComposer
    extends Composer<_$AppDb, $SeriesInfoTable> {
  $$SeriesInfoTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameKey => $composableBuilder(
    column: $table.nameKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeriesInfoTableAnnotationComposer
    extends Composer<_$AppDb, $SeriesInfoTable> {
  $$SeriesInfoTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nameKey =>
      $composableBuilder(column: $table.nameKey, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);

  GeneratedColumn<int> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$SeriesInfoTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $SeriesInfoTable,
          SeriesInfoRow,
          $$SeriesInfoTableFilterComposer,
          $$SeriesInfoTableOrderingComposer,
          $$SeriesInfoTableAnnotationComposer,
          $$SeriesInfoTableCreateCompanionBuilder,
          $$SeriesInfoTableUpdateCompanionBuilder,
          (
            SeriesInfoRow,
            BaseReferences<_$AppDb, $SeriesInfoTable, SeriesInfoRow>,
          ),
          SeriesInfoRow,
          PrefetchHooks Function()
        > {
  $$SeriesInfoTableTableManager(_$AppDb db, $SeriesInfoTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeriesInfoTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeriesInfoTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeriesInfoTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nameKey = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<int?> total = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => SeriesInfoCompanion(
                id: id,
                nameKey: nameKey,
                name: name,
                locked: locked,
                total: total,
                status: status,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nameKey,
                required String name,
                Value<bool> locked = const Value.absent(),
                Value<int?> total = const Value.absent(),
                Value<String> status = const Value.absent(),
              }) => SeriesInfoCompanion.insert(
                id: id,
                nameKey: nameKey,
                name: name,
                locked: locked,
                total: total,
                status: status,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SeriesInfoTable, SeriesInfoRow>(table),
                  BaseReferences<_$AppDb, $SeriesInfoTable, SeriesInfoRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeriesInfoTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $SeriesInfoTable,
      SeriesInfoRow,
      $$SeriesInfoTableFilterComposer,
      $$SeriesInfoTableOrderingComposer,
      $$SeriesInfoTableAnnotationComposer,
      $$SeriesInfoTableCreateCompanionBuilder,
      $$SeriesInfoTableUpdateCompanionBuilder,
      (SeriesInfoRow, BaseReferences<_$AppDb, $SeriesInfoTable, SeriesInfoRow>),
      SeriesInfoRow,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$ReadsTableTableManager get reads =>
      $$ReadsTableTableManager(_db, _db.reads);
  $$ShelvesTableTableManager get shelves =>
      $$ShelvesTableTableManager(_db, _db.shelves);
  $$BookShelvesTableTableManager get bookShelves =>
      $$BookShelvesTableTableManager(_db, _db.bookShelves);
  $$QuotesTableTableManager get quotes =>
      $$QuotesTableTableManager(_db, _db.quotes);
  $$ReadingSessionsTableTableManager get readingSessions =>
      $$ReadingSessionsTableTableManager(_db, _db.readingSessions);
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db, _db.loans);
  $$SeriesInfoTableTableManager get seriesInfo =>
      $$SeriesInfoTableTableManager(_db, _db.seriesInfo);
}
