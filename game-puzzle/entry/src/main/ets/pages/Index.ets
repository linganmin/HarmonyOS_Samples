/*
 * Copyright (c) 2022-2023 Huawei Device Co., Ltd.
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

import { mediaquery } from '@kit.ArkUI';
import { Permissions, abilityAccessCtrl } from '@kit.AbilityKit';
import { emitter } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import GameRules from '../model/GameRules';
import ImagePicker from '../common/ImagePicker';
import PictureItem from '../model/PictureItem';
import ImageModel from '../model/ImageModel';
import { CommonConstants as Common } from '../common/CommonConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

const PERMISSIONS: Array<Permissions> = [
  'ohos.permission.READ_IMAGEVIDEO'
];

@Entry
@Component
struct Index {
  @State numArray: PictureItem[] = [];
  @State imgData: Array<photoAccessHelper.PhotoAsset> = [];
  @State @Watch('onTimeOver') gameTime: number = Common.GAME_TIME;
  @State @Watch('onImageChange') index: number = Common.ZERO;
  @State isLand: boolean = false;
  @StorageLink('isGameStart') isGameStart: boolean = false;
  private listener = this.getUIContext().getMediaQuery().matchMediaSync('screen and (min-aspect-ratio: 1.5) or (orientation: landscape)');
  private hostContext: Context = this.getUIContext().getHostContext() as Context;
  private ImageModel: ImageModel = new ImageModel(this.hostContext);
  private game: GameRules = new GameRules();
  private timer: number = -1;
  private isRefresh: boolean = false;

  onLand = (mediaQueryResult: mediaquery.MediaQueryResult) => {
    hilog.info(0x0000, Common.TAG, `[eTSMediaQuery.Index]onLand: mediaQueryResult.matches=${mediaQueryResult.matches}`);
    this.isLand = mediaQueryResult.matches;
  };
  over = () => {
    hilog.info(0x0000, Common.TAG, 'emitter on , eventID = 0');
    for (let i = Common.ZERO; i < Common.LOOP; i++) {
      this.numArray[i].index = i;
    }
    this.gameOver();
  };
  timeEnd = () => {
    hilog.info(0x0000, Common.TAG, 'emitter on , eventID = 1');
    this.gameTime = Common.ZERO;
  };

  async aboutToAppear() {
    this.listener.on('change', this.onLand);
    try {
      await abilityAccessCtrl.createAtManager().requestPermissionsFromUser(this.hostContext, PERMISSIONS);
    } catch (err) {
      hilog.error(0x0000, Common.TAG, `requestPermissionsFromUser failed, error code=${err.code}, message=${err.message}`);
    }
    this.imgData = await this.ImageModel.getAllImg();
    hilog.info(0x0000, Common.TAG, `images = ${this.imgData.length}`);
    this.numArray = await this.ImageModel.splitPic(this.index);
    // Test case. The game is simulated successfully.
    emitter.on({ eventId: Common.ZERO, priority: Common.ZERO }, this.over);
    // Test case. End of simulation time.
    emitter.on({ eventId: Common.ONE, priority: Common.ZERO }, this.timeEnd);
  }

  onTimeOver() {
    if (this.gameTime === Common.ZERO) {
      this.isGameStart = false;
      this.getUIContext().showAlertDialog({ message: 'TimeOver' });
      clearInterval(this.timer);
    }
  }

  async onImageChange() {
    this.isRefresh = true;
    this.dialogController.close();
    this.numArray = [];
    this.numArray = await this.ImageModel.splitPic(this.index);
    this.init();
    this.isGameStart = false;
    this.isRefresh = false;
  }

  init() {
    this.gameTime = Common.GAME_TIME;
    clearInterval(this.timer);
  }

  gameOver() {
    let count = Common.ZERO;
    for (let i = Common.ZERO; i < Common.LOOP; i++) {
      if (this.numArray[i].index === i) {
        count++;
      } else {
        count = Common.ZERO;
        break;
      }
    }
    if (count === Common.LOOP) {
      this.isGameStart = false;
      this.getUIContext().showAlertDialog({ message: $r('app.string.congratulations') });
      clearInterval(this.timer);
      this.gameTime = Common.GAME_TIME;
    }
  }

  start() {
    this.init();
    this.timer = setInterval(() => {
      this.gameTime--;
    }, Common.TIME_NUMBER)
  }

  dialogController: CustomDialogController = new CustomDialogController({
    builder: ImagePicker({
      imagesData: this.imgData,
      index: $index
    }),
    autoCancel: true,
    gridCount: Common.GRID_COUNT
  })

  @Builder
  ImageShow() {
    Image(this.imgData[this.index].uri)
      .id(Common.IMAGE_SHOW)
      .width(Common.IMAGE_WIDTH)
      .height($r('app.float.imageShow_height'))
      .objectFit(ImageFit.Fill)
      .onClick(async () => {
        if (this.isRefresh) {
          return;
        }
        this.imgData = await this.ImageModel.getAllImg();
        setTimeout(() => {
          this.dialogController.open();
        }, Common.TIME);
      })
  }

  @Builder
  ImageGrid(leftMargin: number, topMargin: number) {
    Grid() {
      ForEach(this.numArray, (item: PictureItem, index) => {
        GridItem() {
          Image(item.pixelMap)
            .width(Common.GRID_IMAGE_WIDTH)
            .objectFit(ImageFit.Fill)
            .height($r('app.float.grid_image_height'))
        }
        .id(`image${index}`)
        .backgroundColor(item.pixelMap === undefined ? $r('app.color.blank_picture_background') : $r('app.color.picture_background'))
        .onClick(() => {
          if (this.isRefresh) {
            return;
          }
          if (this.isGameStart) {
            this.isRefresh = true;
            this.numArray = this.game.gameInit(index, this.numArray);
            this.gameOver();
            this.isRefresh = false;
          }
        })
      }, (item: PictureItem) => JSON.stringify(item))
    }
    .id(Common.IMAGE_GRID)
    .columnsTemplate(Common.COLUMN_TEMPLATE)
    .columnsGap($r('app.float.gap'))
    .rowsGap($r('app.float.gap'))
    .width(Common.IMAGE_WIDTH)
    .height($r('app.float.grid_height'))
    .margin({
      left: leftMargin,
      top: topMargin
    })
  }

  build() {
    Column() {
      Row() {
        Text(`Time:0${Math.floor(this.gameTime / Common.SECOND)}:${this.gameTime % Common.SECOND < Common.TEN
          ? Common.STRING_ZERO + this.gameTime % Common.SECOND : this.gameTime % Common.SECOND}`)
          .id(Common.TIME_STRING)
          .margin({ top: Common.MARGIN, bottom: Common.MARGIN })
      }

      if (this.imgData.length > Common.ZERO) {
        if (this.isLand) {
          Row() {
            this.ImageShow()
            this.ImageGrid(Common.TEN, Common.ZERO)
          }
          .margin({ top: Common.MARGIN })
        } else {
          Column() {
            this.ImageShow()
            this.ImageGrid(Common.ZERO, Common.FIVE)
          }
          .margin({ top: Common.MARGIN })
        }
      }
      Button($r('app.string.start'), { type: ButtonType.Capsule, stateEffect: true })
        .id(Common.START_BUTTON)
        .height($r('app.float.button_height'))
        .width(Common.FULL_WIDTH)
        .fontSize($r('app.float.button_font_size'))
        .margin({ top: Common.MARGIN })
        .backgroundColor(this.isGameStart ? $r('app.color.forbid') : $r('app.color.allow'))
        .enabled(!this.isGameStart)
        .onClick(() => {
          this.isGameStart = true;
          this.start();
          this.numArray = this.game.gameBegin(this.numArray);
        })

      Button($r('app.string.restart'), { type: ButtonType.Capsule, stateEffect: true })
        .id(Common.RESTART_BUTTON)
        .height($r('app.float.button_height'))
        .width(Common.FULL_WIDTH)
        .fontSize($r('app.float.button_font_size'))
        .margin({ top: Common.MARGIN })
        .backgroundColor(this.isGameStart ? $r('app.color.allow') : $r('app.color.forbid'))
        .enabled(this.isGameStart)
        .onClick(() => {
          this.isGameStart = true;
          this.start();
          this.numArray = this.game.gameBegin(this.numArray);
        })
    }
    .width(Common.FULL_WIDTH)
    .height(Common.FULL_HEIGHT)
    .padding({ left: Common.PERCENT, right: Common.PERCENT })
  }
}