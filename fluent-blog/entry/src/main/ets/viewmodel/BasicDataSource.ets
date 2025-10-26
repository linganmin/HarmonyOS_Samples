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

import { AVPlayerItem } from '../view/AVPlayerItem';
import ButtonUnitItem from './ButtonUnitItem';
import TitleUnitItem from './TitleUnitItem';
import SampleUnitItem from './SampleUnitItem';
import App from '@system.app';
import { common } from '@kit.AbilityKit';

export class DataSource {
  dataSource: BasicDataSource = new BasicDataSource();

  getData(): BasicDataSource {
    return this.dataSource;
  }

  clear() {
    this.dataSource.data = [];
  }
}

class BasicDataSource implements IDataSource {
  imageArray1: Resource[] = [$r("app.media.b")];
  imageArray3: Resource[] = [$r("app.media.a"), $r("app.media.b"), $r("app.media.c")];
  imageArray4: Resource[] = [$r("app.media.a"), $r("app.media.b"), $r("app.media.c"), $r("app.media.d")];
  imageArray8: Resource[] =
    [$r("app.media.a"), $r("app.media.b"), $r("app.media.c"), $r("app.media.d"), $r("app.media.e"), $r("app.media.f"),
      $r("app.media.g"), $r("app.media.h")];
  imageArray9: Resource[] =
    [$r("app.media.a"), $r("app.media.b"), $r("app.media.c"), $r("app.media.d"), $r("app.media.e"), $r("app.media.f"),
      $r("app.media.g"), $r("app.media.h"), $r("app.media.i")];
  public data: SampleUnitItem[] = [];
  private listeners: DataChangeListener[] = [];

  constructor() {
    let uiContext = AppStorage.get('uiContext') as UIContext
    let buttonUnit: ButtonUnitItem =
      new ButtonUnitItem($r('app.media.share'), 5, $r('app.media.like'), 18, $r('app.media.collect'), 53);
    let areaUnit: TitleUnitItem =
      new TitleUnitItem($r('app.media.avatar'),
        uiContext.getHostContext()!.resourceManager.getStringByNameSync('show_netname'),
        uiContext.getHostContext()!.resourceManager.getStringByNameSync('show_time'),
         );
    let textContext = uiContext.getHostContext()!.resourceManager.getStringByNameSync('show_text');

    let data: SampleUnitItem[] = [
      new SampleUnitItem('video', areaUnit, textContext, buttonUnit, this.imageArray1, new VideoController(),
        new AVPlayerItem()),
      new SampleUnitItem('pic', areaUnit, textContext, buttonUnit, this.imageArray3, new VideoController(),
        new AVPlayerItem()),
      new SampleUnitItem('pic', areaUnit, textContext, buttonUnit, this.imageArray4, new VideoController(),
        new AVPlayerItem()),
      new SampleUnitItem('pic', areaUnit, textContext, buttonUnit, this.imageArray8, new VideoController(),
        new AVPlayerItem()),
      new SampleUnitItem('pic', areaUnit, textContext, buttonUnit, this.imageArray9, new VideoController(),
        new AVPlayerItem()),
      new SampleUnitItem('pic', areaUnit, textContext, buttonUnit, this.imageArray3, new VideoController(),
        new AVPlayerItem()),
      new SampleUnitItem('av', areaUnit, textContext, buttonUnit, this.imageArray1, new VideoController(),
        new AVPlayerItem()),
      new SampleUnitItem('pic', areaUnit, textContext, buttonUnit, this.imageArray1, new VideoController(),
        new AVPlayerItem()),
      new SampleUnitItem('pic', areaUnit, textContext, buttonUnit, this.imageArray3, new VideoController(),
        new AVPlayerItem()),
    ];

    this.data = data;
  }

  totalCount(): number {
    return this.data.length;
  }

  getData(index: number): SampleUnitItem {
    return this.data[index];
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      console.info('add listener');
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      console.info('remove listener');
      this.listeners.splice(pos, 1);
    }
  }
}

export default new DataSource();