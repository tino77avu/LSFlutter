import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

/// Opción para combos (guardamos `value` en `books`, mostramos `label`).
class BookSelectOption {
  const BookSelectOption({required this.value, required this.label});

  final String value;
  final String label;
}

/// Item para renderizar libros en Explore.
class BookListItem {
  const BookListItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.author,
    required this.category,
    required this.condition,
    required this.city,
    required this.status,
    this.imageUrl,
  });

  final int id;
  final String userId;
  final String title;
  final String author;
  final String category;
  final String condition;
  final String city;
  final String status;
  final String? imageUrl;
}

class FavoriteBookItem {
  const FavoriteBookItem({
    required this.bookId,
    required this.title,
    required this.author,
    required this.category,
    required this.status,
    this.imageUrl,
  });

  final int bookId;
  final String title;
  final String author;
  final String category;
  final String status;
  final String? imageUrl;
}

class HomeStats {
  const HomeStats({
    required this.availableBooks,
    required this.myPublications,
    required this.donatedBooks,
  });

  final int availableBooks;
  final int myPublications;
  final int donatedBooks;

  int get impactedLives => donatedBooks;
}

class DonatedBookItem {
  const DonatedBookItem({
    required this.title,
    required this.author,
    this.createdAt,
  });

  final String title;
  final String author;
  final DateTime? createdAt;
}

class CategoryImpactItem {
  const CategoryImpactItem({required this.category, required this.count});

  final String category;
  final int count;
}

class ImpactData {
  const ImpactData({
    required this.totalPublished,
    required this.totalDonated,
    required this.totalConnections,
    required this.totalAvailable,
    required this.myDonated,
    required this.myReceived,
    required this.myImpactedLives,
    required this.myDonatedBooks,
    required this.categories,
    required this.institutionalTotal,
    required this.institutionalDonated,
    required this.institutionalAvailable,
  });

  final int totalPublished;
  final int totalDonated;
  final int totalConnections;
  final int totalAvailable;

  final int myDonated;
  final int myReceived;
  final int myImpactedLives;
  final List<DonatedBookItem> myDonatedBooks;
  final List<CategoryImpactItem> categories;

  final int institutionalTotal;
  final int institutionalDonated;
  final int institutionalAvailable;
}

String _cellToString(dynamic v) {
  if (v == null) return '';
  return v.toString();
}

/// Catálogos y alta de libros en Supabase.
class BooksService {
  BooksService._();

  static final BooksService instance = BooksService._();

  SupabaseClient get _client => Supabase.instance.client;

