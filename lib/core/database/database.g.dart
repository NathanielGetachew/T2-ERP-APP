// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, CustomerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idPhotoFrontMeta = const VerificationMeta(
    'idPhotoFront',
  );
  @override
  late final GeneratedColumn<String> idPhotoFront = GeneratedColumn<String>(
    'id_photo_front',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idPhotoBackMeta = const VerificationMeta(
    'idPhotoBack',
  );
  @override
  late final GeneratedColumn<String> idPhotoBack = GeneratedColumn<String>(
    'id_photo_back',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidedAtMeta = const VerificationMeta(
    'voidedAt',
  );
  @override
  late final GeneratedColumn<DateTime> voidedAt = GeneratedColumn<DateTime>(
    'voided_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    fullName,
    phone,
    address,
    idPhotoFront,
    idPhotoBack,
    notes,
    voidedAt,
    voidReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('id_photo_front')) {
      context.handle(
        _idPhotoFrontMeta,
        idPhotoFront.isAcceptableOrUnknown(
          data['id_photo_front']!,
          _idPhotoFrontMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idPhotoFrontMeta);
    }
    if (data.containsKey('id_photo_back')) {
      context.handle(
        _idPhotoBackMeta,
        idPhotoBack.isAcceptableOrUnknown(
          data['id_photo_back']!,
          _idPhotoBackMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('voided_at')) {
      context.handle(
        _voidedAtMeta,
        voidedAt.isAcceptableOrUnknown(data['voided_at']!, _voidedAtMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      idPhotoFront: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id_photo_front'],
      )!,
      idPhotoBack: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id_photo_back'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      voidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}voided_at'],
      ),
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class CustomerRow extends DataClass implements Insertable<CustomerRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String fullName;
  final String phone;
  final String address;
  final String idPhotoFront;
  final String? idPhotoBack;
  final String? notes;
  final DateTime? voidedAt;
  final String? voidReason;
  const CustomerRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.fullName,
    required this.phone,
    required this.address,
    required this.idPhotoFront,
    this.idPhotoBack,
    this.notes,
    this.voidedAt,
    this.voidReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['full_name'] = Variable<String>(fullName);
    map['phone'] = Variable<String>(phone);
    map['address'] = Variable<String>(address);
    map['id_photo_front'] = Variable<String>(idPhotoFront);
    if (!nullToAbsent || idPhotoBack != null) {
      map['id_photo_back'] = Variable<String>(idPhotoBack);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || voidedAt != null) {
      map['voided_at'] = Variable<DateTime>(voidedAt);
    }
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      fullName: Value(fullName),
      phone: Value(phone),
      address: Value(address),
      idPhotoFront: Value(idPhotoFront),
      idPhotoBack: idPhotoBack == null && nullToAbsent
          ? const Value.absent()
          : Value(idPhotoBack),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      voidedAt: voidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedAt),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
    );
  }

  factory CustomerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      fullName: serializer.fromJson<String>(json['fullName']),
      phone: serializer.fromJson<String>(json['phone']),
      address: serializer.fromJson<String>(json['address']),
      idPhotoFront: serializer.fromJson<String>(json['idPhotoFront']),
      idPhotoBack: serializer.fromJson<String?>(json['idPhotoBack']),
      notes: serializer.fromJson<String?>(json['notes']),
      voidedAt: serializer.fromJson<DateTime?>(json['voidedAt']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'fullName': serializer.toJson<String>(fullName),
      'phone': serializer.toJson<String>(phone),
      'address': serializer.toJson<String>(address),
      'idPhotoFront': serializer.toJson<String>(idPhotoFront),
      'idPhotoBack': serializer.toJson<String?>(idPhotoBack),
      'notes': serializer.toJson<String?>(notes),
      'voidedAt': serializer.toJson<DateTime?>(voidedAt),
      'voidReason': serializer.toJson<String?>(voidReason),
    };
  }

  CustomerRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fullName,
    String? phone,
    String? address,
    String? idPhotoFront,
    Value<String?> idPhotoBack = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> voidedAt = const Value.absent(),
    Value<String?> voidReason = const Value.absent(),
  }) => CustomerRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    fullName: fullName ?? this.fullName,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    idPhotoFront: idPhotoFront ?? this.idPhotoFront,
    idPhotoBack: idPhotoBack.present ? idPhotoBack.value : this.idPhotoBack,
    notes: notes.present ? notes.value : this.notes,
    voidedAt: voidedAt.present ? voidedAt.value : this.voidedAt,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
  );
  CustomerRow copyWithCompanion(CustomersCompanion data) {
    return CustomerRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      idPhotoFront: data.idPhotoFront.present
          ? data.idPhotoFront.value
          : this.idPhotoFront,
      idPhotoBack: data.idPhotoBack.present
          ? data.idPhotoBack.value
          : this.idPhotoBack,
      notes: data.notes.present ? data.notes.value : this.notes,
      voidedAt: data.voidedAt.present ? data.voidedAt.value : this.voidedAt,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('idPhotoFront: $idPhotoFront, ')
          ..write('idPhotoBack: $idPhotoBack, ')
          ..write('notes: $notes, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    fullName,
    phone,
    address,
    idPhotoFront,
    idPhotoBack,
    notes,
    voidedAt,
    voidReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.fullName == this.fullName &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.idPhotoFront == this.idPhotoFront &&
          other.idPhotoBack == this.idPhotoBack &&
          other.notes == this.notes &&
          other.voidedAt == this.voidedAt &&
          other.voidReason == this.voidReason);
}

