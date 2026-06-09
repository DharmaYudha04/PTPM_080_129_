const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const slugify = require('slugify');
const { destinations, quizQuestions } = require('./jogjasplorasi_data');

const prisma = new PrismaClient();

function cleanText(value) {
  return String(value || '')
    .replace(/\s+/g, ' ')
    .replace(/\s+([,.!?])/g, '$1')
    .trim();
}

function sentenceCase(value) {
  const text = cleanText(value);
  if (!text) return '';
  return text.charAt(0).toUpperCase() + text.slice(1);
}

function getCategoryLabel(destination) {
  const raw = cleanText(destination.category || destination.type || '').toLowerCase();
  const type = cleanText(destination.type || '').toUpperCase();
  const tags = Array.isArray(destination.tags) ? destination.tags.join(' ').toLowerCase() : '';
  const text = `${raw} ${type.toLowerCase()} ${tags}`;

  if (text.includes('kuliner') || text.includes('culinary') || text.includes('food') || text.includes('coffee') || text.includes('gudeg') || text.includes('bakmi') || text.includes('sate')) return 'kuliner';
  if (text.includes('alam') || text.includes('nature') || text.includes('pantai') || text.includes('beach') || text.includes('goa') || text.includes('bukit') || text.includes('hutan')) return 'alam';
  if (text.includes('sejarah') || text.includes('history') || text.includes('heritage') || text.includes('candi') || text.includes('museum')) return 'sejarah';
  if (text.includes('budaya') || text.includes('culture') || text.includes('keraton') || text.includes('seni') || text.includes('tradisi')) return 'budaya';
  if (text.includes('belanja') || text.includes('shopping') || text.includes('oleh') || text.includes('gift') || text.includes('pasar')) return 'belanja';
  if (text.includes('keluarga') || text.includes('rekreasi') || text.includes('zoo') || text.includes('edukasi')) return 'keluarga';
  if (text.includes('foto') || text.includes('photo') || text.includes('spot')) return 'foto';
  return 'wisata';
}

function getTone(category) {
  switch (category) {
    case 'kuliner':
      return {
        kind: 'tujuan kuliner khas Jogja',
        value: 'rasa, suasana, dan cerita lokal yang membuat pengalaman makan terasa lebih dekat dengan kehidupan warga.',
        tips: 'Datang di luar jam makan utama biasanya membuat kunjungan lebih nyaman. Coba nikmati pelan-pelan, karena daya tarik kuliner Jogja sering muncul dari suasana, cara penyajian, dan obrolan sederhana di tempatnya.',
      };
    case 'alam':
      return {
        kind: 'destinasi alam yang menyegarkan',
        value: 'pemandangan, udara, ritme perjalanan, dan suasana terbuka yang memberi jeda dari keramaian kota.',
        tips: 'Waktu terbaik biasanya pagi atau sore ketika cahaya lebih lembut dan cuaca lebih nyaman. Gunakan alas kaki yang enak dipakai, bawa air minum, dan tetap ikuti arahan keselamatan di area wisata.',
      };
    case 'sejarah':
      return {
        kind: 'tempat bersejarah yang penting untuk memahami Jogja',
        value: 'jejak masa lalu, arsitektur, tokoh, dan peristiwa yang membantu pengunjung membaca Yogyakarta dari sisi yang lebih bermakna.',
        tips: 'Luangkan waktu membaca papan informasi atau bertanya kepada pemandu lokal. Dengan begitu, kunjungan tidak berhenti pada foto saja, tetapi juga memberi cerita yang bisa dibawa pulang.',
      };
    case 'budaya':
      return {
        kind: 'ruang budaya yang memperlihatkan karakter Yogyakarta',
        value: 'tradisi, tata krama, seni, kerajinan, dan kehidupan masyarakat yang membuat Jogja terasa hangat sekaligus berlapis makna.',
        tips: 'Nikmati tempat ini dengan ritme pelan dan sikap sopan. Beberapa area budaya memiliki aturan tertentu, jadi perhatikan papan petunjuk dan hormati aktivitas warga atau pengelola setempat.',
      };
    case 'belanja':
      return {
        kind: 'tempat belanja dan berburu oleh-oleh',
        value: 'produk lokal, interaksi dengan pedagang, serta suasana ramai yang menjadi bagian dari pengalaman wisata Jogja.',
        tips: 'Siapkan waktu untuk melihat-lihat sebelum membeli. Bertanya harga dengan sopan dan membandingkan pilihan akan membuat pengalaman belanja terasa lebih santai dan menyenangkan.',
      };
    case 'keluarga':
      return {
        kind: 'destinasi ramah keluarga',
        value: 'aktivitas ringan, edukasi, ruang santai, dan pengalaman yang mudah dinikmati oleh anak-anak hingga orang tua.',
        tips: 'Datang lebih awal agar tidak terburu-buru dan pilih rute yang nyaman untuk semua anggota keluarga. Pastikan membawa kebutuhan dasar seperti air minum, topi, atau perlengkapan anak bila diperlukan.',
      };
    case 'foto':
      return {
        kind: 'spot visual yang menarik untuk mengabadikan perjalanan',
        value: 'sudut foto, suasana, latar pemandangan, dan momen perjalanan yang membuat kunjungan terasa lebih berkesan.',
        tips: 'Cahaya pagi atau sore biasanya memberi hasil foto yang lebih hangat. Tetap perhatikan keamanan saat mengambil gambar, terutama jika berada di tepi jalan, bukit, pantai, atau area yang ramai.',
      };
    default:
      return {
        kind: 'destinasi menarik di Yogyakarta',
        value: 'suasana, cerita lokal, dan pengalaman khas Jogja yang membuat perjalanan terasa lebih hidup.',
        tips: 'Nikmati kunjungan dengan santai dan sesuaikan waktu perjalanan dengan kondisi cuaca serta kepadatan pengunjung. Jika tersedia, gunakan pemandu atau informasi lokal agar pengalaman lebih lengkap.',
      };
  }
}

