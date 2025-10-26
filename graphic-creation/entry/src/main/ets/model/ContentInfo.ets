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
import { commonType } from '@kit.ArkData';

export class ContentInfo {
  public title: string | undefined;
  public description: string | undefined;
  public imageInfoArray: Array<ImageInfo> | undefined;
  public attachments: commonType.Assets | undefined;

  constructor(title: string | undefined, description: string | undefined, imageInfoArray: Array<ImageInfo> | undefined,
    attachments: commonType.Assets | undefined) {
    this.title = title;
    this.description = description;
    this.imageInfoArray = imageInfoArray;
    this.attachments = attachments;
  }

  flatAssets(): object {
    let obj: object = this;
    if (!this.attachments) {
      return obj;
    }
    for (let i = 0; i < this.attachments.length; i++) {
      obj[`attachments${i}`] = this.attachments[i];
    }
    return obj;
  }
}

export interface ImageInfo {
  imagePixelMap: PixelMap;
  imageName: string;
}