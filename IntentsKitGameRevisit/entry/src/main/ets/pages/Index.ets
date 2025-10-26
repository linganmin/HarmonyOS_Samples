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

import { i18n } from '@kit.LocalizationKit';
import { common } from '@kit.AbilityKit';
import { FileReader } from '../common/utils/FileReader';
import CommonConstants from '../common/constants/CommonConstants';
import { IGameInfo } from '../model/DataModel';

@Entry
@Component
struct Index {
  @State gameList: IGameInfo[] = [];
  private storage: LocalStorage | undefined = this.getUIContext().getSharedLocalStorage();
  private abilityContext: common.UIAbilityContext | undefined =
    this.getUIContext().getHostContext() as common.UIAbilityContext;
  private navPathStack: NavPathStack = new NavPathStack();

  async aboutToAppear(): Promise<void> {
    // listen intent execute event
    this.abilityContext?.eventHub.on(CommonConstants.PLAY_GAME_EVENT, (entityId: string) => {
      this.gotoPlayGame(entityId)
    })
    // read game.json
    this.gameList =
      await FileReader.readJson(this.abilityContext as common.UIAbilityContext,
        CommonConstants.GAME_FILE_NAME) as IGameInfo[];
    // cold start
    if (this.storage?.get('entityId')) {
      this.gotoPlayGame(this.storage?.get('entityId') as string);
    }
  }

  aboutToDisappear(): void {
    this.abilityContext?.eventHub.off(CommonConstants.PLAY_GAME_EVENT);
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
          ForEach(this.gameList, (item: IGameInfo) => {
            ListItem() {
              this.gameCard(item)
            }
          }, (item: IGameInfo) => item.id)
        }
        .width('100%')

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
  gameCard(item: IGameInfo) {
    Column() {
      Stack() {
        Image($r(item.thumbnail))
          .width('100%')
          .height(200)
          .borderRadius(16)
      }
      .onClick(() => {
        this.navPathStack.replacePathByName(CommonConstants.PLAY_PATH_NAME, item);
      })

      Column() {
        Text($r(`${item.displayName}`))
          .width('100%')
          .font({ weight: FontWeight.Medium, size: 16 })
          .lineHeight(21)
          .margin({ bottom: 4 })
        Text($r(`${item.description}`))
          .width('100%')
          .font({ weight: FontWeight.Normal, size: 14 })
          .lineHeight(19)
          .fontColor(Color.Gray)
      }
      .padding({ left: 12, right: 12, top: 12 })

    }
    .width('100%')

  }

  gotoPlayGame(entityId: string) {
    if (entityId) {
      let gameItem = this.gameList.find((item: IGameInfo) => item.id === entityId);
      gameItem && this.navPathStack.replacePathByName(CommonConstants.PLAY_PATH_NAME, gameItem);
    }
  }
}


