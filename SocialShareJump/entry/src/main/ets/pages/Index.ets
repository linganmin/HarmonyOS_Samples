/*
* Copyright (C) 2025 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

// [Start deferred_link]
// entry/src/main/ets/pages/Index.ets
import { BusinessError } from '@kit.BasicServicesKit';
import { deferredLink } from '@kit.AppLinkingKit';
import { url } from '@kit.ArkTS';
import { Logger } from '../common/Logger';
// [StartExclude deferred_link]
import { Article, ARTICLE_LIST_DATA } from '../model/Article';
import { ArticleItem } from '../view/ArticleItem';
import { LazyDataSource } from '../common/LazyDataSource';

const TAG = 'Index';
// [EndExclude deferred_link]
@Entry
@Component
struct Index {
  // [StartExclude deferred_link]
  @StorageProp('statusBarHeight') statusBarHeight: number = 0;
  @StorageProp('naviIndicatorHeight') naviIndicatorHeight: number = 0;
  private dataSource: LazyDataSource<Article> = new LazyDataSource(ARTICLE_LIST_DATA);
  // [Start deal_jump_background2forward]
  @StorageLink('newWantFlag') @Watch('newWantFlagChange') isNewWant: boolean = false;

  newWantFlagChange() {
    if (this.isNewWant && AppStorage.has('aid')) {
      let aid: string = AppStorage.get('aid') as string;
      if (aid) {
        this.isNewWant = false;
        this.getUIContext().getRouter().pushUrl({
          url: 'pages/Detail',
          params: {
            aid: aid
          }
        }).catch((error: BusinessError) => {
          Logger.error(TAG, `pushUrl err, code: ${error.code}, mesage: ${error.message}`);
        });
      }
    }
  }
  // [End deal_jump_background2forward]

  // [EndExclude deferred_link]
  aboutToAppear(): void {
    // Get the deferred link parameter and go to the details page
    deferredLink.popDeferredLink().then((link: string) => {
      Logger.info(TAG, `Succeeded in getting deferred link, result: ${link}`);
      if (link) {
        // Get the link parameters
        let urlObject = url.URL.parseURL(link);
        let aid = urlObject.params.get('aid') as string;
        // Go to the details component
        this.getUIContext().getRouter().pushUrl({
          url: 'pages/Detail',
          params: {
            aid: aid
          }
        });
      }
    }).catch((error: BusinessError) => {
      Logger.error(TAG, `Failed to get deferred link. code: ${error.code}, message: ${error.message}`);
    });
  }
  // [StartExclude deferred_link]

  build() {
    Stack() {
      Row() {
        Text($r('app.string.title_recommend'))
          .fontSize($r('sys.float.Title_M'))
          .fontWeight(FontWeight.Bold)
          .fontColor($r('sys.color.font_primary'))

        Button({ type: ButtonType.Circle }) {
          SymbolGlyph($r('sys.symbol.AI_search'))
            .fontSize($r('sys.float.Title_M'))
            .fontColor([$r('sys.color.icon_primary')])
        }
        .height(40)
        .aspectRatio(1)
        .backgroundColor($r('sys.color.comp_background_tertiary'))
      }
      .backgroundBlurStyle(BlurStyle.COMPONENT_THICK)
      .width('100%')
      .height(64 + this.statusBarHeight)
      .justifyContent(FlexAlign.SpaceBetween)
      .padding({
        bottom: 8,
        left: 16,
        right: 16,
        top: this.statusBarHeight
      })
      .zIndex(2)

      WaterFlow() {
        LazyForEach(this.dataSource, (article: Article, index: number) => {
          FlowItem() {
            ArticleItem({ article: article })
              .onClick(() => {
                this.getUIContext().getRouter().pushUrl({
                  url: 'pages/Detail',
                  params: {
                    aid: article.aId
                  }
                });
              })
              .margin({ top: (index === 0 || index === 1) ? 64 + this.statusBarHeight : 0 })
          }
        }, (article: Article) => article.aId)
      }
      .cachedCount(2)
      .columnsTemplate('1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .layoutWeight(1)
      .width('100%')
      .padding({
        left: 16,
        right: 16
      })
    }
    .height('100%')
    .width('100%')
    .alignContent(Alignment.TopStart)
    .backgroundColor($r('sys.color.background_secondary'))
  }
  // [EndExclude deferred_link]
}
// [End deferred_link]