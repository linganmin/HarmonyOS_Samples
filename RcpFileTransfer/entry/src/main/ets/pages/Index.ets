/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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

import { CustomList, CustomListItem } from '../components/CustomList';
import { Route, ROUTES } from '../constants/Constants';
import { AlbumImageTransfer } from './AlbumImageTransfer';
import { BackgroundFileTransfer } from './BackgroundFileTransfer';
import { ChunkedFileTransfer } from './ChunkedFileTransfer';
import { ResumableFileTransfer } from './ResumableFileTransfer';

@Entry
@Component
struct Index {
  @Provide navPageInfos: NavPathStack = new NavPathStack();

  go(route: Route) {
    if (!route.to) {
      return;
    }
    this.navPageInfos.pushPath({
      name: route.to,
      param: route.title
    });
  }

  getCustomListData(): CustomListItem[] {
    return ROUTES.map((route, index) => {
      const item: CustomListItem = {
        id: index.toString(),
        title: route.title
      }
      return item
    })
  }

  onRowClick(row: CustomListItem) {
    const index = Number(row.id)
    const route = ROUTES[index]
    this.go(route)
  }

  @Builder
  NavPageMap(name: string) {
    if (name === 'AlbumImageTransfer') {
      AlbumImageTransfer();
    } else if (name === 'ChunkedFileTransfer') {
      ChunkedFileTransfer()
    } else if (name === 'ResumableFileTransfer') {
      ResumableFileTransfer()
    } else if (name === 'BackgroundFileTransfer') {
      BackgroundFileTransfer()
    }
  }

  build() {
    Navigation(this.navPageInfos) {
      Column() {
        Text($r('app.string.title'))
          .fontWeight(FontWeight.Bold)
          .fontSize(30)
          .fontColor('#E6000000')
          .width('100%')
          .height(140)
        CustomList({
          data: this.getCustomListData(),
          onRowClick: row => { this.onRowClick(row) }
        })
      }
      .width('100%')
      .height('100%')
      .padding(16)
    }
    .hideToolBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.NavPageMap)
    .backgroundColor('#F1F3F5')
  }
}