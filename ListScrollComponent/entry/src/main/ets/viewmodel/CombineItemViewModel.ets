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

import { ListManager } from '@hadss/scroll_components';
import { BlogData, ImagePixelMap } from "../model/types";
import { http } from "@kit.NetworkKit";
import { HttpGet } from "../model/mock";
import { sendableImage } from "@kit.ImageKit";

@Observed
export class CombineItemViewModel {
  @Track dataArray: BlogData[] = [];
  myListManager: ListManager;
  private NetworkTime: number = 200;
  private isLoadingMore: boolean = false;
  // private fetches: Map<number, http.HttpRequest> = new Map();
  private readonly fetchesMore: Map<number, Map<number, http.HttpRequest>> = new Map();

  constructor(myListManager: ListManager) {
    this.myListManager = myListManager;
  }

  loadData(callBack?: (isSuccess: boolean) => void): void {
    generateRandomBlogData().then((data: BlogData[]) => {
      this.dataArray = data;
      this.myListManager.setDataSource(data);
      if (callBack) {
        callBack(true);
      }
    });
  }

  loadDataMore(callBack?: (isSuccess: boolean) => void): void {
    if (!this.isLoadingMore) {
      this.isLoadingMore = true;
      setTimeout(() => {
        generateRandomBlogData().then((data: BlogData[]) => {
          this.myListManager.nodeAdapter.pushData(data);
          this.isLoadingMore = false;
          if (callBack) {
            callBack(true);
          }
        })
      }, this.NetworkTime);
    }
  }
  // [Start Prefetch_3_2]
  registerPrefetch() {
    this.myListManager?.registerFetchCallback(this.fetchCallback);
    this.myListManager?.registerCancelCallback(this.cancelCallback);
  }
  // [End Prefetch_3_2]
  // [Start Prefetch_2]
  fetchCallback: (item: ESObject, fetchId: number) => Promise<void> = (item: ESObject, fetchId: number) => {
    // Simulate a simple pre-loading scenario ,This is where you can migrate the preloaded scenarios for your project
    // 1、When the component is not displayed or created, the image is obtained. PixelMap, when the component is displayed, load the image directly. PixelMap and show no need to wait for the network
    // 2、If the image is displayed but the pixelMap is not obtained, the data is bound to the Image component first, and the image can be refreshed immediately after the pixelMap is obtained
    let data = item as BlogData;
    this.fetchesMore.set(fetchId, new Map());
    return new Promise(resolve => {
      setTimeout(() => {
        data.imagePixelMapArray.forEach((pixMap: ImagePixelMap, index, _array) => {
          if (pixMap.imagePixelMap) {
            return;
          }
          let httpRequest = HttpGet(pixMap.imageUrl, (error: number, pixelMap?: sendableImage.PixelMap) => {
            let fetchMap = this.fetchesMore.get(fetchId);
            if (fetchMap) {
              fetchMap.delete(index);
              if (fetchMap?.size === 0) {
                this.fetchesMore.delete(fetchId);
              }
            }
            if (error === -1) {
              return;
            }
            if (pixelMap) {
              // You need to create an array to store the pixelMap, because there is a change in the internal data of the array to make the component respond, which is more complicated, the developer can choose the preloading scheme by himself:
              // Define the ImagePixelMap class to store the pixelMap, encapsulate the Image component as an ObservedImage, add @ObjectLink imagePixelMap: ImagePixelMap property to bind the data object,
              // In the preloaded callback fetchCallback, after the image pixelMap is obtained, set ImagePixelMap.imagePixelMap, and the image can be refreshed by ObservedImage
              pixMap.imagePixelMap = sendableImage.convertToPixelMap(pixelMap);
            }
          })
          let fetchMap = this.fetchesMore.get(fetchId);
          if (fetchMap) {
            fetchMap = new Map;
            fetchMap.set(index, httpRequest);
          }
        })
        resolve();
      }, 0);
    })
  }
  cancelCallback: (fetchId: number) => void = (fetchId: number) => {
    Array.from(this.fetchesMore.get(fetchId)?.values() ?? []).forEach(element => {
      element.destroy();
    });
    this.fetchesMore.clear();
    this.fetchesMore.delete(fetchId);
  }
  // [End Prefetch_2]
}

@Concurrent
async function generateRandomBlogData(count?: number): Promise<BlogData[]> {
  const module = await import('../model/mock');
  return module.generateRandomBlogData(count ?? 20, false, true);
}