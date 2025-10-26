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

import { TabDataModel } from '../model/TabDataModel';
import { hilog } from '@kit.PerformanceAnalysisKit';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context = uiContext!.getHostContext()!;

export class TabViewModel {
  private tabMap: TabDataModel;

  constructor() {
    let tabMap: Map<string, string[]> = new Map();
    try {
      tabMap.set(context.resourceManager.getStringSync($r('app.string.tab_home').id), [
        context.resourceManager.getStringSync($r('app.string.selected').id),
        context.resourceManager.getStringSync($r('app.string.video').id),
        context.resourceManager.getStringSync($r('app.string.community').id),
        context.resourceManager.getStringSync($r('app.string.news').id)
      ]);
      tabMap.set(context.resourceManager.getStringSync($r('app.string.tab_moments').id), []);
      tabMap.set(context.resourceManager.getStringSync($r('app.string.tab_shopping').id), []);
      tabMap.set(context.resourceManager.getStringSync($r('app.string.tab_me').id), []);
    } catch (error) {
      hilog.error(0x0000, 'testTag', 'Failed to get string. Cause: %{public}s', JSON.stringify(error) ?? '');
    }
    this.tabMap = new TabDataModel(tabMap);
  }

  getTabMap(): TabDataModel {
    return this.tabMap;
  }

  getTabNameOfFirstLevel(index: number): string {
    return this.tabMap.getFirstList()[index];
  }

  getTabNameOfSecondLevel(firstTab: string, index: number): string {
    return this.tabMap.getSecondList(firstTab)[index];
  }
}