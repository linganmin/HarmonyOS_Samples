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
import { ObservedArray } from '../utils/ObservedArray';
import { ArticleCardView } from '../components/ArticleCardView';
import Constants from '../constants/Constants';
import { util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

function bufferToString(buffer: ArrayBufferLike): string {
  let textDecoder = util.TextDecoder.create('utf-8', {
    ignoreBOM: true
  });
  let resultPut = textDecoder.decodeToString(new Uint8Array(buffer), {
    stream: true
  });
  return resultPut;
}

// [Start ForEachListPage1_start]
@Entry
@Component
export struct ForEachListPage {
  UIContext = this.getUIContext()
  context = this.UIContext.getHostContext() as common.UIAbilityContext;

  // [StartExclude ForEachListPage1_start]
  @State articleList: LearningResource[] = [];
  @State collectedIds: ObservedArray<string> = ['1', '2', '3', '4', '5', '6'];
  @State likedIds: ObservedArray<string> = ['1', '2', '3', '4', '5', '6'];
  @State isListReachEnd: boolean = false;

  aboutToAppear() {
    this.getArticleModelObjFromJSON();
  }

  aboutToDisappear(): void {
    this.articleList = [];
  }

  getArticleModelObjFromJSON() {
    this.context.resourceManager.getRawFileContent('article1000.json').then(value => {
      let jsonObj = JSON.parse(bufferToString(value.buffer)) as LearningResource[];
      let resources: LearningResource[] = [];
      jsonObj.forEach((res: LearningResource) => {
        resources.push(res);
      });
      this.articleList = resources;
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
  // [EndExclude ForEachListPage1_start]

  build() {
    Column() {
      Header()
      List({ space: Constants.SPACE_16 }) {
        ForEach(this.articleList, (item: LearningResource) => {
          ListItem() {
            Column({ space: Constants.SPACE_12 }) {
              ArticleCardView({
                articleItem: item,
                isLiked: this.isLiked(item.id),
                isCollected: this.isCollected(item.id)
              })
            }
          }
        }, (item: LearningResource) => item.id)
      }
      .width(Constants.FULL_SCREEN)
      .height(Constants.FULL_SCREEN)
      .padding({ left: 10, right: 10 })
      .layoutWeight(1)
    }
    .backgroundColor($r('app.color.text_background'))
  }
}
// [End ForEachListPage1_start]

@Builder
function Header() {
  Row() {
    Text($r('app.string.foreach'))
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
