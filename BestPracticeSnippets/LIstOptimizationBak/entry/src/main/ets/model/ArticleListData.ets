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

// DocsCode 1
import { SongInfoItem } from '../model/LearningResource';
import { HashMap } from '@kit.ArkTS';
import { fileIo } from '@kit.CoreFileKit';
import { IDataSourcePrefetching } from '@kit.ArkUI';
import { rcp } from '@kit.RemoteCommunicationKit';

let PREFETCH_ENABLED: boolean = false;
const CANCEL_CODE: number = 1007900992;
const IMADE_UNAVAILABLE = $r('app.media.startIcon');
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
const context = uiContext?.getHostContext();

export default class DataSourcePrefetching implements IDataSourcePrefetching {
  private dataArray: Array<SongInfoItem>;
  private listeners: DataChangeListener[] = [];
  private readonly requestsInFlight: HashMap<number, rcp.Request> = new HashMap();
  private readonly session: rcp.Session = rcp.createSession();
  private readonly cachePath = context?.getApplicationContext().cacheDir;

  constructor(dataArray: Array<SongInfoItem>) {
    this.dataArray = dataArray;
  }

  async prefetch(index: number): Promise<void> {
    PREFETCH_ENABLED = true;
    if (this.requestsInFlight.hasKey(index)) {
      throw new Error('Already being prefetched')
    }
    const item = this.dataArray[index];
    if (item.cachedImage) {
      return;
    }
    // 数据请求
    const request = new rcp.Request(item.albumUrl, 'GET');
    // 缓存网络请求对象，便于在需要取消请求的时候进行处理
    this.requestsInFlight.set(index, request);
    try {
      // 发送http请求获得响应
      const response = await this.session.fetch(request);
      if (response.statusCode !== 200 || !response.body) {
        throw new Error('Bad response');
      }
      // 将加载的数据信息存储到缓存文件中
      item.cachedImage = await this.cache(item.songId, response.body);
      // 删除指定元素
      this.requestsInFlight.remove(index);
    } catch (err) {
      if (err.code !== CANCEL_CODE) {
        item.cachedImage = IMADE_UNAVAILABLE;
        // 移除有异常的网络请求任务
        this.requestsInFlight.remove(index);
      }
      throw err as Error;
    }
  }

  cancel(index: number) {
    if (this.requestsInFlight.hasKey(index)) {
      // 返回MAP对象指定元素
      const request = this.requestsInFlight.get(index);
      // 取消数据请求
      this.session.cancel(request);
      // 移除被取消的网络请求对象
      this.requestsInFlight.remove(index);
    }
  }
  // DocsDot

  getData(index: number): SongInfoItem {
    if (!PREFETCH_ENABLED) {
      this.dataArray[index].cachedImage = this.dataArray[index].albumUrl;
    }
    return this.dataArray[index];
  }

  totalCount(): number {
    return this.dataArray.length;
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  private async cache(songId: number, data: ArrayBuffer): Promise<string> {
    const path = `file://${this.cachePath}/${songId}.jpg`;
    const file = await fileIo.open(path, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    await fileIo.write(file.fd, data);
    await fileIo.close(file);
    return path;
  }
  // DocsDot
}
// DocsCode 1