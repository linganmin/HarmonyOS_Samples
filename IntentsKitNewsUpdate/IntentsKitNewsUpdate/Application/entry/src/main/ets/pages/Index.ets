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

import { common } from '@kit.AbilityKit';
import { i18n } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { News } from '../clouddb/news/News';
import newsDb from '../clouddb/news/NewsDb';
import Logger from '../common/utils/Logger';
import { formatRelativeTime } from '../common/utils/Utils';
import CommonConstants, { enDict } from '../common/constants/CommonConstants';
import { IIntentParam } from '../model/IntentParam';

const TAG = 'Home';

@Entry
@Component
struct Home {
  pathStack: NavPathStack = new NavPathStack();
  private storage: LocalStorage | undefined = this.getUIContext().getSharedLocalStorage();
  private abilityContext: common.UIAbilityContext | undefined =
    this.getUIContext().getHostContext() as common.UIAbilityContext;
  @State currentTabIndex: number = 0;
  @State newsTab: Resource[] =
    [$r('app.string.home_tabs_one'), $r('app.string.home_tabs_two'), $r('app.string.home_tabs_three'),
      $r('app.string.home_tabs_four'), $r('app.string.home_tabs_five')];
  private tabsController: TabsController = new TabsController();
  @State newsList: News[] = [];
  @State recommendList: News[] = [];
  handleIntentParam = async (data: IIntentParam) => {
    if (!data) {
      return;
    }

    if (data?.blogCategory) {
      const categories = Object.values(enDict) as string[];
      this.currentTabIndex = categories.findIndex((item) => item === data.blogCategory);
      if (this.newsList.length === 0) {
        this.newsList = await newsDb.getNewsByNewsType(data.blogCategory);
      }
    }
    if (data?.entityId) {
      this.gotoViewNews(data.entityId as string);
    }

    if (data.items && data.items?.length > 0) {
      this.recommendList = data.items?.map((item) => {
        const news = new News();
        news.newsId = Number(item.entityId);
        news.title = item.blogTitle;
        news.newsType = item.blogCategory;
        news.pubUserName = item.blogAuthor;
        news.pubUserAvatar = item.blogAuthorImage;
        news.pubDate = new Date(item.blogPublishTime);
        return news;
      })
    }
  }

