import {VertexAI} from "@google-cloud/vertexai";

// Vertex AI初期化
export const vertexAI = new VertexAI({
  project: process.env.GCLOUD_PROJECT || "tyarekyara-85659",
  location: "us-central1", // グローバルリージョン
});

// モデル設定
// 速度重視: gemini-1.5-flash, 精度重視: gemini-1.5-pro
export const MODEL_CONFIG = {
  model: "gemini-2.0-flash",
  temperature: 0.7,
  maxOutputTokens: 2048,
  topP: 0.95,
  topK: 40,
};
