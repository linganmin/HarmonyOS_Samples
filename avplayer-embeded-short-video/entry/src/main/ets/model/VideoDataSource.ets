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

import { util } from '@kit.ArkTS';
import { VIDEO_DATA } from './VideoItemData';
import { VideoItemData, VideoInfo } from './VideoInfo';

export class VideoDataSource implements IDataSource {
  private videoInfoList: VideoInfo[] = [];
  private listeners: DataChangeListener[] = [];

  public totalCount(): number {
    return this.videoInfoList.length;
  }

  public getData(index: number): VideoInfo {
    return this.videoInfoList[index];
  }

  // [Start refresh_data]
  // [Start demo_refresh_data]
  refreshData() {
    this.videoInfoList = [];
    VIDEO_DATA.forEach(async (item: VideoItemData) => {
      this.videoInfoList.push({
        id: util.generateRandomUUID(),
        src: item.src,
        stopTime: 0,
        preview: item.preview,
        detail: item.detail,
        duration: item.duration,
        xController: new XComponentController(),
      });
    })
    this.notifyDataReload();
  }

  // [End demo_refresh_data]
  // [End refresh_data]
  // [Start load_data]
  // [Start demo_load_data]
  loadData() {
    VIDEO_DATA.forEach(async (item: VideoItemData) => {
      this.videoInfoList.push({
        id: util.generateRandomUUID(),
        src: item.src,
        stopTime: 0,
        preview: item.preview,
        detail: item.detail,
        duration: item.duration,
        xController: new XComponentController(),
      });
      this.notifyDataAdd(this.videoInfoList.length - 1);
    })
  }

  // [End demo_load_data]
  // [End load_data]

  // [Start notify_data_reload]
  private notifyDataReload(): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataReloaded();
    });
  }

  // [End notify_data_reload]
  // [Start notify_data_add]
  public notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  // [End notify_data_add]
  public registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  public unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }
}