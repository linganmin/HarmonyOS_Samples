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

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import ContentItemModel from './ContentItemModel';
import StringUtil from '../common/utils/StringUtil';

export default class InTabsModel {
  contentItems: ContentItemModel[] = [];

  async loadContentItems(ctx: Context) {
    let filename = '';
    try {
      filename = await ctx.resourceManager.getStringValue($r('app.string.default_content_items_file').id);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'InTabsModel', `getStringValue failed, error code=${err.code}, message=${err.message}`);
    }

    let res = await StringUtil.getStringFromRawFile(ctx, filename);

    this.contentItems = JSON.parse(res).map((item: ContentItemModel) => {

      let img1 = item.imgUrl1 as string;
      if (img1.indexOf('app.media') === 0) {
        item.imgUrl1 = $r(img1);
      }

      let img2 = item.imgUrl2 as string;
      if (img2.indexOf('app.media') === 0) {
        item.imgUrl2 = $r(img2);
      }

      let img3 = item.imgUrl3 as string;
      if (img3.indexOf('app.media') === 0) {
        item.imgUrl3 = $r(img3);
      }

      let img4 = item.imgUrl4 as string;
      if (img4.indexOf('app.media') === 0) {
        item.imgUrl4 = $r(img4);
      }

      return item;
    });
  }
}
