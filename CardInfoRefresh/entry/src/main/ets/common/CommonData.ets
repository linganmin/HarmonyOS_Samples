/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { CommonConstants } from './CommonConstants';

export class CommonData {
  static flag: number = 0;

  static getData(index: number): Array<CardListItemData> {
    CommonData.flag = index % 3;
    if (CommonData.flag === 0) {
      return CommonConstants.CARD_LIST_DATA_FIRST;
    } else if (CommonData.flag === 1) {
      return CommonConstants.CARD_LIST_DATA_SECOND;
    } else {
      return CommonConstants.CARD_LIST_DATA_THIRD;
    }
  }
}

export interface CardListItemData {
  id: number;
  title: ResourceStr;
  content: ResourceStr;
  icon: Resource;
  favour: boolean;
  bgImage: Resource;
}
// [Start form_data]
export class FormData {
  formId: string = '';
  formTime: string = '';
  isFavor?: boolean = false;
  index?: number = 0;
  cardList: Array<CardListItemData> = [];

  constructor(formId: string) {
    this.formId = formId;
  }
}
// [End form_data]