  List<BookSelectOption> _mapRows(List<dynamic> rows) {
    return rows
        .map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return BookSelectOption(
            value: _cellToString(m['value']).trim(),
            label: _cellToString(m['label']).trim(),
          );
        })
        .where((o) => o.value.isNotEmpty && o.label.isNotEmpty)
        .toList();
  }

  /// `book_categories` con `active = true`, ordenado por `label` (A–Z).
  Future<List<BookSelectOption>> loadActiveCategories() async {
    try {
      final rows = await _client
          .from('book_categories')
          .select('value,label,active')
          .eq('active', true)
          .order('label', ascending: true);

      final list = rows as List<dynamic>;
      debugPrint('[BooksService] book_categories filas: ${list.length}');
      return _mapRows(list);
    } on PostgrestException catch (e, st) {
      debugPrint(
        '[BooksService] book_categories PostgrestException ${e.code} ${e.message} $st',
      );
      rethrow;
    }
  }

  /// `book_conditions` con `active = true`, ordenado por `label` (A–Z).
  Future<List<BookSelectOption>> loadActiveConditions() async {
    try {
      final rows = await _client
          .from('book_conditions')
          .select('value,label,active')
          .eq('active', true)
          .order('label', ascending: true);

      final list = rows as List<dynamic>;
      debugPrint('[BooksService] book_conditions filas: ${list.length}');
      return _mapRows(list);
    } on PostgrestException catch (e, st) {
      debugPrint(
        '[BooksService] book_conditions PostgrestException ${e.code} ${e.message} $st',
      );
      rethrow;
    }
  }

  /// Estado inicial del libro recién publicado (ajusta si tu DB usa otro texto).
  static const String defaultBookStatus = 'disponible';
  static const String _bookImagesBucket = 'book-images';

  Future<Set<int>> loadFavoriteBookIds() async {
    final user = _client.auth.currentUser;
    if (user == null) return <int>{};
    try {
      final rows = await _client
          .from('favorites')
          .select('book_id')
          .eq('user_id', user.id);
      final ids = <int>{};
      for (final row in rows as List<dynamic>) {
        final m = Map<String, dynamic>.from(row as Map);
        final idRaw = m['book_id'];
        final id = idRaw is int ? idRaw : int.tryParse('$idRaw');
        if (id != null) ids.add(id);
      }
      return ids;
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> toggleFavorite({
    required int bookId,
    required bool shouldFavorite,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Debes iniciar sesión para gestionar favoritos.');
    }
    try {
      if (shouldFavorite) {
        final exists = await _client
            .from('favorites')
            .select('id')
            .eq('user_id', user.id)
            .eq('book_id', bookId)
            .maybeSingle();
        if (exists == null) {
          await _client.from('favorites').insert({
            'user_id': user.id,
            'book_id': bookId,
          });
        }
      } else {
        await _client
            .from('favorites')
            .delete()
            .eq('user_id', user.id)
            .eq('book_id', bookId);
      }
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<List<FavoriteBookItem>> loadMyFavorites() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Debes iniciar sesión para ver tus favoritos.');
    }
    try {
      final rows = await _client
          .from('favorites')
          .select(
            'book_id,books!inner(id,title,author,category,status,image_url)',
          )
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return (rows as List<dynamic>).map((row) {
        final m = Map<String, dynamic>.from(row as Map);
        final book = Map<String, dynamic>.from(m['books'] as Map);
        final idRaw = book['id'];
        final id = idRaw is int ? idRaw : int.tryParse('$idRaw') ?? 0;
        final imageValue = _cellToString(book['image_url']).trim();
        return FavoriteBookItem(
          bookId: id,
          title: _cellToString(book['title']).trim(),
          author: _cellToString(book['author']).trim(),
          category: _cellToString(book['category']).trim(),
          status: _cellToString(book['status']).trim(),
          imageUrl: imageValue.isEmpty ? null : imageValue,
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<HomeStats> loadHomeStats() async {
    final currentUserId = _client.auth.currentUser?.id;
    try {
      final rows = await _client.from('books').select('user_id,status');
      final list = rows as List<dynamic>;

      var availableBooks = 0;
      var myPublications = 0;
      var donatedBooks = 0;

      for (final row in list) {
        final book = Map<String, dynamic>.from(row as Map);
        final userId = _cellToString(book['user_id']).trim();
        final status = _normalizeText(_cellToString(book['status']));

        if (currentUserId != null && userId == currentUserId) {
          myPublications++;
        }
        if (status == 'disponible' &&
            (currentUserId == null || userId != currentUserId)) {
          availableBooks++;
        }
        if (_isDonatedStatus(status)) {
          donatedBooks++;
        }
      }

      return HomeStats(
        availableBooks: availableBooks,
        myPublications: myPublications,
        donatedBooks: donatedBooks,
      );
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  bool _isDonatedStatus(String normalizedStatus) {
    return normalizedStatus == 'donado' ||
        normalizedStatus == 'donada' ||
        normalizedStatus == 'donados' ||
        normalizedStatus == 'donadas' ||
        normalizedStatus == 'entregado' ||
        normalizedStatus == 'entregada';
  }

  String _normalizeText(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u');
  }

  Future<ImpactData> loadImpactData() async {
    final currentUserId = _client.auth.currentUser?.id;
    try {
      final rows = await _client
          .from('books')
          .select(
            'user_id,title,author,category,status,recipient_type,created_at',
          );

      final list = rows as List<dynamic>;
      var totalPublished = 0;
      var totalDonated = 0;
      var totalAvailable = 0;
      var myDonated = 0;
      var myReceived = 0;
      var myImpactedLives = 0;
      var institutionalTotal = 0;
      var institutionalDonated = 0;
      var institutionalAvailable = 0;

      final categoriesCount = <String, int>{};
      final donatedBooks = <DonatedBookItem>[];

      for (final row in list) {
        final b = Map<String, dynamic>.from(row as Map);
        totalPublished++;

        final userId = _cellToString(b['user_id']).trim();
        final title = _cellToString(b['title']).trim();
        final author = _cellToString(b['author']).trim();
        final category = _cellToString(b['category']).trim();
        final status = _normalizeText(_cellToString(b['status']));
        final recipientType = _normalizeText(
          _cellToString(b['recipient_type']),
        );
        final createdAtRaw = _cellToString(b['created_at']).trim();
        final createdAt = createdAtRaw.isEmpty
            ? null
            : DateTime.tryParse(createdAtRaw)?.toLocal();

        final isDonated = _isDonatedStatus(status);
        final isAvailable = status == 'disponible';
        final isInstitutional = recipientType == 'institucion';
        final isMine = currentUserId != null && userId == currentUserId;

        if (isDonated) totalDonated++;
        if (isAvailable) totalAvailable++;

        if (isInstitutional) {
          institutionalTotal++;
          if (isDonated) institutionalDonated++;
          if (isAvailable) institutionalAvailable++;
        }

        if (isMine) {
          if (isDonated) {
            myDonated++;
            donatedBooks.add(
              DonatedBookItem(
                title: title,
                author: author,
                createdAt: createdAt,
              ),
            );
          }
          if (_normalizeText(recipientType) == 'persona' ||
              _normalizeText(recipientType) == 'institucion') {
            myImpactedLives++;
          }
        }

        if (category.isNotEmpty) {
          categoriesCount.update(
            category,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
        }
      }

      final categories =
          categoriesCount.entries
              .map((e) => CategoryImpactItem(category: e.key, count: e.value))
              .toList()
            ..sort((a, b) {
              final byCount = b.count.compareTo(a.count);
              if (byCount != 0) return byCount;
              return a.category.toLowerCase().compareTo(
                b.category.toLowerCase(),
              );
            });

      donatedBooks.sort((a, b) {
        final aTime = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final bTime = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return bTime.compareTo(aTime);
      });

      return ImpactData(
        totalPublished: totalPublished,
        totalDonated: totalDonated,
        totalConnections: totalDonated,
        totalAvailable: totalAvailable,
        myDonated: myDonated,
        myReceived: myReceived,
        myImpactedLives: myImpactedLives,
        myDonatedBooks: donatedBooks,
        categories: categories.take(6).toList(),
        institutionalTotal: institutionalTotal,
        institutionalDonated: institutionalDonated,
        institutionalAvailable: institutionalAvailable,
      );
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<List<BookListItem>> loadExploreBooks() async {
    try {
      final rows = await _client
          .from('books')
          .select(
            'id,user_id,title,author,category,condition,city,status,image_url,created_at',
          )
          .order('created_at', ascending: false);

      final list = rows as List<dynamic>;
      return list.map((row) {
        final m = Map<String, dynamic>.from(row as Map);
        final idRaw = m['id'];
        final id = idRaw is int ? idRaw : int.tryParse('$idRaw') ?? 0;
        final imageValue = _cellToString(m['image_url']).trim();

        return BookListItem(
          id: id,
          userId: _cellToString(m['user_id']).trim(),
          title: _cellToString(m['title']).trim(),
          author: _cellToString(m['author']).trim(),
          category: _cellToString(m['category']).trim(),
          condition: _cellToString(m['condition']).trim(),
          city: _cellToString(m['city']).trim(),
          status: _cellToString(m['status']).trim(),
          imageUrl: imageValue.isEmpty ? null : imageValue,
        );
      }).toList();
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Sube una imagen al bucket público `book-images` y retorna su URL pública.
  Future<String> uploadBookImage({
    required Uint8List bytes,
    required String userId,
    required int timestampMs,
    String contentType = 'image/jpeg',
  }) async {
    final path = 'publicaciones/$userId/$timestampMs.jpg';
    try {
      await _client.storage
          .from(_bookImagesBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: false),
          );
      return _client.storage.from(_bookImagesBucket).getPublicUrl(path);
    } on StorageException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Inserta en `public.books`. Requiere sesión.
  Future<void> publishBook({
    required String title,
    required String author,
    required String categoryValue,
    required String conditionValue,
    String? description,
    String? imageUrl,
    required String city,
    required String recipientTypeValue,
    String? donorName,
    String? donorEmail,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('Debes iniciar sesión para publicar un libro.');
    }

    final now = DateTime.now().toUtc().toIso8601String();
    final desc = description?.trim();
    final payload = <String, dynamic>{
      'user_id': user.id,
      'title': title.trim(),
      'author': author.trim(),
      'category': categoryValue,
      'condition': conditionValue,
      'description': (desc == null || desc.isEmpty) ? null : desc,
      'image_url': (imageUrl == null || imageUrl.trim().isEmpty)
          ? null
          : imageUrl.trim(),
      'city': city.trim(),
      'status': defaultBookStatus,
      'donor_name': (donorName == null || donorName.trim().isEmpty)
          ? null
          : donorName.trim(),
      'donor_email': (donorEmail == null || donorEmail.trim().isEmpty)
          ? null
          : donorEmail.trim(),
      'recipient_type': recipientTypeValue,
      'created_at': now,
      'updated_at': now,
    };

    try {
      await _client.from('books').insert(payload);
    } on PostgrestException catch (e) {
      throw Exception(e.message);
    }
  }
}
