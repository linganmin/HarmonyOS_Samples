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

import MediaItem, { ItemType } from '../model/MediaItem';

/**
 * Water flow data source.
 */
export class StickyWaterFlowDataSource implements IDataSource {
  public dataArray: MediaItem[] = [];
  private listeners: DataChangeListener[] = [];

  constructor() {
    for (let i: number = 0; i < 100; i++) {
      let mediaItem: MediaItem = this.createMediaItem(i);
      this.dataArray.push(mediaItem);
    }
  }

  /**
   * Set water flow data array.
   *
   * @param {ProductItem[]} productDataArray Displaying water flow Data.
   */
  public setDataArray(productDataArray: MediaItem[]): void {
    this.dataArray = productDataArray;
  }

  /**
   * Get the total number of data records.
   */
  public totalCount(): number {
    return this.dataArray.length;
  }

  /**
   * Get the data corresponding to the index.
   *
   * @param {number} index Data index.
   * @returns Return ProductItem.
   */
  public getData(index: number): MediaItem {
    return this.dataArray[index];
  }

  /**
   * Register a controller that changes data.
   *
   * @param {DataChangeListener} listener Data change listener
   */
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  /**
   * Register a controller that changes data.
   *
   * @param {DataChangeListener} listener  Data change listener
   */
  unregisterDataChangeListener(listener: DataChangeListener): void {
    let pos: number = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach(listener => {
      listener.onDataAdd(index);
    })
  }

  /**
   * Add last item to the list.
   *
   */
  public addLastItem() {
    let mediaItem: MediaItem = this.createMediaItem(this.dataArray.length);
    this.dataArray.splice(this.dataArray.length, 0, mediaItem);
    this.notifyDataAdd(this.dataArray.length - 1);
  }

  createMediaItem(i: number): MediaItem {
    let videoName: string = `video_sample${(i % 5) + 1}`;
    let imageName: string = `${(i % 4)}`;
    let type: ItemType = (i % 3 === 0) ? ItemType.VIDEO : ItemType.IMAGE;
    return new MediaItem(i, type,
      $rawfile(`covers/${videoName}.png`), $rawfile(`${videoName}.mp4`),
      $rawfile(`sections/${imageName}.jpg`));
  }
}