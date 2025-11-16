import {VertexAI} from "@google-cloud/vertexai";

// Vertex AI初期化
export const vertexAI = new VertexAI({
  project: process.env.GCLOUD_PROJECT || "tyarekyara-85659",
  location: "asia-northeast1", // 東京リージョン
});

// モデル設定
export const MODEL_CONFIG = {
  model: "gemini-1.5-flash", // 速度重視: gemini-1.5-flash, 精度重視: gemini-1.5-pro
  temperature: 0.7,
  maxOutputTokens: 2048,
  topP: 0.95,
  topK: 40,
};
