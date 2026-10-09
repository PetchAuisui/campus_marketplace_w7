import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  /// อัปโหลดรูปประกาศขึ้น Storage แล้วคืนค่า Download URL
  Future<String> uploadListingImage(File imageFile, String sellerId) async {
    final fileName = '${sellerId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('listings/$fileName');

    // ต้อง await ให้อัปโหลดเสร็จก่อน จึงจะเรียก getDownloadURL() ได้
    await ref.putFile(imageFile);
    return ref.getDownloadURL();
  }
}
