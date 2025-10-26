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

import { genResourceArray } from 'commons';
import { Faq } from '../models/Detail';

export const BANNER_IMAGES = [$r('app.media.product_detail_1'),
  $r('app.media.product_detail_2'), $r('app.media.product_detail_2'), $r('app.media.product_detail_2'),
  $r('app.media.product_detail_3')];

export const BANNER_SMALL_IMAGES = [$r('app.media.product_small_1'),
  $r('app.media.product_small_2'), $r('app.media.product_small_2'), $r('app.media.product_small_2'),
  $r('app.media.product_small_3')];

export const FOOTER_IMAGES =
  [$r('app.media.ic_public_home'), $r('app.media.ic_public_comments'), $r('app.media.ic_public_bag')];

export const PRODUCT_LABELS = genResourceArray(3, 'product_labels');

export const FAQ_DATA: Faq[] = Array.from({ length: 12 }, (_: undefined, index) => {
  const faq: Faq = {
    question: $r(`app.string.faq_data_question_${index + 1}`),
    answer: $r(`app.string.faq_data_answer_${index + 1}`)
  };
  return faq;
})