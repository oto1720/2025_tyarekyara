/**
 * トピック重複検出サービス（高度な類似度アルゴリズム）
 */

import * as logger from "firebase-functions/logger";

/**
 * 文字列の類似度を計算（レーベンシュタイン距離ベース）
 * @param {string} str1 文字列1
 * @param {string} str2 文字列2
 * @return {number} 類似度（0-1の範囲）
 */
function levenshteinSimilarity(str1: string, str2: string): number {
  const len1 = str1.length;
  const len2 = str2.length;
  const matrix: number[][] = [];

  for (let i = 0; i <= len1; i++) {
    matrix[i] = [i];
  }

  for (let j = 0; j <= len2; j++) {
    matrix[0][j] = j;
  }

  for (let i = 1; i <= len1; i++) {
    for (let j = 1; j <= len2; j++) {
      const cost = str1[i - 1] === str2[j - 1] ? 0 : 1;
      matrix[i][j] = Math.min(
        matrix[i - 1][j] + 1, // 削除
        matrix[i][j - 1] + 1, // 挿入
        matrix[i - 1][j - 1] + cost // 置換
      );
    }
  }

  const distance = matrix[len1][len2];
  const maxLength = Math.max(len1, len2);
  return 1 - distance / maxLength;
}

/**
 * Jaccard係数を計算（単語の集合ベース）
 * @param {string} str1 文字列1
 * @param {string} str2 文字列2
 * @return {number} Jaccard係数（0-1の範囲）
 */
function jaccardSimilarity(str1: string, str2: string): number {
  const words1 = new Set(str1.toLowerCase().split(/\s+/));
  const words2 = new Set(str2.toLowerCase().split(/\s+/));

  const intersection = new Set(
    [...words1].filter((word) => words2.has(word))
  );
  const union = new Set([...words1, ...words2]);

  if (union.size === 0) return 0;
  return intersection.size / union.size;
}

/**
 * N-gram類似度を計算（文字レベルのN-gram）
 * @param {string} str1 文字列1
 * @param {string} str2 文字列2
 * @param {number} n N-gramのサイズ
 * @return {number} N-gram類似度（0-1の範囲）
 */
function ngramSimilarity(str1: string, str2: string, n = 2): number {
  const getNgrams = (text: string): Set<string> => {
    const ngrams = new Set<string>();
    for (let i = 0; i <= text.length - n; i++) {
      ngrams.add(text.substring(i, i + n));
    }
    return ngrams;
  };

  const ngrams1 = getNgrams(str1);
  const ngrams2 = getNgrams(str2);

  const intersection = new Set(
    [...ngrams1].filter((ngram) => ngrams2.has(ngram))
  );
  const union = new Set([...ngrams1, ...ngrams2]);

  if (union.size === 0) return 0;
  return intersection.size / union.size;
}

/**
 * コサイン類似度を計算（TF-IDFベース）
 * @param {string} str1 文字列1
 * @param {string} str2 文字列2
 * @return {number} コサイン類似度（0-1の範囲）
 */
function cosineSimilarity(str1: string, str2: string): number {
  const getWordFrequency = (text: string): Map<string, number> => {
    const words = text.toLowerCase().split(/\s+/);
    const frequency = new Map<string, number>();
    for (const word of words) {
      frequency.set(word, (frequency.get(word) || 0) + 1);
    }
    return frequency;
  };

  const freq1 = getWordFrequency(str1);
  const freq2 = getWordFrequency(str2);

  const allWords = new Set([...freq1.keys(), ...freq2.keys()]);

  let dotProduct = 0;
  let magnitude1 = 0;
  let magnitude2 = 0;

  for (const word of allWords) {
    const val1 = freq1.get(word) || 0;
    const val2 = freq2.get(word) || 0;

    dotProduct += val1 * val2;
    magnitude1 += val1 * val1;
    magnitude2 += val2 * val2;
  }

  if (magnitude1 === 0 || magnitude2 === 0) return 0;

  return dotProduct / (Math.sqrt(magnitude1) * Math.sqrt(magnitude2));
}

/**
 * 意味的類似度を計算（キーワード抽出ベース）
 * @param {string} str1 文字列1
 * @param {string} str2 文字列2
 * @return {number} 意味的類似度（0-1の範囲）
 */
