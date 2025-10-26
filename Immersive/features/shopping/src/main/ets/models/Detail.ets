/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

import { FAQ_DATA } from '../constants/Detail';

export interface Faq {
  question: ResourceStr
  answer: ResourceStr
  likeCount?: number
}

export function getFaqQuestions() {
  return FAQ_DATA.slice(0, 3).map(faq => faq.question);
}

export function getFaqData() {
  return FAQ_DATA.map(faq => {
    const newFaq: Faq = {
      question: faq.question,
      answer: faq.answer,
      likeCount: Math.floor(Math.random() * 99)
    }
    return newFaq;
  });
}