function scoreAnswer(isCorrect, timeTakenSeconds) {
  if (!isCorrect) return 0;
  const t = Math.max(0, Number(timeTakenSeconds || 0));
  return 100 + Math.max(0, 50 - Math.floor(t));
}
module.exports = { scoreAnswer };
