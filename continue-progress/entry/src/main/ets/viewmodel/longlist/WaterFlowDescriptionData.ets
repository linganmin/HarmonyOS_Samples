/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export class WaterFlowDescriptionData {
  public title: string;
  public titleEn: string;
  public userImage: string;
  public vipSign: string;
  public userName: string;
  public collectionsCount: number;
  public url: string;
  public index: number;

  constructor(title: string, titleEn: string, userImage: string, vipSign: string, userName: string,
    collectionsCount: number, url: string, index: number) {
    this.title = title;
    this.titleEn = titleEn;
    this.userImage = userImage;
    this.vipSign = vipSign;
    this.userName = userName;
    this.collectionsCount = collectionsCount;
    this.url = url;
    this.index = index;
  }
}