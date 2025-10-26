/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { UIAbility } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { http } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { util } from '@kit.ArkTS';
import { DataCache } from '@hadss/datacache';
import { createNWeb } from '../common/utils/Common';
import * as Const from '../common/constant/CommonConstants';
import { ResData } from '../common/types/CommonTypes';

export default class EntryAbility extends UIAbility {
  storage: LocalStorage = new LocalStorage();
  net = http.createHttp();

  onCreate(): void {
    // init web engine
    webview.WebviewController.initializeWebEngine();
    const URL = `${Const.URL}/?filename=${this.context.resourceManager.getStringSync($r('app.string.fileName').id)}`;
    webview.WebviewController.prepareForPageLoad(URL, true, 2);
    this.getCache().then((cache) => {
      if (!cache) {
        const fileName = this.context.resourceManager.getStringSync($r('app.string.fileName').id);
        this.net.request(`${Const.REQUEST_URL}fileName=${fileName}.json&pageNum=1&pageSize=5`).then((data) => {
          const _res: ResData[] = JSON.parse(data.result as string).data;
          this.storage.setOrCreate('List', _res);
          this.setCache(_res);
        }).catch(() => {
          hilog.info(0x0000, 'onCreate', 'http request fail');
          this.storage.setOrCreate('Fail', true);
        })
      }
    })
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    windowStage.loadContent('pages/Index', this.storage, () => {
      AppStorage.setOrCreate('uiContext', windowStage.getMainWindowSync().getUIContext());
      const URL = `${Const.URL}/?filename=${this.context.resourceManager.getStringSync($r('app.string.fileName').id)}`;
      createNWeb(URL, windowStage.getMainWindowSync().getUIContext());
    });
  }

  async getCache(): Promise<ResData[] | undefined> {
    const dataCache: DataCache = DataCache.getInstance(this.context);
    const _list = await dataCache.get<ResData[]>('List');
    if (_list) {
      this.storage.setOrCreate('List', _list);
    }
    return _list;
  }

  async setCache(data: ResData[]) {
    const dataCache = DataCache.getInstance(this.context);
    const _arr: Array<Promise<void>> = [];
    data.forEach(it => {
      it.imagesUrl.forEach(img => {
        _arr.push((async () => {
          const url = await this.net.request(img.url);
          let base64 = new util.Base64Helper();
          let arr = new Uint8Array(url.result as ArrayBuffer);
          let base64str = Const.IMAGE_BASE64_PREFIX + base64.encodeToStringSync(arr);
          img.url = base64str;
        })());
      })
    })
    await Promise.all(_arr);
    // storage time, in seconds, for example, with a validity period of 2 days
    dataCache.put('List', data, 2 * 24 * 60 * 60);
  }
}