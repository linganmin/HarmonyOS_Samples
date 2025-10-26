/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { common } from '@kit.AbilityKit';
import { LearningResource } from '../model/LearningResource';
import ArticleListData from '../model/ArticleListData';
import { ObservedArray } from '../utils/ObservedArray';
import { ReusableArticleCardView } from '../components/ReusableArticleCardView';
import Constants from '../constants/Constants';
import { util } from '@kit.ArkTS';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';


function bufferToString(buffer: ArrayBufferLike): string {
  let textDecoder = util.TextDecoder.create('utf-8', {
    ignoreBOM: true
  });
  let resultPut = textDecoder.decodeToString(new Uint8Array(buffer), {
    stream: true
  });
  return resultPut;
}

// [Start LazyForEachListPage2_start]
// [Start LazyForEachListPage3_start]
// [Start LazyForEachListPage4_start]
@Entry
@Component
export struct LazyForEachListPage {
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext;

  // [StartExclude LazyForEachListPage3_start]
  // [StartExclude LazyForEachListPage2_start]
  // [StartExclude LazyForEachListPage4_start]
  @State collectedIds: ObservedArray<string> = ['1', '2', '3', '4', '5', '6'];
  @State likedIds: ObservedArray<string> = ['1', '2', '3', '4', '5', '6'];
  @State isListReachEnd: boolean = false;
  @State data: ArticleListData | null = null;

  aboutToAppear() {
    this.getArticleModelObjFromJSON();
  }

  aboutToDisappear(): void {
    this.data = null;
  }

  getArticleModelObjFromJSON() {
    this.context.resourceManager.getRawFileContent('article1000.json').then(value => {
      let jsonObj = JSON.parse(bufferToString(value.buffer)) as LearningResource[];
      let resources: LearningResource[] = [];
      jsonObj.forEach((res: LearningResource) => {
        resources.push(res);
      });
      this.data = new ArticleListData(resources);
    }).catch((err: BusinessError) => {
      hilog.error(0xFF00, 'ListOptimization', `getArticleModelObjFromJSON fail, code = ${err.code}, message = ${err.message}`);
    })
  }

  isCollected(resourceId: string): boolean {
    return this.collectedIds.some((id: string) => id === resourceId);
  }

  isLiked(resourceId: string): boolean {
    return this.likedIds.some((id: string) => id === resourceId);
  }
  // [EndExclude LazyForEachListPage2_start]
  // [EndExclude LazyForEachListPage3_start]
  // [EndExclude LazyForEachListPage4_start]

  build() {
    Column() {
      Header()
      List({ space: Constants.SPACE_16 }) {
        if (this.data !== null) {
          // Optimization method 1: Use LazyForEach.
          LazyForEach(this.data, (item: LearningResource) => {
            ListItem() {
              Column({ space: Constants.SPACE_12 }) {
                // Optimization method 3：Reuse Component
                ReusableArticleCardView({
                  articleItem: item,
                  isLiked: this.isLiked(item.id),
                  isCollected: this.isCollected(item.id)
                })
              }
            }
            .reuseId('article')
          }, (item: LearningResource) => item.id)
        }
      }
      .width(Constants.FULL_SCREEN)
      .height(Constants.FULL_SCREEN)
      .padding({ left: 10, right: 10 })
      .layoutWeight(1)
      // [StartExclude LazyForEachListPage2_start]
      // Optimization method 2：Use cachedCount
      .cachedCount(3);
      // [EndExclude LazyForEachListPage2_start]
    }
    .backgroundColor($r('app.color.text_background'))
  }
}
// [End LazyForEachListPage2_start]
// [End LazyForEachListPage3_start]
// [End LazyForEachListPage4_start]

@Builder
function Header() {
  Row() {
    Text($r('app.string.lazy_foreach'))
      .fontSize($r('app.float.header_font_size'))
      .fontWeight(FontWeight.Bold)
      .textAlign(TextAlign.Start)
      .width('100%')
      .fontFamily('HarmonyHeiTi-Bold')
      .padding({ left: $r('app.float.md_padding_margin') })
  }
  .height($r('app.float.top_navigation_height'))
  .margin({ top: $r('app.float.lg_padding_margin') })
}
