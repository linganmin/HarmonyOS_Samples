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

export default class CommonConstants {
  /**
   * intent execute event name
   */
  static readonly VIEW_NEWS_EVENT: string = 'viewNewsEvent';
  /**
   * intent execute event name
   */
  static readonly STORAGE_KEY: string = 'INTENT_PARAM_STORAGE_KEY';
  /**
   * route path
   */
  static readonly NEWS_DETAIL_PATH_NAME = "NewsDetail";

  /**
   * en lang
   */
  static readonly LANGUAGE_ENG = 'en-Latn-US';
}

export const enDict: Record<string, string> = {
  "Recd": "推荐",
  "Sports": "体育",
  "Fin": "财经",
  "Tech": "科技",
  "Fiction": "小说"
}