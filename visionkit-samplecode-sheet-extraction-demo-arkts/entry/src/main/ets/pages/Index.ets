/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import { SheetExtractionPage } from './SheetExtractionPage';

@Entry
@Component
struct Index {
  @Provide('pathStack') pageInfo: NavPathStack = new NavPathStack();

  @Builder
  PageMap(name: string) {
    if (name === 'SheetExtraction') {
      SheetExtractionPage()
    }
  }

  build() {
    Navigation(this.pageInfo) {
      Column({ space: 20 }) {
        Button('SheetExtraction', { stateEffect: true, type: ButtonType.Capsule })
          .width('80%')
          .height(40)
          .onClick(() => {
            this.pageInfo.pushPath({ name: 'SheetExtraction' });
          })
      }
      .padding({ top: 40 })
    }
    .title('SheetDemo')
    .navDestination(this.PageMap)
    .mode(NavigationMode.Stack)
  }
}
