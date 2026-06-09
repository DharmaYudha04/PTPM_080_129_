function toRad(value) {
  return (Number(value) * Math.PI) / 180;
}

function distanceKm(aLat, aLng, bLat, bLng) {
  const R = 6371;
  const dLat = toRad(bLat - aLat);
  const dLng = toRad(bLng - aLng);
  const lat1 = toRad(aLat);
  const lat2 = toRad(bLat);
  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.atan2(Math.sqrt(h), Math.sqrt(1 - h));
}

function parseHourRange(openingHours) {
  if (!openingHours) return null;
  const match = String(openingHours).match(/(\d{1,2})[:.]?(\d{2})?\s*[-–]\s*(\d{1,2})[:.]?(\d{2})?/);
  if (!match) return null;
  const start = Number(match[1]) + Number(match[2] || 0) / 60;
  const end = Number(match[3]) + Number(match[4] || 0) / 60;
  return { start, end };
}

function isOpenNow(destination, now = new Date()) {
  const range = parseHourRange(destination.openingHours);
  if (!range) return true;
  const hour = now.getHours() + now.getMinutes() / 60;
  if (range.end < range.start) return hour >= range.start || hour <= range.end;
  return hour >= range.start && hour <= range.end;
}

function normalizeType(value) {
  const text = String(value || '').toUpperCase();
  if (['TOURISM', 'CULINARY', 'CULTURE'].includes(text)) return text;
  if (['WISATA', 'DESTINATION'].includes(text)) return 'TOURISM';
  if (['KULINER', 'FOOD'].includes(text)) return 'CULINARY';
  if (['BUDAYA', 'CULTURAL'].includes(text)) return 'CULTURE';
  return null;
}

function preferenceScore(destination, preferences) {
  if (!preferences) return 0;

  const preferredTypes = (preferences.preferredCategories || [])
    .map(normalizeType)
    .filter(Boolean);
  const preferredMoods = (preferences.preferredMoods || []).map((v) =>
    String(v).toLowerCase(),
  );
  const tags = (destination.tags || []).map((v) => String(v).toLowerCase());

  let score = 0;
  if (preferredTypes.includes(destination.type)) score += 14;
  score += preferredMoods.filter((mood) => tags.includes(mood)).length * 6;
  return score;
}

function buildReason(destination, distance, openNow, alreadyShownCount, preferences) {
  const parts = [];
  parts.push(`${distance.toFixed(1)} km dari lokasimu`);
  if (openNow) parts.push('sedang cocok dikunjungi sekarang');
  if (destination.isFeatured) parts.push('termasuk rekomendasi unggulan');
  if ((preferences?.preferredMoods || []).length > 0) {
    parts.push('sesuai preferensi jelajahmu');
  }
  if (alreadyShownCount === 0) parts.push('belum pernah muncul di rekomendasi hari ini');
  return parts.join(', ') + '.';
}

function scoreDestination(destination, context) {
  const { lat, lng, preferences, shownCounts, now } = context;
  const distance = distanceKm(lat, lng, destination.latitude, destination.longitude);
  const radius = preferences?.recommendationRadiusKm || 25;
  const openNow = isOpenNow(destination, now);
  const alreadyShownCount = shownCounts.get(destination.id) || 0;

  const distanceScore = Math.max(0, 70 - (distance / Math.max(radius, 1)) * 70);
  const ratingScore = Number(destination.rating || 0) * 9;
  const culturalScore = Number(destination.culturalValue || 0) * 3;
  const featuredScore = destination.isFeatured ? 12 : 0;
  const openScore = openNow ? 10 : -12;
  const preference = preferenceScore(destination, preferences);
  const repetitionPenalty = alreadyShownCount * 15;

  const score =
    distanceScore +
    ratingScore +
    culturalScore +
    featuredScore +
    openScore +
    preference -
    repetitionPenalty;

  return {
    ...destination,
    distanceKm: Number(distance.toFixed(2)),
    isOpenNow: openNow,
    recommendationScore: Number(score.toFixed(2)),
    reason: buildReason(destination, distance, openNow, alreadyShownCount, preferences),
  };
}

function rankDestinations(destinations, context) {
  const radius = context.preferences?.recommendationRadiusKm || 25;
  return destinations
    .map((destination) => scoreDestination(destination, context))
    .filter((destination) => destination.distanceKm <= radius || destination.isFeatured)
    .sort((a, b) => b.recommendationScore - a.recommendationScore);
}

module.exports = {
  distanceKm,
  isOpenNow,
  normalizeType,
  rankDestinations,
  scoreDestination,
};
