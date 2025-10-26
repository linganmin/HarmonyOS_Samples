/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { FileReader } from '../common/utils/FileReader';
import { common } from '@kit.AbilityKit';
import CommonConstants from '../common/constants/CommonConstants';
import { IVideoInfo } from '../model/DataModel';
import { i18n } from '@kit.LocalizationKit';

@Entry
@Component
struct Index {
  @State videoList: IVideoInfo[] = [];
  private storage: LocalStorage | undefined = this.getUIContext().getSharedLocalStorage();
  private abilityContext: common.UIAbilityContext | undefined =
    this.getUIContext().getHostContext() as common.UIAbilityContext;
  private navPathStack: NavPathStack = new NavPathStack();

  async aboutToAppear(): Promise<void> {
    // listen intent execute event
    this.abilityContext?.eventHub.on(CommonConstants.PLAY_VIDEO_EVENT, (entityId: string) => {
      this.gotoPlayVideo(entityId);
    });
    // read video.json
    this.videoList =
      await FileReader.readJson(this.abilityContext as common.UIAbilityContext,
        CommonConstants.VIDEO_FILE_NAME) as IVideoInfo[];
    if (this.storage?.get('entityId')) {
      this.gotoPlayVideo(this.storage?.get('entityId') as string);
    }
  }

  aboutToDisappear(): void {
    this.abilityContext?.eventHub.off(CommonConstants.PLAY_VIDEO_EVENT);
  }

  build() {
    Navigation(this.navPathStack) {
      Column() {
        Text($r('app.string.List_title'))
          .fontSize(18)
          .lineHeight(24)
          .fontWeight(FontWeight.Bold)
          .width('100%')
          .margin({ bottom: 12 })
        List({ space: 24 }) {
          ForEach(this.videoList, (item: IVideoInfo) => {
            ListItem() {
              this.videoCard(item);
            }
          }, (item: IVideoInfo) => item.id)
        }
        .width('100%')
        .height("100%")
      }
      .height('100%')
      .width('100%')
      .padding({
        left: 16,
        right: 16,
        top: 24,
        bottom: 24
      })
    }
    .title({ builder: this.titleBuilder, height: 112 })
    .navBarWidth(300)
  }

  @Builder
  titleBuilder() {
    Column() {
      Text($r('app.string.Navbar_title'))
        .fontSize(i18n.System.getSystemLanguage() === CommonConstants.ENG_LANGUAGE ? 18 : 30)
        .lineHeight(40)
        .fontWeight(FontWeight.Bold)
        .width("100%")
    }
    .justifyContent(FlexAlign.Center)
    .margin({
      left: 16,
      right: 16,
      top: 64,
      bottom: 8
    })
    .height(40)
  }

  @Builder
  videoCard(item: IVideoInfo) {
    Column() {
      Stack() {
        Image($r(item.thumbnail))
          .width('100%')
          .height(200)
          .borderRadius(16)
        Row()
          .width('100%')
          .height(200)
          .backgroundColor('rgba(0,0,0,0.15)')
          .borderRadius(16)
        SymbolGlyph($r('sys.symbol.play_circle'))
          .fontSize(48)
          .fontColor([Color.White])
      }
      .onClick(() => {
        this.navPathStack.replacePathByName(CommonConstants.PLAY_PATH_NAME, item);
      })

      Column() {
        Text($r(item.displayName))
          .width('100%')
          .font({ weight: FontWeight.Medium, size: 16 })
          .lineHeight(21)
          .margin({ bottom: 4 })
        Text($r(item.description))
          .width('100%')
          .font({ weight: FontWeight.Normal, size: 14 })
          .lineHeight(19)
          .fontColor(Color.Gray)
      }
      .padding({ left: 12, right: 12, top: 12 })
    }
    .width('100%')
  }

  gotoPlayVideo(entityId: string) {
    if (entityId) {
      let videoItem = this.videoList.find((item: IVideoInfo) => item.id === entityId);
      videoItem && this.navPathStack.replacePathByName(CommonConstants.PLAY_PATH_NAME, videoItem);
    }
  }
}