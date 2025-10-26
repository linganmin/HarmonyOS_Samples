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

import { DownLoadComponent } from './DownLoadComponent';
import { DownLoadData } from './model/DownLoadData';
import Logger from '../utils/Logger';

@Component
export struct DownLoadFilePage {
  listData: Array<DownLoadData> = [
    new DownLoadData($r('app.string.spring_story'), 'xxx.spring.xxx'),
    new DownLoadData($r('app.string.summer_story'), 'xxx.summer.xxx'),
    new DownLoadData($r('app.string.autumn_story'), 'xxx.autumn.xxx'),
    new DownLoadData($r('app.string.winter_story'), 'xxx.winter.xxx')
  ];

  getResourceString(resource: Resource): string {
    let resourceString: string = '';
    try {
      resourceString = this.getUIContext().getHostContext()?.resourceManager.getStringSync(resource.id) as string;
    } catch (error) {
      Logger.error('getResourceString err:' + JSON.stringify(error));
    }
    return resourceString;
  }

  build() {
    NavDestination() {
      Column() {
        ForEach(this.listData, (item: DownLoadData) => {
          ListItem() {
            DownLoadComponent({ DownLoadData: item })
          }
          .margin({
            left: $r('app.integer.comm_padding_margin16'),
            right: $r('app.integer.comm_padding_margin16')
          })
        }, (item: DownLoadData) => JSON.stringify(item))
      }
      .margin({
        top: $r('app.integer.comm_padding_margin24')
      })
    }
    .title(this.getResourceString($r('app.string.file_download_list')))
  }
}