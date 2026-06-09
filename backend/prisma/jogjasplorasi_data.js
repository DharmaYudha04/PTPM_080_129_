// Data utama JogjaSplorasi.
// Semua data seed destinasi dan kuis disatukan di file ini agar tidak tercecer.
// Edit data destinasi atau soal kuis dari file ini saja, lalu jalankan: npm run db:seed

const destinations = [
  {
    name: "Keraton Yogyakarta",
    type: "CULTURE",
    category: "Sejarah",
    lat: -7.8053,
    lng: 110.3642,
    address: "Jl. Rotowijayan Blok No.1, Panembahan, Kraton, Yogyakarta",
    rating: 4.8,
    culturalValue: 5,
    ticketPrice: "Mulai sekitar Rp15.000-Rp25.000, cek loket resmi untuk update",
    openingHours: "Umumnya 08.00-14.00, Senin sering terbatas",
    bestTime: "Pagi hari saat area belum terlalu ramai",
    duration: "1,5-2,5 jam",
    tags: ["Keraton", "Budaya", "Sejarah", "Heritage", "Keluarga"],
    description: "Jantung budaya Yogyakarta yang menyimpan kisah Kesultanan, tata ruang Jawa, dan peninggalan bersejarah yang masih hidup hingga hari ini.",
    story: "Keraton bukan sekadar bangunan istana, tetapi pusat kebudayaan yang memperlihatkan bagaimana tradisi Jawa dijaga lewat arsitektur, upacara, busana, gamelan, dan tata krama.",
    insight: "Datang pagi agar lebih nyaman menikmati museum, halaman keraton, dan suasana klasik kawasan Kraton.",
    imageUrl: "assets/images/destinations/keraton.jpg",
  },
  {
    name: "Taman Sari",
    type: "CULTURE",
    category: "Sejarah",
    lat: -7.8101,
    lng: 110.3594,
    address: "Patehan, Kraton, Yogyakarta",
    rating: 4.7,
    culturalValue: 5,
    ticketPrice: "Mulai sekitar Rp15.000-Rp25.000",
    openingHours: "Umumnya 09.00-15.00",
    bestTime: "Pagi atau menjelang sore untuk cahaya foto yang lembut",
    duration: "1-2 jam",
    tags: ["Taman-sari", "Sejarah", "Arsitektur", "Foto", "Keraton"],
    description: "Bekas taman kerajaan dengan kolam pemandian, lorong bawah tanah, dan sudut arsitektur yang fotogenik.",
    story: "Taman Sari dahulu menjadi area peristirahatan keluarga kerajaan. Lorong, sumur gumuling, dan kolamnya membuat tempat ini terasa seperti labirin sejarah di tengah kota.",
    insight: "Gunakan alas kaki nyaman karena area kunjungannya berupa lorong, tangga, dan gang kampung.",
    imageUrl: "assets/images/destinations/tamansari.jpg",
  },
  {
    name: "Malioboro",
    type: "TOURISM",
    category: "Ikonik",
    lat: -7.793,
    lng: 110.3658,
    address: "Jl. Malioboro, Sosromenduran, Gedong Tengen, Yogyakarta",
    rating: 4.8,
    culturalValue: 5,
    ticketPrice: "Gratis, siapkan biaya parkir/belanja",
    openingHours: "Area terbuka 24 jam, toko umumnya siang-malam",
    bestTime: "Sore hingga malam",
    duration: "1-3 jam",
    tags: ["Malioboro", "Belanja", "Ikonik", "Jalan-kaki", "Oleh-oleh"],
    description: "Koridor paling legendaris di Jogja untuk berjalan santai, berburu oleh-oleh, menikmati suasana kota, dan merasakan denyut wisata Yogyakarta.",
    story: "Malioboro tumbuh sebagai ruang pertemuan wisatawan, pedagang, seniman jalanan, dan sejarah kota. Di sini Jogja terasa hidup dari pagi sampai malam.",
    insight: "Lebih nyaman berjalan kaki; gunakan kantong kecil dan jaga barang bawaan saat area ramai.",
    imageUrl: "assets/images/destinations/malioboro.jpg",
  },
  {
    name: "Tugu Yogyakarta",
    type: "TOURISM",
    category: "Ikonik",
    lat: -7.7829,
    lng: 110.3671,
    address: "Cokrodiningratan, Jetis, Yogyakarta",
    rating: 4.7,
    culturalValue: 5,
    ticketPrice: "Gratis",
    openingHours: "Area publik 24 jam",
    bestTime: "Malam hari atau pagi sangat awal",
    duration: "20-45 menit",
    tags: ["Tugu", "Ikonik", "Foto", "Filosofi", "Kota"],
    description: "Landmark ikonik Jogja yang menjadi simbol arah, filosofi, dan kenangan bagi banyak orang yang pernah singgah di Yogyakarta.",
    story: "Tugu berada pada garis imajiner antara Merapi, Keraton, dan Laut Selatan. Karena itu, ia bukan sekadar monumen, tetapi bagian dari filosofi tata ruang Jogja.",
    insight: "Berfoto dari trotoar dengan aman; jangan berdiri di tengah jalan karena lalu lintas cukup ramai.",
    imageUrl: "assets/images/destinations/tugu.jpg",
  },
  {
    name: "Museum Benteng Vredeburg",
    type: "CULTURE",
    category: "Sejarah",
    lat: -7.8002,
    lng: 110.3668,
    address: "Jl. Margo Mulyo No.6, Ngupasan, Yogyakarta",
    rating: 4.6,
    culturalValue: 5,
    ticketPrice: "Mulai sekitar Rp3.000-Rp10.000",
    openingHours: "Umumnya 08.00-15.30, Senin tutup",
    bestTime: "Pagi atau siang",
    duration: "1-2 jam",
    tags: ["Museum", "Sejarah", "Vredeburg", "Edukasi", "Keluarga"],
    description: "Benteng kolonial yang kini menjadi museum perjuangan, cocok untuk memahami perjalanan sejarah Indonesia lewat diorama dan suasana bangunan tua.",
    story: "Bangunan ini pernah menjadi saksi masa kolonial dan dinamika politik Yogyakarta. Kini Vredeburg menawarkan cerita sejarah dengan cara yang mudah dinikmati keluarga.",
    insight: "Lokasinya dekat Malioboro dan Titik Nol, cocok digabung dalam satu rute jalan kaki.",
    imageUrl: "assets/images/destinations/bentengvredeburg.jpg",
  },
  {
    name: "Museum Sonobudoyo",
    type: "CULTURE",
    category: "Budaya",
    lat: -7.8038,
    lng: 110.3633,
    address: "Jl. Pangurakan No.6, Ngupasan, Yogyakarta",
    rating: 4.7,
    culturalValue: 5,
    ticketPrice: "Mulai sekitar Rp10.000-Rp20.000",
    openingHours: "Umumnya 08.00-20.00, cek jadwal pertunjukan",
    bestTime: "Sore jika ingin lanjut pertunjukan wayang",
    duration: "1-2 jam",
    tags: ["Museum", "Wayang", "Keris", "Batik", "Budaya"],
    description: "Museum budaya Jawa dengan koleksi wayang, keris, batik, topeng, dan benda tradisi yang membuat kisah Jawa terasa dekat.",
    story: "Sonobudoyo adalah tempat yang pas untuk memahami detail budaya Jawa tanpa harus membaca buku tebal. Koleksinya kaya, ruangnya nyaman, dan lokasinya sangat strategis.",
    insight: "Cek jadwal pertunjukan wayang malam agar kunjungan lebih berkesan.",
    imageUrl: "assets/images/destinations/museumsonobudoyo.jpg",
  },
  {
    name: "Kotagede",
    type: "CULTURE",
    category: "Sejarah",
    lat: -7.8281,
    lng: 110.3984,
    address: "Kotagede, Yogyakarta",
    rating: 4.7,
    culturalValue: 5,
    ticketPrice: "Gratis untuk kawasan, beberapa objek bisa berbayar sukarela",
    openingHours: "Kawasan terbuka, toko perak umumnya siang-sore",
    bestTime: "Pagi atau sore",
    duration: "2-3 jam",
    tags: ["Kotagede", "Perak", "Mataram", "Heritage", "Kampung"],
    description: "Kawasan heritage bekas pusat Mataram Islam dengan gang tua, rumah tradisional, makam raja, dan sentra kerajinan perak.",
    story: "Kotagede menyimpan lapisan sejarah panjang Jogja. Dari tembok tua, pasar tradisional, sampai pengrajin perak, tiap sudutnya punya cerita.",
    insight: "Jelajahi pelan-pelan dengan berjalan kaki; beberapa area punya aturan berpakaian sopan.",
    imageUrl: "assets/images/destinations/kotagede.jpg",
  },
  {
    name: "Kampung Wisata Tamansari",
    type: "CULTURE",
    category: "Budaya",
    lat: -7.8108,
    lng: 110.3577,
    address: "Patehan, Kraton, Yogyakarta",
    rating: 4.5,
    culturalValue: 4,
    ticketPrice: "Gratis untuk kampung, bayar sesuai aktivitas/workshop",
    openingHours: "Umumnya pagi-sore",
    bestTime: "Pagi atau sore",
    duration: "1-2 jam",
    tags: ["Kampung-wisata", "Batik", "Mural", "Lokal", "Kerajinan"],
    description: "Kampung wisata di sekitar Taman Sari yang menawarkan suasana lokal, mural, batik, dan cerita kehidupan warga Kraton.",
    story: "Di balik area populer Taman Sari, kampung ini memperlihatkan Jogja yang lebih intim: lorong kecil, senyum warga, kerajinan, dan ritme kampung kota.",
    insight: "Hormati area rumah warga dan minta izin sebelum memotret aktivitas pribadi.",
    imageUrl: "assets/images/destinations/kampungwisatatamansari.jpg",
  },
  {
    name: "Museum Ullen Sentalu",
    type: "CULTURE",
    category: "Budaya",
    lat: -7.5967,
    lng: 110.4233,
    address: "Jl. Boyong, Kaliurang, Hargobinangun, Sleman",
    rating: 4.8,
    culturalValue: 5,
    ticketPrice: "Mulai sekitar Rp50.000-Rp100.000 tergantung paket",
    openingHours: "Umumnya 08.30-16.00, Senin tutup",
    bestTime: "Pagi atau siang sejuk Kaliurang",
    duration: "1,5-2 jam",
    tags: ["Museum", "Jawa", "Kaliurang", "Budaya", "Keluarga"],
    description: "Museum seni dan budaya Jawa di kawasan Kaliurang dengan narasi yang elegan tentang keluarga kerajaan, batik, dan kehidupan bangsawan.",
    story: "Ullen Sentalu terkenal karena cara bercerita yang immersive. Pengunjung diajak memahami sisi manusiawi sejarah Jawa melalui ruang-ruang museum yang tenang.",
    insight: "Ikuti tur resmi museum; sebagian area biasanya tidak boleh difoto.",
    imageUrl: "assets/images/destinations/museumullensentanu.jpg",
  },
  {
    name: "Candi Prambanan",
    type: "CULTURE",
    category: "Sejarah",
    lat: -7.752,
    lng: 110.4915,
    address: "Bokoharjo, Prambanan, Sleman",
    rating: 4.9,
    culturalValue: 5,
    ticketPrice: "Mulai sekitar Rp50.000 untuk wisatawan domestik, cek tarif resmi",
    openingHours: "Umumnya 06.30-17.00",
    bestTime: "Pagi atau sore menjelang sunset",
    duration: "2-3 jam",
    tags: ["Candi", "Prambanan", "Unesco", "Sejarah", "Keluarga"],
    description: "Kompleks candi Hindu megah yang menjadi salah satu ikon terbesar Yogyakarta dan warisan budaya kelas dunia.",
    story: "Prambanan memukau lewat relief Ramayana, arsitektur menjulang, dan komposisi candi yang dramatis. Tempat ini cocok untuk wisata sejarah sekaligus foto lanskap.",
    insight: "Datang sore jika ingin lanjut menikmati Sendratari Ramayana pada jadwal tertentu.",
    imageUrl: "assets/images/destinations/candiprambanan.jpg",
  },
  {
    name: "Ratu Boko",
    type: "CULTURE",
    category: "Sejarah",
    lat: -7.7705,
    lng: 110.4894,
    address: "Bokoharjo, Prambanan, Sleman",
    rating: 4.7,
    culturalValue: 5,
    ticketPrice: "Mulai sekitar Rp40.000-Rp50.000, cek tarif resmi",
    openingHours: "Umumnya 06.00-17.00",
    bestTime: "Sore hari untuk sunset",
    duration: "1,5-2,5 jam",
    tags: ["Ratu-boko", "Candi", "Sunset", "Sejarah", "Foto"],
    description: "Kompleks situs arkeologi di atas bukit yang terkenal dengan gerbang batu dan panorama matahari terbenam.",
    story: "Ratu Boko memberi pengalaman berbeda dari candi biasa. Area luas, sisa bangunan, dan langit senja membuat tempat ini terasa sinematik.",
    insight: "Bawa air minum dan topi karena area terbuka cukup luas.",
    imageUrl: "assets/images/destinations/candiratuboko.jpg",
  },
  {
    name: "Tebing Breksi",
    type: "TOURISM",
    category: "Alam",
    lat: -7.7816,
    lng: 110.5046,
    address: "Sambirejo, Prambanan, Sleman",
    rating: 4.6,
    culturalValue: 3,
    ticketPrice: "Retribusi/parkir terjangkau, cek loket setempat",
    openingHours: "Umumnya 06.00-21.00",
    bestTime: "Sore menjelang sunset",
    duration: "1-2 jam",
    tags: ["Tebing-breksi", "Alam", "Foto", "Sunset", "Keluarga"],
    description: "Bekas tambang batu yang berubah menjadi destinasi kreatif dengan ukiran tebing, gardu pandang, dan panorama Jogja dari ketinggian.",
    story: "Tebing Breksi menunjukkan bagaimana ruang bekas tambang bisa bertransformasi menjadi destinasi wisata populer yang ramah keluarga.",
    insight: "Area batu bisa panas saat siang; sore hari biasanya lebih nyaman.",
    imageUrl: "assets/images/destinations/tebingpreksi.jpg",
  },
  {
    name: "HeHa Sky View",
    type: "TOURISM",
    category: "Foto",
    lat: -7.8495,
    lng: 110.4783,
    address: "Patuk, Gunungkidul, Yogyakarta",
    rating: 4.5,
    culturalValue: 2,
    ticketPrice: "Mulai sekitar Rp20.000-Rp30.000, spot foto tertentu bisa berbayar",
    openingHours: "Umumnya 10.00-21.00",
    bestTime: "Sore hingga malam",
    duration: "1,5-3 jam",
    tags: ["Heha", "Foto", "Malam", "View", "Keluarga"],
    description: "Tempat menikmati panorama kota dari perbukitan Patuk dengan spot foto modern dan suasana malam yang hidup.",
    story: "HeHa cocok untuk wisata santai setelah menjelajah kota. Lampu kota, angin bukit, dan spot foto membuatnya populer untuk keluarga dan anak muda.",
    insight: "Datang sebelum sunset agar dapat dua suasana: senja dan malam.",
    imageUrl: "assets/images/destinations/hehaskyview.jpg",
  },
  {
    name: "Bukit Bintang",
    type: "TOURISM",
    category: "Alam",
    lat: -7.847,
    lng: 110.4798,
    address: "Jl. Wonosari, Patuk, Gunungkidul",
    rating: 4.5,
    culturalValue: 2,
    ticketPrice: "Gratis, biaya parkir/makan sesuai tempat",
    openingHours: "Area publik, warung biasanya sore-malam",
    bestTime: "Malam hari",
    duration: "1-2 jam",
    tags: ["Bukit-bintang", "Malam", "View", "Kuliner", "Patuk"],
    description: "Spot malam klasik untuk melihat lampu kota Jogja dari ketinggian sambil menikmati jagung bakar atau minuman hangat.",
    story: "Bukit Bintang punya daya tarik sederhana: duduk santai, ngobrol, menikmati angin malam, dan melihat Jogja berkelip dari kejauhan.",
    insight: "Gunakan jaket karena angin malam di kawasan Patuk bisa cukup dingin.",
    imageUrl: "assets/images/destinations/bukitbintang.jpg",
  },
  {
    name: "Hutan Pinus Mangunan",
    type: "TOURISM",
    category: "Alam",
    lat: -7.9266,
    lng: 110.4318,
    address: "Mangunan, Dlingo, Bantul",
    rating: 4.6,
    culturalValue: 3,
    ticketPrice: "Retribusi/parkir terjangkau",
    openingHours: "Umumnya 06.00-17.30",
    bestTime: "Pagi hari",
    duration: "1-2 jam",
    tags: ["Hutan-pinus", "Mangunan", "Alam", "Foto", "Keluarga"],
    description: "Hutan pinus sejuk di Bantul yang cocok untuk jalan santai, foto, dan menikmati suasana alam yang teduh.",
    story: "Deretan pinus tinggi memberi suasana tenang dan fotogenik. Tempat ini sering jadi pilihan keluarga yang ingin kabur sejenak dari hiruk-pikuk kota.",
    insight: "Pagi hari biasanya lebih sejuk dan cahaya matahari menembus pepohonan dengan indah.",
    imageUrl: "assets/images/destinations/hutanpinusmangunan.jpg",
  },
  {
    name: "Kebun Buah Mangunan",
    type: "TOURISM",
    category: "Alam",
    lat: -7.9401,
    lng: 110.4266,
    address: "Mangunan, Dlingo, Bantul",
    rating: 4.6,
    culturalValue: 3,
    ticketPrice: "Retribusi/parkir terjangkau",
    openingHours: "Umumnya 05.00-17.00",
    bestTime: "Subuh-pagi untuk kabut dan sunrise",
    duration: "1-2 jam",
    tags: ["Mangunan", "Sunrise", "Alam", "View", "Keluarga"],
    description: "Spot gardu pandang yang terkenal dengan panorama lembah dan kabut pagi seperti negeri di atas awan.",
    story: "Kebun Buah Mangunan paling memikat saat pagi. Kabut yang menutup lembah membuat pemandangannya terasa dramatis dan menenangkan.",
    insight: "Datang sangat pagi jika ingin mengejar kabut dan sunrise.",
    imageUrl: "assets/images/destinations/kebunbuahmangunan.jpg",
  },
  {
    name: "Pantai Parangtritis",
    type: "TOURISM",
    category: "Alam",
    lat: -8.0255,
    lng: 110.329,
    address: "Parangtritis, Kretek, Bantul",
    rating: 4.7,
    culturalValue: 5,
    ticketPrice: "Retribusi kawasan pantai, cek loket setempat",
    openingHours: "Area pantai terbuka, aktivitas aman saat terang",
    bestTime: "Sore menjelang sunset",
    duration: "1,5-3 jam",
    tags: ["Parangtritis", "Pantai", "Sunset", "Legenda", "Keluarga"],
    description: "Pantai legendaris Jogja dengan ombak besar, gumuk pasir, delman, ATV, dan cerita budaya yang melekat kuat.",
    story: "Parangtritis bukan hanya pantai, tetapi juga bagian dari lanskap budaya Jogja yang terhubung dengan kisah Laut Selatan.",
    insight: "Jangan berenang terlalu jauh karena ombak selatan kuat; ikuti arahan petugas pantai.",
    imageUrl: "assets/images/destinations/pantaiparangtritis.jpg",
  },
  {
    name: "Gumuk Pasir Parangkusumo",
    type: "TOURISM",
    category: "Alam",
    lat: -8.0159,
    lng: 110.3158,
    address: "Parangkusumo, Kretek, Bantul",
    rating: 4.5,
    culturalValue: 4,
    ticketPrice: "Gratis/retribusi parkir, sandboarding bisa berbayar",
    openingHours: "Umumnya pagi-sore",
    bestTime: "Sore hari",
    duration: "1-2 jam",
    tags: ["Gumuk-pasir", "Parangkusumo", "Foto", "Sandboarding", "Alam"],
    description: "Hamparan pasir unik dekat pantai yang menawarkan suasana seperti gurun kecil dan spot foto berbeda di Jogja.",
    story: "Gumuk Pasir terbentuk dari proses alam panjang yang melibatkan material vulkanik, sungai, angin, dan laut. Lanskapnya jarang ditemukan di Indonesia.",
    insight: "Sore lebih nyaman karena pasir tidak terlalu panas.",
    imageUrl: "assets/images/destinations/gumukpasirparangkusumo.jpg",
  },
  {
    name: "Pantai Indrayanti",
    type: "TOURISM",
    category: "Alam",
    lat: -8.15,
    lng: 110.6121,
    address: "Tepus, Gunungkidul, Yogyakarta",
    rating: 4.6,
    culturalValue: 3,
    ticketPrice: "Retribusi kawasan pantai Gunungkidul",
    openingHours: "Area pantai, aman dikunjungi saat terang",
    bestTime: "Pagi atau sore",
    duration: "2-3 jam",
    tags: ["Pantai", "Gunungkidul", "Pasir-putih", "Keluarga", "Foto"],
    description: "Pantai pasir putih di Gunungkidul dengan tebing karang, restoran tepi pantai, dan suasana liburan yang santai.",
    story: "Indrayanti populer karena aksesnya relatif mudah dan fasilitasnya lengkap. Cocok untuk wisata keluarga yang ingin menikmati pantai cantik tanpa terlalu ekstrem.",
    insight: "Tetap hati-hati dengan ombak selatan dan jangan berenang melewati batas aman.",
    imageUrl: "assets/images/destinations/pantaiindrayanti.jpg",
  },
  {
    name: "Pantai Timang",
    type: "TOURISM",
    category: "Alam",
    lat: -8.1746,
    lng: 110.6617,
    address: "Purwodadi, Tepus, Gunungkidul",
    rating: 4.6,
    culturalValue: 3,
    ticketPrice: "Retribusi dan wahana gondola/jembatan berbayar",
    openingHours: "Umumnya pagi-sore",
    bestTime: "Pagi hingga siang",
    duration: "2-3 jam",
    tags: ["Pantai-timang", "Gondola", "Adrenalin", "Gunungkidul", "Laut"],
    description: "Pantai karang dengan gondola tradisional dan jembatan gantung menuju pulau kecil, cocok untuk pencari pengalaman unik.",
    story: "Dulu gondola Timang dipakai nelayan untuk menyeberang mencari lobster. Kini pengalaman itu menjadi daya tarik wisata yang memacu adrenalin.",
    insight: "Cek cuaca dan kondisi ombak sebelum mencoba wahana.",
    imageUrl: "assets/images/destinations/pantaitimang.jpg",
  },
  {
    name: "Goa Pindul",
    type: "TOURISM",
    category: "Alam",
    lat: -7.9306,
    lng: 110.6494,
    address: "Bejiharjo, Karangmojo, Gunungkidul",
    rating: 4.6,
    culturalValue: 3,
    ticketPrice: "Paket cave tubing bervariasi, cek operator resmi",
    openingHours: "Umumnya pagi-sore",
    bestTime: "Pagi atau siang saat cuaca cerah",
    duration: "2-3 jam",
    tags: ["Goa-pindul", "Cave-tubing", "Alam", "Keluarga", "Air"],
    description: "Wisata cave tubing menyusuri sungai bawah tanah dengan ban pelampung, pemandu lokal, dan suasana goa yang seru.",
    story: "Goa Pindul memadukan petualangan ringan dan edukasi alam. Jalurnya cocok untuk pemula karena dibantu pemandu dan perlengkapan keselamatan.",
    insight: "Bawa pakaian ganti dan simpan barang elektronik di dry bag.",
    imageUrl: "assets/images/destinations/goapindul.jpg",
  },
  {
    name: "Kaliurang",
    type: "TOURISM",
    category: "Alam",
    lat: -7.596,
    lng: 110.4241,
    address: "Kaliurang, Hargobinangun, Sleman",
    rating: 4.6,
    culturalValue: 4,
    ticketPrice: "Tergantung objek/area, beberapa spot gratis",
    openingHours: "Kawasan terbuka, objek wisata mengikuti jam masing-masing",
    bestTime: "Pagi atau siang sejuk",
    duration: "2-4 jam",
    tags: ["Kaliurang", "Merapi", "Sejuk", "Alam", "Keluarga"],
    description: "Kawasan lereng Merapi yang sejuk dengan museum, taman, kuliner jadah tempe, dan suasana pegunungan.",
    story: "Kaliurang telah lama menjadi tempat beristirahat warga Jogja. Udaranya sejuk dan pemandangannya mengarah ke sisi gagah Gunung Merapi.",
    insight: "Cocok digabung dengan Museum Ullen Sentalu atau jeep lava tour.",
    imageUrl: "assets/images/destinations/kaliurang.jpg",
  },
  {
    name: "Lava Tour Merapi",
    type: "TOURISM",
    category: "Petualangan",
    lat: -7.5815,
    lng: 110.4473,
    address: "Kawasan Kaliadem, Cangkringan, Sleman",
    rating: 4.7,
    culturalValue: 4,
    ticketPrice: "Paket jeep bervariasi, cek operator lokal",
    openingHours: "Umumnya pagi-sore",
    bestTime: "Pagi hari saat langit cerah",
    duration: "1,5-3 jam",
    tags: ["Merapi", "Jeep", "Lava-tour", "Petualangan", "Alam"],
    description: "Tur jeep menyusuri kawasan bekas erupsi Merapi, museum mini, bunker, dan lanskap vulkanik yang dramatis.",
    story: "Lava Tour mengajak pengunjung memahami kekuatan alam Merapi sekaligus ketangguhan warga lereng gunung setelah erupsi.",
    insight: "Pilih operator resmi dan gunakan masker/kacamata jika jalur berdebu.",
    imageUrl: "assets/images/destinations/lavatourmerapi.jpg",
  },
  {
    name: "Alun-Alun Kidul",
    type: "TOURISM",
    category: "Keluarga",
    lat: -7.8117,
    lng: 110.3635,
    address: "Patehan, Kraton, Yogyakarta",
    rating: 4.6,
    culturalValue: 5,
    ticketPrice: "Gratis, wahana/sepeda hias berbayar",
    openingHours: "Area publik 24 jam, ramai sore-malam",
    bestTime: "Malam hari",
    duration: "1-2 jam",
    tags: ["Alkid", "Keluarga", "Malam", "Tradisi", "Kuliner"],
    description: "Ruang publik selatan Keraton yang ramai malam hari dengan sepeda hias, kuliner, dan tradisi masangin.",
    story: "Alun-Alun Kidul menjadi tempat santai warga dan wisatawan. Permainan melewati dua beringin dengan mata tertutup menambah unsur cerita dan hiburan.",
    insight: "Jaga anak-anak saat area ramai dan negosiasikan harga wahana sebelum naik.",
    imageUrl: "assets/images/destinations/alunalunkidul.jpg",
  },
  {
    name: "Pasar Beringharjo",
    type: "TOURISM",
    category: "Belanja",
    lat: -7.7989,
    lng: 110.3671,
    address: "Jl. Margo Mulyo No.16, Yogyakarta",
    rating: 4.6,
    culturalValue: 5,
    ticketPrice: "Gratis masuk",
    openingHours: "Umumnya 08.00-16.00",
    bestTime: "Pagi hingga siang",
    duration: "1-2 jam",
    tags: ["Beringharjo", "Batik", "Belanja", "Oleh-oleh", "Pasar"],
    description: "Pasar legendaris untuk berburu batik, kain, jamu, jajanan, dan oleh-oleh khas Jogja dengan suasana tradisional.",
    story: "Beringharjo telah menjadi bagian penting denyut ekonomi Malioboro. Di sini pengalaman belanja terasa lebih hidup karena interaksi langsung dengan pedagang.",
    insight: "Siapkan uang tunai dan jangan ragu bertanya harga dengan sopan.",
    imageUrl: "assets/images/destinations/pasarberingharjo.jpg",
  },
  {
    name: "Gudeg Yu Djum Wijilan",
    type: "CULINARY",
    category: "Kuliner",
    lat: -7.8066,
    lng: 110.3686,
    address: "Jl. Wijilan No.31, Panembahan, Yogyakarta",
    rating: 4.6,
    culturalValue: 4,
    ticketPrice: "Mulai sekitar Rp20.000-Rp60.000 per porsi/paket",
    openingHours: "Umumnya pagi-malam",
    bestTime: "Pagi atau siang",
    duration: "45-75 menit",
    tags: ["Gudeg", "Kuliner", "Wijilan", "Ikonik", "Keluarga"],
    description: "Salah satu ikon gudeg Jogja dengan cita rasa manis-gurih khas, cocok untuk mengenal kuliner klasik Yogyakarta.",
    story: "Gudeg adalah rasa yang sangat lekat dengan Jogja. Di kawasan Wijilan, tradisi memasak nangka muda, krecek, telur, dan ayam terasa sebagai pengalaman kuliner budaya.",
    insight: "Rasa gudeg cenderung manis; padukan dengan sambal krecek jika ingin lebih pedas.",
    imageUrl: "assets/images/destinations/gudegyudjum.jpg",
  },
  {
    name: "Sate Klathak Pak Pong",
    type: "CULINARY",
    category: "Kuliner",
    lat: -7.8738,
    lng: 110.3879,
    address: "Jl. Sultan Agung No.18, Jejeran, Bantul",
    rating: 4.7,
    culturalValue: 4,
    ticketPrice: "Mulai sekitar Rp30.000-Rp70.000",
    openingHours: "Umumnya siang-malam",
    bestTime: "Sore atau malam",
    duration: "1-1,5 jam",
    tags: ["Sate-klathak", "Kuliner", "Bantul", "Kambing", "Ikonik"],
    description: "Sate kambing khas Bantul yang ditusuk jeruji besi, berbumbu sederhana, dan terkenal karena rasa dagingnya yang kuat.",
    story: "Keunikan sate klathak ada pada bumbu minimalis dan tusuk besi yang membantu menghantarkan panas. Rasanya jujur, gurih, dan sangat khas Bantul.",
    insight: "Biasanya ramai pada jam makan malam; datang lebih awal jika ingin antre lebih singkat.",
    imageUrl: "assets/images/destinations/sateklathakpakpong.jpg",
  },
  {
    name: "Kopi Klotok",
    type: "CULINARY",
    category: "Kuliner",
    lat: -7.6488,
    lng: 110.4216,
    address: "Jl. Kaliurang KM 16, Pakem, Sleman",
    rating: 4.7,
    culturalValue: 4,
    ticketPrice: "Menu rumahan relatif terjangkau",
    openingHours: "Umumnya pagi-sore",
    bestTime: "Pagi menjelang siang",
    duration: "1-1,5 jam",
    tags: ["Kopi-klotok", "Kuliner", "Rumahan", "Sleman", "Keluarga"],
    description: "Warung bernuansa rumah desa dengan menu sederhana seperti sayur lodeh, telur dadar, pisang goreng, dan kopi panas yang membuat rindu suasana kampung.",
    story: "Daya tarik Kopi Klotok bukan hanya rasa, tetapi atmosfer: dapur ramai, rumah joglo, sawah, dan makanan rumahan yang terasa akrab.",
    insight: "Datang pagi pada hari biasa agar suasana lebih santai.",
    imageUrl: "assets/images/destinations/kopi klotok.jpg",
  },
  {
    name: "Bakpia Pathok 25",
    type: "CULINARY",
    category: "Oleh-oleh",
    lat: -7.7938,
    lng: 110.3566,
    address: "Jl. AIP II KS Tubun, Pathuk, Yogyakarta",
    rating: 4.6,
    culturalValue: 4,
    ticketPrice: "Harga per kotak bervariasi sesuai varian",
    openingHours: "Umumnya pagi-malam",
    bestTime: "Siang atau sore",
    duration: "30-60 menit",
    tags: ["Bakpia", "Oleh-oleh", "Pathok", "Kuliner", "Belanja"],
    description: "Pusat oleh-oleh bakpia klasik Jogja dengan berbagai varian rasa untuk dibawa pulang.",
    story: "Bakpia telah menjadi oleh-oleh yang hampir wajib dari Jogja. Kawasan Pathuk dikenal sebagai salah satu sentra bakpia paling populer.",
    insight: "Cek tanggal produksi agar bakpia tetap segar sampai dibawa pulang.",
    imageUrl: "assets/images/destinations/bakpiapathok25.jpg",
  },
  {
    name: "Angkringan Lik Man",
    type: "CULINARY",
    category: "Kuliner",
    lat: -7.7897,
    lng: 110.365,
    address: "Dekat Stasiun Tugu, Yogyakarta",
    rating: 4.5,
    culturalValue: 4,
    ticketPrice: "Menu angkringan terjangkau",
    openingHours: "Umumnya sore-malam",
    bestTime: "Malam hari",
    duration: "45-90 menit",
    tags: ["Angkringan", "Kopi-joss", "Malam", "Kuliner", "Tugu"],
    description: "Angkringan legendaris dekat Stasiun Tugu yang terkenal dengan kopi joss dan suasana ngobrol malam khas Jogja.",
    story: "Angkringan adalah budaya makan sederhana yang merakyat. Di Lik Man, wisatawan bisa merasakan ritme malam Jogja lewat nasi kucing, gorengan, dan kopi arang.",
    insight: "Pilih tempat duduk yang aman dari lalu lintas dan nikmati pelan-pelan.",
    imageUrl: "assets/images/destinations/angkringanlikman.jpg",
  },
  {
    name: "House of Raminten",
    type: "CULINARY",
    category: "Kuliner",
    lat: -7.7821,
    lng: 110.37,
    address: "Jl. Faridan M Noto No.7, Kotabaru, Yogyakarta",
    rating: 4.5,
    culturalValue: 4,
    ticketPrice: "Menu bervariasi, umumnya terjangkau-menengah",
    openingHours: "Umumnya buka lama hingga malam",
    bestTime: "Siang atau malam",
    duration: "1-1,5 jam",
    tags: ["Raminten", "Kuliner", "Jawa", "Unik", "Keluarga"],
    description: "Restoran bernuansa Jawa teatrikal dengan menu beragam, interior unik, dan pengalaman makan yang berbeda.",
    story: "Raminten memadukan kuliner, humor, dan estetika Jawa kontemporer. Cocok untuk wisatawan yang ingin suasana makan yang tidak biasa.",
    insight: "Menu sangat banyak; tanyakan rekomendasi pelayan jika bingung memilih.",
    imageUrl: "assets/images/destinations/houseoframinten.jpg",
  },
  {
    name: "Tempo Gelato Prawirotaman",
    type: "CULINARY",
    category: "Kuliner",
    lat: -7.8197,
    lng: 110.3716,
    address: "Jl. Prawirotaman No.43, Yogyakarta",
    rating: 4.6,
    culturalValue: 2,
    ticketPrice: "Mulai sekitar Rp25.000-Rp50.000",
    openingHours: "Umumnya siang-malam",
    bestTime: "Siang saat cuaca panas",
    duration: "30-60 menit",
    tags: ["Gelato", "Prawirotaman", "Kuliner", "Anak-muda", "Keluarga"],
    description: "Kedai gelato populer dengan banyak rasa dan suasana santai, cocok untuk jeda manis saat menjelajah kota.",
    story: "Di kawasan Prawirotaman yang ramai wisatawan, Tempo Gelato menjadi tempat singgah favorit untuk mendinginkan hari Jogja yang hangat.",
    insight: "Saat akhir pekan antrean bisa panjang; pilih jam di luar puncak.",
    imageUrl: "assets/images/destinations/tempogelatoprawirotaman.jpg",
  },
  {
    name: "Jalan Prawirotaman",
    type: "TOURISM",
    category: "Kawasan",
    lat: -7.8199,
    lng: 110.3713,
    address: "Prawirotaman, Brontokusuman, Yogyakarta",
    rating: 4.5,
    culturalValue: 3,
    ticketPrice: "Gratis untuk kawasan",
    openingHours: "Kawasan terbuka, kafe/restoran sesuai jam masing-masing",
    bestTime: "Sore hingga malam",
    duration: "1-2 jam",
    tags: ["Prawirotaman", "Kafe", "Jalan-santai", "Wisatawan", "Kuliner"],
    description: "Kawasan wisata kota dengan kafe, penginapan, restoran, toko kecil, dan suasana internasional yang tetap dekat dengan kampung Jogja.",
    story: "Prawirotaman sering disebut kampung turis. Namun di balik kafe dan hotelnya, kawasan ini tetap menyimpan ritme lokal yang menarik untuk dijelajahi.",
    insight: "Cocok untuk jalan santai setelah makan malam.",
    imageUrl: "assets/images/destinations/jalanprawirotaman.jpg",
  },
  {
    name: "Jalan Sosrowijayan",
    type: "TOURISM",
    category: "Kawasan",
    lat: -7.7912,
    lng: 110.3646,
    address: "Sosromenduran, Gedong Tengen, Yogyakarta",
    rating: 4.4,
    culturalValue: 3,
    ticketPrice: "Gratis untuk kawasan",
    openingHours: "Kawasan terbuka",
    bestTime: "Sore-malam",
    duration: "45-90 menit",
    tags: ["Sosrowijayan", "Malioboro", "Kampung", "Kuliner", "Penginapan"],
    description: "Gang wisata dekat Malioboro dengan penginapan, kuliner, mural, dan suasana backpacker yang hangat.",
    story: "Sosrowijayan menjadi pintu kecil untuk melihat sisi Malioboro yang lebih kampung dan akrab.",
    insight: "Jelajahi dengan berjalan kaki karena gangnya relatif sempit.",
    imageUrl: "assets/images/destinations/jalansosrowijayan.jpg",
  },
  {
    name: "Masjid Gedhe Kauman",
    type: "CULTURE",
    category: "Religi",
    lat: -7.8033,
    lng: 110.3627,
    address: "Kauman, Kraton, Yogyakarta",
    rating: 4.8,
    culturalValue: 5,
    ticketPrice: "Gratis",
    openingHours: "Mengikuti waktu ibadah dan aturan masjid",
    bestTime: "Di luar waktu ibadah ramai",
    duration: "30-60 menit",
    tags: ["Masjid-gedhe", "Kauman", "Religi", "Sejarah", "Keraton"],
    description: "Masjid bersejarah Kesultanan yang menjadi bagian penting dari tata ruang Keraton dan kehidupan keagamaan Yogyakarta.",
    story: "Masjid Gedhe Kauman memperlihatkan hubungan erat antara budaya, spiritualitas, dan kekuasaan tradisional Jawa.",
    insight: "Gunakan pakaian sopan dan jaga ketenangan area ibadah.",
    imageUrl: "assets/images/destinations/MasjidGedheKauman.jpg",
  },
  {
    name: "Kampung Kauman",
    type: "CULTURE",
    category: "Budaya",
    lat: -7.8028,
    lng: 110.3615,
    address: "Kauman, Gondomanan, Yogyakarta",
    rating: 4.5,
    culturalValue: 5,
    ticketPrice: "Gratis untuk kawasan",
    openingHours: "Kawasan permukiman, kunjungi dengan sopan",
    bestTime: "Pagi atau sore",
    duration: "45-90 menit",
    tags: ["Kauman", "Kampung", "Muhammadiyah", "Sejarah", "Religi"],
    description: "Kampung bersejarah dekat Keraton yang lekat dengan perkembangan pendidikan, dakwah, dan gerakan sosial di Yogyakarta.",
    story: "Kauman memiliki lorong-lorong kecil dan rumah tua yang menyimpan banyak cerita tentang kehidupan religius dan sosial masyarakat Jogja.",
    insight: "Karena kawasan permukiman, hormati privasi warga dan jangan membuat bising.",
    imageUrl: "assets/images/destinations/KampungKauman.jpg",
  },
  {
    name: "Museum Affandi",
    type: "CULTURE",
    category: "Seni",
    lat: -7.7828,
    lng: 110.3964,
    address: "Jl. Laksda Adisucipto No.167, Yogyakarta",
    rating: 4.6,
    culturalValue: 4,
    ticketPrice: "Mulai sekitar Rp25.000-Rp50.000",
    openingHours: "Umumnya 09.00-16.00, Senin tutup",
    bestTime: "Pagi atau siang",
    duration: "1-1,5 jam",
    tags: ["Affandi", "Museum", "Seni", "Lukisan", "Edukasi"],
    description: "Museum seni yang menampilkan karya dan kehidupan Affandi, salah satu pelukis besar Indonesia.",
    story: "Bangunan museum yang unik dan koleksi lukisannya membuat pengunjung masuk ke dunia ekspresi Affandi yang kuat dan emosional.",
    insight: "Cocok untuk wisatawan yang suka seni visual dan suasana museum yang lebih personal.",
    imageUrl: "assets/images/destinations/museumaffandi.jpg",
  },
  {
    name: "Desa Wisata Kasongan",
    type: "CULTURE",
    category: "Kerajinan",
    lat: -7.8468,
    lng: 110.3423,
    address: "Kasongan, Bangunjiwo, Bantul",
    rating: 4.6,
    culturalValue: 4,
    ticketPrice: "Gratis untuk kawasan, belanja/workshop sesuai aktivitas",
    openingHours: "Toko umumnya pagi-sore",
    bestTime: "Pagi atau siang",
    duration: "1-2 jam",
    tags: ["Kasongan", "Gerabah", "Kerajinan", "Bantul", "Belanja"],
    description: "Sentra gerabah Bantul dengan deretan toko kerajinan tanah liat, dekorasi rumah, dan workshop kreatif.",
    story: "Kasongan menunjukkan wajah kreatif masyarakat Bantul. Dari tanah liat, lahir karya yang bisa menjadi oleh-oleh, dekorasi, atau pengalaman belajar.",
    insight: "Tanyakan opsi pengiriman jika membeli kerajinan besar.",
    imageUrl: "assets/images/destinations/desawisatakasongan.jpg",
  },
  {
    name: "Desa Wisata Krebet",
    type: "CULTURE",
    category: "Kerajinan",
    lat: -7.886,
    lng: 110.2949,
    address: "Sendangsari, Pajangan, Bantul",
    rating: 4.5,
    culturalValue: 4,
    ticketPrice: "Gratis untuk kawasan, workshop/belanja sesuai aktivitas",
    openingHours: "Umumnya pagi-sore",
    bestTime: "Pagi atau siang",
    duration: "1,5-2,5 jam",
    tags: ["Krebet", "Batik-kayu", "Kerajinan", "Desa-wisata", "Bantul"],
    description: "Desa wisata kreatif yang terkenal dengan batik kayu, suasana pedesaan, dan aktivitas edukasi kerajinan.",
    story: "Krebet membuktikan batik tidak hanya hadir di kain. Motif tradisional dipindahkan ke media kayu dan menjadi karya khas desa.",
    insight: "Hubungi pengelola desa wisata jika ingin paket workshop kelompok.",
    imageUrl: "assets/images/destinations/desawisatakrebet.jpg",
  },
  {
    name: "Desa Wisata Tembi",
    type: "CULTURE",
    category: "Budaya",
    lat: -7.8726,
    lng: 110.3546,
    address: "Timbulharjo, Sewon, Bantul",
    rating: 4.5,
    culturalValue: 4,
    ticketPrice: "Tergantung aktivitas/paket",
    openingHours: "Umumnya pagi-sore",
    bestTime: "Pagi atau sore",
    duration: "1,5-3 jam",
    tags: ["Tembi", "Desa-wisata", "Budaya", "Tradisi", "Bantul"],
    description: "Desa wisata budaya dengan suasana pedesaan, aktivitas tradisional, dan ruang belajar budaya Jawa.",
    story: "Tembi cocok untuk memahami Jogja di luar keramaian kota. Pengunjung bisa merasakan atmosfer desa, seni, dan keramahtamahan warga.",
    insight: "Cocok untuk rombongan karena banyak aktivitas bisa dikemas paket.",
    imageUrl: "assets/images/destinations/desawisatatembi.jpg",
  },
  {
    name: "Desa Wisata Pentingsari",
    type: "CULTURE",
    category: "Desa Wisata",
    lat: -7.6339,
    lng: 110.4307,
    address: "Umbulharjo, Cangkringan, Sleman",
    rating: 4.7,
    culturalValue: 4,
    ticketPrice: "Tergantung paket wisata desa",
    openingHours: "Dengan reservasi/pengelola",
    bestTime: "Pagi hingga siang",
    duration: "2-4 jam",
    tags: ["Pentingsari", "Desa-wisata", "Merapi", "Edukasi", "Keluarga"],
    description: "Desa wisata lereng Merapi dengan aktivitas edukasi, alam, permainan tradisional, dan kehidupan desa.",
    story: "Pentingsari menawarkan pengalaman tinggal dan belajar bersama warga. Cocok untuk sekolah, keluarga, atau wisatawan yang ingin lebih dekat dengan kehidupan desa.",
    insight: "Reservasi lebih dulu jika ingin kegiatan lengkap.",
    imageUrl: "assets/images/destinations/desawisatapentingsari.jpg",
  },
  {
    name: "Sendratari Ramayana Prambanan",
    type: "CULTURE",
    category: "Seni",
    lat: -7.7526,
    lng: 110.4918,
    address: "Kompleks Candi Prambanan, Sleman",
    rating: 4.8,
    culturalValue: 5,
    ticketPrice: "Harga tiket tergantung kelas dan panggung",
    openingHours: "Mengikuti jadwal pertunjukan malam",
    bestTime: "Malam hari saat pertunjukan",
    duration: "2 jam",
    tags: ["Ramayana", "Prambanan", "Tari", "Pertunjukan", "Budaya"],
    description: "Pertunjukan tari kolosal yang menghidupkan kisah Ramayana dengan latar megah Candi Prambanan.",
    story: "Perpaduan tari, musik, kostum, dan latar candi membuat Sendratari Ramayana menjadi salah satu pengalaman budaya paling berkesan di Jogja.",
    insight: "Cek jadwal panggung terbuka/tertutup dan pesan tiket lebih awal saat musim liburan.",
    imageUrl: "assets/images/destinations/sendratariprambanan.jpg",
  },
  {
    name: "Titik Nol Kilometer Yogyakarta",
    type: "TOURISM",
    category: "Ikonik",
    lat: -7.8015,
    lng: 110.3647,
    address: "Ngupasan, Gondomanan, Yogyakarta",
    rating: 4.7,
    culturalValue: 4,
    ticketPrice: "Gratis",
    openingHours: "Area publik 24 jam",
    bestTime: "Sore hingga malam",
    duration: "30-90 menit",
    tags: ["Titik-nol", "Ikonik", "Foto", "Malioboro", "Kota"],
    description: "Ruang kota populer di ujung Malioboro dengan bangunan heritage, lampu malam, dan suasana Jogja yang meriah.",
    story: "Titik Nol menjadi simpul pertemuan banyak rute wisata kota: Malioboro, Vredeburg, Beringharjo, Gedung Agung, dan Keraton.",
    insight: "Malam hari ramai; tetap perhatikan barang bawaan.",
    imageUrl: "assets/images/destinations/titiknol.jpg",
  },
  {
    name: "Gedung Agung Yogyakarta",
    type: "CULTURE",
    category: "Sejarah",
    lat: -7.8008,
    lng: 110.3646,
    address: "Jl. Ahmad Yani, Ngupasan, Yogyakarta",
    rating: 4.5,
    culturalValue: 5,
    ticketPrice: "Tidak selalu terbuka umum, cek agenda resmi",
    openingHours: "Terbatas sesuai agenda",
    bestTime: "Dilihat dari kawasan Titik Nol",
    duration: "15-30 menit",
    tags: ["Gedung-agung", "Sejarah", "Presiden", "Titik-nol", "Heritage"],
    description: "Istana Kepresidenan Yogyakarta yang menjadi saksi penting masa awal Republik Indonesia.",
    story: "Gedung Agung berkaitan erat dengan periode Yogyakarta sebagai pusat pemerintahan RI. Bangunannya memperkuat nuansa heritage kawasan Titik Nol.",
    insight: "Biasanya dinikmati dari luar saat berjalan di kawasan Titik Nol.",
    imageUrl: "assets/images/destinations/gedungagungjogja.jpg",
  },
  {
    name: "Jalan Wijilan",
    type: "CULINARY",
    category: "Kuliner",
    lat: -7.8065,
    lng: 110.3682,
    address: "Wijilan, Panembahan, Yogyakarta",
    rating: 4.6,
    culturalValue: 4,
    ticketPrice: "Bervariasi sesuai warung gudeg",
    openingHours: "Umumnya pagi-malam",
    bestTime: "Pagi atau siang",
    duration: "45-90 menit",
    tags: ["Wijilan", "Gudeg", "Kuliner", "Keraton", "Keluarga"],
    description: "Kawasan kuliner gudeg dekat Keraton yang cocok untuk mencicipi rasa klasik Jogja dalam banyak pilihan warung.",
    story: "Wijilan adalah salah satu titik terbaik untuk mengenal gudeg. Aroma nangka muda, krecek, dan ayam kampung membuat jalan ini terasa sangat Jogja.",
    insight: "Bandingkan menu beberapa warung jika ingin memilih rasa gudeg yang sesuai selera.",
    imageUrl: "assets/images/destinations/jalanwijilan.jpg",
  },
  {
    name: "Sindu Kusuma Edupark",
    type: "TOURISM",
    category: "Keluarga",
    lat: -7.7675,
    lng: 110.354,
    address: "Jl. Jambon, Sinduadi, Sleman",
    rating: 4.4,
    culturalValue: 2,
    ticketPrice: "Tiket/wahana bervariasi",
    openingHours: "Umumnya siang-malam, cek jadwal terbaru",
    bestTime: "Sore hingga malam",
    duration: "2-3 jam",
    tags: ["Keluarga", "Wahana", "Bianglala", "Anak", "Sleman"],
    description: "Taman rekreasi keluarga dengan wahana permainan, bianglala, dan suasana santai untuk anak-anak.",
    story: "SKE cocok untuk keluarga yang ingin jeda dari wisata sejarah dan alam dengan aktivitas hiburan yang lebih ringan.",
    insight: "Cek jam operasional terbaru karena bisa berubah sesuai hari dan musim.",
    imageUrl: "assets/images/destinations/sindukusuma.jpg",
  },
  {
    name: "Gembira Loka Zoo",
    type: "TOURISM",
    category: "Keluarga",
    lat: -7.8063,
    lng: 110.3962,
    address: "Jl. Kebun Raya No.2, Yogyakarta",
    rating: 4.7,
    culturalValue: 3,
    ticketPrice: "Mulai sekitar Rp60.000-Rp75.000, cek tarif resmi",
    openingHours: "Umumnya 08.00-16.00",
    bestTime: "Pagi hari",
    duration: "2-4 jam",
    tags: ["Kebun-binatang", "Keluarga", "Anak", "Edukasi", "Gembira-loka"],
    description: "Kebun binatang dan taman edukasi satwa yang cocok untuk wisata keluarga dan anak-anak.",
    story: "Gembira Loka menawarkan pengalaman belajar satwa yang mudah dinikmati semua umur, dengan area luas dan fasilitas keluarga.",
    insight: "Datang pagi agar satwa lebih aktif dan cuaca belum terlalu panas.",
    imageUrl: "assets/images/destinations/gembiraloka.jpg",
  },
  {
    name: "Jogja National Museum",
    type: "CULTURE",
    category: "Seni",
    lat: -7.8007,
    lng: 110.3526,
    address: "Jl. Prof. Ki Amri Yahya No.1, Wirobrajan, Yogyakarta",
    rating: 4.6,
    culturalValue: 4,
    ticketPrice: "Tergantung pameran/acara",
    openingHours: "Mengikuti jadwal pameran",
    bestTime: "Saat ada pameran seni",
    duration: "1-2 jam",
    tags: ["Jnm", "Seni", "Pameran", "Kontemporer", "Budaya"],
    description: "Ruang seni kontemporer yang sering menjadi lokasi pameran, festival, dan kegiatan kreatif di Jogja.",
    story: "JNM memperlihatkan sisi Jogja sebagai kota seni yang terus bergerak, dari seniman muda sampai agenda berskala besar.",
    insight: "Cek agenda pameran sebelum datang agar kunjungan tidak kosong.",
    imageUrl: "assets/images/destinations/jogjanationalmuseum.jpg",
  },
  {
    name: "Puncak Becici",
    type: "TOURISM",
    category: "Alam",
    lat: -7.9023,
    lng: 110.4417,
    address: "Muntuk, Dlingo, Bantul",
    rating: 4.6,
    culturalValue: 3,
    ticketPrice: "Retribusi/parkir terjangkau",
    openingHours: "Umumnya 06.00-18.00",
    bestTime: "Pagi atau sore",
    duration: "1-2 jam",
    tags: ["Becici", "Mangunan", "Hutan", "View", "Foto"],
    description: "Spot hutan pinus dan gardu pandang di Dlingo dengan panorama perbukitan yang teduh dan menenangkan.",
    story: "Puncak Becici menawarkan suasana alam yang sederhana tetapi memikat: pinus, angin bukit, dan pemandangan terbuka.",
    insight: "Sore hari cocok untuk foto, tapi pastikan turun sebelum terlalu gelap.",
    imageUrl: "assets/images/destinations/puncakbecici.jpg",
  },
  {
    name: "Seribu Batu Songgo Langit",
    type: "TOURISM",
    category: "Alam",
    lat: -7.9312,
    lng: 110.4304,
    address: "Mangunan, Dlingo, Bantul",
    rating: 4.5,
    culturalValue: 3,
    ticketPrice: "Retribusi/parkir terjangkau",
    openingHours: "Umumnya 07.00-17.00",
    bestTime: "Pagi atau sore",
    duration: "1-2 jam",
    tags: ["Songgo-langit", "Rumah-hobbit", "Mangunan", "Keluarga", "Foto"],
    description: "Destinasi hutan di Mangunan dengan spot foto, rumah hobbit, dan suasana keluarga yang ringan.",
    story: "Seribu Batu cocok untuk wisatawan yang ingin berjalan santai di alam tanpa jalur terlalu berat.",
    insight: "Gunakan sepatu nyaman karena beberapa jalur sedikit menanjak.",
    imageUrl: "assets/images/destinations/seribubatu.jpg",
  },
  {
    name: "Pule Payung",
    type: "TOURISM",
    category: "Alam",
    lat: -7.805,
    lng: 110.1207,
    address: "Hargotirto, Kokap, Kulon Progo",
    rating: 4.5,
    culturalValue: 3,
    ticketPrice: "Retribusi dan spot foto/wahana bervariasi",
    openingHours: "Umumnya pagi-sore",
    bestTime: "Pagi atau sore",
    duration: "1-2 jam",
    tags: ["Pule-payung", "Kulon-progo", "View", "Waduk-sermo", "Foto"],
    description: "Spot foto dan gardu pandang di perbukitan Kulon Progo dengan panorama Waduk Sermo.",
    story: "Pule Payung memperkenalkan sisi barat Jogja yang hijau dan tenang, cocok untuk wisata pemandangan.",
    insight: "Perjalanan cukup jauh dari kota; gabungkan dengan Waduk Sermo atau Kalibiru.",
    imageUrl: "assets/images/destinations/pulepayung.jpg",
  },
  {
    name: "Waduk Sermo",
    type: "TOURISM",
    category: "Alam",
    lat: -7.823,
    lng: 110.1229,
    address: "Hargowilis, Kokap, Kulon Progo",
    rating: 4.6,
    culturalValue: 3,
    ticketPrice: "Retribusi/parkir terjangkau",
    openingHours: "Area wisata umumnya pagi-sore",
    bestTime: "Sore atau pagi",
    duration: "1-2 jam",
    tags: ["Waduk-sermo", "Kulon-progo", "Alam", "Piknik", "Keluarga"],
    description: "Danau buatan di Kulon Progo dengan suasana tenang, cocok untuk piknik ringan dan menikmati panorama air-perbukitan.",
    story: "Waduk Sermo menjadi ruang santai warga dan wisatawan yang ingin menikmati Jogja dari sisi yang lebih sepi dan hijau.",
    insight: "Jaga kebersihan area piknik dan jangan membuang sampah ke waduk.",
    imageUrl: "assets/images/destinations/waduksermo.jpg",
  },
  {
    name: "Kalibiru",
    type: "TOURISM",
    category: "Alam",
    lat: -7.8067,
    lng: 110.1288,
    address: "Hargowilis, Kokap, Kulon Progo",
    rating: 4.5,
    culturalValue: 3,
    ticketPrice: "Retribusi dan spot foto/wahana bervariasi",
    openingHours: "Umumnya pagi-sore",
    bestTime: "Pagi atau sore",
    duration: "1-2 jam",
    tags: ["Kalibiru", "Kulon-progo", "View", "Foto", "Alam"],
    description: "Destinasi perbukitan dengan gardu pandang menghadap Waduk Sermo dan lanskap hijau Kulon Progo.",
    story: "Kalibiru pernah menjadi ikon wisata foto alam Jogja. Pemandangan dari ketinggian tetap jadi daya tarik utamanya.",
    insight: "Datang saat cuaca cerah agar view Waduk Sermo terlihat jelas.",
    imageUrl: "assets/images/destinations/kalibiru.jpg",
  },
];