  aboutToAppear(): void {
    try {
      const data = this.storage?.get(CommonConstants.STORAGE_KEY) as IIntentParam;
      Logger.showInfo(TAG, `aboutToAppear: ${JSON.stringify(data)}`);
      this.handleIntentParam(data);

      // listen intent execute event
      this.abilityContext?.eventHub.on(CommonConstants.VIEW_NEWS_EVENT, (data: IIntentParam) => {
        Logger.showInfo(TAG, `aboutToAppear.eventHub: ${JSON.stringify(data)}`);
        this.handleIntentParam(data);
      });

      if (this.currentTabIndex > 0) {
        const newsType = this.getUIContext()
          .getHostContext()?.resourceManager.getStringSync(this.newsTab[this.currentTabIndex].id) as string;
        const isEn = i18n.System.getSystemLanguage() === CommonConstants.LANGUAGE_ENG;
        let type = isEn ? enDict[newsType] : newsType;
        newsDb.getNewsByNewsType(type).then((ret) => {
          this.newsList = ret;
        });
      } else {
        this.newsList = this.recommendList;
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.showError(TAG, `aboutToAppear, error.code is ${error.code}, error.message is ${error.message}`);
    }
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        List({ space: 8 }) {
          ForEach(this.newsTab, (item: string, index: number) => {
            this.tabBuilder(item, index);
          }, (item: string) => item)
        }.height(56).width('100%').listDirection(Axis.Horizontal).scrollBar(BarState.Off)

        Tabs({ index: this.currentTabIndex, controller: this.tabsController }) {
          ForEach(this.newsTab, (item: string, idx: number) => {
            TabContent() {
              List() {
                if (this.newsList.length > 0) {
                  ForEach(this.newsList, (item: News) => {
                    ListItem() {
                      RelativeContainer() {
                        Column() {
                          Text(item.title)
                            .fontSize(16)
                            .fontWeight(FontWeight.Medium)
                            .lineHeight(23)
                            .textAlign(TextAlign.Start)
                            .maxLines(2)
                            .width('100%')

                          Row() {
                            Text(`${item.pubUserName} ${formatRelativeTime(item.pubDate.getTime())}`)
                              .fontSize(12)
                              .fontColor('rgba(0,0,0,0.4)')
                              .fontWeight(FontWeight.Normal)
                              .lineHeight(16)
                              .textAlign(TextAlign.Start)
                            Text(':')
                              .textAlign(TextAlign.End)
                              .fontSize(12)
                              .lineHeight(14)
                              .fontColor('rgba(0,0,0,0.4)')
                          }.width('100%').justifyContent(FlexAlign.SpaceBetween)
                        }
                        .justifyContent(FlexAlign.SpaceBetween)
                        .height('100%')
                        .id('id_news_left_group')
                        .alignRules({
                          top: { anchor: '__container__', align: VerticalAlign.Top },
                          left: { anchor: '__container__', align: HorizontalAlign.Start },
                          right: { anchor: 'id_news_right_logo', align: HorizontalAlign.Start },
                          bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
                        })
                        .margin({ right: 8 })

                        Image($r('app.media.sm_img'))
                          .width(108)
                          .height('100%')
                          .objectFit(ImageFit.Cover)
                          .borderRadius(4)
                          .id('id_news_right_logo')
                          .alignRules({
                            top: { anchor: '__container__', align: VerticalAlign.Top },
                            right: { anchor: '__container__', align: HorizontalAlign.End },
                            bottom: { anchor: '__container__', align: VerticalAlign.Bottom }
                          })
                      }.width('100%').height(81)
                    }.height(105)
                    .onClick(() => {
                      this.pathStack.pushPath({ name: 'NewsDetail', param: item });
                    })
                  }, (item: News) => item.newsId.toString())
                } else {
                  ListItem() {
                    Text($r('app.string.home_no_content'))
                      .fontColor('rgba(0,0,0,0.6)')
                      .fontSize(15)
                      .fontWeight(FontWeight.Medium)
                      .margin({ top: 24 })
                      .textAlign(TextAlign.Center)
                      .width('100%')
                  }
                }

              }.width('100%').height('100%').listDirection(Axis.Vertical)
              .margin({ top: 12 })
            }
          }, (item: string) => item)
        }
        .barHeight(0)
        .onChange((index: number) => {
          this.currentTabIndex = index;
        })
      }
      .width('100%').height('100%')
      .padding({
        top: 8,
        bottom: 8,
        left: 16,
        right: 16
      })
    }
    .title({ builder: this.titleBuilder(), height: 56 })
  }

  @Builder
  titleBuilder() {
    Column() {
      Text($r('app.string.home_title'))
        .fontSize(30)
        .fontWeight(FontWeight.Bold)
        .lineHeight(40)
        .fontColor('rgba(0,0,0,0.9)')
        .margin({
          left: 16,
          right: 16,
          top: 8,
          bottom: 8
        })
    }
    .height('100%')
  }

  @Builder
  tabBuilder(text:
    string, index:
    number
  ) {
    Column() {
      Text(text)
        .fontSize(14)
        .lineHeight(19)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.currentTabIndex === index ? '#FFFFFF' : 'rgba(0,0,0,0.9)')
        .textAlign(TextAlign.Center)
        .width(60)
        .height(40)
        .backgroundColor(this.currentTabIndex === index ? 'rgb(10,89,247)' : 'rgba(0,0,0,0.05)')
        .borderRadius(20)
        .onClick(() => {
          this.tabsController.changeIndex(index);
          if (index > 0) {
            const newsType =
              this.getUIContext().getHostContext()?.resourceManager.getStringSync(this.newsTab[index].id) as string;
            const isEn = i18n.System.getSystemLanguage() === "en-Latn-US";
            let type = isEn ? enDict[newsType] : newsType;
            newsDb.getNewsByNewsType(type).then((ret) => {
              this.newsList = ret;
            });
          } else {
            this.newsList = this.recommendList;
          }
        })
    }.height('100%').justifyContent(FlexAlign.Center)
  }

  gotoViewNews(entityId:
    string
  ) {
    if (entityId) {
      newsDb.getNewsByNewsId(entityId).then((ret: null | News[]) => {
        if (!ret) {
          return;
        }
        this.pathStack.replacePathByName(CommonConstants.NEWS_DETAIL_PATH_NAME, (ret as News[])[0]);
      })
    }
  }
}