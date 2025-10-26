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

import { insightIntent } from '@kit.IntentsKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { IdGenerator, importObject } from 'cloud_objects';
import { News } from '../clouddb/news/News';
import { containsChinese, formatDateTime } from '../common/utils/Utils';
import newsDb from '../clouddb/news/NewsDb';
import Logger from '../common/utils/Logger';
import CommonConstants from '../common/constants/CommonConstants';
import { i18n } from '@kit.LocalizationKit';

@Builder
export function NewsDetailBuilder() {
  NewsDetail()
}

const TAG = 'NewsDetail';

@Component
export struct NewsDetail {
  pathStack: NavPathStack = new NavPathStack();
  @State currentNews: News | undefined = undefined;
  @State pubDate: string = '';
  @State pubUser: string = '';

  build() {
    NavDestination() {
      Row() {
        Text(this.currentNews?.title)
          .fontSize(24)
          .fontWeight(700)
          .lineHeight(32)
          .letterSpacing(0.2)
          .textAlign(TextAlign.Start)
          .maxLines(2)
          .width('100%')
      }.width('100%').height(64)
      .padding({ left: 16, right: 16 })
      .margin({ top: 8})

      Row() {
        Row() {
          // avatar
          Image($r('app.media.avatar'))
            .aspectRatio(1)
            .size({ width: 32, height: 32})
            .border({
              width: 0.22,
              color: 'rgba(0, 0, 0, 0.05)',
              style: BorderStyle.Solid,
              radius: 20
            }).margin({ top: 12, bottom: 12, right: 10})

          Flex({ justifyContent: FlexAlign.SpaceBetween, direction: FlexDirection.Column}) {
            Text(this.currentNews?.pubUserName)
              .fontColor(Color.Black)
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .lineHeight(19)
              .letterSpacing(0)
              .textAlign(TextAlign.Start)
              .align(Alignment.Start)
            Text(`${this.pubDate} - ${this.pubUser}`)
              .fontColor('rgba(0, 0, 0, 0.4)')
              .fontSize(10)
              .lineHeight(14)
              .letterSpacing(0)
              .textAlign(TextAlign.Start).margin({top: 0.5})
          }.height(33.5)
        }

        Button({ stateEffect: true}) {
          Row() {
            SymbolGlyph($r('sys.symbol.plus'))
              .fontSize(9)
              .width(9).height(9)
              .fontWeight(FontWeight.Medium)
              .fontColor(['rgb(10, 89, 247)'])
              .margin({ right: 3.5})
            Text($r('app.string.news_detail_concern_btn'))
              .fontColor('rgb(10, 89, 247)')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .lineHeight(16)
              .letterSpacing(0)
              .textAlign(TextAlign.Center)
          }.alignItems(VerticalAlign.Center)
        }.width(64).height(28).borderRadius(14).backgroundColor('rgba(0, 0, 0, 0.05)')
        .margin({ top: 14, bottom: 14})
      }.justifyContent(FlexAlign.SpaceBetween)
      .width('100%').height(56)
      .padding({ left: 16, right: 16 })
      .margin({ top: 8})

      Column(){
        Text(undefined) {
          Span(this.currentNews?.content)
          ImageSpan($r('app.media.sm_img'))
            .width('100%')
            .objectFit(ImageFit.Contain)
            .verticalAlign(ImageSpanAlignment.BOTTOM)
            .margin({top: 24}).borderRadius(8)
        }
          .width('100%')
          .fontSize(17)
          .fontWeight(FontWeight.Normal)
          .lineHeight(25.6)
          .textAlign(TextAlign.Start)
      }.margin({ top: 8})
      .width('100%').height('100%')
      .padding({ left: 16, right: 16})
    }
    .title({ builder: this.navigationTitle($r('app.string.news_detail_title')), height: 56})
    .onReady(async (context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
      this.currentNews = this.pathStack.getParamByIndex(0) as News;
      if (!this.currentNews.content) {
        this.currentNews = (await newsDb.getNewsByNewsId(this.currentNews.newsId.toString()) as News[])[0];
      }
      this.pubDate = formatDateTime(this.currentNews?.pubDate);
      const isEn = i18n.System.getSystemLanguage() === CommonConstants.LANGUAGE_ENG;
      const containChinese = containsChinese(this.currentNews.pubUserName);
      Logger.showInfo(TAG, `containChinese is ${containChinese}`);
      let suffix = '官方账号';
      if (!containChinese && isEn) {
        suffix = 'Official Account';
      }
      this.pubUser = `${this.currentNews?.pubUserName} ${suffix}`;
      await this.shareIntent(this.currentNews);
    })
  }

  @Builder
  navigationTitle(content: ResourceStr) {
    Text(content)
      .fontColor('rgba(0,0,0,0.9)')
      .fontSize(20)
      .fontWeight(FontWeight.Bold)
      .lineHeight(27)
      .margin({ top: 14.5, left: 8, bottom: 14.5 })
  }

  // Share intent
  async shareIntent(news: News) {
    const uuid = await this.callIdGenerator();
    let readNewsIntent: insightIntent.InsightIntent = {
      intentName: 'ViewBlog',
      intentVersion: '1.0.1',
      identifier: uuid,
      intentActionInfo: {
        actionMode: 'EXECUTED',
        executedTimeSlots: {
          'executedStartTime': 1747208475000,
          'executedEndTime': 1747208475000
        }
      },
      intentEntityInfo: {
        entityName: 'Blog',
        entityId: news.newsId.toString(),
        displayName: news.title,
        description: '这里是新闻的描述',
        logoURL: 'https://gitee.com/gorit/screenshots/raw/main/sm_img.png',
        blogTitle: news.title,
        blogType: '图文',
        blogCategory: news.newsType,
        categoryDisplayName: news.newsType + '资讯',
        blogAuthor: news.pubUserName,
        blogAuthorImage: 'https://gitee.com/gorit/screenshots/raw/main/avatar.png',
        blogPublishTime: news.pubDate
      }
    }

    Logger.showInfo(TAG, `${JSON.stringify(readNewsIntent)}`);
    insightIntent.shareIntent(this.getUIContext().getHostContext(), [readNewsIntent]).then(() => {
      Logger.showInfo(TAG, `shareIntent succeed`);
    }).catch((err: BusinessError) => {
      Logger.showError(TAG, `error.code: ${err?.code}, failed because ${ err.message}`);
    });

  }

  // Call the cloud function uuid interface
  private callIdGenerator(): Promise<string> {
    const idGenerator = importObject(IdGenerator);
    return new Promise((resolve, reject) => {
      idGenerator.randomUUID().then(result => {
        resolve(result.uuid);
      }).catch((err: BusinessError) => {
        Logger.showError(TAG, 'call id-generator exception, ErrCode: %{public}d ErrMessage: %{public}s',
          err.code.toString(), err.message);
        reject('');
      });
    });
  }
}