import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/item.dart';
import 'item_repository.dart';

class ItemRepositoryApi implements ItemRepository {
  static const _baseUrl = 'https://fakestoreapi.com/products';

  static const List<Item> _fallbackItems = [
    Item(
      id: 1,
      title: 'Fjallraven - Foldsack No. 1 Backpack, Fits 15 Laptops',
      price: 109.95,
      description:
          'Your perfect pack for everyday use and walks in the forest. Stash your laptop (up to 15 inches) in the padded sleeve, your everyday',
      category: "men's clothing",
      imageUrl:
          'https://m.media-amazon.com/images/I/81fPKd-2AYL._AC_SL1500_.jpg',
    ),
    Item(
      id: 2,
      title: 'Mens Casual Premium Slim Fit T-Shirts',
      price: 22.3,
      description:
          'Slim-fitting style, contrast raglan long sleeve, three-button henley placket, light weight & soft fabric for breathable and comfortable wearing.',
      category: "men's clothing",
      imageUrl:
          'https://m.media-amazon.com/images/I/71-3HjGNDUL._AC_SY879._SX._UX._SY._UY_.jpg',
    ),
    Item(
      id: 3,
      title: 'Mens Cotton Jacket',
      price: 55.99,
      description:
          'great outerwear jackets for Spring/Autumn/Winter, suitable for many occasions, such as working, hiking, camping, mountain/rock climbing, cycling, traveling or other outdoors.',
      category: "men's clothing",
      imageUrl:
          'https://m.media-amazon.com/images/I/71li-ujtlUL._AC_UX679_.jpg',
    ),
    Item(
      id: 4,
      title: 'Mens Casual Slim Fit',
      price: 15.99,
      description:
          'The color could be slightly different between on the screen and in practice. / Please note that body builds vary by person, therefore, detailed size information should be reviewed below on the product description.',
      category: "men's clothing",
      imageUrl:
          'https://m.media-amazon.com/images/I/71YXzeOuslL._AC_UY879_.jpg',
    ),
    Item(
      id: 5,
      title:
          'John Hardy Women\'s Legends Naga Gold & Silver Dragon Station Chain Bracelet',
      price: 695.0,
      description:
          'From our Legends Collection, the Naga was inspired by the mythical water dragon that protects the ocean\'s pearl. Wear facing inward to be bestowed with love and abundance, or outward for protection.',
      category: 'jewelery',
      imageUrl:
          'https://m.media-amazon.com/images/I/71pWzhdJNwL._AC_UL640_QL65_ML3_.jpg',
    ),
    Item(
      id: 6,
      title: 'Solid Gold Petite Micropave',
      price: 168.0,
      description:
          'Satisfaction Guaranteed. Return or exchange any order within 30 days. Designed and sold by Hafeez Center in the United States. Satisfaction Guaranteed. Return or exchange any order within 30 days.',
      category: 'jewelery',
      imageUrl:
          'https://m.media-amazon.com/images/I/61sbMiUnoGL._AC_UL640_QL65_ML3_.jpg',
    ),
    Item(
      id: 7,
      title: 'White Gold Plated Princess',
      price: 9.99,
      description:
          'Classic Created Wedding Engagement Solitaire Diamond Promise Ring for Her. Quietly stylish, it is made of pure sterling silver and cubic zirconia crystals.',
      category: 'jewelery',
      imageUrl:
          'https://m.media-amazon.com/images/I/71YAIFU48IL._AC_UL640_QL65_ML3_.jpg',
    ),
    Item(
      id: 8,
      title: 'Pierced Owl Rose Gold Plated Stainless Steel Double',
      price: 10.99,
      description:
          'Rose Gold Plated Double Flared Tunnel Plug Earrings. Made of 316L Stainless Steel',
      category: 'jewelery',
      imageUrl:
          'https://m.media-amazon.com/images/I/51UDEzMJVpL._AC_UL640_QL65_ML3_.jpg',
    ),
    Item(
      id: 9,
      title: 'WD 2TB Elements Portable External Hard Drive - USB 3.0',
      price: 64.0,
      description:
          'USB 3.0 and USB 2.0 Compatibility Fast data transfers Improve PC Performance High Capacity; Compatibility Formatted NTFS for Windows 10, Windows 8.1, Windows 7; Reformatting may be required for other operating systems',
      category: 'electronics',
      imageUrl:
          'https://m.media-amazon.com/images/I/61IBBVJvSDL._AC_SY879_.jpg',
    ),
    Item(
      id: 10,
      title: 'SanDisk SSD PLUS 1TB Internal SSD - SATA III 6 Gb/s',
      price: 109.0,
      description:
          'Easy upgrade for faster boot up, shutdown, application load and response (As compared to 5400 RPM SATA 2.5” hard drive; Based on published specifications and internal benchmarking tests using PCMark vantage scores) Boosts burst write performance, making it ideal for typical PC workloads The perfect balance of performance and reliability Read/write speeds of up to 535MB/s/450MB/s (Based on internal testing; Performance may vary depending upon drive capacity, host device, OS and application.)',
      category: 'electronics',
      imageUrl:
          'https://m.media-amazon.com/images/I/61U7T1koQqL._AC_SX679_.jpg',
    ),
    Item(
      id: 11,
      title:
          'Silicon Power 256GB SSD 3D NAND A55 SLC Cache Performance Boost 2.5 Inch SATA III 6Gb/s',
      price: 109.0,
      description:
          '3D NAND flash are applied to deliver high transfer speeds Remarkable transfer speeds that enable faster bootup and improved overall system performance. The advanced SLC Cache Technology allows performance boost and longer lifespan 7mm slim design suitable for Ultrabooks and Ultra-slim notebooks.',
      category: 'electronics',
      imageUrl:
          'https://m.media-amazon.com/images/I/71kWymZQtCL._AC_SX679_.jpg',
    ),
    Item(
      id: 12,
      title:
          'WD 4TB Gaming Drive Works with Playstation 4 Portable External Hard Drive',
      price: 114.0,
      description:
          'Expand your PS4 gaming experience, Play anywhere Fast and easy, setup Sleek design with high capacity, 3-year manufacturer\'s limited warranty',
      category: 'electronics',
      imageUrl:
          'https://m.media-amazon.com/images/I/61mtL65D4cL._AC_SX679_.jpg',
    ),
    Item(
      id: 13,
      title:
          'Acer SB220Q bi 21.5 inches Full HD (1920 x 1080) IPS Ultra-Thin',
      price: 599.0,
      description:
          '21. 5 inches Full HD (1920 x 1080) widescreen IPS display And Radeon free Sync technology. No compatibility for VESA Mount Refresh Rate: 75Hz - Using HDMI port Zero-frame design | ultra-thin | 4ms response time | IPS panel Aspect ratio - 16: 9. Color Supported - 16. 7 million colors.',
      category: 'electronics',
      imageUrl:
          'https://m.media-amazon.com/images/I/81QpkIctqPL._AC_SX679_.jpg',
    ),
    Item(
      id: 14,
      title:
          'Samsung 49-Inch CHG90 144Hz Curved Gaming Monitor (LC49HG90DMNXZA) – Super Ultrawide Screen QLED',
      price: 999.99,
      description:
          '49 INCH SUPER ULTRAWIDE 32:9 CURVED GAMING MONITOR with dual 27 inch screen side by side QUANTUM DOT (QLED) TECHNOLOGY, HDR support and factory calibration provides stunningly realistic and accurate color and contrast 144HZ HIGH REFRESH RATE and 1ms ultra fast response time work to eliminate motion blur, ghosting, and reduce input lag',
      category: 'electronics',
      imageUrl:
          'https://m.media-amazon.com/images/I/81rus0UFhsL._AC_SX679_.jpg',
    ),
    Item(
      id: 16,
      title:
          'Lock and Love Women\'s Removable Hooded Faux Leather Moto Biker Jacket',
      price: 29.95,
      description:
          '100% POLYURETHANE(shell) 100% POLYESTER(lining) 75% POLYESTER 25% COTTON (SWEATER), Faux leather material for style and comfort / 2 pockets of front, 2-For-One Hooded denim style faux leather jacket, Button detail on waist / Detail stitching at sides, HAND WASH ONLY / DO NOT BLEACH / LINE DRY / DO NOT IRON',
      category: "women's clothing",
      imageUrl:
          'https://m.media-amazon.com/images/I/81XH0e8fefL._AC_UY879_.jpg',
    ),
    Item(
      id: 17,
      title: 'Rain Jacket Women Windbreaker Striped Climbing Raincoats',
      price: 39.99,
      description:
          'Lightweight perfet for trip or casual wear---Long sleeve with hooded, adjustable drawstring waist design. Button and zipper front closure raincoat, fully stripes Lined and The Raincoat has 2 side pockets are a good size to hold all kinds of things, it covers the hips, and the hood is generous but doesn\'t overdo it.',
      category: "women's clothing",
      imageUrl:
          'https://m.media-amazon.com/images/I/71HblAHs5xL._AC_UY879_-2.jpg',
    ),
    Item(
      id: 18,
      title: 'MBJ Women\'s Solid Short Sleeve Boat Neck V',
      price: 9.85,
      description:
          '95% RAYON 5% SPANDEX, Made in USA or Imported, Do Not Bleach, Lightweight fabric with great stretch for comfort, Ribbed on sleeves and neckline / Double stitching on bottom hem',
      category: "women's clothing",
      imageUrl:
          'https://m.media-amazon.com/images/I/71z3kpMAYsL._AC_UY879_.jpg',
    ),
    Item(
      id: 20,
      title: 'DANVOUY Womens T Shirt Casual Cotton Short',
      price: 12.99,
      description:
          '95%Cotton,5%Spandex, Features: Casual, Short Sleeve, Letter Print,V-Neck,Fashion Tees, The fabric is soft and has some stretch., Occasion: Casual/Office/Beach/School/Home/Street. Season: Spring,Summer,Autumn,Winter.',
      category: "women's clothing",
      imageUrl:
          'https://m.media-amazon.com/images/I/61pHAEJ4NML._AC_UX679_.jpg',
    ),
  ];

  @override
  Future<List<Item>> getItems() async {
    final uri = Uri.parse(_baseUrl);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((e) => Item.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return _fallbackItems;
    } catch (_) {
      // เมื่อ FakeStoreAPI ล่ม (Cloudflare 522/403) ให้คืนค่า 20 รายการเต็มพร้อมรูปภาพต้นฉบับทันที
      return _fallbackItems;
    }
  }
}
