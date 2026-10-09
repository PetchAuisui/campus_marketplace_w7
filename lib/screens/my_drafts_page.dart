import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/item.dart';
import '../repositories/item_repository_firestore.dart';
import '../repositories/listing_draft_repository.dart';
import '../services/storage_service.dart';
import '../database/app_database.dart';

class MyDraftsPage extends StatefulWidget {
  final ListingDraftRepository draftRepository;

  const MyDraftsPage({super.key, required this.draftRepository});

  @override
  State<MyDraftsPage> createState() => _MyDraftsPageState();
}

class _MyDraftsPageState extends State<MyDraftsPage> {
  late Future<List<ListingDraftRow>> _draftsFuture;

  @override
  void initState() {
    super.initState();
    _loadDrafts();
  }

  void _loadDrafts() {
    setState(() {
      _draftsFuture = widget.draftRepository.getAllDrafts();
    });
  }

  Future<void> _deleteDraft(int id) async {
    await widget.draftRepository.deleteDraft(id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ลบร่างประกาศแล้ว')),
    );
    _loadDrafts(); // รีโหลดหลังจากลบ
  }

  Future<double?> _askPrice() {
    final controller = TextEditingController();
    String? errorText;
    return showDialog<double>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('ระบุราคาสินค้า'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'ราคา (บาท)',
              errorText: errorText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            FilledButton(
              onPressed: () {
                final price = double.tryParse(controller.text.trim());
                if (price == null || price <= 0) {
                  setDialogState(
                      () => errorText = 'กรุณากรอกตัวเลขที่มากกว่า 0');
                  return;
                }
                Navigator.pop(context, price);
              },
              child: const Text('ตกลง'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _publishDraft(ListingDraftRow draft) async {
    if (draft.imagePath.isNotEmpty && !File(draft.imagePath).existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่พบไฟล์รูปของร่างนี้ กรุณาลบร่างแล้วสร้างใหม่'),
        ),
      );
      return;
    }
    final price = await _askPrice();
    if (price == null || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final sellerId = FirebaseAuth.instance.currentUser!.uid;

      var imageUrl = '';
      if (draft.imagePath.isNotEmpty) {
        // ต้องได้ URL ก่อน แล้วค่อยเขียน Firestore
        imageUrl = await StorageService()
            .uploadListingImage(File(draft.imagePath), sellerId);
      }

      final item = Item(
        id: DateTime.now().millisecondsSinceEpoch,
        title: draft.title,
        price: price,
        description: draft.description,
        category: draft.category,
        imageUrl: imageUrl,
        sellerId: sellerId,
      );
      await ItemRepositoryFirestore().postItem(item);
      await widget.draftRepository.deleteDraft(draft.id);

      if (!mounted) return;
      Navigator.pop(context); // ปิด Progress Indicator
      messenger.showSnackBar(
        const SnackBar(content: Text('โพสต์ขายสำเร็จแล้ว')),
      );
      _loadDrafts();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text('โพสต์ไม่สำเร็จ: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ร่างประกาศของฉัน'),
      ),
      body: FutureBuilder<List<ListingDraftRow>>(
        future: _draftsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: _loadDrafts,
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          }

          final drafts = snapshot.data ?? [];

          if (drafts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'ยังไม่มีร่างประกาศ',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: drafts.length,
            itemBuilder: (context, index) {
              final draft = drafts[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: draft.imagePath.isNotEmpty
                        ? Image.file(
                            File(draft.imagePath),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.broken_image),
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image),
                          ),
                  ),
                  title: Text(
                    draft.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'หมวดหมู่: ${draft.category}\nแก้ไขล่าสุด: ${draft.updatedAt.toLocal().toString().split('.')[0]}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.cloud_upload,
                            color: Colors.green),
                        tooltip: 'โพสต์ขายจริง',
                        onPressed: () => _publishDraft(draft),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteDraft(draft.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
