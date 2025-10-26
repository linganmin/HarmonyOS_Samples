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

import ContentItemModel from "../model/ContentItemModel";

@Observed
export default class ContentItemViewModel {
  username: string | Resource = '';
  publishTime: string | Resource = '';
  rawTitle: string | Resource = '';
  title: string | Resource = '';
  imgUrl1: string | Resource = '';
  imgUrl2: string | Resource = '';
  imgUrl3: string | Resource = '';
  imgUrl4: string | Resource = '';

  updateContentItem(contentItemModel: ContentItemModel) {
    this.username = contentItemModel.username;
    this.publishTime = contentItemModel.publishTime;
    this.rawTitle = contentItemModel.rawTitle;
    this.title = contentItemModel.title;
    this.imgUrl1 = contentItemModel.imgUrl1;
    this.imgUrl2 = contentItemModel.imgUrl2;
    this.imgUrl3 = contentItemModel.imgUrl3;
    this.imgUrl4 = contentItemModel.imgUrl4;
  }
}