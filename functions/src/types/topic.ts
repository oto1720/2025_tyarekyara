/**
 * トピック関連の型定義
 */

export type TopicCategory = "daily" | "social" | "value";
export type TopicDifficulty = "easy" | "medium" | "hard";
export type TopicSource = "ai" | "manual";

export interface NewsItem {
  title: string;
  summary: string;
  url?: string;
  source?: string;
  publishedAt?: Date;
  imageUrl?: string;
}

export interface Topic {
  id: string;
  text: string;
  category: TopicCategory;
  difficulty: TopicDifficulty;
  createdAt: Date;
  source: TopicSource;
  tags: string[];
  description?: string;
  similarityScore: number;
  relatedNews: NewsItem[];
  feedbackCounts: {
    good?: number;
    normal?: number;
    bad?: number;
  };
  feedbackUsers: { [userId: string]: string };
}

export interface TopicGenerationResult {
  topic: Topic;
  eventId?: string;
}
