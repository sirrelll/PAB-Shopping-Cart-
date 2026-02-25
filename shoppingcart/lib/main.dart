import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HalamanProduk()));
}

// data produk
List<Map<String, dynamic>> produkList = [
  {'nama': 'Sepatu Nike', 'harga': 850000, 'kategori': 'Sepatu'},
  {'nama': 'Sepatu Adidas', 'harga': 750000, 'kategori': 'Sepatu'},
  {'nama': 'Kaos Polos', 'harga': 120000, 'kategori': 'Baju'},
  {'nama': 'Kemeja Batik', 'harga': 250000, 'kategori': 'Baju'},
  {'nama': 'Celana Jeans', 'harga': 350000, 'kategori': 'Celana'},
  {'nama': 'Topi Baseball', 'harga': 95000, 'kategori': 'Aksesoris'},
  {'nama': 'Jam Tangan', 'harga': 500000, 'kategori': 'Aksesoris'},
  {'nama': 'Tas Ransel', 'harga': 320000, 'kategori': 'Tas'},
];

// isi keranjang belanja
List<Map<String, dynamic>> cart = [];

// ubah angka jadi format rupiah
String rupiah(int angka) {
  String s = angka.toString();
  String hasil = '';
  int hitung = 0;
  for (int i = s.length - 1; i >= 0; i--) {
    if (hitung > 0 && hitung % 3 == 0) hasil = '.' + hasil;
    hasil = s[i] + hasil;
    hitung++;
  }
  return 'Rp $hasil';
}

// HALAMAN PRODUK

class HalamanProduk extends StatefulWidget {
  @override
  State<HalamanProduk> createState() => _HalamanProdukState();
}

class _HalamanProdukState extends State<HalamanProduk> {
  String cari = '';
  String kategoriDipilih = 'Semua';
  List<String> kategoriList = ['Semua', 'Sepatu', 'Baju', 'Celana', 'Aksesoris', 'Tas'];

  // hitung total item di cart buat badge
  int totalDiCart() {
    int total = 0;
    for (int i = 0; i < cart.length; i++) {
      total = total + (cart[i]['qty'] as int);
    }
    return total;
  }