function semanticSimilarity(str1: string, str2: string): number {
  // 日本語の重要キーワード（助詞などを除外）
  const stopWords = new Set([
    "は", "が", "を", "に", "へ", "と", "から", "まで", "より",
    "で", "や", "の", "か", "も", "ない", "です", "ます", "だ",
    "である", "する", "いる", "ある", "なる", "れる", "られる",
  ]);

  const extractKeywords = (text: string): Set<string> => {
    const words = text
      .toLowerCase()
      .split(/[\s、。！？「」]/g)
      .filter((w) => w.length > 1 && !stopWords.has(w));
    return new Set(words);
  };

  const keywords1 = extractKeywords(str1);
  const keywords2 = extractKeywords(str2);

  const intersection = new Set(
    [...keywords1].filter((kw) => keywords2.has(kw))
  );
  const union = new Set([...keywords1, ...keywords2]);

  if (union.size === 0) return 0;
  return intersection.size / union.size;
}

/**
 * 複合類似度を計算（複数のアルゴリズムを組み合わせ）
 * @param {string} str1 文字列1
 * @param {string} str2 文字列2
 * @return {object} 各類似度スコアと総合スコア
 */
export function calculateCompositeSimilarity(
  str1: string,
  str2: string
): {
  levenshtein: number;
  jaccard: number;
  ngram: number;
  cosine: number;
  semantic: number;
  composite: number;
} {
  const levenshtein = levenshteinSimilarity(str1, str2);
  const jaccard = jaccardSimilarity(str1, str2);
  const ngram = ngramSimilarity(str1, str2, 2);
  const cosine = cosineSimilarity(str1, str2);
  const semantic = semanticSimilarity(str1, str2);

  // 重み付き平均（調整可能）
  const weights = {
    levenshtein: 0.15, // 文字レベルの類似度
    jaccard: 0.20, // 単語の重複
    ngram: 0.20, // 文字列パターン
    cosine: 0.25, // 単語の頻度
    semantic: 0.20, // 意味的類似度
  };

  const composite =
    levenshtein * weights.levenshtein +
    jaccard * weights.jaccard +
    ngram * weights.ngram +
    cosine * weights.cosine +
    semantic * weights.semantic;

  return {
    levenshtein,
    jaccard,
    ngram,
    cosine,
    semantic,
    composite,
  };
}

/**
 * トピックが重複しているか判定
 * @param {string} newTopic 新しいトピック
 * @param {string} existingTopic 既存のトピック
 * @param {number} threshold 閾値（デフォルト: 0.75）
 * @return {boolean} 重複している場合true
 */
export function isDuplicate(
  newTopic: string,
  existingTopic: string,
  threshold = 0.75
): boolean {
  const similarity = calculateCompositeSimilarity(newTopic, existingTopic);

  logger.info("Similarity check:", {
    newTopic: newTopic.substring(0, 50),
    existingTopic: existingTopic.substring(0, 50),
    scores: similarity,
    isDuplicate: similarity.composite >= threshold,
  });

  return similarity.composite >= threshold;
}

/**
 * トピックリストから重複を検出
 * @param {string} newTopic 新しいトピック
 * @param {string[]} existingTopics 既存のトピックリスト
 * @param {number} threshold 閾値（デフォルト: 0.75）
 * @return {object} 重複情報
 */
export function findDuplicates(
  newTopic: string,
  existingTopics: string[],
  threshold = 0.75
): {
  hasDuplicates: boolean;
  duplicates: Array<{
    topic: string;
    similarity: number;
  }>;
  maxSimilarity: number;
} {
  const duplicates: Array<{topic: string; similarity: number}> = [];
  let maxSimilarity = 0;

  for (const existing of existingTopics) {
    const similarity = calculateCompositeSimilarity(newTopic, existing);
    const score = similarity.composite;

    if (score > maxSimilarity) {
      maxSimilarity = score;
    }

    if (score >= threshold) {
      duplicates.push({
        topic: existing,
        similarity: score,
      });
    }
  }

  return {
    hasDuplicates: duplicates.length > 0,
    duplicates: duplicates.sort((a, b) => b.similarity - a.similarity),
    maxSimilarity,
  };
}
