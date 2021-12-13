import 'dart:convert';

import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/shared_preference_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

class MemesRepository {
  final updater = PublishSubject<Null>();
  final SharedPreferenceData spData;

  static MemesRepository? _instance;

  factory MemesRepository.getInstance() => _instance ??=
      MemesRepository._internal(SharedPreferenceData.getInstance());

  MemesRepository._internal(this.spData);

  Future<bool> addToMemes(final Meme meme) async {
    final memes = await _getMemes();
    memes.add(meme);
    return _setMemes(memes);
  }

  Future<bool> removeFromMemes(final String id) async {
    final memes = await _getMemes();
    memes.removeWhere((meme) => meme.id == id);
    return _setMemes(memes);
  }

  Future<bool> updateMeme(final Meme meme) async {
    final memes = await _getMemes();
    int pos = memes.indexWhere((element) => element.id == meme.id);
    if (pos != -1) {
      memes[pos] = meme;
      return _setMemes(memes);
    }
    return false;
  }

  Future<Meme?> getMeme(final String id) async {
    final memes = await _getMemes();
    return memes.firstWhereOrNull((meme) => meme.id == id);
  }

  Stream<List<Meme>> observeMemes() async* {
    yield await _getMemes();
    await for (final _ in updater) {
      yield await _getMemes();
    }
  }

  Future<List<Meme>> _getMemes() async {
    final rawMemes = await spData.getMemes();
    return rawMemes
        .map((rawMeme) => Meme.fromJson(json.decode(rawMeme)))
        .toList();
  }

  Future<bool> _setMemes(List<Meme> memes) async {
    final rawMemes = memes.map((meme) => json.encode(meme.toJson())).toList();
    updater.add(null);
    return spData.setMemes(rawMemes);
  }
}