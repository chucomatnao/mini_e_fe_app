// lib/screens/home_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/category_provider.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<int, int> _stockCache = {};
  final TextEditingController _searchCtrl = TextEditingController();

  int? _selectedRootId;
  int? _selectedCategoryId;
  String _keyword = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchPublicProducts();
      Provider.of<CartProvider>(context, listen: false).fetchCart();
      Provider.of<CategoryProvider>(context, listen: false).fetchTree(); // ✅
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ✅ LẤY categoryId từ ProductModel (an toàn theo dynamic — tránh lệch field)
  int? _tryGetCategoryId(ProductModel product) {
    try {
      final d = product as dynamic;

      final v1 = d.categoryId;
      if (v1 is int) return v1;
      if (v1 is num) return v1.toInt();

      final v2 = d.category_id;
      if (v2 is int) return v2;
      if (v2 is num) return v2.toInt();

      final v3 = d.category?.id;
      if (v3 is int) return v3;
      if (v3 is num) return v3.toInt();

      // nếu có toJson()
      try {
        final m = d.toJson();
        if (m is Map) {
          final v = m['categoryId'] ?? m['category_id'];
          if (v is int) return v;
          if (v is num) return v.toInt();
          if (m['category'] is Map) {
            final vv = (m['category'] as Map)['id'];
            if (vv is int) return vv;
            if (vv is num) return vv.toInt();
          }
        }
      } catch (_) {}

      return null;
    } catch (_) {
      return null;
    }
  }

  CategoryModel? _findNodeById(List<CategoryModel> nodes, int id) {
    for (final n in nodes) {
      if (n.id == id) return n;
      final child = _findNodeById(n.children, id);
      if (child != null) return child;
    }
    return null;
  }

  List<int> _collectSubtreeIds(List<CategoryModel> tree, int rootId) {
    final node = _findNodeById(tree, rootId);
    if (node == null) return [rootId];

    final ids = <int>[];
    void dfs(CategoryModel n) {
      ids.add(n.id);
      for (final c in n.children) dfs(c);
    }

    dfs(node);
    return ids;
  }

  List<ProductModel> _applyFilters(List<ProductModel> products, List<CategoryModel> tree) {
    List<int>? allowedCategoryIds;
    if (_selectedCategoryId != null) {
      allowedCategoryIds = _collectSubtreeIds(tree, _selectedCategoryId!);
    }

    return products.where((p) {
      // filter category
      if (allowedCategoryIds != null) {
        final catId = _tryGetCategoryId(p);
        if (catId == null) return false;
        if (!allowedCategoryIds.contains(catId)) return false;
      }

      // filter keyword
      if (_keyword.trim().isNotEmpty) {
        final kw = _keyword.trim().toLowerCase();
        if (!p.title.toLowerCase().contains(kw)) return false;
      }

      return true;
    }).toList();
  }

  Future<int> _getRealStock(ProductModel product) async {
    if (_stockCache.containsKey(product.id)) return _stockCache[product.id]!;
    try {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final variants = await provider.getVariants(product.id);

      int total = 0;
      if (variants.isNotEmpty) {
        for (var v in variants) {
          total += v.stock;
        }
      } else {
        total = product.stock ?? 0;
      }
      _stockCache[product.id] = total;
      return total;
    } catch (_) {
      final fallback = product.stock ?? 0;
      _stockCache[product.id] = fallback;
      return fallback;
    }
  }

  String _formatPrice(dynamic price) {
    double value = 0.0;
    if (price is String) value = double.tryParse(price) ?? 0.0;
    else if (price is num) value = price.toDouble();
    return value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  void _selectAll() {
    setState(() {
      _selectedRootId = null;
      _selectedCategoryId = null;
    });
  }

  void _selectRoot(CategoryModel root) {
    setState(() {
      _selectedRootId = root.id;
      _selectedCategoryId = root.id;
    });
  }

  void _selectChild(CategoryModel child) {
    setState(() {
      _selectedCategoryId = child.id;
    });
  }

  void _openCategoryPicker(CategoryProvider cp) {
    final options = cp.flattenTree();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Tất cả'),
              trailing: _selectedCategoryId == null ? const Icon(Icons.check) : null,
              onTap: () {
                Navigator.pop(context);
                _selectAll();
              },
            ),
            const Divider(height: 1),
            ...options.map((c) {
              final selected = _selectedCategoryId == c.id;
              return ListTile(
                title: Text(c.name),
                trailing: selected ? const Icon(Icons.check) : null,
                onTap: () {
                  Navigator.pop(context);
                  // rootId: lấy theo parent chain là phức tạp -> ở Home chip vẫn xử lý root,
                  // picker thì cứ chọn trực tiếp categoryId
                  setState(() => _selectedCategoryId = c.id);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _showProductCartDialog(ProductModel product, {bool isBuyNow = false}) async {
    int quantity = 1;

    int? selectedVariantId;
    List<VariantItem> variants = [];

    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    try {
      variants = await productProvider.getVariants(product.id);
    } catch (_) {
      variants = [];
    }

    if (!mounted) return;

    bool didInitDefault = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          if (!didInitDefault) {
            didInitDefault = true;
            if (variants.isNotEmpty) {
              final firstInStock = variants.firstWhere(
                (v) => v.stock > 0,
                orElse: () => variants.first,
              );
              if (firstInStock.stock > 0) {
                selectedVariantId = firstInStock.id;
              }
            }
          }

          VariantItem? selectedVariant;
          if (selectedVariantId != null) {
            try {
              selectedVariant = variants.firstWhere((v) => v.id == selectedVariantId);
            } catch (_) {
              selectedVariant = null;
            }
          }

          int maxStock = _stockCache[product.id] ?? (product.stock ?? 0);
          if (selectedVariant != null) {
            maxStock = selectedVariant.stock;
          }

          final displayPrice = (selectedVariant != null && selectedVariant.price > 0)
              ? _formatPrice(selectedVariant.price)
              : _formatPrice(product.price);

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 650),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl.isNotEmpty
                              ? product.imageUrl
                              : 'https://via.placeholder.com/150',
                          width: 110,
                          height: 110,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$displayPrice VNĐ',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),

                            if (variants.isNotEmpty)
                              Text(
                                selectedVariant != null ? 'Kho: ${selectedVariant.stock}' : 'Kho: ...',
                                style: const TextStyle(color: Colors.grey),
                              )
                            else
                              FutureBuilder<int>(
                                future: _getRealStock(product),
                                builder: (context, snapshot) {
                                  final stock = snapshot.data ?? 0;
                                  return Text('Kho: $stock', style: const TextStyle(color: Colors.grey));
                                },
                              ),

                            if (variants.isNotEmpty && selectedVariant != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  'Đang chọn: ${selectedVariant.name}',
                                  style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  if (variants.isNotEmpty) ...[
                    const Text('Phân loại:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: variants.map((v) {
                        final isSelected = selectedVariantId == v.id;
                        final stock = v.stock;

                        return ChoiceChip(
                          label: Text('${v.name} ($stock)'),
                          selected: isSelected,
                          onSelected: stock <= 0
                              ? null
                              : (val) {
                                  setStateDialog(() {
                                    selectedVariantId = val ? v.id : null;
                                    quantity = 1;
                                  });
                                },
                          selectedColor: const Color(0xFF0D6EFD),
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                          backgroundColor: Colors.grey.shade100,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.25)),
                      ),
                      child: const Text(
                        'Sản phẩm này chưa có biến thể để mua (variant).\nVui lòng chọn sản phẩm khác.',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Số lượng:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: quantity <= 1 ? null : () => setStateDialog(() => quantity--),
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('$quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          IconButton(
                            onPressed: (maxStock <= 0 || quantity >= maxStock)
                                ? null
                                : () => setStateDialog(() => quantity++),
                            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0D6EFD)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (variants.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sản phẩm chưa có biến thể để mua')),
                          );
                          return;
                        }

                        if (selectedVariantId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng chọn phân loại')),
                          );
                          return;
                        }

                        if (maxStock <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sản phẩm đã hết hàng')),
                          );
                          return;
                        }

                        try {
                          await Provider.of<CartProvider>(context, listen: false).addToCart(
                            product.id,
                            variantId: selectedVariantId!,
                            quantity: quantity,
                          );

                          if (!mounted) return;
                          Navigator.pop(context);

                          if (isBuyNow) {
                            Navigator.pushNamed(context, '/cart');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã thêm vào giỏ hàng'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;
                          final msg = e.toString().replaceAll('Exception: ', '');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(msg), backgroundColor: Colors.red),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6EFD),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        isBuyNow ? 'MUA NGAY' : 'THÊM VÀO GIỎ',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _header(BuildContext context, CategoryProvider cp) {
    final roots = cp.tree; // root nodes

    CategoryModel? selectedRoot;
    if (_selectedRootId != null) {
      selectedRoot = _findNodeById(roots, _selectedRootId!);
    }

    final children = selectedRoot?.children ?? const <CategoryModel>[];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D6EFD), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Mini-E',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                ),
                Consumer<CartProvider>(
                  builder: (_, provider, __) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      InkWell(
                        onTap: () => Navigator.pushNamed(context, '/cart'),
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                        ),
                      ),
                      if ((provider.cartData?.itemsCount ?? 0) > 0)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: Text(
                              '${provider.cartData!.itemsCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(Icons.person_outline, color: Colors.white),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Text(
              'Tìm món bạn thích 👀',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            // Search
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchCtrl,
                textInputAction: TextInputAction.search,
                onSubmitted: (v) => setState(() => _keyword = v.trim()),
                decoration: InputDecoration(
                  hintText: 'Tìm sản phẩm...',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Chọn danh mục',
                        icon: const Icon(Icons.category_outlined),
                        onPressed: () => _openCategoryPicker(cp),
                      ),
                      if (_searchCtrl.text.isNotEmpty || _keyword.isNotEmpty)
                        IconButton(
                          tooltip: 'Xoá tìm kiếm',
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _keyword = '');
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ✅ Categories from API
            if (cp.loadingTree)
              const Text('Đang tải danh mục...', style: TextStyle(color: Colors.white70))
            else ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _CategoryChip(
                      label: 'Tất cả',
                      selected: _selectedCategoryId == null,
                      onTap: _selectAll,
                    ),
                    ...roots.map((c) => _CategoryChip(
                          label: c.name,
                          selected: _selectedRootId == c.id,
                          onTap: () => _selectRoot(c),
                        )),
                  ],
                ),
              ),

              if (children.isNotEmpty) ...[
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...children.map((c) => _CategoryChip(
                            label: c.name,
                            selected: _selectedCategoryId == c.id,
                            onTap: () => _selectChild(c),
                          )),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {VoidCallback? onViewAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ),
          if (onViewAll != null)
            InkWell(
              onTap: onViewAll,
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Text('Xem tất cả', style: TextStyle(color: Color(0xFF0D6EFD), fontWeight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _productCard(ProductModel product) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/product-detail', arguments: product),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl.isNotEmpty ? product.imageUrl : 'https://via.placeholder.com/300',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Container(color: Colors.grey.shade200),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        child: const Center(child: Icon(Icons.image_not_supported, size: 44, color: Colors.grey)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827).withOpacity(0.75),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text('Hot', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_formatPrice(product.price)} VNĐ',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.red),
                    ),
                    const SizedBox(height: 6),
                    FutureBuilder<int>(
                      future: _getRealStock(product),
                      builder: (_, snapshot) {
                        final stock = snapshot.data ?? 0;
                        return Text(
                          stock > 0 ? 'Còn $stock' : 'Hết hàng',
                          style: TextStyle(fontSize: 12, color: stock > 0 ? Colors.grey.shade700 : Colors.red),
                        );
                      },
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _showProductCartDialog(product),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6EFD),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Thêm giỏ', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Consumer2<ProductProvider, CategoryProvider>(
        builder: (context, productProvider, categoryProvider, child) {
          final filtered = _applyFilters(productProvider.products, categoryProvider.tree);

          return Column(
            children: [
              _header(context, categoryProvider),
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (productProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (productProvider.products.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Không tải được sản phẩm.\nVui lòng kiểm tra kết nối mạng.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Không có sản phẩm trong bộ lọc hiện tại.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _sectionHeader('Sản phẩm nổi bật', onViewAll: () {}),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => _productCard(filtered[index]),
                              childCount: filtered.length,
                            ),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 14,
                              mainAxisSpacing: 14,
                              childAspectRatio: 0.70,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 18)),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: const Color(0xFF111827),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 3) Navigator.pushNamed(context, '/personal-info');
          if (index == 2) Navigator.pushNamed(context, '/cart');
          if (index == 1) {
            final cp = Provider.of<CategoryProvider>(context, listen: false);
            _openCategoryPicker(cp); // ✅ mở picker danh mục
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Danh mục'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Giỏ hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Tôi'),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.white.withOpacity(0.20),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.28)),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF0D6EFD) : Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
