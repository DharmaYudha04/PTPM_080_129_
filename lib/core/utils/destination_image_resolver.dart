import '../../shared/models/destination.dart';

abstract final class DestinationImageResolver {
  static const String assetBasePath = 'assets/images/destinations/';

  static const Map<String, String> _assetByKey = {
    'alunalunkidul': 'alunalunkidul.jpg',
    'alunalunutara': 'alunalunutara.jpeg',
    'angkringanlikman': 'angkringanlikman.jpg',
    'bakmiepele': 'bakmie pele.jpeg',
    'bakmijawambahgito': 'bakmijawambahgito.jpg',
    'bakmikadin': 'bakmikadin.jpg',
    'bakmipele': 'bakmie pele.jpeg',
    'bakpiapathok25': 'bakpiapathok25.jpg',
    'bentengvredeburg': 'bentengvredeburg.jpg',
    'brongkoshandayani': 'brongkoshandayani.jpg',
    'bukitbintang': 'bukitbintang.jpg',
    'candiijo': 'candiijo.jpg',
    'candiplaosan': 'candiplaosan.jpg',
    'candiprambanan': 'candiprambanan.jpg',
    'candiratuboko': 'candiratuboko.jpg',
    'candisambisari': 'candisambisari.jpg',
    'desawisatabrayut': 'desawisatabrayut.jpg',
    'desawisatakasongan': 'desawisatakasongan.jpg',
    'desawisatakrebet': 'desawisatakrebet.jpg',
    'desawisatamanding': 'desawisatamanding.jpg',
    'desawisatapentingsari': 'desawisatapentingsari.jpg',
    'desawisatatembi': 'desawisatatembi.jpg',
    'embungnglanggeran': 'embungnglanggeran.jpg',
    'esbuahpk': 'esbuahpk.jpg',
    'gedungagungjogja': 'gedungagungjogja.jpg',
    'gembiraloka': 'gembiraloka.jpg',
    'geplakbantul': 'geplakbantul.jpg',
    'goapindul': 'goapindul.jpg',
    'guapindul': 'goapindul.jpg',
    'gudegpawon': 'gudegpawon.jpeg',
    'gudegpermata': 'gudegpermata.jpg',
    'gudegsagan': 'gudeg sagan.jpeg',
    'gudegyudjum': 'gudegyudjum.jpg',
    'gumukpasirparangkusumo': 'gumukpasirparangkusumo.jpg',
    'gunungapipurbanglanggeran': 'gunungapipurbanglanggeran.jpg',
    'hehaoceanview': 'hehaoceanview.jpg',
    'hehaskyview': 'hehaskyview.jpg',
    'houseoframinten': 'houseoframinten.jpg',
    'hutanpinusmangunan': 'hutanpinusmangunan.jpg',
    'ingkungkuali': 'Ingkungkuali.jpg',
    'jalanprawirotaman': 'jalanprawirotaman.jpg',
    'jalansosrowijayan': 'jalansosrowijayan.jpg',
    'jalanwijilan': 'jalanwijilan.jpg',
    'jejamuran': 'jejamuran.jpg',
    'jogjanationalmuseum': 'jogjanationalmuseum.jpg',
    'jurangtembelan': 'jurangtembelan.jpg',
    'kalibiru': 'kalibiru.jpg',
    'kalisucicavetubing': 'kalisucicavetubing.jpg',
    'kaliurang': 'kaliurang.jpg',
    'kampungkauman': 'KampungKauman.jpg',
    'kampungwisatadipowinatan': 'kampungwisatadipowinatan.jpeg',
    'kampungwisatatamansari': 'kampungwisatatamansari.jpg',
    'kebunbuahmangunan': 'kebunbuahmangunan.jpg',
    'kedairakyatdjelata': 'kedairakyatdjelata.jpg',
    'keraton': 'keraton.jpg',
    'keratonjogja': 'keraton.jpg',
    'keratonyogyakarta': 'keraton.jpg',
    'kopiklotok': 'kopi klotok.jpg',
    'kotagede': 'kotagede.jpg',
    'kratonresto': 'kratonresto.jpg',
    'lavatourmerapi': 'lavatourmerapi.jpg',
    'lotekteteg': 'lotekteteg.jpg',
    'malioboro': 'malioboro.jpg',
    'mangutlelembahmarto': 'mangutlelembahmarto.jfif',
    'masjidgedhekauman': 'MasjidGedheKauman.jpg',
    'merapipark': 'merapipark.jpg',
    'mielethekmbahmendes': 'mielethekmbahmendes.jpg',
    'museumaffandi': 'museumaffandi.jpg',
    'museumbentengvredeburg': 'bentengvredeburg.jpg',
    'museumdirgantara': 'museumdirgantara.jpg',
    'museumdirgantaramandala': 'museumdirgantara.jpg',
    'museumsonobudoyo': 'museumsonobudoyo.jpg',
    'museumullensentalu': 'museumullensentanu.jpg',
    'museumullensentanu': 'museumullensentanu.jpg',
    'museumwayangkekayon': 'museumwayangkekayon.jpg',
    'nasiterigejayan': 'nasiterigejayan.jpg',
    'obelixhills': 'obellixhills.jpg',
    'obellixhills': 'obellixhills.jpg',
    'osengmerconbunarti': 'oseng mercon bu narti.jpg',
    'padepokansenibagongkussu': 'padepokansenibagongkussu.jpg',
    'pantaidepok': 'pantaidepok.jpg',
    'pantaiindrayanti': 'pantaiindrayanti.jpg',
    'pantaingobaran': 'pantaingobaran.jpg',
    'pantaingrenehan': 'pantaingrenehan.jpeg',
    'pantaiparangtritis': 'pantaiparangtritis.jpg',
    'pantaipoktunggal': 'pantaipoktunggal.jpg',
    'pantaisadranan': 'pantaisadranan.jpg',
    'pantaitimang': 'pantaitimang.jpg',
    'pantaiwediombo': 'pantaiwediombo.jpg',
    'pasarberingharjo': 'pasarberingharjo.jpg',
    'pasarkotagede': 'pasarkotagede.jpg',
    'pasarsentul': 'pasarsentul.jpg',
    'pecelsenggolberingharjo': 'pecelsenggolberingharjo.jpg',
    'prawirotamanstreetfood': 'prawirotamanstreet food.jpg',
    'pulepayung': 'pulepayung.jpg',
    'puncakbecici': 'puncakbecici.jpg',
    'ratu boko': 'candiratuboko.jpg',
    'ratuboko': 'candiratuboko.jpg',
    'sateklathakpakbari': 'sateklathakpakbari.jpg',
    'sateklathakpakpong': 'sateklathakpakpong.jpg',
    'sateratu': 'sateratu.jpg',
    'segokoyorbuparman': 'segokoyorbuparman.jpg',
    'sendratariprambanan': 'sendratariprambanan.jpg',
    'sendratariramayanaprambanan': 'sendratariprambanan.jpg',
    'seribubatu': 'seribubatu.jpg',
    'seribubatusonggolangit': 'seribubatu.jpg',
    'sgpcbuwiryo': 'sgpcbuwiryo.jpg',
    'sindukusuma': 'sindukusuma.jpg',
    'sotobathokmbahkatro': 'sotobathokmbahkatro.jpg',
    'sotokadipiro': 'sotokadipiro.jpg',
    'tamanpelangimonjali': 'taman pelangi monjali.jpg',
    'tamanpintaryogyakarta': 'tamanpintaryogyakarta.jpg',
    'tamansari': 'tamansari.jpg',
    'tebingbreksi': 'tebingpreksi.jpg',
    'tebingpreksi': 'tebingpreksi.jpg',
    'tempogelatoprawirotaman': 'tempogelatoprawirotaman.jpg',
    'thelostworldcastle': 'thelostworldcastle.jpg',
    'titiknol': 'titiknol.jpg',
    'titiknolkilometeryogyakarta': 'titiknol.jpg',
    'tugu': 'tugu.jpg',
    'tuguyogyakarta': 'tugu.jpg',
    'waduksermo': 'waduksermo.jpg',
    'warungbuageng': 'warungbuageng.jpeg',
    'warungklangenan': 'warungklangenan.jpg',
    'wedangrondembahpayem': 'wedangrondembahpayem.jpg',
    'yangkopakprapto': 'yangkopakprapto.jpg',
  };

  static String resolve(DestinationModel destination) {
    final explicit = destination.imageUrl.trim();
    if (isNetwork(explicit)) return explicit;

    // Kalau backend sudah mengirim path asset, pakai hanya bila file-nya ada di daftar asset.
    // Jika tidak cocok, lanjut cari dari nama/slug/tag supaya foto lokal baru tetap muncul.
    if (isAsset(explicit)) {
      final fileName = explicit.split('/').last;
      final byFile = _assetByKey[_normalize(fileName)];
      if (byFile != null) return '$assetBasePath$byFile';
    }

    for (final value in <String>[
      destination.slug,
      destination.name,
      ...destination.tags,
      destination.category,
    ]) {
      final fromValue = _assetByKey[_normalize(value)];
      if (fromValue != null) return '$assetBasePath$fromValue';
    }

    return explicit.isNotEmpty ? explicit : '';
  }

  static bool isAsset(String value) => value.trim().startsWith('assets/');

  static bool isNetwork(String value) {
    final cleaned = value.trim().toLowerCase();
    return cleaned.startsWith('http://') || cleaned.startsWith('https://');
  }

  static String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
