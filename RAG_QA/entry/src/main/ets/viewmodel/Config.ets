/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import MyChatLlm from './MyChatLlm'
import { relationalStore } from '@kit.ArkData';
import { rag, retrieval } from '@kit.DataAugmentationKit';
import { common } from '@kit.AbilityKit';

export default class Config {
  // [Start getRetrievalConfig]
  getRetrievalConfig(): retrieval.RetrievalConfig {
    let storeConfigVector: relationalStore.StoreConfig = {
      name: "testmail_store_vector.db", // VectorBase
      securityLevel: relationalStore.SecurityLevel.S3,
      vector: true
    };

    let storeConfigInvIdx: relationalStore.StoreConfig = {
      name: "testmail_store.db", // original db is the inverted index db
      securityLevel: relationalStore.SecurityLevel.S3,
      tokenizer: relationalStore.Tokenizer.CUSTOM_TOKENIZER
    };

    let context = AppStorage.get<common.UIAbilityContext>("Context") as common.UIAbilityContext;
    let channelConfigVector: retrieval.ChannelConfig = {
      channelType: retrieval.ChannelType.VECTOR_DATABASE,
      context: context,
      dbConfig: storeConfigVector
    }
    let channelConfigInvIdx: retrieval.ChannelConfig = {
      channelType: retrieval.ChannelType.INVERTED_INDEX_DATABASE,
      context: context,
      dbConfig: storeConfigInvIdx
    }
    let retrievalConfig: retrieval.RetrievalConfig = {
      channelConfigs: [channelConfigInvIdx, channelConfigVector]
    }
    return retrievalConfig;
  }
  // [End getRetrievalConfig]

  // [Start getRetrivalCondition]
  getRetrivalCondition(): retrieval.RetrievalCondition {
    let recallConditionInvIdx: retrieval.InvertedIndexRecallCondition = {
      ftsTableName: "email_inverted",
      fromClause: "select email_inverted.reference_id as rowid, * from email INNER JOIN email_inverted ON email.id = email_inverted.reference_id",
      primaryKey: ["chunk_id"],
      responseColumns: ["reference_id", "chunk_id", "chunk_source", "chunk_text", "subject", "image_text",
        "attachment_names"],
      deepSize: 500,
      recallName: 'invertedvectorRecall',
    }
    let floatArray = new Float32Array(128).fill(0.1);
    let vectorQuery: retrieval.VectorQuery = {
      column: "repr",
      value: floatArray,
      similarityThreshold: 0.1
    }
    let recallConditionVector: retrieval.VectorRecallCondition = {
      vectorQuery: vectorQuery,
      fromClause: "email_vector",
      primaryKey: ["id"],
      responseColumns: ["reference_id", "chunk_id", "chunk_source", "repr"],
      recallName: "vectorRecall",
      deepSize: 500
    }
    let rerankMethod: retrieval.RerankMethod = {
      rerankType: retrieval.RerankType.RRF,
      isSoftmaxNormalized: true,
    }
    let retrievalCondition: retrieval.RetrievalCondition = {
      rerankMethod: rerankMethod,
      recallConditions: [recallConditionInvIdx, recallConditionVector],
      resultCount: 5
    }
    return retrievalCondition;
  }
  // [End getRetrivalCondition]

  // [Start getRAGConfig]
  getRAGConfig(): rag.Config {
    let retrievalConfig: retrieval.RetrievalConfig = this.getRetrievalConfig();
    let retrievalCondition: retrieval.RetrievalCondition = this.getRetrivalCondition();
    let config: rag.Config = {
      llm: new MyChatLlm(),
      retrievalConfig: retrievalConfig,
      retrievalCondition: retrievalCondition,
    }
    return config;
  }
  // [End getRAGConfig]
}