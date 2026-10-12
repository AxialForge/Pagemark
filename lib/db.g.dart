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
    publisher,
    year,
    pages,
    description,
    tags,
    notes,
    locked,
    added,
    deletedAt,
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
  final String publisher;
  final int? year;
  final int? pages;
  final String description;
  final String tags;
  final String notes;
  final bool locked;
  final DateTime added;
  final DateTime? deletedAt;
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.coverUrl,
    required this.genre,
    required this.series,
    this.seriesNumber,
    required this.publisher,
    this.year,
    this.pages,
    required this.description,
    required this.tags,
    required this.notes,
    required this.locked,
    required this.added,
    this.deletedAt,
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
      publisher: serializer.fromJson<String>(json['publisher']),
      year: serializer.fromJson<int?>(json['year']),
      pages: serializer.fromJson<int?>(json['pages']),
      description: serializer.fromJson<String>(json['description']),
      tags: serializer.fromJson<String>(json['tags']),
      notes: serializer.fromJson<String>(json['notes']),
      locked: serializer.fromJson<bool>(json['locked']),
      added: serializer.fromJson<DateTime>(json['added']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
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
      'publisher': serializer.toJson<String>(publisher),
      'year': serializer.toJson<int?>(year),
      'pages': serializer.toJson<int?>(pages),
      'description': serializer.toJson<String>(description),
      'tags': serializer.toJson<String>(tags),
      'notes': serializer.toJson<String>(notes),
      'locked': serializer.toJson<bool>(locked),
      'added': serializer.toJson<DateTime>(added),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
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
    String? publisher,
    Value<int?> year = const Value.absent(),
    Value<int?> pages = const Value.absent(),
    String? description,
    String? tags,
    String? notes,
    bool? locked,
    DateTime? added,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Book(
    id: id ?? this.id,
    title: title ?? this.title,
    author: author ?? this.author,
    isbn: isbn ?? this.isbn,
    coverUrl: coverUrl ?? this.coverUrl,
    genre: genre ?? this.genre,
    series: series ?? this.series,
    seriesNumber: seriesNumber.present ? seriesNumber.value : this.seriesNumber,
    publisher: publisher ?? this.publisher,
    year: year.present ? year.value : this.year,
    pages: pages.present ? pages.value : this.pages,
    description: description ?? this.description,
    tags: tags ?? this.tags,
    notes: notes ?? this.notes,
    locked: locked ?? this.locked,
    added: added ?? this.added,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
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
          ..write('publisher: $publisher, ')
          ..write('year: $year, ')
          ..write('pages: $pages, ')
          ..write('description: $description, ')
          ..write('tags: $tags, ')
          ..write('notes: $notes, ')
          ..write('locked: $locked, ')
          ..write('added: $added, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    author,
    isbn,
    coverUrl,
    genre,
    series,
    seriesNumber,
    publisher,
    year,
    pages,
    description,
    tags,
    notes,
    locked,
    added,
    deletedAt,
  );
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
          other.publisher == this.publisher &&
          other.year == this.year &&
          other.pages == this.pages &&
          other.description == this.description &&
          other.tags == this.tags &&
          other.notes == this.notes &&
          other.locked == this.locked &&
          other.added == this.added &&
          other.deletedAt == this.deletedAt);
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
  final Value<String> publisher;
  final Value<int?> year;
  final Value<int?> pages;
  final Value<String> description;
  final Value<String> tags;
  final Value<String> notes;
  final Value<bool> locked;
  final Value<DateTime> added;
  final Value<DateTime?> deletedAt;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.isbn = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.genre = const Value.absent(),
    this.series = const Value.absent(),
    this.seriesNumber = const Value.absent(),
    this.publisher = const Value.absent(),
    this.year = const Value.absent(),
    this.pages = const Value.absent(),
    this.description = const Value.absent(),
    this.tags = const Value.absent(),
    this.notes = const Value.absent(),
    this.locked = const Value.absent(),
    this.added = const Value.absent(),
    this.deletedAt = const Value.absent(),
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
    this.publisher = const Value.absent(),
    this.year = const Value.absent(),
    this.pages = const Value.absent(),
    this.description = const Value.absent(),
    this.tags = const Value.absent(),
    this.notes = const Value.absent(),
    this.locked = const Value.absent(),
    this.added = const Value.absent(),
    this.deletedAt = const Value.absent(),
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
    Expression<String>? publisher,
    Expression<int>? year,
    Expression<int>? pages,
    Expression<String>? description,
    Expression<String>? tags,
    Expression<String>? notes,
    Expression<bool>? locked,
    Expression<DateTime>? added,
    Expression<DateTime>? deletedAt,
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
      if (publisher != null) 'publisher': publisher,
      if (year != null) 'year': year,
      if (pages != null) 'pages': pages,
      if (description != null) 'description': description,
      if (tags != null) 'tags': tags,
      if (notes != null) 'notes': notes,
      if (locked != null) 'locked': locked,
      if (added != null) 'added': added,
      if (deletedAt != null) 'deleted_at': deletedAt,
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
    Value<String>? publisher,
    Value<int?>? year,
    Value<int?>? pages,
    Value<String>? description,
    Value<String>? tags,
    Value<String>? notes,
    Value<bool>? locked,
    Value<DateTime>? added,
    Value<DateTime?>? deletedAt,
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
      publisher: publisher ?? this.publisher,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      locked: locked ?? this.locked,
      added: added ?? this.added,
      deletedAt: deletedAt ?? this.deletedAt,
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
          ..write('publisher: $publisher, ')
          ..write('year: $year, ')
          ..write('pages: $pages, ')
          ..write('description: $description, ')
          ..write('tags: $tags, ')
          ..write('notes: $notes, ')
          ..write('locked: $locked, ')
          ..write('added: $added, ')
          ..write('deletedAt: $deletedAt')
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
          ..write('currentPage: $currentPage')
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
          other.currentPage == this.currentPage);
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
          ..write('currentPage: $currentPage')
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

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $ReadsTable reads = $ReadsTable(this);
  late final $ShelvesTable shelves = $ShelvesTable(this);
  late final $BookShelvesTable bookShelves = $BookShelvesTable(this);
  late final Index booksLocked = Index(
    'books_locked',
    'CREATE INDEX books_locked ON books (locked)',
  );
  late final Index booksTitle = Index(
    'books_title',
    'CREATE INDEX books_title ON books (title)',
  );
  late final Index readsBook = Index(
    'reads_book',
    'CREATE INDEX reads_book ON reads (book_id)',
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
    booksLocked,
    booksTitle,
    readsBook,
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
  Value<String> publisher,
  Value<int?> year,
  Value<int?> pages,
  Value<String> description,
  Value<String> tags,
  Value<String> notes,
  Value<bool> locked,
  Value<DateTime> added,
  Value<DateTime?> deletedAt,
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
  Value<String> publisher,
  Value<int?> year,
  Value<int?> pages,
  Value<String> description,
  Value<String> tags,
  Value<String> notes,
  Value<bool> locked,
  Value<DateTime> added,
  Value<DateTime?> deletedAt,
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
          PrefetchHooks Function({bool readsRefs, bool bookShelvesRefs})
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
                Value<String> publisher = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<int?> pages = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<DateTime> added = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                title: title,
                author: author,
                isbn: isbn,
                coverUrl: coverUrl,
                genre: genre,
                series: series,
                seriesNumber: seriesNumber,
                publisher: publisher,
                year: year,
                pages: pages,
                description: description,
                tags: tags,
                notes: notes,
                locked: locked,
                added: added,
                deletedAt: deletedAt,
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
                Value<String> publisher = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<int?> pages = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<DateTime> added = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                title: title,
                author: author,
                isbn: isbn,
                coverUrl: coverUrl,
                genre: genre,
                series: series,
                seriesNumber: seriesNumber,
                publisher: publisher,
                year: year,
                pages: pages,
                description: description,
                tags: tags,
                notes: notes,
                locked: locked,
                added: added,
                deletedAt: deletedAt,
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
              ({readsRefs = false, bookShelvesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (readsRefs) db.reads,
                    if (bookShelvesRefs) db.bookShelves,
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
      PrefetchHooks Function({bool readsRefs, bool bookShelvesRefs})
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
}