  // tambah produk ke cart
  void tambahKeCart(Map<String, dynamic> produk) {
    String namaProduk = produk['nama'] as String;
    int hargaProduk = produk['harga'] as int;

    // cek dulu apakah sudah ada di cart
    for (int i = 0; i < cart.length; i++) {
      String namaCart = cart[i]['nama'] as String;
      if (namaCart == namaProduk) {
        setState(() {
          cart[i]['qty'] = (cart[i]['qty'] as int) + 1;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$namaProduk ditambahkan!'), duration: Duration(seconds: 1)),
        );
        return;
      }
    }

    // belum ada, masukin baru
    setState(() {
      cart.add({'nama': namaProduk, 'harga': hargaProduk, 'qty': 1});
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$namaProduk ditambahkan!'), duration: Duration(seconds: 1)),
    );
  }

  // filter produk berdasarkan search dan kategori
  List<Map<String, dynamic>> getProdukFiltered() {
    List<Map<String, dynamic>> hasil = [];
    for (int i = 0; i < produkList.length; i++) {
      String namaItem = produkList[i]['nama'] as String;
      String kategoriItem = produkList[i]['kategori'] as String;

      bool cocokKategori = kategoriDipilih == 'Semua' || kategoriItem == kategoriDipilih;
      bool cocokNama = namaItem.toLowerCase().contains(cari.toLowerCase());

      if (cocokKategori && cocokNama) {
        hasil.add(produkList[i]);
      }
    }
    return hasil;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> produkTampil = getProdukFiltered();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Toko Gacor', style: TextStyle(color: Colors.white)),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (c) => HalamanCart()))
                  .then((_) {
                setState(() {});
              });
            },
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Stack(
                children: [
                  Icon(Icons.shopping_cart, color: Colors.white, size: 28),
                  if (totalDiCart() > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text(
                          '${totalDiCart()}',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // search bar
          Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (val) {
                setState(() {
                  cari = val;
                });
              },
            ),
          ),

          // filter kategori
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              children: kategoriList.map((kat) {
                bool aktif = kat == kategoriDipilih;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      kategoriDipilih = kat;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 8),
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: aktif ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      kat,
                      style: TextStyle(
                        color: aktif ? Colors.white : Colors.black,
                        fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 8),

          // list produk
          Expanded(
            child: produkTampil.isEmpty
                ? Center(child: Text('Produk tidak ditemukan'))
                : ListView.builder(
                    itemCount: produkTampil.length,
                    itemBuilder: (context, index) {
                      var produk = produkTampil[index];
                      String nama = produk['nama'] as String;
                      int harga = produk['harga'] as int;
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue[100],
                            child: Text(nama[0]),
                          ),
                          title: Text(nama),
                          subtitle: Text(
                            rupiah(harga),
                            style: TextStyle(color: Colors.orange[700]),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              tambahKeCart(produk);
                            },
                            child: Text('+ Cart'),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// HALAMAN CART

class HalamanCart extends StatefulWidget {
  @override
  State<HalamanCart> createState() => _HalamanCartState();
}

class _HalamanCartState extends State<HalamanCart> {
  int totalHarga() {
    int total = 0;
    for (int i = 0; i < cart.length; i++) {
      int harga = cart[i]['harga'] as int;
      int qty = cart[i]['qty'] as int;
      total = total + (harga * qty);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Keranjang', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: cart.isEmpty
          ? Center(child: Text('Keranjang masih kosong'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      String nama = cart[index]['nama'] as String;
                      int harga = cart[index]['harga'] as int;
                      int qty = cart[index]['qty'] as int;

                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(nama, style: TextStyle(fontWeight: FontWeight.bold)),
                                    SizedBox(height: 4),
                                    Text(
                                      rupiah(harga * qty),
                                      style: TextStyle(color: Colors.orange[700]),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    if ((cart[index]['qty'] as int) > 1) {
                                      cart[index]['qty'] = (cart[index]['qty'] as int) - 1;
                                    } else {
                                      cart.removeAt(index);
                                    }
                                  });
                                },
                              ),
                              Text('$qty', style: TextStyle(fontSize: 16)),
                              IconButton(
                                icon: Icon(Icons.add_circle, color: Colors.green),
                                onPressed: () {
                                  setState(() {
                                    cart[index]['qty'] = (cart[index]['qty'] as int) + 1;
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    cart.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total:', style: TextStyle(fontSize: 16)),
                          Text(
                            rupiah(totalHarga()),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (c) => HalamanCheckout()));
                          },
                          child: Text('Checkout',
                              style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// HALAMAN CHECKOUT 

class HalamanCheckout extends StatefulWidget {
  @override
  State<HalamanCheckout> createState() => _HalamanCheckoutState();
}

class _HalamanCheckoutState extends State<HalamanCheckout> {
  TextEditingController namaCtrl = TextEditingController();
  TextEditingController alamatCtrl = TextEditingController();
  TextEditingController hpCtrl = TextEditingController();

  int totalHarga() {
    int total = 0;
    for (int i = 0; i < cart.length; i++) {
      int harga = cart[i]['harga'] as int;
      int qty = cart[i]['qty'] as int;
      total = total + (harga * qty);
    }
    return total;
  }

  void order() {
    if (namaCtrl.text.isEmpty || alamatCtrl.text.isEmpty || hpCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Semua field harus diisi!'), backgroundColor: Colors.red),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Pesanan Berhasil! 🎉'),
        content: Text('Makasih ${namaCtrl.text}!\nDikirim ke: ${alamatCtrl.text}'),
        actions: [
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.popUntil(context, (r) => r.isFirst);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('Checkout', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ringkasan Pesanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        String nama = cart[index]['nama'] as String;
                        int harga = cart[index]['harga'] as int;
                        int qty = cart[index]['qty'] as int;
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$nama x$qty'),
                              Text(rupiah(harga * qty)),
                            ],
                          ),
                        );
                      },
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(rupiah(totalHarga()),
                            style:
                                TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Text('Data Pengiriman',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextField(
              controller: namaCtrl,
              decoration: InputDecoration(labelText: 'Nama', border: OutlineInputBorder()),
            ),
            SizedBox(height: 12),
            TextField(
              controller: alamatCtrl,
              maxLines: 2,
              decoration: InputDecoration(labelText: 'Alamat', border: OutlineInputBorder()),
            ),
            SizedBox(height: 12),
            TextField(
              controller: hpCtrl,
              keyboardType: TextInputType.phone,
              decoration:
                  InputDecoration(labelText: 'Nomor HP', border: OutlineInputBorder()),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  order();
                },
                child: Text('Pesan Sekarang',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}