function buildDescription(destination) {
  const name = cleanText(destination.name);
  const address = cleanText(destination.address);
  const original = sentenceCase(destination.description || destination.story || destination.localInsight || '');
  const category = getCategoryLabel(destination);
  const tone = getTone(category);

  const opening = original
    ? `${name} adalah ${tone.kind} yang layak masuk daftar jelajah Jogja. ${original} Daya tariknya tidak hanya ada pada apa yang terlihat di depan mata, tetapi juga pada ${tone.value}`
    : `${name} adalah ${tone.kind} yang layak masuk daftar jelajah Jogja. Tempat ini menawarkan ${tone.value} Karena itu, ${name} cocok menjadi pilihan ketika kamu ingin melihat sisi Yogyakarta yang lebih dekat dan berkesan.`;

  const locationPart = address
    ? `Lokasinya berada di ${address}, sehingga bisa kamu jadikan titik singgah dalam rute perjalanan sesuai area terdekat.`
    : 'Lokasinya bisa kamu cek melalui tombol navigasi agar rute perjalanan lebih mudah disesuaikan dengan posisimu.';
  const closing = `${locationPart} ${tone.tips}`;

  return `${opening}\n\n${closing}`;
}

async function seedAdmin() {
  const adminPass = await bcrypt.hash('Admin12345', 12);
  await prisma.user.upsert({
    where: { email: 'admin@jogjasplorasi.local' },
    update: { role: 'ADMIN' },
    create: {
      email: 'admin@jogjasplorasi.local',
      passwordHash: adminPass,
      role: 'ADMIN',
      profile: { create: { fullName: 'JogjaSplorasi Admin' } },
      preferences: { create: {} },
    },
  });
}

async function seedDestinations() {
  for (const destination of destinations) {
    const slug = slugify(destination.name, { lower: true, strict: true });
    const enrichedDescription = buildDescription(destination);
    const data = {
      name: destination.name,
      slug,
      type: destination.type,
      category: destination.category,
      latitude: destination.lat,
      longitude: destination.lng,
      description: enrichedDescription,
      story: destination.story || null,
      localInsight: destination.insight || null,
      address: destination.address,
      imageUrl: destination.imageUrl || null,
      tags: destination.tags || [],
      culturalValue: destination.culturalValue || 3,
      rating: destination.rating || 4.5,
      isFeatured: (destination.culturalValue || 0) >= 4 || (destination.rating || 0) >= 4.7,
      openingHours: destination.openingHours || 'Cek informasi terbaru sebelum berangkat',
      ticketPrice: destination.ticketPrice || 'Cek informasi terbaru di loket/sumber resmi',
      bestTimeToVisit: destination.bestTime || 'Pagi atau sore',
      recommendedDuration: destination.duration || '1-2 jam',
      isActive: true,
      isVerified: true,
    };

    await prisma.destination.upsert({
      where: { slug },
      update: data,
      create: data,
    });
  }
}

async function seedQuiz() {
  await prisma.quizAttemptAnswer.deleteMany();
  await prisma.quizAttemptQuestion.deleteMany();
  await prisma.quizOption.deleteMany();
  await prisma.quizQuestion.deleteMany();

  for (const question of quizQuestions) {
    const [questionText, options, correctIndex, category, explanation] = question;
    await prisma.quizQuestion.create({
      data: {
        questionText,
        category,
        explanation,
        options: {
          create: options.map((optionText, index) => ({
            optionText,
            isCorrect: index === correctIndex,
          })),
        },
      },
    });
  }
}

async function main() {
  await seedAdmin();
  await seedDestinations();
  await seedQuiz();
  console.log(`Seed completed: ${destinations.length} destinations and ${quizQuestions.length} quiz questions.`);
  console.log('Admin: admin@jogjasplorasi.local / Admin12345');
  console.log('Destination descriptions are enriched automatically during seed.');
}

main()
  .catch((error) => {
    console.error(error);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