const quizQuestions = [
  [
    "Apa daya tarik utama Keraton Yogyakarta dalam wisata Jogja?",
    [
      "Pusat budaya Kesultanan Yogyakarta",
      "Istana Kepresidenan",
      "Pelabuhan dagang besar",
      "Terminal bus utama"
    ],
    0,
    "Budaya",
    "Keraton Yogyakarta menjadi pusat budaya dan tradisi Kesultanan."
  ],
  [
    "Apa daya tarik utama Taman Sari dalam wisata Jogja?",
    [
      "Pasar burung utama",
      "Bekas taman dan pesanggrahan Keraton",
      "Stasiun kereta pertama",
      "Pabrik gula kolonial"
    ],
    1,
    "Sejarah",
    "Taman Sari berkaitan dengan kompleks istirahat dan pertahanan Keraton."
  ],
  [
    "Apa daya tarik utama Malioboro dalam wisata Jogja?",
    [
      "Kompleks candi Hindu",
      "Kawasan perkebunan teh",
      "Koridor belanja dan jalan kaki ikonik",
      "Desa wisata lereng Merapi"
    ],
    2,
    "Ikonik",
    "Malioboro dikenal sebagai koridor wisata kota yang ikonik."
  ],
  [
    "Apa daya tarik utama Tugu Yogyakarta dalam wisata Jogja?",
    [
      "Pasar tradisional tertutup",
      "Situs pertambangan batu",
      "Museum seni rupa modern",
      "Landmark pada garis filosofi kota"
    ],
    3,
    "Ikonik",
    "Tugu Yogyakarta berkaitan dengan filosofi tata ruang Jogja."
  ],
  [
    "Apa daya tarik utama Kotagede dalam wisata Jogja?",
    [
      "Kawasan heritage dan kerajinan perak",
      "Pusat wahana air",
      "Kampung nelayan selatan",
      "Sentra perkebunan kopi"
    ],
    0,
    "Sejarah",
    "Kotagede dikenal sebagai kawasan Mataram Islam dan perak."
  ],
  [
    "Apa daya tarik utama Vredeburg dalam wisata Jogja?",
    [
      "Pusat latihan tari klasik",
      "Museum perjuangan dalam bangunan benteng",
      "Kawasan kuliner malam",
      "Desa kerajinan gerabah"
    ],
    1,
    "Sejarah",
    "Benteng Vredeburg kini berfungsi sebagai museum sejarah perjuangan."
  ],
  [
    "Apa daya tarik utama Sonobudoyo dalam wisata Jogja?",
    [
      "Kawasan hutan pinus",
      "Pantai pasir hitam",
      "Museum budaya Jawa dekat Keraton",
      "Terminal wisata desa"
    ],
    2,
    "Budaya",
    "Museum Sonobudoyo menyimpan koleksi budaya Jawa."
  ],
  [
    "Apa daya tarik utama Ullen Sentalu dalam wisata Jogja?",
    [
      "Jalan kuliner gudeg",
      "Pasar batik tertua",
      "Bangunan mercusuar pantai",
      "Museum budaya Jawa di Kaliurang"
    ],
    3,
    "Budaya",
    "Ullen Sentalu terkenal dengan narasi budaya Jawa yang elegan."
  ],
  [
    "Apa daya tarik utama Candi Prambanan dalam wisata Jogja?",
    [
      "Kompleks candi Hindu besar",
      "Masjid agung keraton",
      "Museum lukisan ekspresionis",
      "Kampung wisata kuliner"
    ],
    0,
    "Sejarah",
    "Prambanan adalah kompleks candi Hindu penting di Yogyakarta."
  ],
  [
    "Apa daya tarik utama Ratu Boko dalam wisata Jogja?",
    [
      "Goa horizontal bawah laut",
      "Situs arkeologi bukit untuk sunset",
      "Terminal bus antarkota",
      "Kampung batik kayu"
    ],
    1,
    "Sejarah",
    "Ratu Boko dikenal sebagai situs bukit dengan panorama senja."
  ],
  [
    "Apa daya tarik utama Candi Sambisari dalam wisata Jogja?",
    [
      "Panggung sendratari malam",
      "Pusat oleh-oleh bakpia",
      "Candi yang ditemukan terkubur tanah",
      "Pasar burung tradisional"
    ],
    2,
    "Sejarah",
    "Candi Sambisari terkenal karena ditemukan terkubur dan berada lebih rendah dari tanah sekitar."
  ],
  [
    "Apa daya tarik utama Candi Ijo dalam wisata Jogja?",
    [
      "Warung kopi dekat sawah",
      "Taman air bekas istana",
      "Kampung kerajinan perak",
      "Candi di perbukitan dengan panorama"
    ],
    3,
    "Sejarah",
    "Candi Ijo berada di area perbukitan dan dikenal dengan pemandangan luas."
  ],
  [
    "Apa daya tarik utama Kalibiru dalam wisata Jogja?",
    [
      "Wisata alam dengan spot pandang Waduk Sermo",
      "Museum koleksi keris",
      "Kampung wisata batik kayu",
      "Jalan belanja Malioboro"
    ],
    0,
    "Alam",
    "Kalibiru populer dengan panorama alam dan spot foto ketinggian."
  ],
  [
    "Apa daya tarik utama Pantai Parangtritis dalam wisata Jogja?",
    [
      "Museum perjuangan kota",
      "Pantai ikonik Laut Selatan",
      "Sentra kerajinan perak",
      "Kawasan kuliner gudeg"
    ],
    1,
    "Alam",
    "Parangtritis melekat dengan wisata pantai dan budaya Laut Selatan."
  ],
  [
    "Apa daya tarik utama Gumuk Pasir Parangkusumo dalam wisata Jogja?",
    [
      "Pasar buku tradisional",
      "Istana air dalam kota",
      "Bentang pasir unik dekat pantai",
      "Kampung wisata kopi"
    ],
    2,
    "Alam",
    "Gumuk Pasir Parangkusumo dikenal sebagai bentang pasir unik di Bantul."
  ],
  [
    "Apa daya tarik utama Hutan Pinus Mangunan dalam wisata Jogja?",
    [
      "Museum budaya keraton",
      "Candi Hindu utama",
      "Jalan ikonik belanja",
      "Hutan pinus untuk wisata alam"
    ],
    3,
    "Alam",
    "Hutan Pinus Mangunan menawarkan suasana alam dan fotografi."
  ],
  [
    "Apa daya tarik utama HeHa Sky View dalam wisata Jogja?",
    [
      "Spot foto dan panorama malam",
      "Desa wisata gerabah",
      "Museum perjuangan nasional",
      "Situs candi kuno"
    ],
    0,
    "Foto",
    "HeHa Sky View dikenal dengan spot foto modern dan panorama kota."
  ],
  [
    "Apa daya tarik utama Bukit Bintang dalam wisata Jogja?",
    [
      "Sentra bakpia Pathuk",
      "Tempat melihat lampu kota malam",
      "Museum seni lukis",
      "Kompleks keraton utama"
    ],
    1,
    "Alam",
    "Bukit Bintang populer untuk menikmati pemandangan malam dari perbukitan."
  ],
  [
    "Apa daya tarik utama Kopi Klotok dalam wisata Jogja?",
    [
      "Museum budaya klasik",
      "Pusat belanja batik modern",
      "Warung rumahan bernuansa desa",
      "Candi di perbukitan"
    ],
    2,
    "Kuliner",
    "Kopi Klotok terkenal dengan menu rumahan dan suasana desa."
  ],
  [
    "Apa daya tarik utama Bakpia Pathok dalam wisata Jogja?",
    [
      "Candi terkubur tanah",
      "Upacara labuhan pantai",
      "Panggung tari kolosal",
      "Oleh-oleh khas yang populer"
    ],
    3,
    "Kuliner",
    "Bakpia Pathok menjadi oleh-oleh yang sangat melekat dengan Jogja."
  ],
  [
    "Apa daya tarik utama Angkringan Lik Man dalam wisata Jogja?",
    [
      "Angkringan legendaris kopi joss",
      "Museum lukisan modern",
      "Sentra kerajinan gerabah",
      "Pantai sunset Gunungkidul"
    ],
    0,
    "Kuliner",
    "Angkringan Lik Man dikenal dengan suasana malam dan kopi joss."
  ],
  [
    "Apa daya tarik utama Gudeg Wijilan dalam wisata Jogja?",
    [
      "Candi Buddha besar",
      "Kawasan kuliner gudeg dekat Keraton",
      "Desa wisata Merapi",
      "Museum perak Kotagede"
    ],
    1,
    "Kuliner",
    "Wijilan dikenal sebagai salah satu kawasan kuliner gudeg di Jogja."
  ],
  [
    "Apa daya tarik utama Sate Ratu dalam wisata Jogja?",
    [
      "Museum keris klasik",
      "Kompleks candi Hindu",
      "Kuliner sate populer di Jogja",
      "Spot sunset perbukitan"
    ],
    2,
    "Kuliner",
    "Sate Ratu dikenal sebagai salah satu kuliner populer Jogja."
  ],
  [
    "Apa daya tarik utama Bakmi Jawa Mbah Gito dalam wisata Jogja?",
    [
      "Sentra kerajinan perak",
      "Museum perjuangan kolonial",
      "Wisata air pegunungan",
      "Bakmi Jawa dengan suasana tradisional"
    ],
    3,
    "Kuliner",
    "Bakmi Jawa Mbah Gito dikenal lewat bakmi dan atmosfer tradisional."
  ],
  [
    "Apa daya tarik utama Soto Bathok Mbah Katro dalam wisata Jogja?",
    [
      "Soto dalam bathok kelapa",
      "Panggung tari Ramayana",
      "Pusat oleh-oleh batik",
      "Candi di lereng Merapi"
    ],
    0,
    "Kuliner",
    "Soto Bathok Mbah Katro dikenal dengan penyajian soto yang khas."
  ],
  [
    "Apa daya tarik utama Sendratari Ramayana dalam wisata Jogja?",
    [
      "Pasar malam tahunan",
      "Pertunjukan tari berlatar Prambanan",
      "Museum teknologi penerbangan",
      "Desa wisata gerabah"
    ],
    1,
    "Seni",
    "Sendratari Ramayana mengangkat kisah Ramayana lewat tari dan musik."
  ],
  [
    "Apa daya tarik utama Museum Affandi dalam wisata Jogja?",
    [
      "Pantai pasir putih",
      "Sentra bakmi Jawa",
      "Museum karya pelukis Affandi",
      "Desa wisata Merapi"
    ],
    2,
    "Seni",
    "Museum Affandi menyimpan karya dan kisah pelukis Affandi."
  ],
  [
    "Apa daya tarik utama Kasongan dalam wisata Jogja?",
    [
      "Museum perjuangan kota",
      "Kawasan candi Hindu",
      "Jalan kuliner angkringan",
      "Sentra kerajinan gerabah Bantul"
    ],
    3,
    "Kerajinan",
    "Kasongan terkenal sebagai sentra gerabah dan kerajinan tanah liat."
  ],
  [
    "Apa daya tarik utama Krebet dalam wisata Jogja?",
    [
      "Desa wisata batik kayu",
      "Sentra kopi joss",
      "Terminal kota tua",
      "Pantai pasir besi"
    ],
    0,
    "Kerajinan",
    "Krebet dikenal dengan kerajinan batik di media kayu."
  ],
  [
    "Apa daya tarik utama Pentingsari dalam wisata Jogja?",
    [
      "Jalan belanja ikonik",
      "Desa wisata lereng Merapi",
      "Museum seni lukis",
      "Kawasan istana air"
    ],
    1,
    "Desa Wisata",
    "Pentingsari menawarkan kegiatan edukasi dan suasana desa lereng Merapi."
  ],
  [
    "Kategori yang paling tepat untuk Keraton Yogyakarta adalah apa?",
    [
      "Kuliner",
      "Budaya",
      "Alam",
      "Belanja"
    ],
    1,
    "Budaya",
    "Keraton Yogyakarta paling sesuai ditampilkan sebagai kategori Budaya."
  ],
  [
    "Kategori yang paling tepat untuk Taman Sari adalah apa?",
    [
      "Alam",
      "Kuliner",
      "Sejarah",
      "Foto"
    ],
    2,
    "Sejarah",
    "Taman Sari paling sesuai ditampilkan sebagai kategori Sejarah."
  ],
  [
    "Kategori yang paling tepat untuk Malioboro adalah apa?",
    [
      "Kerajinan",
      "Religi",
      "Kuliner",
      "Ikonik"
    ],
    3,
    "Ikonik",
    "Malioboro paling sesuai ditampilkan sebagai kategori Ikonik."
  ],
  [
    "Kategori yang paling tepat untuk Tugu Yogyakarta adalah apa?",
    [
      "Ikonik",
      "Religi",
      "Kuliner",
      "Kerajinan"
    ],
    0,
    "Ikonik",
    "Tugu Yogyakarta paling sesuai ditampilkan sebagai kategori Ikonik."
  ],
  [
    "Kategori yang paling tepat untuk Kotagede adalah apa?",
    [
      "Kuliner",
      "Sejarah",
      "Alam",
      "Foto"
    ],
    1,
    "Sejarah",
    "Kotagede paling sesuai ditampilkan sebagai kategori Sejarah."
  ],
  [
    "Kategori yang paling tepat untuk Vredeburg adalah apa?",
    [
      "Alam",
      "Kuliner",
      "Sejarah",
      "Foto"
    ],
    2,
    "Sejarah",
    "Vredeburg paling sesuai ditampilkan sebagai kategori Sejarah."
  ],
  [
    "Kategori yang paling tepat untuk Sonobudoyo adalah apa?",
    [
      "Belanja",
      "Kuliner",
      "Alam",
      "Budaya"
    ],
    3,
    "Budaya",
    "Sonobudoyo paling sesuai ditampilkan sebagai kategori Budaya."
  ],
  [
    "Kategori yang paling tepat untuk Ullen Sentalu adalah apa?",
    [
      "Budaya",
      "Kuliner",
      "Alam",
      "Belanja"
    ],
    0,
    "Budaya",
    "Ullen Sentalu paling sesuai ditampilkan sebagai kategori Budaya."
  ],
  [
    "Kategori yang paling tepat untuk Candi Prambanan adalah apa?",
    [
      "Kuliner",
      "Sejarah",
      "Alam",
      "Foto"
    ],
    1,
    "Sejarah",
    "Candi Prambanan paling sesuai ditampilkan sebagai kategori Sejarah."
  ],
  [
    "Kategori yang paling tepat untuk Ratu Boko adalah apa?",
    [
      "Alam",
      "Kuliner",
      "Sejarah",
      "Foto"
    ],
    2,
    "Sejarah",
    "Ratu Boko paling sesuai ditampilkan sebagai kategori Sejarah."
  ],
  [
    "Kategori yang paling tepat untuk Candi Sambisari adalah apa?",
    [
      "Foto",
      "Kuliner",
      "Alam",
      "Sejarah"
    ],
    3,
    "Sejarah",
    "Candi Sambisari paling sesuai ditampilkan sebagai kategori Sejarah."
  ],
  [
    "Kategori yang paling tepat untuk Candi Ijo adalah apa?",
    [
      "Sejarah",
      "Kuliner",
      "Alam",
      "Foto"
    ],
    0,
    "Sejarah",
    "Candi Ijo paling sesuai ditampilkan sebagai kategori Sejarah."
  ],
  [
    "Kategori yang paling tepat untuk Kalibiru adalah apa?",
    [
      "Kuliner",
      "Alam",
      "Sejarah",
      "Belanja"
    ],
    1,
    "Alam",
    "Kalibiru paling sesuai ditampilkan sebagai kategori Alam."
  ],
  [
    "Kategori yang paling tepat untuk Pantai Parangtritis adalah apa?",
    [
      "Sejarah",
      "Kuliner",
      "Alam",
      "Belanja"
    ],
    2,
    "Alam",
    "Pantai Parangtritis paling sesuai ditampilkan sebagai kategori Alam."
  ],
  [
    "Kategori yang paling tepat untuk Gumuk Pasir Parangkusumo adalah apa?",
    [
      "Belanja",
      "Kuliner",
      "Sejarah",
      "Alam"
    ],
    3,
    "Alam",
    "Gumuk Pasir Parangkusumo paling sesuai ditampilkan sebagai kategori Alam."
  ],
  [
    "Kategori yang paling tepat untuk Hutan Pinus Mangunan adalah apa?",
    [
      "Alam",
      "Kuliner",
      "Sejarah",
      "Belanja"
    ],
    0,
    "Alam",
    "Hutan Pinus Mangunan paling sesuai ditampilkan sebagai kategori Alam."
  ],
  [
    "Kategori yang paling tepat untuk HeHa Sky View adalah apa?",
    [
      "Sejarah",
      "Foto",
      "Kuliner",
      "Religi"
    ],
    1,
    "Foto",
    "HeHa Sky View paling sesuai ditampilkan sebagai kategori Foto."
  ],
  [
    "Kategori yang paling tepat untuk Bukit Bintang adalah apa?",
    [
      "Sejarah",
      "Kuliner",
      "Alam",
      "Belanja"
    ],
    2,
    "Alam",
    "Bukit Bintang paling sesuai ditampilkan sebagai kategori Alam."
  ],
  [
    "Kategori yang paling tepat untuk Kopi Klotok adalah apa?",
    [
      "Belanja",
      "Sejarah",
      "Alam",
      "Kuliner"
    ],
    3,
    "Kuliner",
    "Kopi Klotok paling sesuai ditampilkan sebagai kategori Kuliner."
  ],
  [
    "Kategori yang paling tepat untuk Bakpia Pathok adalah apa?",
    [
      "Kuliner",
      "Sejarah",
      "Alam",
      "Belanja"
    ],
    0,
    "Kuliner",
    "Bakpia Pathok paling sesuai ditampilkan sebagai kategori Kuliner."
  ],
  [
    "Kategori yang paling tepat untuk Angkringan Lik Man adalah apa?",
    [
      "Sejarah",
      "Kuliner",
      "Alam",
      "Belanja"
    ],
    1,
    "Kuliner",
    "Angkringan Lik Man paling sesuai ditampilkan sebagai kategori Kuliner."
  ],
  [
    "Kategori yang paling tepat untuk Gudeg Wijilan adalah apa?",
    [
      "Alam",
      "Sejarah",
      "Kuliner",
      "Belanja"
    ],
    2,
    "Kuliner",
    "Gudeg Wijilan paling sesuai ditampilkan sebagai kategori Kuliner."
  ],
  [
    "Kategori yang paling tepat untuk Sate Ratu adalah apa?",
    [
      "Belanja",
      "Sejarah",
      "Alam",
      "Kuliner"
    ],
    3,
    "Kuliner",
    "Sate Ratu paling sesuai ditampilkan sebagai kategori Kuliner."
  ],
  [
    "Kategori yang paling tepat untuk Bakmi Jawa Mbah Gito adalah apa?",
    [
      "Kuliner",
      "Sejarah",
      "Alam",
      "Belanja"
    ],
    0,
    "Kuliner",
    "Bakmi Jawa Mbah Gito paling sesuai ditampilkan sebagai kategori Kuliner."
  ],
  [
    "Kategori yang paling tepat untuk Soto Bathok Mbah Katro adalah apa?",
    [
      "Sejarah",
      "Kuliner",
      "Alam",
      "Belanja"
    ],
    1,
    "Kuliner",
    "Soto Bathok Mbah Katro paling sesuai ditampilkan sebagai kategori Kuliner."
  ],
  [
    "Kategori yang paling tepat untuk Sendratari Ramayana adalah apa?",
    [
      "Alam",
      "Kuliner",
      "Seni",
      "Belanja"
    ],
    2,
    "Seni",
    "Sendratari Ramayana paling sesuai ditampilkan sebagai kategori Seni."
  ],
  [
    "Kategori yang paling tepat untuk Museum Affandi adalah apa?",
    [
      "Belanja",
      "Kuliner",
      "Alam",
      "Seni"
    ],
    3,
    "Seni",
    "Museum Affandi paling sesuai ditampilkan sebagai kategori Seni."
  ],
  [
    "Kategori yang paling tepat untuk Kasongan adalah apa?",
    [
      "Kerajinan",
      "Pantai",
      "Kuliner",
      "Religi"
    ],
    0,
    "Kerajinan",
    "Kasongan paling sesuai ditampilkan sebagai kategori Kerajinan."
  ],
  [
    "Kategori yang paling tepat untuk Krebet adalah apa?",
    [
      "Pantai",
      "Kerajinan",
      "Kuliner",
      "Religi"
    ],
    1,
    "Kerajinan",
    "Krebet paling sesuai ditampilkan sebagai kategori Kerajinan."
  ],
  [
    "Kategori yang paling tepat untuk Pentingsari adalah apa?",
    [
      "Pantai",
      "Museum",
      "Desa Wisata",
      "Belanja"
    ],
    2,
    "Desa Wisata",
    "Pentingsari paling sesuai ditampilkan sebagai kategori Desa Wisata."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Garis imajiner Jogja?",
    [
      "Membagi wilayah pajak kota",
      "Menandai rute kereta wisata",
      "Menghubungkan Merapi, Tugu, Keraton, dan Laut Selatan",
      "Menentukan jam buka pasar"
    ],
    2,
    "Budaya",
    "Garis imajiner sering dipahami sebagai filosofi tata ruang Yogyakarta."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Sumbu filosofi?",
    [
      "Membatasi area kuliner",
      "Mengatur tarif tiket wisata",
      "Menentukan jalur bus malam",
      "Menjelaskan relasi simbolik ruang kota"
    ],
    3,
    "Budaya",
    "Sumbu filosofi berkaitan dengan makna tata ruang Jogja."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Gudeg?",
    [
      "Olahan nangka muda bercita rasa manis gurih",
      "Minuman kopi dengan arang",
      "Kue lapis berisi kacang hijau",
      "Sate ayam bumbu merah"
    ],
    0,
    "Kuliner",
    "Gudeg dikenal sebagai salah satu kuliner khas Yogyakarta."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Kopi joss?",
    [
      "Teh rempah dengan santan",
      "Kopi panas yang diberi arang membara",
      "Es buah dari pantai selatan",
      "Minuman cokelat dari kakao"
    ],
    1,
    "Kuliner",
    "Kopi joss populer di angkringan sekitar Tugu dan Malioboro."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Bakpia?",
    [
      "Minuman rempah keraton",
      "Nasi kecil lauk sederhana",
      "Kue oleh-oleh berisi kacang atau varian lain",
      "Olahan daging kambing"
    ],
    2,
    "Kuliner",
    "Bakpia banyak dikenal sebagai oleh-oleh khas Jogja."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Nasi kucing?",
    [
      "Nasi bakar laut selatan",
      "Nasi kuning untuk kenduri",
      "Nasi liwet khas keraton",
      "Porsi nasi kecil khas angkringan"
    ],
    3,
    "Kuliner",
    "Nasi kucing melekat dengan budaya angkringan."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Blangkon?",
    [
      "Penutup kepala tradisional pria Jawa",
      "Alat musik petik Jawa",
      "Motif batik pesisir",
      "Senjata pusaka keraton"
    ],
    0,
    "Budaya",
    "Blangkon adalah bagian dari busana tradisional Jawa."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Batik parang?",
    [
      "Alat musik gamelan utama",
      "Motif batik dengan filosofi keteguhan",
      "Makanan ritual keraton",
      "Arsitektur pintu gerbang"
    ],
    1,
    "Budaya",
    "Batik parang dikenal memiliki makna simbolik dalam budaya Jawa."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Wayang kulit?",
    [
      "Alat musik bambu Sunda",
      "Tari perang dari Bali",
      "Seni pertunjukan bayangan dengan dalang",
      "Permainan anak pantai"
    ],
    2,
    "Seni",
    "Wayang kulit adalah seni pertunjukan yang kuat dalam budaya Jawa."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Gamelan?",
    [
      "Perahu nelayan selatan",
      "Senjata tradisional Madura",
      "Kain tenun khas timur",
      "Ansambel musik tradisional Jawa"
    ],
    3,
    "Seni",
    "Gamelan menjadi pengiring penting dalam seni Jawa."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Labuhan?",
    [
      "Tradisi persembahan simbolik dalam budaya keraton",
      "Festival kuliner modern",
      "Lomba lari malam kota",
      "Pameran otomotif tahunan"
    ],
    0,
    "Budaya",
    "Labuhan berkaitan dengan tradisi dan spiritualitas keraton."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Sekaten?",
    [
      "Pameran fotografi pantai",
      "Tradisi peringatan Maulid di lingkungan Keraton",
      "Festival kopi modern",
      "Lomba sepeda gunung"
    ],
    1,
    "Budaya",
    "Sekaten terkait tradisi keagamaan dan budaya Keraton Yogyakarta."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Grebeg?",
    [
      "Pameran kerajinan logam",
      "Permainan pasir pantai",
      "Upacara dengan gunungan dari Keraton",
      "Ritual membuka museum"
    ],
    2,
    "Budaya",
    "Grebeg dikenal melalui gunungan dan tradisi keraton."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Kraton?",
    [
      "Pelabuhan wisata selatan",
      "Terminal utama bus kota",
      "Pusat industri modern",
      "Pusat tradisi dan simbol pemerintahan budaya"
    ],
    3,
    "Budaya",
    "Kraton merupakan pusat budaya Kesultanan Yogyakarta."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Alun-Alun Kidul?",
    [
      "Ruang publik yang lekat dengan tradisi kota",
      "Candi di puncak bukit",
      "Museum seni modern",
      "Desa wisata gerabah"
    ],
    0,
    "Ikonik",
    "Alun-Alun Kidul merupakan ruang publik yang populer di malam hari."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Masangin?",
    [
      "Tari pembuka keraton",
      "Tradisi berjalan di antara dua beringin",
      "Ritual membuat batik kayu",
      "Cara memasak gudeg"
    ],
    1,
    "Budaya",
    "Masangin berkaitan dengan dua beringin di Alun-Alun Kidul."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Pasar Beringharjo?",
    [
      "Pantai populer Bantul",
      "Museum lukisan modern",
      "Pasar tradisional dekat Malioboro",
      "Desa wisata Merapi"
    ],
    2,
    "Belanja",
    "Beringharjo dikenal sebagai pasar tradisional di kawasan Malioboro."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Jalan Malioboro?",
    [
      "Desa kerajinan gerabah",
      "Jalur pendakian Merapi",
      "Pantai selatan Bantul",
      "Koridor kota untuk belanja dan jalan kaki"
    ],
    3,
    "Ikonik",
    "Malioboro adalah salah satu koridor wisata kota paling dikenal."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Titik Nol Kilometer?",
    [
      "Ruang kota dekat Vredeburg dan Malioboro",
      "Pintu masuk Pantai Selatan",
      "Situs candi tersembunyi",
      "Desa wisata lereng Merapi"
    ],
    0,
    "Ikonik",
    "Titik Nol berada di kawasan pusat kota yang strategis."
  ],
  [
    "Dalam konteks Jogja, apa makna atau ciri utama Prawirotaman?",
    [
      "Sentra tambang batu bara",
      "Kawasan penginapan dan kafe wisatawan",
      "Kompleks keraton utama",
      "Pantai pasir putih"
    ],
    1,
    "Kawasan",
    "Prawirotaman dikenal sebagai kawasan wisatawan dengan kafe dan penginapan."
  ],
  [
    "Destinasi mana yang paling sesuai jika wisatawan ingin belajar sejarah Keraton dalam waktu singkat?",
    [
      "Kopi Klotok",
      "Tempo Gelato",
      "Pantai Drini",
      "Keraton Yogyakarta"
    ],
    3,
    "Budaya",
    "Keraton cocok untuk memahami budaya Kesultanan."
  ],
  [
    "Destinasi mana yang paling sesuai jika pengunjung ingin jalan santai dan belanja oleh-oleh malam?",
    [
      "Malioboro",
      "Candi Ijo",
      "Hutan Pinus",
      "Museum Affandi"
    ],
    0,
    "Ikonik",
    "Malioboro cocok untuk belanja dan menikmati suasana kota."
  ],
  [
    "Destinasi mana yang paling sesuai jika keluarga ingin museum sejarah dekat pusat kota?",
    [
      "Kopi Klotok",
      "Benteng Vredeburg",
      "Pantai Indrayanti",
      "HeHa Sky View"
    ],
    1,
    "Sejarah",
    "Vredeburg berada dekat pusat kota dan menyajikan sejarah perjuangan."
  ],
  [
    "Destinasi mana yang paling sesuai jika wisatawan ingin pemandangan sunset di situs arkeologi?",
    [
      "Sonobudoyo",
      "Pasar Beringharjo",
      "Ratu Boko",
      "Gudeg Wijilan"
    ],
    2,
    "Sejarah",
    "Ratu Boko dikenal dengan panorama senja dan situs arkeologi."
  ],
  [
    "Destinasi mana yang paling sesuai jika pengunjung ingin kuliner rumahan di suasana pedesaan?",
    [
      "Kasongan",
      "Candi Sambisari",
      "Titik Nol",
      "Kopi Klotok"
    ],
    3,
    "Kuliner",
    "Kopi Klotok menawarkan suasana rumahan dan menu sederhana."
  ],
  [
    "Destinasi mana yang paling sesuai jika wisatawan mencari pertunjukan budaya malam?",
    [
      "Sendratari Ramayana",
      "Museum Affandi",
      "Pantai Glagah",
      "Pasar Satwa"
    ],
    0,
    "Seni",
    "Sendratari Ramayana adalah pertunjukan budaya malam."
  ],
  [
    "Destinasi mana yang paling sesuai jika pengunjung ingin belajar kerajinan gerabah?",
    [
      "Prambanan",
      "Kasongan",
      "Malioboro",
      "Alun-Alun Kidul"
    ],
    1,
    "Kerajinan",
    "Kasongan dikenal sebagai sentra gerabah Bantul."
  ],
  [
    "Destinasi mana yang paling sesuai jika wisatawan mencari foto kota dari ketinggian malam?",
    [
      "Kauman",
      "Sonobudoyo",
      "Bukit Bintang",
      "Kotagede"
    ],
    2,
    "Alam",
    "Bukit Bintang populer untuk melihat lampu kota malam."
  ],
  [
    "Destinasi mana yang paling sesuai jika pengunjung ingin memahami karya pelukis Affandi?",
    [
      "Kalibiru",
      "Taman Sari",
      "Bakpia Pathok",
      "Museum Affandi"
    ],
    3,
    "Seni",
    "Museum Affandi menyimpan karya dan kisah pelukis Affandi."
  ],
  [
    "Destinasi mana yang paling sesuai jika wisatawan ingin menjelajah desa wisata lereng Merapi?",
    [
      "Pentingsari",
      "Malioboro",
      "Wijilan",
      "Vredeburg"
    ],
    0,
    "Desa Wisata",
    "Pentingsari menawarkan pengalaman desa wisata lereng Merapi."
  ],
  [
    "Manakah pilihan yang paling tepat: Waktu yang nyaman untuk mengunjungi Tugu Yogyakarta?",
    [
      "Malam hari atau pagi sangat awal",
      "Siang terik tanpa trotoar",
      "Saat museum tutup total",
      "Hanya tengah malam Jumat"
    ],
    0,
    "Ikonik",
    "Tugu lebih nyaman dinikmati saat tidak terlalu ramai dan cuaca teduh."
  ],
  [
    "Manakah pilihan yang paling tepat: Waktu yang sering disarankan untuk Ratu Boko?",
    [
      "Pagi buta saat loket tutup",
      "Sore hari menjelang sunset",
      "Siang bolong tanpa persiapan",
      "Malam larut tanpa penerangan"
    ],
    1,
    "Sejarah",
    "Ratu Boko terkenal dengan panorama senja."
  ],
  [
    "Manakah pilihan yang paling tepat: Sikap yang tepat saat masuk area masjid bersejarah?",
    [
      "Memotret tanpa izin jamaah",
      "Berlari di ruang utama",
      "Berpakaian sopan dan menjaga tenang",
      "Makan di area ibadah"
    ],
    2,
    "Religi",
    "Tempat ibadah perlu dikunjungi dengan sopan dan tenang."
  ],
  [
    "Manakah pilihan yang paling tepat: Hal yang perlu diperhatikan saat berkunjung ke kampung wisata?",
    [
      "Membuang sampah di gang",
      "Masuk rumah warga sembarangan",
      "Membunyikan musik keras",
      "Menghormati warga dan meminta izin foto"
    ],
    3,
    "Budaya",
    "Kampung wisata tetap ruang hidup warga."
  ],
  [
    "Manakah pilihan yang paling tepat: Cara aman menikmati foto di Tugu Jogja?",
    [
      "Berfoto dari trotoar dan area aman",
      "Berdiri lama di tengah jalan",
      "Menghambat kendaraan sekitar",
      "Memanjat bagian monumen"
    ],
    0,
    "Ikonik",
    "Tugu berada di area lalu lintas aktif sehingga keselamatan perlu dijaga."
  ],
  [
    "Manakah pilihan yang paling tepat: Hal yang disarankan saat membeli oleh-oleh bakpia?",
    [
      "Membeli tanpa melihat kemasan",
      "Cek tanggal produksi dan varian rasa",
      "Menaruh di tempat sangat panas",
      "Membuka semua kotak dahulu"
    ],
    1,
    "Kuliner",
    "Bakpia sebaiknya dibeli dengan memperhatikan kesegaran."
  ],
  [
    "Manakah pilihan yang paling tepat: Saran saat menikmati pantai selatan Jogja?",
    [
      "Mengabaikan peringatan petugas",
      "Berenang jauh dari pengawasan",
      "Mematuhi rambu dan waspada ombak",
      "Bermain dekat arus kuat"
    ],
    2,
    "Alam",
    "Pantai selatan memiliki ombak yang perlu diwaspadai."
  ],
  [
    "Manakah pilihan yang paling tepat: Pilihan transportasi nyaman untuk Malioboro?",
    [
      "Motor di area pedestrian",
      "Mobil berhenti di semua titik",
      "Truk barang masuk trotoar",
      "Jalan kaki atau transportasi umum sekitar"
    ],
    3,
    "Ikonik",
    "Malioboro nyaman dinikmati dengan berjalan kaki."
  ],
  [
    "Manakah pilihan yang paling tepat: Sikap saat mengikuti tur museum?",
    [
      "Mengikuti arahan pemandu dan aturan foto",
      "Menyentuh koleksi sembarangan",
      "Memotong jalur tur sesuka hati",
      "Berteriak di ruang pamer"
    ],
    0,
    "Budaya",
    "Museum memiliki aturan untuk menjaga koleksi dan kenyamanan."
  ],
  [
    "Manakah pilihan yang paling tepat: Saran saat ke Tebing Breksi siang hari?",
    [
      "Memakai jaket tebal saja",
      "Membawa topi dan air minum",
      "Menghindari alas kaki nyaman",
      "Datang tanpa pelindung panas"
    ],
    1,
    "Alam",
    "Area terbuka seperti Tebing Breksi dapat terasa panas saat siang."
  ],
  [
    "Kesamaan yang paling tepat antara Candi Prambanan dan Sendratari Ramayana adalah apa?",
    [
      "Pasar tradisional dan sentra perak",
      "Candi Hindu dan pertunjukan kisah Ramayana",
      "Desa wisata dan kerajinan gerabah",
      "Pantai dan hutan pinus"
    ],
    1,
    "Sejarah",
    "Prambanan dan Sendratari Ramayana saling terkait lewat kisah dan lokasi budaya."
  ],
  [
    "Kesamaan yang paling tepat antara Malioboro dan Pasar Beringharjo adalah apa?",
    [
      "Museum seni dan galeri lukisan",
      "Sunset pantai dan olahraga air",
      "Belanja, jalan kaki, dan oleh-oleh",
      "Candi bukit dan relief Hindu"
    ],
    2,
    "Belanja",
    "Keduanya cocok untuk suasana kota, belanja, dan oleh-oleh."
  ],
  [
    "Kesamaan yang paling tepat antara Kotagede dan Kasongan adalah apa?",
    [
      "Kawasan stasiun dan bandara",
      "Pantai pasir dan sunset laut",
      "Museum modern dan gelato",
      "Kawasan heritage dan kerajinan lokal"
    ],
    3,
    "Kerajinan",
    "Keduanya punya kekuatan kerajinan dan identitas lokal."
  ],
  [
    "Kesamaan yang paling tepat antara Parangtritis dan Gumuk Pasir adalah apa?",
    [
      "Lanskap pesisir dan bentang pasir",
      "Museum budaya dan keris",
      "Pasar batik dan kuliner",
      "Candi Hindu dan Buddha"
    ],
    0,
    "Alam",
    "Keduanya berada dalam kawasan pesisir Bantul yang populer."
  ],
  [
    "Kesamaan yang paling tepat antara Vredeburg dan Titik Nol adalah apa?",
    [
      "Lereng Merapi dan lava tour",
      "Pusat kota dan bangunan heritage",
      "Kuliner desa dan sawah",
      "Pantai selatan dan pasir"
    ],
    1,
    "Sejarah",
    "Vredeburg dan Titik Nol berada berdekatan di pusat kota."
  ],
  [
    "Kesamaan yang paling tepat antara Kopi Klotok dan Soto Bathok adalah apa?",
    [
      "Candi sejarah dan relief",
      "Museum lukisan dan galeri",
      "Kuliner lokal dengan suasana khas",
      "Panggung tari dan musik"
    ],
    2,
    "Kuliner",
    "Keduanya menawarkan pengalaman kuliner khas Jogja."
  ],
  [
    "Kesamaan yang paling tepat antara Museum Affandi dan Sonobudoyo adalah apa?",
    [
      "Terminal dan stasiun",
      "Pasar satwa dan tanaman",
      "Pantai dan bukit karst",
      "Ruang belajar seni dan budaya"
    ],
    3,
    "Seni",
    "Keduanya cocok untuk belajar seni, budaya, dan sejarah."
  ],
  [
    "Kesamaan yang paling tepat antara Pentingsari dan Tembi adalah apa?",
    [
      "Desa wisata dan pengalaman lokal",
      "Jalan belanja dan mall modern",
      "Candi utama dan istana air",
      "Pantai pasir dan tebing laut"
    ],
    0,
    "Desa Wisata",
    "Keduanya menawarkan pengalaman desa wisata berbasis kegiatan lokal."
  ],
  [
    "Kesamaan yang paling tepat antara Candi Sambisari dan Candi Ijo adalah apa?",
    [
      "Kuliner angkringan malam",
      "Situs candi di kawasan Sleman",
      "Sentra bakpia dan gudeg",
      "Pantai selatan Bantul"
    ],
    1,
    "Sejarah",
    "Keduanya merupakan situs candi di wilayah Sleman-Prambanan sekitarnya."
  ],
  [
    "Kesamaan yang paling tepat antara Prawirotaman dan Sosrowijayan adalah apa?",
    [
      "Pantai pasir putih terpencil",
      "Desa kerajinan batik kayu",
      "Kawasan wisatawan dengan penginapan",
      "Museum perjuangan kolonial"
    ],
    2,
    "Kawasan",
    "Keduanya dikenal sebagai kawasan wisatawan dengan penginapan dan kuliner."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Keraton Yogyakarta?",
    [
      "Keraton Yogyakarta utama sebagai terminal barang",
      "Keraton Yogyakarta paling tepat disebut kawasan industri",
      "Keraton Yogyakarta lebih cocok untuk tema Budaya",
      "Keraton Yogyakarta dikenal sebagai pelabuhan besar"
    ],
    2,
    "Budaya",
    "Keraton Yogyakarta menjadi pusat budaya dan tradisi Kesultanan."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Taman Sari?",
    [
      "Taman Sari dikenal sebagai pelabuhan besar",
      "Taman Sari paling tepat disebut kawasan industri",
      "Taman Sari utama sebagai terminal barang",
      "Taman Sari lebih cocok untuk tema Sejarah"
    ],
    3,
    "Sejarah",
    "Taman Sari berkaitan dengan kompleks istirahat dan pertahanan Keraton."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Malioboro?",
    [
      "Malioboro lebih cocok untuk tema Ikonik",
      "Malioboro paling tepat disebut kawasan industri",
      "Malioboro utama sebagai terminal barang",
      "Malioboro dikenal sebagai pelabuhan besar"
    ],
    0,
    "Ikonik",
    "Malioboro dikenal sebagai koridor wisata kota yang ikonik."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Tugu Yogyakarta?",
    [
      "Tugu Yogyakarta paling tepat disebut kawasan industri",
      "Tugu Yogyakarta lebih cocok untuk tema Ikonik",
      "Tugu Yogyakarta utama sebagai terminal barang",
      "Tugu Yogyakarta dikenal sebagai pelabuhan besar"
    ],
    1,
    "Ikonik",
    "Tugu Yogyakarta berkaitan dengan filosofi tata ruang Jogja."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Kotagede?",
    [
      "Kotagede utama sebagai terminal barang",
      "Kotagede paling tepat disebut kawasan industri",
      "Kotagede lebih cocok untuk tema Sejarah",
      "Kotagede dikenal sebagai pelabuhan besar"
    ],
    2,
    "Sejarah",
    "Kotagede dikenal sebagai kawasan Mataram Islam dan perak."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Vredeburg?",
    [
      "Vredeburg dikenal sebagai pelabuhan besar",
      "Vredeburg paling tepat disebut kawasan industri",
      "Vredeburg utama sebagai terminal barang",
      "Vredeburg lebih cocok untuk tema Sejarah"
    ],
    3,
    "Sejarah",
    "Benteng Vredeburg kini berfungsi sebagai museum sejarah perjuangan."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Sonobudoyo?",
    [
      "Sonobudoyo lebih cocok untuk tema Budaya",
      "Sonobudoyo paling tepat disebut kawasan industri",
      "Sonobudoyo utama sebagai terminal barang",
      "Sonobudoyo dikenal sebagai pelabuhan besar"
    ],
    0,
    "Budaya",
    "Museum Sonobudoyo menyimpan koleksi budaya Jawa."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Ullen Sentalu?",
    [
      "Ullen Sentalu paling tepat disebut kawasan industri",
      "Ullen Sentalu lebih cocok untuk tema Budaya",
      "Ullen Sentalu utama sebagai terminal barang",
      "Ullen Sentalu dikenal sebagai pelabuhan besar"
    ],
    1,
    "Budaya",
    "Ullen Sentalu terkenal dengan narasi budaya Jawa yang elegan."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Candi Prambanan?",
    [
      "Candi Prambanan utama sebagai terminal barang",
      "Candi Prambanan paling tepat disebut kawasan industri",
      "Candi Prambanan lebih cocok untuk tema Sejarah",
      "Candi Prambanan dikenal sebagai pelabuhan besar"
    ],
    2,
    "Sejarah",
    "Prambanan adalah kompleks candi Hindu penting di Yogyakarta."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Ratu Boko?",
    [
      "Ratu Boko dikenal sebagai pelabuhan besar",
      "Ratu Boko paling tepat disebut kawasan industri",
      "Ratu Boko utama sebagai terminal barang",
      "Ratu Boko lebih cocok untuk tema Sejarah"
    ],
    3,
    "Sejarah",
    "Ratu Boko dikenal sebagai situs bukit dengan panorama senja."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Candi Sambisari?",
    [
      "Candi Sambisari lebih cocok untuk tema Sejarah",
      "Candi Sambisari paling tepat disebut kawasan industri",
      "Candi Sambisari utama sebagai terminal barang",
      "Candi Sambisari dikenal sebagai pelabuhan besar"
    ],
    0,
    "Sejarah",
    "Candi Sambisari terkenal karena ditemukan terkubur dan berada lebih rendah dari tanah sekitar."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Candi Ijo?",
    [
      "Candi Ijo paling tepat disebut kawasan industri",
      "Candi Ijo lebih cocok untuk tema Sejarah",
      "Candi Ijo utama sebagai terminal barang",
      "Candi Ijo dikenal sebagai pelabuhan besar"
    ],
    1,
    "Sejarah",
    "Candi Ijo berada di area perbukitan dan dikenal dengan pemandangan luas."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Kalibiru?",
    [
      "Kalibiru utama sebagai terminal barang",
      "Kalibiru paling tepat disebut kawasan industri",
      "Kalibiru lebih cocok untuk tema Alam",
      "Kalibiru dikenal sebagai pelabuhan besar"
    ],
    2,
    "Alam",
    "Kalibiru populer dengan panorama alam dan spot foto ketinggian."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Pantai Parangtritis?",
    [
      "Pantai Parangtritis dikenal sebagai pelabuhan besar",
      "Pantai Parangtritis paling tepat disebut kawasan industri",
      "Pantai Parangtritis utama sebagai terminal barang",
      "Pantai Parangtritis lebih cocok untuk tema Alam"
    ],
    3,
    "Alam",
    "Parangtritis melekat dengan wisata pantai dan budaya Laut Selatan."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Gumuk Pasir Parangkusumo?",
    [
      "Gumuk Pasir Parangkusumo lebih cocok untuk tema Alam",
      "Gumuk Pasir Parangkusumo paling tepat disebut kawasan industri",
      "Gumuk Pasir Parangkusumo utama sebagai terminal barang",
      "Gumuk Pasir Parangkusumo dikenal sebagai pelabuhan besar"
    ],
    0,
    "Alam",
    "Gumuk Pasir Parangkusumo dikenal sebagai bentang pasir unik di Bantul."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Hutan Pinus Mangunan?",
    [
      "Hutan Pinus Mangunan paling tepat disebut kawasan industri",
      "Hutan Pinus Mangunan lebih cocok untuk tema Alam",
      "Hutan Pinus Mangunan utama sebagai terminal barang",
      "Hutan Pinus Mangunan dikenal sebagai pelabuhan besar"
    ],
    1,
    "Alam",
    "Hutan Pinus Mangunan menawarkan suasana alam dan fotografi."
  ],
  [
    "Pernyataan mana yang paling tepat tentang HeHa Sky View?",
    [
      "HeHa Sky View utama sebagai terminal barang",
      "HeHa Sky View paling tepat disebut kawasan industri",
      "HeHa Sky View lebih cocok untuk tema Foto",
      "HeHa Sky View dikenal sebagai pelabuhan besar"
    ],
    2,
    "Foto",
    "HeHa Sky View dikenal dengan spot foto modern dan panorama kota."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Bukit Bintang?",
    [
      "Bukit Bintang dikenal sebagai pelabuhan besar",
      "Bukit Bintang paling tepat disebut kawasan industri",
      "Bukit Bintang utama sebagai terminal barang",
      "Bukit Bintang lebih cocok untuk tema Alam"
    ],
    3,
    "Alam",
    "Bukit Bintang populer untuk menikmati pemandangan malam dari perbukitan."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Kopi Klotok?",
    [
      "Kopi Klotok lebih cocok untuk tema Kuliner",
      "Kopi Klotok paling tepat disebut kawasan industri",
      "Kopi Klotok utama sebagai terminal barang",
      "Kopi Klotok dikenal sebagai pelabuhan besar"
    ],
    0,
    "Kuliner",
    "Kopi Klotok terkenal dengan menu rumahan dan suasana desa."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Bakpia Pathok?",
    [
      "Bakpia Pathok paling tepat disebut kawasan industri",
      "Bakpia Pathok lebih cocok untuk tema Kuliner",
      "Bakpia Pathok utama sebagai terminal barang",
      "Bakpia Pathok dikenal sebagai pelabuhan besar"
    ],
    1,
    "Kuliner",
    "Bakpia Pathok menjadi oleh-oleh yang sangat melekat dengan Jogja."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Angkringan Lik Man?",
    [
      "Angkringan Lik Man utama sebagai terminal barang",
      "Angkringan Lik Man paling tepat disebut kawasan industri",
      "Angkringan Lik Man lebih cocok untuk tema Kuliner",
      "Angkringan Lik Man dikenal sebagai pelabuhan besar"
    ],
    2,
    "Kuliner",
    "Angkringan Lik Man dikenal dengan suasana malam dan kopi joss."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Gudeg Wijilan?",
    [
      "Gudeg Wijilan dikenal sebagai pelabuhan besar",
      "Gudeg Wijilan paling tepat disebut kawasan industri",
      "Gudeg Wijilan utama sebagai terminal barang",
      "Gudeg Wijilan lebih cocok untuk tema Kuliner"
    ],
    3,
    "Kuliner",
    "Wijilan dikenal sebagai salah satu kawasan kuliner gudeg di Jogja."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Sate Ratu?",
    [
      "Sate Ratu lebih cocok untuk tema Kuliner",
      "Sate Ratu paling tepat disebut kawasan industri",
      "Sate Ratu utama sebagai terminal barang",
      "Sate Ratu dikenal sebagai pelabuhan besar"
    ],
    0,
    "Kuliner",
    "Sate Ratu dikenal sebagai salah satu kuliner populer Jogja."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Bakmi Jawa Mbah Gito?",
    [
      "Bakmi Jawa Mbah Gito paling tepat disebut kawasan industri",
      "Bakmi Jawa Mbah Gito lebih cocok untuk tema Kuliner",
      "Bakmi Jawa Mbah Gito utama sebagai terminal barang",
      "Bakmi Jawa Mbah Gito dikenal sebagai pelabuhan besar"
    ],
    1,
    "Kuliner",
    "Bakmi Jawa Mbah Gito dikenal lewat bakmi dan atmosfer tradisional."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Soto Bathok Mbah Katro?",
    [
      "Soto Bathok Mbah Katro utama sebagai terminal barang",
      "Soto Bathok Mbah Katro paling tepat disebut kawasan industri",
      "Soto Bathok Mbah Katro lebih cocok untuk tema Kuliner",
      "Soto Bathok Mbah Katro dikenal sebagai pelabuhan besar"
    ],
    2,
    "Kuliner",
    "Soto Bathok Mbah Katro dikenal dengan penyajian soto yang khas."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Sendratari Ramayana?",
    [
      "Sendratari Ramayana dikenal sebagai pelabuhan besar",
      "Sendratari Ramayana paling tepat disebut kawasan industri",
      "Sendratari Ramayana utama sebagai terminal barang",
      "Sendratari Ramayana lebih cocok untuk tema Seni"
    ],
    3,
    "Seni",
    "Sendratari Ramayana mengangkat kisah Ramayana lewat tari dan musik."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Museum Affandi?",
    [
      "Museum Affandi lebih cocok untuk tema Seni",
      "Museum Affandi paling tepat disebut kawasan industri",
      "Museum Affandi utama sebagai terminal barang",
      "Museum Affandi dikenal sebagai pelabuhan besar"
    ],
    0,
    "Seni",
    "Museum Affandi menyimpan karya dan kisah pelukis Affandi."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Kasongan?",
    [
      "Kasongan paling tepat disebut kawasan industri",
      "Kasongan lebih cocok untuk tema Kerajinan",
      "Kasongan utama sebagai terminal barang",
      "Kasongan dikenal sebagai pelabuhan besar"
    ],
    1,
    "Kerajinan",
    "Kasongan terkenal sebagai sentra gerabah dan kerajinan tanah liat."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Krebet?",
    [
      "Krebet utama sebagai terminal barang",
      "Krebet paling tepat disebut kawasan industri",
      "Krebet lebih cocok untuk tema Kerajinan",
      "Krebet dikenal sebagai pelabuhan besar"
    ],
    2,
    "Kerajinan",
    "Krebet dikenal dengan kerajinan batik di media kayu."
  ],
  [
    "Pernyataan mana yang paling tepat tentang Pentingsari?",
    [
      "Pentingsari dikenal sebagai pelabuhan besar",
      "Pentingsari paling tepat disebut kawasan industri",
      "Pentingsari utama sebagai terminal barang",
      "Pentingsari lebih cocok untuk tema Desa Wisata"
    ],
    3,
    "Desa Wisata",
    "Pentingsari menawarkan kegiatan edukasi dan suasana desa lereng Merapi."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Garis imajiner Jogja.",
    [
      "Garis imajiner Jogja dipakai untuk menentukan jam buka pasar",
      "Garis imajiner Jogja terutama untuk menandai rute kereta wisata",
      "Garis imajiner Jogja biasanya berarti membagi wilayah pajak kota",
      "Garis imajiner Jogja berkaitan dengan menghubungkan Merapi, Tugu, Keraton, dan Laut Selatan"
    ],
    3,
    "Budaya",
    "Garis imajiner sering dipahami sebagai filosofi tata ruang Yogyakarta."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Sumbu filosofi.",
    [
      "Sumbu filosofi berkaitan dengan menjelaskan relasi simbolik ruang kota",
      "Sumbu filosofi terutama untuk mengatur tarif tiket wisata",
      "Sumbu filosofi biasanya berarti menentukan jalur bus malam",
      "Sumbu filosofi dipakai untuk membatasi area kuliner"
    ],
    0,
    "Budaya",
    "Sumbu filosofi berkaitan dengan makna tata ruang Jogja."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Gudeg.",
    [
      "Gudeg terutama untuk minuman kopi dengan arang",
      "Gudeg berkaitan dengan olahan nangka muda bercita rasa manis gurih",
      "Gudeg biasanya berarti kue lapis berisi kacang hijau",
      "Gudeg dipakai untuk sate ayam bumbu merah"
    ],
    1,
    "Kuliner",
    "Gudeg dikenal sebagai salah satu kuliner khas Yogyakarta."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Kopi joss.",
    [
      "Kopi joss biasanya berarti es buah dari pantai selatan",
      "Kopi joss terutama untuk teh rempah dengan santan",
      "Kopi joss berkaitan dengan kopi panas yang diberi arang membara",
      "Kopi joss dipakai untuk minuman cokelat dari kakao"
    ],
    2,
    "Kuliner",
    "Kopi joss populer di angkringan sekitar Tugu dan Malioboro."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Bakpia.",
    [
      "Bakpia dipakai untuk olahan daging kambing",
      "Bakpia terutama untuk nasi kecil lauk sederhana",
      "Bakpia biasanya berarti minuman rempah keraton",
      "Bakpia berkaitan dengan kue oleh-oleh berisi kacang atau varian lain"
    ],
    3,
    "Kuliner",
    "Bakpia banyak dikenal sebagai oleh-oleh khas Jogja."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Nasi kucing.",
    [
      "Nasi kucing berkaitan dengan porsi nasi kecil khas angkringan",
      "Nasi kucing terutama untuk nasi kuning untuk kenduri",
      "Nasi kucing biasanya berarti nasi liwet khas keraton",
      "Nasi kucing dipakai untuk nasi bakar laut selatan"
    ],
    0,
    "Kuliner",
    "Nasi kucing melekat dengan budaya angkringan."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Blangkon.",
    [
      "Blangkon terutama untuk alat musik petik Jawa",
      "Blangkon berkaitan dengan penutup kepala tradisional pria Jawa",
      "Blangkon biasanya berarti motif batik pesisir",
      "Blangkon dipakai untuk senjata pusaka keraton"
    ],
    1,
    "Budaya",
    "Blangkon adalah bagian dari busana tradisional Jawa."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Batik parang.",
    [
      "Batik parang biasanya berarti makanan ritual keraton",
      "Batik parang terutama untuk alat musik gamelan utama",
      "Batik parang berkaitan dengan motif batik dengan filosofi keteguhan",
      "Batik parang dipakai untuk arsitektur pintu gerbang"
    ],
    2,
    "Budaya",
    "Batik parang dikenal memiliki makna simbolik dalam budaya Jawa."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Wayang kulit.",
    [
      "Wayang kulit dipakai untuk permainan anak pantai",
      "Wayang kulit terutama untuk tari perang dari Bali",
      "Wayang kulit biasanya berarti alat musik bambu Sunda",
      "Wayang kulit berkaitan dengan seni pertunjukan bayangan dengan dalang"
    ],
    3,
    "Seni",
    "Wayang kulit adalah seni pertunjukan yang kuat dalam budaya Jawa."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Gamelan.",
    [
      "Gamelan berkaitan dengan ansambel musik tradisional Jawa",
      "Gamelan terutama untuk senjata tradisional Madura",
      "Gamelan biasanya berarti kain tenun khas timur",
      "Gamelan dipakai untuk perahu nelayan selatan"
    ],
    0,
    "Seni",
    "Gamelan menjadi pengiring penting dalam seni Jawa."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Labuhan.",
    [
      "Labuhan terutama untuk festival kuliner modern",
      "Labuhan berkaitan dengan tradisi persembahan simbolik dalam budaya keraton",
      "Labuhan biasanya berarti lomba lari malam kota",
      "Labuhan dipakai untuk pameran otomotif tahunan"
    ],
    1,
    "Budaya",
    "Labuhan berkaitan dengan tradisi dan spiritualitas keraton."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Sekaten.",
    [
      "Sekaten biasanya berarti festival kopi modern",
      "Sekaten terutama untuk pameran fotografi pantai",
      "Sekaten berkaitan dengan tradisi peringatan Maulid di lingkungan Keraton",
      "Sekaten dipakai untuk lomba sepeda gunung"
    ],
    2,
    "Budaya",
    "Sekaten terkait tradisi keagamaan dan budaya Keraton Yogyakarta."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Grebeg.",
    [
      "Grebeg dipakai untuk ritual membuka museum",
      "Grebeg terutama untuk permainan pasir pantai",
      "Grebeg biasanya berarti pameran kerajinan logam",
      "Grebeg berkaitan dengan upacara dengan gunungan dari Keraton"
    ],
    3,
    "Budaya",
    "Grebeg dikenal melalui gunungan dan tradisi keraton."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Kraton.",
    [
      "Kraton berkaitan dengan pusat tradisi dan simbol pemerintahan budaya",
      "Kraton terutama untuk terminal utama bus kota",
      "Kraton biasanya berarti pusat industri modern",
      "Kraton dipakai untuk pelabuhan wisata selatan"
    ],
    0,
    "Budaya",
    "Kraton merupakan pusat budaya Kesultanan Yogyakarta."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Alun-Alun Kidul.",
    [
      "Alun-Alun Kidul terutama untuk candi di puncak bukit",
      "Alun-Alun Kidul berkaitan dengan ruang publik yang lekat dengan tradisi kota",
      "Alun-Alun Kidul biasanya berarti museum seni modern",
      "Alun-Alun Kidul dipakai untuk desa wisata gerabah"
    ],
    1,
    "Ikonik",
    "Alun-Alun Kidul merupakan ruang publik yang populer di malam hari."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Masangin.",
    [
      "Masangin biasanya berarti ritual membuat batik kayu",
      "Masangin terutama untuk tari pembuka keraton",
      "Masangin berkaitan dengan tradisi berjalan di antara dua beringin",
      "Masangin dipakai untuk cara memasak gudeg"
    ],
    2,
    "Budaya",
    "Masangin berkaitan dengan dua beringin di Alun-Alun Kidul."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Pasar Beringharjo.",
    [
      "Pasar Beringharjo dipakai untuk desa wisata Merapi",
      "Pasar Beringharjo terutama untuk museum lukisan modern",
      "Pasar Beringharjo biasanya berarti pantai populer Bantul",
      "Pasar Beringharjo berkaitan dengan pasar tradisional dekat Malioboro"
    ],
    3,
    "Belanja",
    "Beringharjo dikenal sebagai pasar tradisional di kawasan Malioboro."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Jalan Malioboro.",
    [
      "Jalan Malioboro berkaitan dengan koridor kota untuk belanja dan jalan kaki",
      "Jalan Malioboro terutama untuk jalur pendakian Merapi",
      "Jalan Malioboro biasanya berarti pantai selatan Bantul",
      "Jalan Malioboro dipakai untuk desa kerajinan gerabah"
    ],
    0,
    "Ikonik",
    "Malioboro adalah salah satu koridor wisata kota paling dikenal."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Titik Nol Kilometer.",
    [
      "Titik Nol Kilometer terutama untuk pintu masuk Pantai Selatan",
      "Titik Nol Kilometer berkaitan dengan ruang kota dekat Vredeburg dan Malioboro",
      "Titik Nol Kilometer biasanya berarti situs candi tersembunyi",
      "Titik Nol Kilometer dipakai untuk desa wisata lereng Merapi"
    ],
    1,
    "Ikonik",
    "Titik Nol berada di kawasan pusat kota yang strategis."
  ],
  [
    "Pilih penjelasan yang paling sesuai untuk istilah Prawirotaman.",
    [
      "Prawirotaman biasanya berarti kompleks keraton utama",
      "Prawirotaman terutama untuk sentra tambang batu bara",
      "Prawirotaman berkaitan dengan kawasan penginapan dan kafe wisatawan",
      "Prawirotaman dipakai untuk pantai pasir putih"
    ],
    2,
    "Kawasan",
    "Prawirotaman dikenal sebagai kawasan wisatawan dengan kafe dan penginapan."
  ],
  [
    "Jika Gudeg Wijilan muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Kuliner, karena daya tariknya selaras dengan tema itu",
      "Sejarah, karena fokusnya bukan pada kuliner",
      "Budaya, karena lebih cocok untuk tema lain",
      "Alam, karena tidak terkait konteks kuliner"
    ],
    0,
    "Kuliner",
    "Gudeg Wijilan paling mudah dipahami dalam kategori Kuliner."
  ],
  [
    "Jika Kopi Klotok muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Sejarah, karena fokusnya bukan pada kuliner",
      "Kuliner, karena daya tariknya selaras dengan tema itu",
      "Budaya, karena lebih cocok untuk tema lain",
      "Alam, karena tidak terkait konteks kuliner"
    ],
    1,
    "Kuliner",
    "Kopi Klotok paling mudah dipahami dalam kategori Kuliner."
  ],
  [
    "Jika Bakpia Pathok muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Budaya, karena lebih cocok untuk tema lain",
      "Sejarah, karena fokusnya bukan pada kuliner",
      "Kuliner, karena daya tariknya selaras dengan tema itu",
      "Alam, karena tidak terkait konteks kuliner"
    ],
    2,
    "Kuliner",
    "Bakpia Pathok paling mudah dipahami dalam kategori Kuliner."
  ],
  [
    "Jika Angkringan Lik Man muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Alam, karena tidak terkait konteks kuliner",
      "Sejarah, karena fokusnya bukan pada kuliner",
      "Budaya, karena lebih cocok untuk tema lain",
      "Kuliner, karena daya tariknya selaras dengan tema itu"
    ],
    3,
    "Kuliner",
    "Angkringan Lik Man paling mudah dipahami dalam kategori Kuliner."
  ],
  [
    "Jika Sate Ratu muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Kuliner, karena daya tariknya selaras dengan tema itu",
      "Sejarah, karena fokusnya bukan pada kuliner",
      "Budaya, karena lebih cocok untuk tema lain",
      "Alam, karena tidak terkait konteks kuliner"
    ],
    0,
    "Kuliner",
    "Sate Ratu paling mudah dipahami dalam kategori Kuliner."
  ],
  [
    "Jika Bakmi Jawa Mbah Gito muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Sejarah, karena fokusnya bukan pada kuliner",
      "Kuliner, karena daya tariknya selaras dengan tema itu",
      "Budaya, karena lebih cocok untuk tema lain",
      "Alam, karena tidak terkait konteks kuliner"
    ],
    1,
    "Kuliner",
    "Bakmi Jawa Mbah Gito paling mudah dipahami dalam kategori Kuliner."
  ],
  [
    "Jika Soto Bathok Mbah Katro muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Budaya, karena lebih cocok untuk tema lain",
      "Sejarah, karena fokusnya bukan pada kuliner",
      "Kuliner, karena daya tariknya selaras dengan tema itu",
      "Alam, karena tidak terkait konteks kuliner"
    ],
    2,
    "Kuliner",
    "Soto Bathok Mbah Katro paling mudah dipahami dalam kategori Kuliner."
  ],
  [
    "Jika Candi Prambanan muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Kuliner, karena fokusnya bukan pada sejarah",
      "Sejarah, karena daya tariknya selaras dengan tema itu",
      "Budaya, karena lebih cocok untuk tema lain",
      "Alam, karena tidak terkait konteks sejarah"
    ],
    1,
    "Sejarah",
    "Candi Prambanan paling mudah dipahami dalam kategori Sejarah."
  ],
  [
    "Jika Ratu Boko muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Budaya, karena lebih cocok untuk tema lain",
      "Kuliner, karena fokusnya bukan pada sejarah",
      "Sejarah, karena daya tariknya selaras dengan tema itu",
      "Alam, karena tidak terkait konteks sejarah"
    ],
    2,
    "Sejarah",
    "Ratu Boko paling mudah dipahami dalam kategori Sejarah."
  ],
  [
    "Jika Candi Sambisari muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Alam, karena tidak terkait konteks sejarah",
      "Kuliner, karena fokusnya bukan pada sejarah",
      "Budaya, karena lebih cocok untuk tema lain",
      "Sejarah, karena daya tariknya selaras dengan tema itu"
    ],
    3,
    "Sejarah",
    "Candi Sambisari paling mudah dipahami dalam kategori Sejarah."
  ],
  [
    "Jika Vredeburg muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Sejarah, karena daya tariknya selaras dengan tema itu",
      "Kuliner, karena fokusnya bukan pada sejarah",
      "Budaya, karena lebih cocok untuk tema lain",
      "Alam, karena tidak terkait konteks sejarah"
    ],
    0,
    "Sejarah",
    "Vredeburg paling mudah dipahami dalam kategori Sejarah."
  ],
  [
    "Jika Kotagede muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Kuliner, karena fokusnya bukan pada sejarah",
      "Sejarah, karena daya tariknya selaras dengan tema itu",
      "Budaya, karena lebih cocok untuk tema lain",
      "Alam, karena tidak terkait konteks sejarah"
    ],
    1,
    "Sejarah",
    "Kotagede paling mudah dipahami dalam kategori Sejarah."
  ],
  [
    "Jika Gedung Agung muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Budaya, karena lebih cocok untuk tema lain",
      "Kuliner, karena fokusnya bukan pada sejarah",
      "Sejarah, karena daya tariknya selaras dengan tema itu",
      "Alam, karena tidak terkait konteks sejarah"
    ],
    2,
    "Sejarah",
    "Gedung Agung paling mudah dipahami dalam kategori Sejarah."
  ],
  [
    "Jika Taman Sari muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Alam, karena tidak terkait konteks sejarah",
      "Kuliner, karena fokusnya bukan pada sejarah",
      "Budaya, karena lebih cocok untuk tema lain",
      "Sejarah, karena daya tariknya selaras dengan tema itu"
    ],
    3,
    "Sejarah",
    "Taman Sari paling mudah dipahami dalam kategori Sejarah."
  ],
  [
    "Jika Keraton Yogyakarta muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Sejarah, karena lebih cocok untuk tema lain",
      "Kuliner, karena fokusnya bukan pada budaya",
      "Budaya, karena daya tariknya selaras dengan tema itu",
      "Alam, karena tidak terkait konteks budaya"
    ],
    2,
    "Budaya",
    "Keraton Yogyakarta paling mudah dipahami dalam kategori Budaya."
  ],
  [
    "Jika Sonobudoyo muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Alam, karena tidak terkait konteks budaya",
      "Kuliner, karena fokusnya bukan pada budaya",
      "Sejarah, karena lebih cocok untuk tema lain",
      "Budaya, karena daya tariknya selaras dengan tema itu"
    ],
    3,
    "Budaya",
    "Sonobudoyo paling mudah dipahami dalam kategori Budaya."
  ],
  [
    "Jika Ullen Sentalu muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Budaya, karena daya tariknya selaras dengan tema itu",
      "Kuliner, karena fokusnya bukan pada budaya",
      "Sejarah, karena lebih cocok untuk tema lain",
      "Alam, karena tidak terkait konteks budaya"
    ],
    0,
    "Budaya",
    "Ullen Sentalu paling mudah dipahami dalam kategori Budaya."
  ],
  [
    "Jika Kauman muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Kuliner, karena fokusnya bukan pada budaya",
      "Budaya, karena daya tariknya selaras dengan tema itu",
      "Sejarah, karena lebih cocok untuk tema lain",
      "Alam, karena tidak terkait konteks budaya"
    ],
    1,
    "Budaya",
    "Kauman paling mudah dipahami dalam kategori Budaya."
  ],
  [
    "Jika Tembi muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Sejarah, karena lebih cocok untuk tema lain",
      "Kuliner, karena fokusnya bukan pada budaya",
      "Budaya, karena daya tariknya selaras dengan tema itu",
      "Alam, karena tidak terkait konteks budaya"
    ],
    2,
    "Budaya",
    "Tembi paling mudah dipahami dalam kategori Budaya."
  ],
  [
    "Jika Pentingsari muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Alam, karena tidak terkait konteks budaya",
      "Kuliner, karena fokusnya bukan pada budaya",
      "Sejarah, karena lebih cocok untuk tema lain",
      "Budaya, karena daya tariknya selaras dengan tema itu"
    ],
    3,
    "Budaya",
    "Pentingsari paling mudah dipahami dalam kategori Budaya."
  ],
  [
    "Jika Sekaten muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Budaya, karena daya tariknya selaras dengan tema itu",
      "Kuliner, karena fokusnya bukan pada budaya",
      "Sejarah, karena lebih cocok untuk tema lain",
      "Alam, karena tidak terkait konteks budaya"
    ],
    0,
    "Budaya",
    "Sekaten paling mudah dipahami dalam kategori Budaya."
  ],
  [
    "Jika Parangtritis muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Budaya, karena tidak terkait konteks alam",
      "Kuliner, karena fokusnya bukan pada alam",
      "Sejarah, karena lebih cocok untuk tema lain",
      "Alam, karena daya tariknya selaras dengan tema itu"
    ],
    3,
    "Alam",
    "Parangtritis paling mudah dipahami dalam kategori Alam."
  ],
  [
    "Jika Gumuk Pasir muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Alam, karena daya tariknya selaras dengan tema itu",
      "Kuliner, karena fokusnya bukan pada alam",
      "Sejarah, karena lebih cocok untuk tema lain",
      "Budaya, karena tidak terkait konteks alam"
    ],
    0,
    "Alam",
    "Gumuk Pasir paling mudah dipahami dalam kategori Alam."
  ],
  [
    "Jika Kalibiru muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Kuliner, karena fokusnya bukan pada alam",
      "Alam, karena daya tariknya selaras dengan tema itu",
      "Sejarah, karena lebih cocok untuk tema lain",
      "Budaya, karena tidak terkait konteks alam"
    ],
    1,
    "Alam",
    "Kalibiru paling mudah dipahami dalam kategori Alam."
  ],
  [
    "Jika Hutan Pinus Mangunan muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Sejarah, karena lebih cocok untuk tema lain",
      "Kuliner, karena fokusnya bukan pada alam",
      "Alam, karena daya tariknya selaras dengan tema itu",
      "Budaya, karena tidak terkait konteks alam"
    ],
    2,
    "Alam",
    "Hutan Pinus Mangunan paling mudah dipahami dalam kategori Alam."
  ],
  [
    "Jika Bukit Bintang muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Budaya, karena tidak terkait konteks alam",
      "Kuliner, karena fokusnya bukan pada alam",
      "Sejarah, karena lebih cocok untuk tema lain",
      "Alam, karena daya tariknya selaras dengan tema itu"
    ],
    3,
    "Alam",
    "Bukit Bintang paling mudah dipahami dalam kategori Alam."
  ],
  [
    "Jika Tebing Breksi muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Alam, karena daya tariknya selaras dengan tema itu",
      "Kuliner, karena fokusnya bukan pada alam",
      "Sejarah, karena lebih cocok untuk tema lain",
      "Budaya, karena tidak terkait konteks alam"
    ],
    0,
    "Alam",
    "Tebing Breksi paling mudah dipahami dalam kategori Alam."
  ],
  [
    "Jika Candi Ijo muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Kuliner, karena fokusnya bukan pada alam",
      "Alam, karena daya tariknya selaras dengan tema itu",
      "Sejarah, karena lebih cocok untuk tema lain",
      "Budaya, karena tidak terkait konteks alam"
    ],
    1,
    "Alam",
    "Candi Ijo paling mudah dipahami dalam kategori Alam."
  ],
  [
    "Jika Museum Affandi muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Seni, karena daya tariknya selaras dengan tema itu",
      "Kuliner, karena fokusnya bukan pada seni",
      "Sejarah, karena lebih cocok untuk tema lain",
      "Budaya, karena tidak terkait konteks seni"
    ],
    0,
    "Seni",
    "Museum Affandi paling mudah dipahami dalam kategori Seni."
  ],
  [
    "Jika Sendratari Ramayana muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Kuliner, karena fokusnya bukan pada seni",
      "Seni, karena daya tariknya selaras dengan tema itu",
      "Sejarah, karena lebih cocok untuk tema lain",
      "Budaya, karena tidak terkait konteks seni"
    ],
    1,
    "Seni",
    "Sendratari Ramayana paling mudah dipahami dalam kategori Seni."
  ],
  [
    "Jika Wayang Kulit muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Sejarah, karena lebih cocok untuk tema lain",
      "Kuliner, karena fokusnya bukan pada seni",
      "Seni, karena daya tariknya selaras dengan tema itu",
      "Budaya, karena tidak terkait konteks seni"
    ],
    2,
    "Seni",
    "Wayang Kulit paling mudah dipahami dalam kategori Seni."
  ],
  [
    "Jika Gamelan muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Budaya, karena tidak terkait konteks seni",
      "Kuliner, karena fokusnya bukan pada seni",
      "Sejarah, karena lebih cocok untuk tema lain",
      "Seni, karena daya tariknya selaras dengan tema itu"
    ],
    3,
    "Seni",
    "Gamelan paling mudah dipahami dalam kategori Seni."
  ],
  [
    "Jika Batik Parang muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Seni, karena daya tariknya selaras dengan tema itu",
      "Kuliner, karena fokusnya bukan pada seni",
      "Sejarah, karena lebih cocok untuk tema lain",
      "Budaya, karena tidak terkait konteks seni"
    ],
    0,
    "Seni",
    "Batik Parang paling mudah dipahami dalam kategori Seni."
  ],
  [
    "Jika Kasongan muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Kuliner, karena fokusnya bukan pada seni",
      "Seni, karena daya tariknya selaras dengan tema itu",
      "Sejarah, karena lebih cocok untuk tema lain",
      "Budaya, karena tidak terkait konteks seni"
    ],
    1,
    "Seni",
    "Kasongan paling mudah dipahami dalam kategori Seni."
  ],
  [
    "Jika Krebet muncul di aplikasi, tema apa yang paling cocok ditonjolkan?",
    [
      "Sejarah, karena lebih cocok untuk tema lain",
      "Kuliner, karena fokusnya bukan pada seni",
      "Seni, karena daya tariknya selaras dengan tema itu",
      "Budaya, karena tidak terkait konteks seni"
    ],
    2,
    "Seni",
    "Krebet paling mudah dipahami dalam kategori Seni."
  ],
  [
    "Apa simpulan paling tepat tentang Keraton Yogyakarta dalam konteks wisata Jogja?",
    [
      "Keraton Yogyakarta lebih tepat disebut area industri",
      "Keraton Yogyakarta terkait kuat dengan tema Budaya",
      "Keraton Yogyakarta biasanya menjadi pelabuhan utama",
      "Keraton Yogyakarta dikenal sebagai pusat tambang"
    ],
    1,
    "Budaya",
    "Keraton Yogyakarta menjadi pusat budaya dan tradisi Kesultanan."
  ],
  [
    "Apa simpulan paling tepat tentang Taman Sari dalam konteks wisata Jogja?",
    [
      "Taman Sari biasanya menjadi pelabuhan utama",
      "Taman Sari lebih tepat disebut area industri",
      "Taman Sari terkait kuat dengan tema Sejarah",
      "Taman Sari dikenal sebagai pusat tambang"
    ],
    2,
    "Sejarah",
    "Taman Sari berkaitan dengan kompleks istirahat dan pertahanan Keraton."
  ],
  [
    "Apa simpulan paling tepat tentang Malioboro dalam konteks wisata Jogja?",
    [
      "Malioboro dikenal sebagai pusat tambang",
      "Malioboro lebih tepat disebut area industri",
      "Malioboro biasanya menjadi pelabuhan utama",
      "Malioboro terkait kuat dengan tema Ikonik"
    ],
    3,
    "Ikonik",
    "Malioboro dikenal sebagai koridor wisata kota yang ikonik."
  ],
  [
    "Apa simpulan paling tepat tentang Tugu Yogyakarta dalam konteks wisata Jogja?",
    [
      "Tugu Yogyakarta terkait kuat dengan tema Ikonik",
      "Tugu Yogyakarta lebih tepat disebut area industri",
      "Tugu Yogyakarta biasanya menjadi pelabuhan utama",
      "Tugu Yogyakarta dikenal sebagai pusat tambang"
    ],
    0,
    "Ikonik",
    "Tugu Yogyakarta berkaitan dengan filosofi tata ruang Jogja."
  ],
  [
    "Apa simpulan paling tepat tentang Kotagede dalam konteks wisata Jogja?",
    [
      "Kotagede lebih tepat disebut area industri",
      "Kotagede terkait kuat dengan tema Sejarah",
      "Kotagede biasanya menjadi pelabuhan utama",
      "Kotagede dikenal sebagai pusat tambang"
    ],
    1,
    "Sejarah",
    "Kotagede dikenal sebagai kawasan Mataram Islam dan perak."
  ]
];

module.exports = {
  destinations,
  quizQuestions,
};
