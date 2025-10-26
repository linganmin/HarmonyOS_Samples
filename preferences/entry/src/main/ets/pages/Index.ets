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

import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { preferences } from '@kit.ArkData';
import Logger from '../util/Logger';
import ThemeDesktop from '../common/ThemeDesktop';

export interface ImageAndName {
  image: Resource;
  name: ResourceStr;
}

const THEMES: Array<ImageAndName>[] = [
  [
    { image: $r('app.media.dialer'), name: $r('app.string.dialer') },
    { image: $r('app.media.shopping'), name: $r('app.string.shopping') },
    { image: $r('app.media.notes'), name: $r('app.string.notes') },
    { image: $r('app.media.settings'), name: $r('app.string.settings') },
    { image: $r('app.media.camera'), name: $r('app.string.camera') },
    { image: $r('app.media.gallery'), name: $r('app.string.album') },
    { image: $r('app.media.music'), name: $r('app.string.music') },
    { image: $r('app.media.video'), name: $r('app.string.video') },
  ],
  [
    { image: $r('app.media.simplicityCall'), name: $r('app.string.dialer') },
    { image: $r('app.media.simplicityShop'), name: $r('app.string.shopping') },
    { image: $r('app.media.simplicityNotes'), name: $r('app.string.notes') },
    { image: $r('app.media.simplicitySetting'), name: $r('app.string.settings') },
    { image: $r('app.media.simplicityCamera'), name: $r('app.string.camera') },
    { image: $r('app.media.simplicityPhotos'), name: $r('app.string.album') },
    { image: $r('app.media.simplicityMusic'), name: $r('app.string.music') },
    { image: $r('app.media.simplicityVideo'), name: $r('app.string.video') },
  ],
  [
    { image: $r('app.media.pwcall'), name: $r('app.string.dialer') },
    { image: $r('app.media.pwshop'), name: $r('app.string.shopping') },
    { image: $r('app.media.pwnotes'), name: $r('app.string.notes') },
    { image: $r('app.media.pwsetting'), name: $r('app.string.settings') },
    { image: $r('app.media.pwcamera'), name: $r('app.string.camera') },
    { image: $r('app.media.pwphotos'), name: $r('app.string.album') },
    { image: $r('app.media.pwmusic'), name: $r('app.string.music') },
    { image: $r('app.media.pwvideo'), name: $r('app.string.video') },
  ]
]
const TAG: string = '[Index]';
const PREFERENCES_NAME = 'theme.db';
const THEME_NAMES: string[] = ['default', 'simplicity', 'pomeloWhtie'];
let preferenceTheme: preferences.Preferences | null = null;

@Entry
@Component
struct Index {
  @State nowTheme: string = '';
  @State themeDatas: Array<ImageAndName> = [];

  async aboutToAppear() {
    // Retrieve lightweight storage db files from memory.
    await this.getPreferencesFromStorage()
    // Retrieve the key value with the name 'theme' from the lightweight storage db file.
    this.nowTheme = await this.getPreference()
    Logger.info(TAG, `nowTheme__get ${this.nowTheme}`)
    emitter.emit({ eventId: 0, priority: 0 }, {
      data: {
        nowTheme: this.nowTheme
      }
    })
    let index = THEME_NAMES.indexOf(this.nowTheme)
    this.themeDatas = THEMES[index]
  }

  async getPreferencesFromStorage() {
    try {
      let context = this.getUIContext().getHostContext() as Context
      preferenceTheme = await preferences.getPreferences(context, PREFERENCES_NAME)
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getPreferences failed, error code=${err.code}, message=${err.message}`);
    }
  }

  async putPreference(data: string) {
    Logger.info(TAG, `Put begin`)
    if (preferenceTheme !== null) {
      try {
        await preferenceTheme.put('theme', data)
        await preferenceTheme.flush()
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `preference operate failed, error code=${err.code}, message=${err.message}`);
      }
    }
  }

  async getPreference(): Promise<string> {
    Logger.info(TAG, `Get begin`)
    let theme: string = ''
    if (preferenceTheme !== null) {
      try {
        theme = await preferenceTheme.get('theme', 'default') as string;
        return theme;
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `preference get failed, error code=${err.code}, message=${err.message}`);
      }
    }
    return theme;
  }

  changeTheme(themeNum: number) {
    this.themeDatas = THEMES[themeNum];
    this.putPreference(THEME_NAMES[themeNum]);
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.MainAbility_label'))
          .fontSize(25)
          .layoutWeight(5)
          .padding({ left: 10 })
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
        Image($r('app.media.change'))
          .id('changeBtn')
          .height(30)
          .layoutWeight(1)
          .objectFit(ImageFit.ScaleDown)
          .bindMenu([
            {
              value: THEME_NAMES[0],
              action: () => {
                this.changeTheme(0)
              }
            },
            {
              value: THEME_NAMES[1],
              action: () => {
                this.changeTheme(1)
              }
            },
            {
              value: THEME_NAMES[2],
              action: () => {
                this.changeTheme(2)
              }
            }
          ])
      }
      .width('100%')
      .height(50)
      .backgroundColor('#0D9FFB')

      ThemeDesktop({ themeDatas: $themeDatas })
    }
    .width('100%')
    .height('100%')
  }
}