class CustomersCompanion extends UpdateCompanion<CustomerRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> fullName;
  final Value<String> phone;
  final Value<String> address;
  final Value<String> idPhotoFront;
  final Value<String?> idPhotoBack;
  final Value<String?> notes;
  final Value<DateTime?> voidedAt;
  final Value<String?> voidReason;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.fullName = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.idPhotoFront = const Value.absent(),
    this.idPhotoBack = const Value.absent(),
    this.notes = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String fullName,
    required String phone,
    required String address,
    required String idPhotoFront,
    this.idPhotoBack = const Value.absent(),
    this.notes = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       fullName = Value(fullName),
       phone = Value(phone),
       address = Value(address),
       idPhotoFront = Value(idPhotoFront);
  static Insertable<CustomerRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? fullName,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? idPhotoFront,
    Expression<String>? idPhotoBack,
    Expression<String>? notes,
    Expression<DateTime>? voidedAt,
    Expression<String>? voidReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (idPhotoFront != null) 'id_photo_front': idPhotoFront,
      if (idPhotoBack != null) 'id_photo_back': idPhotoBack,
      if (notes != null) 'notes': notes,
      if (voidedAt != null) 'voided_at': voidedAt,
      if (voidReason != null) 'void_reason': voidReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? fullName,
    Value<String>? phone,
    Value<String>? address,
    Value<String>? idPhotoFront,
    Value<String?>? idPhotoBack,
    Value<String?>? notes,
    Value<DateTime?>? voidedAt,
    Value<String?>? voidReason,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      idPhotoFront: idPhotoFront ?? this.idPhotoFront,
      idPhotoBack: idPhotoBack ?? this.idPhotoBack,
      notes: notes ?? this.notes,
      voidedAt: voidedAt ?? this.voidedAt,
      voidReason: voidReason ?? this.voidReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (idPhotoFront.present) {
      map['id_photo_front'] = Variable<String>(idPhotoFront.value);
    }
    if (idPhotoBack.present) {
      map['id_photo_back'] = Variable<String>(idPhotoBack.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (voidedAt.present) {
      map['voided_at'] = Variable<DateTime>(voidedAt.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('idPhotoFront: $idPhotoFront, ')
          ..write('idPhotoBack: $idPhotoBack, ')
          ..write('notes: $notes, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MaterialTypesTable extends MaterialTypes
    with TableInfo<$MaterialTypesTable, MaterialRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaterialTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
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
  static const VerificationMeta _variantMeta = const VerificationMeta(
    'variant',
  );
  @override
  late final GeneratedColumn<String> variant = GeneratedColumn<String>(
    'variant',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pricePerDayMeta = const VerificationMeta(
    'pricePerDay',
  );
  @override
  late final GeneratedColumn<int> pricePerDay = GeneratedColumn<int>(
    'price_per_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalStockMeta = const VerificationMeta(
    'totalStock',
  );
  @override
  late final GeneratedColumn<int> totalStock = GeneratedColumn<int>(
    'total_stock',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    category,
    name,
    variant,
    pricePerDay,
    totalStock,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'material_types';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaterialRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('variant')) {
      context.handle(
        _variantMeta,
        variant.isAcceptableOrUnknown(data['variant']!, _variantMeta),
      );
    }
    if (data.containsKey('price_per_day')) {
      context.handle(
        _pricePerDayMeta,
        pricePerDay.isAcceptableOrUnknown(
          data['price_per_day']!,
          _pricePerDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerDayMeta);
    }
    if (data.containsKey('total_stock')) {
      context.handle(
        _totalStockMeta,
        totalStock.isAcceptableOrUnknown(data['total_stock']!, _totalStockMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaterialRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaterialRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      variant: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}variant'],
      ),
      pricePerDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_per_day'],
      )!,
      totalStock: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_stock'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $MaterialTypesTable createAlias(String alias) {
    return $MaterialTypesTable(attachedDatabase, alias);
  }
}

class MaterialRow extends DataClass implements Insertable<MaterialRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String category;
  final String name;
  final String? variant;
  final int pricePerDay;
  final int? totalStock;
  final bool isActive;
  const MaterialRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.name,
    this.variant,
    required this.pricePerDay,
    this.totalStock,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['category'] = Variable<String>(category);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || variant != null) {
      map['variant'] = Variable<String>(variant);
    }
    map['price_per_day'] = Variable<int>(pricePerDay);
    if (!nullToAbsent || totalStock != null) {
      map['total_stock'] = Variable<int>(totalStock);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  MaterialTypesCompanion toCompanion(bool nullToAbsent) {
    return MaterialTypesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      category: Value(category),
      name: Value(name),
      variant: variant == null && nullToAbsent
          ? const Value.absent()
          : Value(variant),
      pricePerDay: Value(pricePerDay),
      totalStock: totalStock == null && nullToAbsent
          ? const Value.absent()
          : Value(totalStock),
      isActive: Value(isActive),
    );
  }

  factory MaterialRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaterialRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      category: serializer.fromJson<String>(json['category']),
      name: serializer.fromJson<String>(json['name']),
      variant: serializer.fromJson<String?>(json['variant']),
      pricePerDay: serializer.fromJson<int>(json['pricePerDay']),
      totalStock: serializer.fromJson<int?>(json['totalStock']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'category': serializer.toJson<String>(category),
      'name': serializer.toJson<String>(name),
      'variant': serializer.toJson<String?>(variant),
      'pricePerDay': serializer.toJson<int>(pricePerDay),
      'totalStock': serializer.toJson<int?>(totalStock),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  MaterialRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? category,
    String? name,
    Value<String?> variant = const Value.absent(),
    int? pricePerDay,
    Value<int?> totalStock = const Value.absent(),
    bool? isActive,
  }) => MaterialRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    category: category ?? this.category,
    name: name ?? this.name,
    variant: variant.present ? variant.value : this.variant,
    pricePerDay: pricePerDay ?? this.pricePerDay,
    totalStock: totalStock.present ? totalStock.value : this.totalStock,
    isActive: isActive ?? this.isActive,
  );
  MaterialRow copyWithCompanion(MaterialTypesCompanion data) {
    return MaterialRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      category: data.category.present ? data.category.value : this.category,
      name: data.name.present ? data.name.value : this.name,
      variant: data.variant.present ? data.variant.value : this.variant,
      pricePerDay: data.pricePerDay.present
          ? data.pricePerDay.value
          : this.pricePerDay,
      totalStock: data.totalStock.present
          ? data.totalStock.value
          : this.totalStock,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaterialRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('category: $category, ')
          ..write('name: $name, ')
          ..write('variant: $variant, ')
          ..write('pricePerDay: $pricePerDay, ')
          ..write('totalStock: $totalStock, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    category,
    name,
    variant,
    pricePerDay,
    totalStock,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaterialRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.category == this.category &&
          other.name == this.name &&
          other.variant == this.variant &&
          other.pricePerDay == this.pricePerDay &&
          other.totalStock == this.totalStock &&
          other.isActive == this.isActive);
}

class MaterialTypesCompanion extends UpdateCompanion<MaterialRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> category;
  final Value<String> name;
  final Value<String?> variant;
  final Value<int> pricePerDay;
  final Value<int?> totalStock;
  final Value<bool> isActive;
  final Value<int> rowid;
  const MaterialTypesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.category = const Value.absent(),
    this.name = const Value.absent(),
    this.variant = const Value.absent(),
    this.pricePerDay = const Value.absent(),
    this.totalStock = const Value.absent(),
    this.isActive = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MaterialTypesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String category,
    required String name,
    this.variant = const Value.absent(),
    required int pricePerDay,
    this.totalStock = const Value.absent(),
    required bool isActive,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       category = Value(category),
       name = Value(name),
       pricePerDay = Value(pricePerDay),
       isActive = Value(isActive);
  static Insertable<MaterialRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? category,
    Expression<String>? name,
    Expression<String>? variant,
    Expression<int>? pricePerDay,
    Expression<int>? totalStock,
    Expression<bool>? isActive,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (category != null) 'category': category,
      if (name != null) 'name': name,
      if (variant != null) 'variant': variant,
      if (pricePerDay != null) 'price_per_day': pricePerDay,
      if (totalStock != null) 'total_stock': totalStock,
      if (isActive != null) 'is_active': isActive,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MaterialTypesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? category,
    Value<String>? name,
    Value<String?>? variant,
    Value<int>? pricePerDay,
    Value<int?>? totalStock,
    Value<bool>? isActive,
    Value<int>? rowid,
  }) {
    return MaterialTypesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
      name: name ?? this.name,
      variant: variant ?? this.variant,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      totalStock: totalStock ?? this.totalStock,
      isActive: isActive ?? this.isActive,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (variant.present) {
      map['variant'] = Variable<String>(variant.value);
    }
    if (pricePerDay.present) {
      map['price_per_day'] = Variable<int>(pricePerDay.value);
    }
    if (totalStock.present) {
      map['total_stock'] = Variable<int>(totalStock.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaterialTypesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('category: $category, ')
          ..write('name: $name, ')
          ..write('variant: $variant, ')
          ..write('pricePerDay: $pricePerDay, ')
          ..write('totalStock: $totalStock, ')
          ..write('isActive: $isActive, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RentalsTable extends Rentals with TableInfo<$RentalsTable, Rental> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RentalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rentedAtMeta = const VerificationMeta(
    'rentedAt',
  );
  @override
  late final GeneratedColumn<DateTime> rentedAt = GeneratedColumn<DateTime>(
    'rented_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerSignatureMeta = const VerificationMeta(
    'customerSignature',
  );
  @override
  late final GeneratedColumn<String> customerSignature =
      GeneratedColumn<String>(
        'customer_signature',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _handoverPhotoMeta = const VerificationMeta(
    'handoverPhoto',
  );
  @override
  late final GeneratedColumn<String> handoverPhoto = GeneratedColumn<String>(
    'handover_photo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidedAtMeta = const VerificationMeta(
    'voidedAt',
  );
  @override
  late final GeneratedColumn<DateTime> voidedAt = GeneratedColumn<DateTime>(
    'voided_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    customerId,
    rentedAt,
    status,
    notes,
    customerSignature,
    handoverPhoto,
    voidedAt,
    voidReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rentals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Rental> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('rented_at')) {
      context.handle(
        _rentedAtMeta,
        rentedAt.isAcceptableOrUnknown(data['rented_at']!, _rentedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_rentedAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('customer_signature')) {
      context.handle(
        _customerSignatureMeta,
        customerSignature.isAcceptableOrUnknown(
          data['customer_signature']!,
          _customerSignatureMeta,
        ),
      );
    }
    if (data.containsKey('handover_photo')) {
      context.handle(
        _handoverPhotoMeta,
        handoverPhoto.isAcceptableOrUnknown(
          data['handover_photo']!,
          _handoverPhotoMeta,
        ),
      );
    }
    if (data.containsKey('voided_at')) {
      context.handle(
        _voidedAtMeta,
        voidedAt.isAcceptableOrUnknown(data['voided_at']!, _voidedAtMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Rental map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Rental(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      rentedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}rented_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      customerSignature: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_signature'],
      ),
      handoverPhoto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}handover_photo'],
      ),
      voidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}voided_at'],
      ),
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
    );
  }

  @override
  $RentalsTable createAlias(String alias) {
    return $RentalsTable(attachedDatabase, alias);
  }
}

class Rental extends DataClass implements Insertable<Rental> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String customerId;
  final DateTime rentedAt;
  final String status;
  final String? notes;
  final String? customerSignature;
  final String? handoverPhoto;
  final DateTime? voidedAt;
  final String? voidReason;
  const Rental({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.customerId,
    required this.rentedAt,
    required this.status,
    this.notes,
    this.customerSignature,
    this.handoverPhoto,
    this.voidedAt,
    this.voidReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['customer_id'] = Variable<String>(customerId);
    map['rented_at'] = Variable<DateTime>(rentedAt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || customerSignature != null) {
      map['customer_signature'] = Variable<String>(customerSignature);
    }
    if (!nullToAbsent || handoverPhoto != null) {
      map['handover_photo'] = Variable<String>(handoverPhoto);
    }
    if (!nullToAbsent || voidedAt != null) {
      map['voided_at'] = Variable<DateTime>(voidedAt);
    }
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    return map;
  }

  RentalsCompanion toCompanion(bool nullToAbsent) {
    return RentalsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      customerId: Value(customerId),
      rentedAt: Value(rentedAt),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      customerSignature: customerSignature == null && nullToAbsent
          ? const Value.absent()
          : Value(customerSignature),
      handoverPhoto: handoverPhoto == null && nullToAbsent
          ? const Value.absent()
          : Value(handoverPhoto),
      voidedAt: voidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedAt),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
    );
  }

  factory Rental.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Rental(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      customerId: serializer.fromJson<String>(json['customerId']),
      rentedAt: serializer.fromJson<DateTime>(json['rentedAt']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      customerSignature: serializer.fromJson<String?>(
        json['customerSignature'],
      ),
      handoverPhoto: serializer.fromJson<String?>(json['handoverPhoto']),
      voidedAt: serializer.fromJson<DateTime?>(json['voidedAt']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'customerId': serializer.toJson<String>(customerId),
      'rentedAt': serializer.toJson<DateTime>(rentedAt),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'customerSignature': serializer.toJson<String?>(customerSignature),
      'handoverPhoto': serializer.toJson<String?>(handoverPhoto),
      'voidedAt': serializer.toJson<DateTime?>(voidedAt),
      'voidReason': serializer.toJson<String?>(voidReason),
    };
  }

  Rental copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? customerId,
    DateTime? rentedAt,
    String? status,
    Value<String?> notes = const Value.absent(),
    Value<String?> customerSignature = const Value.absent(),
    Value<String?> handoverPhoto = const Value.absent(),
    Value<DateTime?> voidedAt = const Value.absent(),
    Value<String?> voidReason = const Value.absent(),
  }) => Rental(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    customerId: customerId ?? this.customerId,
    rentedAt: rentedAt ?? this.rentedAt,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    customerSignature: customerSignature.present
        ? customerSignature.value
        : this.customerSignature,
    handoverPhoto: handoverPhoto.present
        ? handoverPhoto.value
        : this.handoverPhoto,
    voidedAt: voidedAt.present ? voidedAt.value : this.voidedAt,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
  );
  Rental copyWithCompanion(RentalsCompanion data) {
    return Rental(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      rentedAt: data.rentedAt.present ? data.rentedAt.value : this.rentedAt,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      customerSignature: data.customerSignature.present
          ? data.customerSignature.value
          : this.customerSignature,
      handoverPhoto: data.handoverPhoto.present
          ? data.handoverPhoto.value
          : this.handoverPhoto,
      voidedAt: data.voidedAt.present ? data.voidedAt.value : this.voidedAt,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Rental(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('customerId: $customerId, ')
          ..write('rentedAt: $rentedAt, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('customerSignature: $customerSignature, ')
          ..write('handoverPhoto: $handoverPhoto, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    customerId,
    rentedAt,
    status,
    notes,
    customerSignature,
    handoverPhoto,
    voidedAt,
    voidReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Rental &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.customerId == this.customerId &&
          other.rentedAt == this.rentedAt &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.customerSignature == this.customerSignature &&
          other.handoverPhoto == this.handoverPhoto &&
          other.voidedAt == this.voidedAt &&
          other.voidReason == this.voidReason);
}

class RentalsCompanion extends UpdateCompanion<Rental> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> customerId;
  final Value<DateTime> rentedAt;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String?> customerSignature;
  final Value<String?> handoverPhoto;
  final Value<DateTime?> voidedAt;
  final Value<String?> voidReason;
  final Value<int> rowid;
  const RentalsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    this.rentedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.customerSignature = const Value.absent(),
    this.handoverPhoto = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RentalsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String customerId,
    required DateTime rentedAt,
    required String status,
    this.notes = const Value.absent(),
    this.customerSignature = const Value.absent(),
    this.handoverPhoto = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       customerId = Value(customerId),
       rentedAt = Value(rentedAt),
       status = Value(status);
  static Insertable<Rental> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? customerId,
    Expression<DateTime>? rentedAt,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? customerSignature,
    Expression<String>? handoverPhoto,
    Expression<DateTime>? voidedAt,
    Expression<String>? voidReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (customerId != null) 'customer_id': customerId,
      if (rentedAt != null) 'rented_at': rentedAt,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (customerSignature != null) 'customer_signature': customerSignature,
      if (handoverPhoto != null) 'handover_photo': handoverPhoto,
      if (voidedAt != null) 'voided_at': voidedAt,
      if (voidReason != null) 'void_reason': voidReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RentalsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? customerId,
    Value<DateTime>? rentedAt,
    Value<String>? status,
    Value<String?>? notes,
    Value<String?>? customerSignature,
    Value<String?>? handoverPhoto,
    Value<DateTime?>? voidedAt,
    Value<String?>? voidReason,
    Value<int>? rowid,
  }) {
    return RentalsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      customerId: customerId ?? this.customerId,
      rentedAt: rentedAt ?? this.rentedAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      customerSignature: customerSignature ?? this.customerSignature,
      handoverPhoto: handoverPhoto ?? this.handoverPhoto,
      voidedAt: voidedAt ?? this.voidedAt,
      voidReason: voidReason ?? this.voidReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (rentedAt.present) {
      map['rented_at'] = Variable<DateTime>(rentedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (customerSignature.present) {
      map['customer_signature'] = Variable<String>(customerSignature.value);
    }
    if (handoverPhoto.present) {
      map['handover_photo'] = Variable<String>(handoverPhoto.value);
    }
    if (voidedAt.present) {
      map['voided_at'] = Variable<DateTime>(voidedAt.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RentalsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('customerId: $customerId, ')
          ..write('rentedAt: $rentedAt, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('customerSignature: $customerSignature, ')
          ..write('handoverPhoto: $handoverPhoto, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('voidReason: $voidReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RentalItemsTable extends RentalItems
    with TableInfo<$RentalItemsTable, RentalItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RentalItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rentalIdMeta = const VerificationMeta(
    'rentalId',
  );
  @override
  late final GeneratedColumn<String> rentalId = GeneratedColumn<String>(
    'rental_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _materialTypeIdMeta = const VerificationMeta(
    'materialTypeId',
  );
  @override
  late final GeneratedColumn<String> materialTypeId = GeneratedColumn<String>(
    'material_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _materialNameSnapshotMeta =
      const VerificationMeta('materialNameSnapshot');
  @override
  late final GeneratedColumn<String> materialNameSnapshot =
      GeneratedColumn<String>(
        'material_name_snapshot',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _pricePerDaySnapshotMeta =
      const VerificationMeta('pricePerDaySnapshot');
  @override
  late final GeneratedColumn<int> pricePerDaySnapshot = GeneratedColumn<int>(
    'price_per_day_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityReturnedMeta = const VerificationMeta(
    'quantityReturned',
  );
  @override
  late final GeneratedColumn<int> quantityReturned = GeneratedColumn<int>(
    'quantity_returned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    rentalId,
    materialTypeId,
    materialNameSnapshot,
    pricePerDaySnapshot,
    quantity,
    quantityReturned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rental_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RentalItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('rental_id')) {
      context.handle(
        _rentalIdMeta,
        rentalId.isAcceptableOrUnknown(data['rental_id']!, _rentalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rentalIdMeta);
    }
    if (data.containsKey('material_type_id')) {
      context.handle(
        _materialTypeIdMeta,
        materialTypeId.isAcceptableOrUnknown(
          data['material_type_id']!,
          _materialTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_materialTypeIdMeta);
    }
    if (data.containsKey('material_name_snapshot')) {
      context.handle(
        _materialNameSnapshotMeta,
        materialNameSnapshot.isAcceptableOrUnknown(
          data['material_name_snapshot']!,
          _materialNameSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_materialNameSnapshotMeta);
    }
    if (data.containsKey('price_per_day_snapshot')) {
      context.handle(
        _pricePerDaySnapshotMeta,
        pricePerDaySnapshot.isAcceptableOrUnknown(
          data['price_per_day_snapshot']!,
          _pricePerDaySnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerDaySnapshotMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('quantity_returned')) {
      context.handle(
        _quantityReturnedMeta,
        quantityReturned.isAcceptableOrUnknown(
          data['quantity_returned']!,
          _quantityReturnedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityReturnedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RentalItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RentalItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      rentalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rental_id'],
      )!,
      materialTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material_type_id'],
      )!,
      materialNameSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material_name_snapshot'],
      )!,
      pricePerDaySnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_per_day_snapshot'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      quantityReturned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_returned'],
      )!,
    );
  }

  @override
  $RentalItemsTable createAlias(String alias) {
    return $RentalItemsTable(attachedDatabase, alias);
  }
}

class RentalItem extends DataClass implements Insertable<RentalItem> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String rentalId;
  final String materialTypeId;
  final String materialNameSnapshot;
  final int pricePerDaySnapshot;
  final int quantity;
  final int quantityReturned;
  const RentalItem({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.rentalId,
    required this.materialTypeId,
    required this.materialNameSnapshot,
    required this.pricePerDaySnapshot,
    required this.quantity,
    required this.quantityReturned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['rental_id'] = Variable<String>(rentalId);
    map['material_type_id'] = Variable<String>(materialTypeId);
    map['material_name_snapshot'] = Variable<String>(materialNameSnapshot);
    map['price_per_day_snapshot'] = Variable<int>(pricePerDaySnapshot);
    map['quantity'] = Variable<int>(quantity);
    map['quantity_returned'] = Variable<int>(quantityReturned);
    return map;
  }

  RentalItemsCompanion toCompanion(bool nullToAbsent) {
    return RentalItemsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      rentalId: Value(rentalId),
      materialTypeId: Value(materialTypeId),
      materialNameSnapshot: Value(materialNameSnapshot),
      pricePerDaySnapshot: Value(pricePerDaySnapshot),
      quantity: Value(quantity),
      quantityReturned: Value(quantityReturned),
    );
  }

  factory RentalItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RentalItem(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      rentalId: serializer.fromJson<String>(json['rentalId']),
      materialTypeId: serializer.fromJson<String>(json['materialTypeId']),
      materialNameSnapshot: serializer.fromJson<String>(
        json['materialNameSnapshot'],
      ),
      pricePerDaySnapshot: serializer.fromJson<int>(
        json['pricePerDaySnapshot'],
      ),
      quantity: serializer.fromJson<int>(json['quantity']),
      quantityReturned: serializer.fromJson<int>(json['quantityReturned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'rentalId': serializer.toJson<String>(rentalId),
      'materialTypeId': serializer.toJson<String>(materialTypeId),
      'materialNameSnapshot': serializer.toJson<String>(materialNameSnapshot),
      'pricePerDaySnapshot': serializer.toJson<int>(pricePerDaySnapshot),
      'quantity': serializer.toJson<int>(quantity),
      'quantityReturned': serializer.toJson<int>(quantityReturned),
    };
  }

  RentalItem copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? rentalId,
    String? materialTypeId,
    String? materialNameSnapshot,
    int? pricePerDaySnapshot,
    int? quantity,
    int? quantityReturned,
  }) => RentalItem(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    rentalId: rentalId ?? this.rentalId,
    materialTypeId: materialTypeId ?? this.materialTypeId,
    materialNameSnapshot: materialNameSnapshot ?? this.materialNameSnapshot,
    pricePerDaySnapshot: pricePerDaySnapshot ?? this.pricePerDaySnapshot,
    quantity: quantity ?? this.quantity,
    quantityReturned: quantityReturned ?? this.quantityReturned,
  );
  RentalItem copyWithCompanion(RentalItemsCompanion data) {
    return RentalItem(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      rentalId: data.rentalId.present ? data.rentalId.value : this.rentalId,
      materialTypeId: data.materialTypeId.present
          ? data.materialTypeId.value
          : this.materialTypeId,
      materialNameSnapshot: data.materialNameSnapshot.present
          ? data.materialNameSnapshot.value
          : this.materialNameSnapshot,
      pricePerDaySnapshot: data.pricePerDaySnapshot.present
          ? data.pricePerDaySnapshot.value
          : this.pricePerDaySnapshot,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      quantityReturned: data.quantityReturned.present
          ? data.quantityReturned.value
          : this.quantityReturned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RentalItem(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rentalId: $rentalId, ')
          ..write('materialTypeId: $materialTypeId, ')
          ..write('materialNameSnapshot: $materialNameSnapshot, ')
          ..write('pricePerDaySnapshot: $pricePerDaySnapshot, ')
          ..write('quantity: $quantity, ')
          ..write('quantityReturned: $quantityReturned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    rentalId,
    materialTypeId,
    materialNameSnapshot,
    pricePerDaySnapshot,
    quantity,
    quantityReturned,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RentalItem &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.rentalId == this.rentalId &&
          other.materialTypeId == this.materialTypeId &&
          other.materialNameSnapshot == this.materialNameSnapshot &&
          other.pricePerDaySnapshot == this.pricePerDaySnapshot &&
          other.quantity == this.quantity &&
          other.quantityReturned == this.quantityReturned);
}

class RentalItemsCompanion extends UpdateCompanion<RentalItem> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> rentalId;
  final Value<String> materialTypeId;
  final Value<String> materialNameSnapshot;
  final Value<int> pricePerDaySnapshot;
  final Value<int> quantity;
  final Value<int> quantityReturned;
  final Value<int> rowid;
  const RentalItemsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rentalId = const Value.absent(),
    this.materialTypeId = const Value.absent(),
    this.materialNameSnapshot = const Value.absent(),
    this.pricePerDaySnapshot = const Value.absent(),
    this.quantity = const Value.absent(),
    this.quantityReturned = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RentalItemsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String rentalId,
    required String materialTypeId,
    required String materialNameSnapshot,
    required int pricePerDaySnapshot,
    required int quantity,
    required int quantityReturned,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       rentalId = Value(rentalId),
       materialTypeId = Value(materialTypeId),
       materialNameSnapshot = Value(materialNameSnapshot),
       pricePerDaySnapshot = Value(pricePerDaySnapshot),
       quantity = Value(quantity),
       quantityReturned = Value(quantityReturned);
  static Insertable<RentalItem> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? rentalId,
    Expression<String>? materialTypeId,
    Expression<String>? materialNameSnapshot,
    Expression<int>? pricePerDaySnapshot,
    Expression<int>? quantity,
    Expression<int>? quantityReturned,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rentalId != null) 'rental_id': rentalId,
      if (materialTypeId != null) 'material_type_id': materialTypeId,
      if (materialNameSnapshot != null)
        'material_name_snapshot': materialNameSnapshot,
      if (pricePerDaySnapshot != null)
        'price_per_day_snapshot': pricePerDaySnapshot,
      if (quantity != null) 'quantity': quantity,
      if (quantityReturned != null) 'quantity_returned': quantityReturned,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RentalItemsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? rentalId,
    Value<String>? materialTypeId,
    Value<String>? materialNameSnapshot,
    Value<int>? pricePerDaySnapshot,
    Value<int>? quantity,
    Value<int>? quantityReturned,
    Value<int>? rowid,
  }) {
    return RentalItemsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rentalId: rentalId ?? this.rentalId,
      materialTypeId: materialTypeId ?? this.materialTypeId,
      materialNameSnapshot: materialNameSnapshot ?? this.materialNameSnapshot,
      pricePerDaySnapshot: pricePerDaySnapshot ?? this.pricePerDaySnapshot,
      quantity: quantity ?? this.quantity,
      quantityReturned: quantityReturned ?? this.quantityReturned,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rentalId.present) {
      map['rental_id'] = Variable<String>(rentalId.value);
    }
    if (materialTypeId.present) {
      map['material_type_id'] = Variable<String>(materialTypeId.value);
    }
    if (materialNameSnapshot.present) {
      map['material_name_snapshot'] = Variable<String>(
        materialNameSnapshot.value,
      );
    }
    if (pricePerDaySnapshot.present) {
      map['price_per_day_snapshot'] = Variable<int>(pricePerDaySnapshot.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (quantityReturned.present) {
      map['quantity_returned'] = Variable<int>(quantityReturned.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RentalItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rentalId: $rentalId, ')
          ..write('materialTypeId: $materialTypeId, ')
          ..write('materialNameSnapshot: $materialNameSnapshot, ')
          ..write('pricePerDaySnapshot: $pricePerDaySnapshot, ')
          ..write('quantity: $quantity, ')
          ..write('quantityReturned: $quantityReturned, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReturnEventsTable extends ReturnEvents
    with TableInfo<$ReturnEventsTable, ReturnEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReturnEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rentalItemIdMeta = const VerificationMeta(
    'rentalItemId',
  );
  @override
  late final GeneratedColumn<String> rentalItemId = GeneratedColumn<String>(
    'rental_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _returnedAtMeta = const VerificationMeta(
    'returnedAt',
  );
  @override
  late final GeneratedColumn<DateTime> returnedAt = GeneratedColumn<DateTime>(
    'returned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conditionNoteMeta = const VerificationMeta(
    'conditionNote',
  );
  @override
  late final GeneratedColumn<String> conditionNote = GeneratedColumn<String>(
    'condition_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _daysMeta = const VerificationMeta('days');
  @override
  late final GeneratedColumn<int> days = GeneratedColumn<int>(
    'days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    rentalItemId,
    quantity,
    returnedAt,
    conditionNote,
    days,
    amount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'return_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReturnEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('rental_item_id')) {
      context.handle(
        _rentalItemIdMeta,
        rentalItemId.isAcceptableOrUnknown(
          data['rental_item_id']!,
          _rentalItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rentalItemIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('returned_at')) {
      context.handle(
        _returnedAtMeta,
        returnedAt.isAcceptableOrUnknown(data['returned_at']!, _returnedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_returnedAtMeta);
    }
    if (data.containsKey('condition_note')) {
      context.handle(
        _conditionNoteMeta,
        conditionNote.isAcceptableOrUnknown(
          data['condition_note']!,
          _conditionNoteMeta,
        ),
      );
    }
    if (data.containsKey('days')) {
      context.handle(
        _daysMeta,
        days.isAcceptableOrUnknown(data['days']!, _daysMeta),
      );
    } else if (isInserting) {
      context.missing(_daysMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReturnEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReturnEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      rentalItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rental_item_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      returnedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}returned_at'],
      )!,
      conditionNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}condition_note'],
      ),
      days: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}days'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
    );
  }

  @override
  $ReturnEventsTable createAlias(String alias) {
    return $ReturnEventsTable(attachedDatabase, alias);
  }
}

class ReturnEvent extends DataClass implements Insertable<ReturnEvent> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String rentalItemId;
  final int quantity;
  final DateTime returnedAt;
  final String? conditionNote;
  final int days;
  final int amount;
  const ReturnEvent({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.rentalItemId,
    required this.quantity,
    required this.returnedAt,
    this.conditionNote,
    required this.days,
    required this.amount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['rental_item_id'] = Variable<String>(rentalItemId);
    map['quantity'] = Variable<int>(quantity);
    map['returned_at'] = Variable<DateTime>(returnedAt);
    if (!nullToAbsent || conditionNote != null) {
      map['condition_note'] = Variable<String>(conditionNote);
    }
    map['days'] = Variable<int>(days);
    map['amount'] = Variable<int>(amount);
    return map;
  }

  ReturnEventsCompanion toCompanion(bool nullToAbsent) {
    return ReturnEventsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      rentalItemId: Value(rentalItemId),
      quantity: Value(quantity),
      returnedAt: Value(returnedAt),
      conditionNote: conditionNote == null && nullToAbsent
          ? const Value.absent()
          : Value(conditionNote),
      days: Value(days),
      amount: Value(amount),
    );
  }

  factory ReturnEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReturnEvent(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      rentalItemId: serializer.fromJson<String>(json['rentalItemId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      returnedAt: serializer.fromJson<DateTime>(json['returnedAt']),
      conditionNote: serializer.fromJson<String?>(json['conditionNote']),
      days: serializer.fromJson<int>(json['days']),
      amount: serializer.fromJson<int>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'rentalItemId': serializer.toJson<String>(rentalItemId),
      'quantity': serializer.toJson<int>(quantity),
      'returnedAt': serializer.toJson<DateTime>(returnedAt),
      'conditionNote': serializer.toJson<String?>(conditionNote),
      'days': serializer.toJson<int>(days),
      'amount': serializer.toJson<int>(amount),
    };
  }

  ReturnEvent copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? rentalItemId,
    int? quantity,
    DateTime? returnedAt,
    Value<String?> conditionNote = const Value.absent(),
    int? days,
    int? amount,
  }) => ReturnEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    rentalItemId: rentalItemId ?? this.rentalItemId,
    quantity: quantity ?? this.quantity,
    returnedAt: returnedAt ?? this.returnedAt,
    conditionNote: conditionNote.present
        ? conditionNote.value
        : this.conditionNote,
    days: days ?? this.days,
    amount: amount ?? this.amount,
  );
  ReturnEvent copyWithCompanion(ReturnEventsCompanion data) {
    return ReturnEvent(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      rentalItemId: data.rentalItemId.present
          ? data.rentalItemId.value
          : this.rentalItemId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      returnedAt: data.returnedAt.present
          ? data.returnedAt.value
          : this.returnedAt,
      conditionNote: data.conditionNote.present
          ? data.conditionNote.value
          : this.conditionNote,
      days: data.days.present ? data.days.value : this.days,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReturnEvent(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rentalItemId: $rentalItemId, ')
          ..write('quantity: $quantity, ')
          ..write('returnedAt: $returnedAt, ')
          ..write('conditionNote: $conditionNote, ')
          ..write('days: $days, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    rentalItemId,
    quantity,
    returnedAt,
    conditionNote,
    days,
    amount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReturnEvent &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.rentalItemId == this.rentalItemId &&
          other.quantity == this.quantity &&
          other.returnedAt == this.returnedAt &&
          other.conditionNote == this.conditionNote &&
          other.days == this.days &&
          other.amount == this.amount);
}

class ReturnEventsCompanion extends UpdateCompanion<ReturnEvent> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> rentalItemId;
  final Value<int> quantity;
  final Value<DateTime> returnedAt;
  final Value<String?> conditionNote;
  final Value<int> days;
  final Value<int> amount;
  final Value<int> rowid;
  const ReturnEventsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rentalItemId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.returnedAt = const Value.absent(),
    this.conditionNote = const Value.absent(),
    this.days = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReturnEventsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String rentalItemId,
    required int quantity,
    required DateTime returnedAt,
    this.conditionNote = const Value.absent(),
    required int days,
    required int amount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       rentalItemId = Value(rentalItemId),
       quantity = Value(quantity),
       returnedAt = Value(returnedAt),
       days = Value(days),
       amount = Value(amount);
  static Insertable<ReturnEvent> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? rentalItemId,
    Expression<int>? quantity,
    Expression<DateTime>? returnedAt,
    Expression<String>? conditionNote,
    Expression<int>? days,
    Expression<int>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rentalItemId != null) 'rental_item_id': rentalItemId,
      if (quantity != null) 'quantity': quantity,
      if (returnedAt != null) 'returned_at': returnedAt,
      if (conditionNote != null) 'condition_note': conditionNote,
      if (days != null) 'days': days,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReturnEventsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? rentalItemId,
    Value<int>? quantity,
    Value<DateTime>? returnedAt,
    Value<String?>? conditionNote,
    Value<int>? days,
    Value<int>? amount,
    Value<int>? rowid,
  }) {
    return ReturnEventsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rentalItemId: rentalItemId ?? this.rentalItemId,
      quantity: quantity ?? this.quantity,
      returnedAt: returnedAt ?? this.returnedAt,
      conditionNote: conditionNote ?? this.conditionNote,
      days: days ?? this.days,
      amount: amount ?? this.amount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rentalItemId.present) {
      map['rental_item_id'] = Variable<String>(rentalItemId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (returnedAt.present) {
      map['returned_at'] = Variable<DateTime>(returnedAt.value);
    }
    if (conditionNote.present) {
      map['condition_note'] = Variable<String>(conditionNote.value);
    }
    if (days.present) {
      map['days'] = Variable<int>(days.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReturnEventsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rentalItemId: $rentalItemId, ')
          ..write('quantity: $quantity, ')
          ..write('returnedAt: $returnedAt, ')
          ..write('conditionNote: $conditionNote, ')
          ..write('days: $days, ')
          ..write('amount: $amount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oldValueMeta = const VerificationMeta(
    'oldValue',
  );
  @override
  late final GeneratedColumn<String> oldValue = GeneratedColumn<String>(
    'old_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newValueMeta = const VerificationMeta(
    'newValue',
  );
  @override
  late final GeneratedColumn<String> newValue = GeneratedColumn<String>(
    'new_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byMeta = const VerificationMeta('by');
  @override
  late final GeneratedColumn<String> by = GeneratedColumn<String>(
    'by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    entityType,
    entityId,
    action,
    oldValue,
    newValue,
    at,
    by,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('old_value')) {
      context.handle(
        _oldValueMeta,
        oldValue.isAcceptableOrUnknown(data['old_value']!, _oldValueMeta),
      );
    }
    if (data.containsKey('new_value')) {
      context.handle(
        _newValueMeta,
        newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('by')) {
      context.handle(_byMeta, by.isAcceptableOrUnknown(data['by']!, _byMeta));
    } else if (isInserting) {
      context.missing(_byMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      oldValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_value'],
      ),
      newValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_value'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      by: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}by'],
      )!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String entityType;
  final String entityId;
  final String action;
  final String? oldValue;
  final String? newValue;
  final DateTime at;
  final String by;
  const AuditLog({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.entityType,
    required this.entityId,
    required this.action,
    this.oldValue,
    this.newValue,
    required this.at,
    required this.by,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || oldValue != null) {
      map['old_value'] = Variable<String>(oldValue);
    }
    if (!nullToAbsent || newValue != null) {
      map['new_value'] = Variable<String>(newValue);
    }
    map['at'] = Variable<DateTime>(at);
    map['by'] = Variable<String>(by);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      entityType: Value(entityType),
      entityId: Value(entityId),
      action: Value(action),
      oldValue: oldValue == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValue),
      newValue: newValue == null && nullToAbsent
          ? const Value.absent()
          : Value(newValue),
      at: Value(at),
      by: Value(by),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      action: serializer.fromJson<String>(json['action']),
      oldValue: serializer.fromJson<String?>(json['oldValue']),
      newValue: serializer.fromJson<String?>(json['newValue']),
      at: serializer.fromJson<DateTime>(json['at']),
      by: serializer.fromJson<String>(json['by']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'action': serializer.toJson<String>(action),
      'oldValue': serializer.toJson<String?>(oldValue),
      'newValue': serializer.toJson<String?>(newValue),
      'at': serializer.toJson<DateTime>(at),
      'by': serializer.toJson<String>(by),
    };
  }

  AuditLog copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? entityType,
    String? entityId,
    String? action,
    Value<String?> oldValue = const Value.absent(),
    Value<String?> newValue = const Value.absent(),
    DateTime? at,
    String? by,
  }) => AuditLog(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    action: action ?? this.action,
    oldValue: oldValue.present ? oldValue.value : this.oldValue,
    newValue: newValue.present ? newValue.value : this.newValue,
    at: at ?? this.at,
    by: by ?? this.by,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      action: data.action.present ? data.action.value : this.action,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      at: data.at.present ? data.at.value : this.at,
      by: data.by.present ? data.by.value : this.by,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('at: $at, ')
          ..write('by: $by')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    entityType,
    entityId,
    action,
    oldValue,
    newValue,
    at,
    by,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.action == this.action &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue &&
          other.at == this.at &&
          other.by == this.by);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> action;
  final Value<String?> oldValue;
  final Value<String?> newValue;
  final Value<DateTime> at;
  final Value<String> by;
  final Value<int> rowid;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.action = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.at = const Value.absent(),
    this.by = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String entityType,
    required String entityId,
    required String action,
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    required DateTime at,
    required String by,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       entityType = Value(entityType),
       entityId = Value(entityId),
       action = Value(action),
       at = Value(at),
       by = Value(by);
  static Insertable<AuditLog> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? action,
    Expression<String>? oldValue,
    Expression<String>? newValue,
    Expression<DateTime>? at,
    Expression<String>? by,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (action != null) 'action': action,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (at != null) 'at': at,
      if (by != null) 'by': by,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditLogsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? action,
    Value<String?>? oldValue,
    Value<String?>? newValue,
    Value<DateTime>? at,
    Value<String>? by,
    Value<int>? rowid,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      action: action ?? this.action,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      at: at ?? this.at,
      by: by ?? this.by,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (oldValue.present) {
      map['old_value'] = Variable<String>(oldValue.value);
    }
    if (newValue.present) {
      map['new_value'] = Variable<String>(newValue.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (by.present) {
      map['by'] = Variable<String>(by.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('action: $action, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('at: $at, ')
          ..write('by: $by, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $MaterialTypesTable materialTypes = $MaterialTypesTable(this);
  late final $RentalsTable rentals = $RentalsTable(this);
  late final $RentalItemsTable rentalItems = $RentalItemsTable(this);
  late final $ReturnEventsTable returnEvents = $ReturnEventsTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customers,
    materialTypes,
    rentals,
    rentalItems,
    returnEvents,
    auditLogs,
  ];
}

typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  required String fullName,
  required String phone,
  required String address,
  required String idPhotoFront,
  Value<String?> idPhotoBack,
  Value<String?> notes,
  Value<DateTime?> voidedAt,
  Value<String?> voidReason,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> fullName,
  Value<String> phone,
  Value<String> address,
  Value<String> idPhotoFront,
  Value<String?> idPhotoBack,
  Value<String?> notes,
  Value<DateTime?> voidedAt,
  Value<String?> voidReason,
  Value<int> rowid,
});

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idPhotoFront => $composableBuilder(
    column: $table.idPhotoFront,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idPhotoBack => $composableBuilder(
    column: $table.idPhotoBack,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idPhotoFront => $composableBuilder(
    column: $table.idPhotoFront,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idPhotoBack => $composableBuilder(
    column: $table.idPhotoBack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get idPhotoFront => $composableBuilder(
    column: $table.idPhotoFront,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idPhotoBack => $composableBuilder(
    column: $table.idPhotoBack,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get voidedAt =>
      $composableBuilder(column: $table.voidedAt, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          CustomerRow,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (
            CustomerRow,
            BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>,
          ),
          CustomerRow,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> idPhotoFront = const Value.absent(),
                Value<String?> idPhotoBack = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                fullName: fullName,
                phone: phone,
                address: address,
                idPhotoFront: idPhotoFront,
                idPhotoBack: idPhotoBack,
                notes: notes,
                voidedAt: voidedAt,
                voidReason: voidReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String fullName,
                required String phone,
                required String address,
                required String idPhotoFront,
                Value<String?> idPhotoBack = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                fullName: fullName,
                phone: phone,
                address: address,
                idPhotoFront: idPhotoFront,
                idPhotoBack: idPhotoBack,
                notes: notes,
                voidedAt: voidedAt,
                voidReason: voidReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      CustomerRow,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (
        CustomerRow,
        BaseReferences<_$AppDatabase, $CustomersTable, CustomerRow>,
      ),
      CustomerRow,
      PrefetchHooks Function()
    >;
typedef $$MaterialTypesTableCreateCompanionBuilder =
    MaterialTypesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String category,
      required String name,
      Value<String?> variant,
      required int pricePerDay,
      Value<int?> totalStock,
      required bool isActive,
      Value<int> rowid,
    });
typedef $$MaterialTypesTableUpdateCompanionBuilder =
    MaterialTypesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> category,
      Value<String> name,
      Value<String?> variant,
      Value<int> pricePerDay,
      Value<int?> totalStock,
      Value<bool> isActive,
      Value<int> rowid,
    });

class $$MaterialTypesTableFilterComposer
    extends Composer<_$AppDatabase, $MaterialTypesTable> {
  $$MaterialTypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get variant => $composableBuilder(
    column: $table.variant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pricePerDay => $composableBuilder(
    column: $table.pricePerDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalStock => $composableBuilder(
    column: $table.totalStock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MaterialTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $MaterialTypesTable> {
  $$MaterialTypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get variant => $composableBuilder(
    column: $table.variant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pricePerDay => $composableBuilder(
    column: $table.pricePerDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalStock => $composableBuilder(
    column: $table.totalStock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MaterialTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaterialTypesTable> {
  $$MaterialTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get variant =>
      $composableBuilder(column: $table.variant, builder: (column) => column);

  GeneratedColumn<int> get pricePerDay => $composableBuilder(
    column: $table.pricePerDay,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalStock => $composableBuilder(
    column: $table.totalStock,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$MaterialTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaterialTypesTable,
          MaterialRow,
          $$MaterialTypesTableFilterComposer,
          $$MaterialTypesTableOrderingComposer,
          $$MaterialTypesTableAnnotationComposer,
          $$MaterialTypesTableCreateCompanionBuilder,
          $$MaterialTypesTableUpdateCompanionBuilder,
          (
            MaterialRow,
            BaseReferences<_$AppDatabase, $MaterialTypesTable, MaterialRow>,
          ),
          MaterialRow,
          PrefetchHooks Function()
        > {
  $$MaterialTypesTableTableManager(_$AppDatabase db, $MaterialTypesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaterialTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaterialTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaterialTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> variant = const Value.absent(),
                Value<int> pricePerDay = const Value.absent(),
                Value<int?> totalStock = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaterialTypesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                category: category,
                name: name,
                variant: variant,
                pricePerDay: pricePerDay,
                totalStock: totalStock,
                isActive: isActive,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String category,
                required String name,
                Value<String?> variant = const Value.absent(),
                required int pricePerDay,
                Value<int?> totalStock = const Value.absent(),
                required bool isActive,
                Value<int> rowid = const Value.absent(),
              }) => MaterialTypesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                category: category,
                name: name,
                variant: variant,
                pricePerDay: pricePerDay,
                totalStock: totalStock,
                isActive: isActive,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MaterialTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaterialTypesTable,
      MaterialRow,
      $$MaterialTypesTableFilterComposer,
      $$MaterialTypesTableOrderingComposer,
      $$MaterialTypesTableAnnotationComposer,
      $$MaterialTypesTableCreateCompanionBuilder,
      $$MaterialTypesTableUpdateCompanionBuilder,
      (
        MaterialRow,
        BaseReferences<_$AppDatabase, $MaterialTypesTable, MaterialRow>,
      ),
      MaterialRow,
      PrefetchHooks Function()
    >;
typedef $$RentalsTableCreateCompanionBuilder = RentalsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  required String customerId,
  required DateTime rentedAt,
  required String status,
  Value<String?> notes,
  Value<String?> customerSignature,
  Value<String?> handoverPhoto,
  Value<DateTime?> voidedAt,
  Value<String?> voidReason,
  Value<int> rowid,
});
typedef $$RentalsTableUpdateCompanionBuilder = RentalsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> customerId,
  Value<DateTime> rentedAt,
  Value<String> status,
  Value<String?> notes,
  Value<String?> customerSignature,
  Value<String?> handoverPhoto,
  Value<DateTime?> voidedAt,
  Value<String?> voidReason,
  Value<int> rowid,
});

class $$RentalsTableFilterComposer
    extends Composer<_$AppDatabase, $RentalsTable> {
  $$RentalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rentedAt => $composableBuilder(
    column: $table.rentedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerSignature => $composableBuilder(
    column: $table.customerSignature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get handoverPhoto => $composableBuilder(
    column: $table.handoverPhoto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RentalsTableOrderingComposer
    extends Composer<_$AppDatabase, $RentalsTable> {
  $$RentalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rentedAt => $composableBuilder(
    column: $table.rentedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerSignature => $composableBuilder(
    column: $table.customerSignature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get handoverPhoto => $composableBuilder(
    column: $table.handoverPhoto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RentalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RentalsTable> {
  $$RentalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get rentedAt =>
      $composableBuilder(column: $table.rentedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get customerSignature => $composableBuilder(
    column: $table.customerSignature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get handoverPhoto => $composableBuilder(
    column: $table.handoverPhoto,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get voidedAt =>
      $composableBuilder(column: $table.voidedAt, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );
}

class $$RentalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RentalsTable,
          Rental,
          $$RentalsTableFilterComposer,
          $$RentalsTableOrderingComposer,
          $$RentalsTableAnnotationComposer,
          $$RentalsTableCreateCompanionBuilder,
          $$RentalsTableUpdateCompanionBuilder,
          (Rental, BaseReferences<_$AppDatabase, $RentalsTable, Rental>),
          Rental,
          PrefetchHooks Function()
        > {
  $$RentalsTableTableManager(_$AppDatabase db, $RentalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RentalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RentalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RentalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<DateTime> rentedAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> customerSignature = const Value.absent(),
                Value<String?> handoverPhoto = const Value.absent(),
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RentalsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                customerId: customerId,
                rentedAt: rentedAt,
                status: status,
                notes: notes,
                customerSignature: customerSignature,
                handoverPhoto: handoverPhoto,
                voidedAt: voidedAt,
                voidReason: voidReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String customerId,
                required DateTime rentedAt,
                required String status,
                Value<String?> notes = const Value.absent(),
                Value<String?> customerSignature = const Value.absent(),
                Value<String?> handoverPhoto = const Value.absent(),
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RentalsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                customerId: customerId,
                rentedAt: rentedAt,
                status: status,
                notes: notes,
                customerSignature: customerSignature,
                handoverPhoto: handoverPhoto,
                voidedAt: voidedAt,
                voidReason: voidReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RentalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RentalsTable,
      Rental,
      $$RentalsTableFilterComposer,
      $$RentalsTableOrderingComposer,
      $$RentalsTableAnnotationComposer,
      $$RentalsTableCreateCompanionBuilder,
      $$RentalsTableUpdateCompanionBuilder,
      (Rental, BaseReferences<_$AppDatabase, $RentalsTable, Rental>),
      Rental,
      PrefetchHooks Function()
    >;
typedef $$RentalItemsTableCreateCompanionBuilder =
    RentalItemsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String rentalId,
      required String materialTypeId,
      required String materialNameSnapshot,
      required int pricePerDaySnapshot,
      required int quantity,
      required int quantityReturned,
      Value<int> rowid,
    });
typedef $$RentalItemsTableUpdateCompanionBuilder =
    RentalItemsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> rentalId,
      Value<String> materialTypeId,
      Value<String> materialNameSnapshot,
      Value<int> pricePerDaySnapshot,
      Value<int> quantity,
      Value<int> quantityReturned,
      Value<int> rowid,
    });

class $$RentalItemsTableFilterComposer
    extends Composer<_$AppDatabase, $RentalItemsTable> {
  $$RentalItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rentalId => $composableBuilder(
    column: $table.rentalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get materialTypeId => $composableBuilder(
    column: $table.materialTypeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get materialNameSnapshot => $composableBuilder(
    column: $table.materialNameSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pricePerDaySnapshot => $composableBuilder(
    column: $table.pricePerDaySnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityReturned => $composableBuilder(
    column: $table.quantityReturned,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RentalItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $RentalItemsTable> {
  $$RentalItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rentalId => $composableBuilder(
    column: $table.rentalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get materialTypeId => $composableBuilder(
    column: $table.materialTypeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get materialNameSnapshot => $composableBuilder(
    column: $table.materialNameSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pricePerDaySnapshot => $composableBuilder(
    column: $table.pricePerDaySnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityReturned => $composableBuilder(
    column: $table.quantityReturned,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RentalItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RentalItemsTable> {
  $$RentalItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get rentalId =>
      $composableBuilder(column: $table.rentalId, builder: (column) => column);

  GeneratedColumn<String> get materialTypeId => $composableBuilder(
    column: $table.materialTypeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get materialNameSnapshot => $composableBuilder(
    column: $table.materialNameSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pricePerDaySnapshot => $composableBuilder(
    column: $table.pricePerDaySnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get quantityReturned => $composableBuilder(
    column: $table.quantityReturned,
    builder: (column) => column,
  );
}

class $$RentalItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RentalItemsTable,
          RentalItem,
          $$RentalItemsTableFilterComposer,
          $$RentalItemsTableOrderingComposer,
          $$RentalItemsTableAnnotationComposer,
          $$RentalItemsTableCreateCompanionBuilder,
          $$RentalItemsTableUpdateCompanionBuilder,
          (
            RentalItem,
            BaseReferences<_$AppDatabase, $RentalItemsTable, RentalItem>,
          ),
          RentalItem,
          PrefetchHooks Function()
        > {
  $$RentalItemsTableTableManager(_$AppDatabase db, $RentalItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RentalItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RentalItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RentalItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> rentalId = const Value.absent(),
                Value<String> materialTypeId = const Value.absent(),
                Value<String> materialNameSnapshot = const Value.absent(),
                Value<int> pricePerDaySnapshot = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> quantityReturned = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RentalItemsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rentalId: rentalId,
                materialTypeId: materialTypeId,
                materialNameSnapshot: materialNameSnapshot,
                pricePerDaySnapshot: pricePerDaySnapshot,
                quantity: quantity,
                quantityReturned: quantityReturned,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String rentalId,
                required String materialTypeId,
                required String materialNameSnapshot,
                required int pricePerDaySnapshot,
                required int quantity,
                required int quantityReturned,
                Value<int> rowid = const Value.absent(),
              }) => RentalItemsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rentalId: rentalId,
                materialTypeId: materialTypeId,
                materialNameSnapshot: materialNameSnapshot,
                pricePerDaySnapshot: pricePerDaySnapshot,
                quantity: quantity,
                quantityReturned: quantityReturned,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RentalItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RentalItemsTable,
      RentalItem,
      $$RentalItemsTableFilterComposer,
      $$RentalItemsTableOrderingComposer,
      $$RentalItemsTableAnnotationComposer,
      $$RentalItemsTableCreateCompanionBuilder,
      $$RentalItemsTableUpdateCompanionBuilder,
      (
        RentalItem,
        BaseReferences<_$AppDatabase, $RentalItemsTable, RentalItem>,
      ),
      RentalItem,
      PrefetchHooks Function()
    >;
typedef $$ReturnEventsTableCreateCompanionBuilder =
    ReturnEventsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      required String rentalItemId,
      required int quantity,
      required DateTime returnedAt,
      Value<String?> conditionNote,
      required int days,
      required int amount,
      Value<int> rowid,
    });
typedef $$ReturnEventsTableUpdateCompanionBuilder =
    ReturnEventsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<String> rentalItemId,
      Value<int> quantity,
      Value<DateTime> returnedAt,
      Value<String?> conditionNote,
      Value<int> days,
      Value<int> amount,
      Value<int> rowid,
    });

class $$ReturnEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ReturnEventsTable> {
  $$ReturnEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rentalItemId => $composableBuilder(
    column: $table.rentalItemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get returnedAt => $composableBuilder(
    column: $table.returnedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conditionNote => $composableBuilder(
    column: $table.conditionNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReturnEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReturnEventsTable> {
  $$ReturnEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rentalItemId => $composableBuilder(
    column: $table.rentalItemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get returnedAt => $composableBuilder(
    column: $table.returnedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conditionNote => $composableBuilder(
    column: $table.conditionNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get days => $composableBuilder(
    column: $table.days,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReturnEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReturnEventsTable> {
  $$ReturnEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get rentalItemId => $composableBuilder(
    column: $table.rentalItemId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<DateTime> get returnedAt => $composableBuilder(
    column: $table.returnedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get conditionNote => $composableBuilder(
    column: $table.conditionNote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get days =>
      $composableBuilder(column: $table.days, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);
}

class $$ReturnEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReturnEventsTable,
          ReturnEvent,
          $$ReturnEventsTableFilterComposer,
          $$ReturnEventsTableOrderingComposer,
          $$ReturnEventsTableAnnotationComposer,
          $$ReturnEventsTableCreateCompanionBuilder,
          $$ReturnEventsTableUpdateCompanionBuilder,
          (
            ReturnEvent,
            BaseReferences<_$AppDatabase, $ReturnEventsTable, ReturnEvent>,
          ),
          ReturnEvent,
          PrefetchHooks Function()
        > {
  $$ReturnEventsTableTableManager(_$AppDatabase db, $ReturnEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReturnEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReturnEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReturnEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> rentalItemId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<DateTime> returnedAt = const Value.absent(),
                Value<String?> conditionNote = const Value.absent(),
                Value<int> days = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReturnEventsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rentalItemId: rentalItemId,
                quantity: quantity,
                returnedAt: returnedAt,
                conditionNote: conditionNote,
                days: days,
                amount: amount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String rentalItemId,
                required int quantity,
                required DateTime returnedAt,
                Value<String?> conditionNote = const Value.absent(),
                required int days,
                required int amount,
                Value<int> rowid = const Value.absent(),
              }) => ReturnEventsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rentalItemId: rentalItemId,
                quantity: quantity,
                returnedAt: returnedAt,
                conditionNote: conditionNote,
                days: days,
                amount: amount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReturnEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReturnEventsTable,
      ReturnEvent,
      $$ReturnEventsTableFilterComposer,
      $$ReturnEventsTableOrderingComposer,
      $$ReturnEventsTableAnnotationComposer,
      $$ReturnEventsTableCreateCompanionBuilder,
      $$ReturnEventsTableUpdateCompanionBuilder,
      (
        ReturnEvent,
        BaseReferences<_$AppDatabase, $ReturnEventsTable, ReturnEvent>,
      ),
      ReturnEvent,
      PrefetchHooks Function()
    >;
typedef $$AuditLogsTableCreateCompanionBuilder = AuditLogsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  required String entityType,
  required String entityId,
  required String action,
  Value<String?> oldValue,
  Value<String?> newValue,
  required DateTime at,
  required String by,
  Value<int> rowid,
});
typedef $$AuditLogsTableUpdateCompanionBuilder = AuditLogsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> action,
  Value<String?> oldValue,
  Value<String?> newValue,
  Value<DateTime> at,
  Value<String> by,
  Value<int> rowid,
});

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get by => $composableBuilder(
    column: $table.by,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get by => $composableBuilder(
    column: $table.by,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get oldValue =>
      $composableBuilder(column: $table.oldValue, builder: (column) => column);

  GeneratedColumn<String> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get by =>
      $composableBuilder(column: $table.by, builder: (column) => column);
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
          AuditLog,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<String> by = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                entityType: entityType,
                entityId: entityId,
                action: action,
                oldValue: oldValue,
                newValue: newValue,
                at: at,
                by: by,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                required String entityType,
                required String entityId,
                required String action,
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                required DateTime at,
                required String by,
                Value<int> rowid = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                entityType: entityType,
                entityId: entityId,
                action: action,
                oldValue: oldValue,
                newValue: newValue,
                at: at,
                by: by,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
      AuditLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$MaterialTypesTableTableManager get materialTypes =>
      $$MaterialTypesTableTableManager(_db, _db.materialTypes);
  $$RentalsTableTableManager get rentals =>
      $$RentalsTableTableManager(_db, _db.rentals);
  $$RentalItemsTableTableManager get rentalItems =>
      $$RentalItemsTableTableManager(_db, _db.rentalItems);
  $$ReturnEventsTableTableManager get returnEvents =>
      $$ReturnEventsTableTableManager(_db, _db.returnEvents);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
}
