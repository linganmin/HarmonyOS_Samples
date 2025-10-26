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

import { GridManager } from "@hadss/scroll_components";
import UserInfoViewModel from "./UserInfoViewModel";
import { image, sendableImage } from "@kit.ImageKit";
import { generateRandomImages, generateRandomUserName, httpGetImage } from "../model/mock";
import { UserInfoModel } from "../model/UserInfoModel";

// [Start control_scroll_position]
@Observed
export default class CardGridViewModel {
  // [StartExclude control_scroll_position]
  fetches: Map<number, number> = new Map();
  imageMap: Map<string, image.PixelMap> = new Map();
  @Track data: UserInfoViewModel[] = [];
  // [EndExclude control_scroll_position]
  gridViewManager?: GridManager;
  scroller?: Scroller;

  constructor(gridViewManager: GridManager, scroller: Scroller) {
    this.gridViewManager = gridViewManager;
    this.scroller = scroller;
  }

  // [StartExclude control_scroll_position]
  loadData() {
    let users = this.requestData();
    for (let index = 0; index < users.length; index++) {
      let user: UserInfoModel = users[index];
      let model = new UserInfoViewModel();
      model.updateModel(user);
      this.data.push(model);
    }
    this.gridViewManager?.setDataSource(this.data);
  }

  private requestData() {
    let array: UserInfoModel[] = [];
    for (let index = 0; index < 162; index++) {
      let user: UserInfoModel = new UserInfoModel();
      user.name = generateRandomUserName();
      user.icon = generateRandomImages()[0];
      user.updateTime = '2025-05-17';
      user.abilities = ['scan', 'add', 'update', 'delete'];
      let random: number = Math.random();
      if (random < 0.1) {
        user.role = 'manager';
      } else {
        user.role = 'user';
        if (random > 0.9) {
          user.abilities = ['scan', 'add', 'update'];
        } else if (random > 0.7) {
          user.abilities = ['scan', 'update'];
        } else {
          user.abilities = ['scan', 'add'];
        }
      }
      array.push(user);
    }
    return array;
  }

  fetchCallback: (item: ESObject, fetchId: number) => Promise<void> = (item: ESObject, fetchId: number) => {
    let user = item as UserInfoViewModel;
    if (user.iconPixelMap) {
      return Promise.resolve();
    }
    return new Promise(resolve => {
      if (this.imageMap.has(user.icon)) {
        user.iconPixelMap = this.imageMap.get(user.icon);
        return;
      }
      this.fetches.set(fetchId, 1);
      if (user.icon) {
        let url = user.icon;
        httpGetImage(url, (error: number, pixelMap?: sendableImage.PixelMap) => {
          this.fetches.delete(fetchId);

          if (error === -1) {
            return;
          }
          if (pixelMap) {
            user.iconPixelMap = sendableImage.convertToPixelMap(pixelMap);
            this.imageMap.set(url, user.iconPixelMap);
          }
        });
      }
      resolve();
    });
  }

  /**
   * cancel callback for prefetch.
   */
  cancelCallback: (fetchId: number) => void = (fetchId: number) => {
    this.fetches.delete(fetchId);
  }

  registerPrefetch() {
    this.gridViewManager?.registerFetchCallback(this.fetchCallback);
    this.gridViewManager?.registerCancelCallback(this.cancelCallback);
  }

  /**
   * clear cache
   */
  destroy() {
    this.imageMap.clear();
    this.fetches.clear();
  }

  // [Start long_press_delete]
  /**
   * delete data by user id
   *
   * @param id user id
   */
  deleteData(id: number) {
    for (let index = 0; index < this.data.length; index++) {
      let model = this.data[index];
      if (model.id === id) {
        // delete components and data
        this.gridViewManager?.nodeAdapter.deleteData(index);
        return;
      }
    }
  }
  // [End long_press_delete]

  // [EndExclude control_scroll_position]
  /**
   * goto pre page
   */
  prePage() {
    this.scroller?.scrollPage({
      next: false,
      animation: true
    });
  }

  /**
   * goto next page.
   */
  nextPage() {
    this.scroller?.scrollPage({
      next: true,
      animation: true
    });
  }
}
// [End control_scroll_position]