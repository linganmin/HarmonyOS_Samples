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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { formInfo } from '@kit.FormKit';
import { CommonConstants } from '../../constants/CommonConstants';
import ImageUtils from '../../utils/ImageUtils';
import { SongItem } from '../../viewmodel/SongItem';

const TAG: string = '[LiveForm]';
const End_SCALE: number = 1.4;
const END_XTRANSLATE: number = 30;
const END_YTRANSLATE: number = -40;
const ROTATE_ANGLE: number = 180;
let storage: LocalStorage = new LocalStorage();

const SingerAlignRules: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
  'top': { 'anchor': 'musicTitle', 'align': VerticalAlign.Bottom },
  'left': { 'anchor': 'musicCover', 'align': HorizontalAlign.End }
};

const CollectAlignRules: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
  'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
  'right': { 'anchor': '__container__', 'align': HorizontalAlign.End }
};

const CoverAlignRules: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
  'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom }
};

const PlayAlignRules: Record<string, Record<string, string | VerticalAlign | HorizontalAlign>> = {
  'bottom': { 'anchor': '__container__', 'align': VerticalAlign.Bottom },
  'right': { 'anchor': '__container__', 'align': HorizontalAlign.End }
};

@Entry(storage)
@Component
struct NewExtensionPage {
  @State singer: string = 'Delacey';
  @State title: string = 'Dream It Possible';
  @State imageColorHex: string = '4c3e3c';
  @State musicCover: Resource = $r('app.media.ic_dream');
  @State isCollected: boolean = false;
  @State columnScale: number = 1.0;
  @State rowTranslate: number = 0.0;
  @State columnTranslate: number = 0.0;
  @State rotateAngle: number = 0;
  @State columnBackgroundColor: Color = Color.Blue;
  @State imageColorHex02: string = '706563';
  @StorageLink('currentSong') currentSong: SongItem = new SongItem();
  private formWidth: number = 0;
  private formHeight: number = 0;
  private formLeft: number = 0;
  private formBottom: number = 0;
  private formRadius: number = 0;

  async aboutToAppear(): Promise<void> {
    hilog.info(0x0000, TAG, `NewExtensionPage aboutToAppear`);
    let localStorage: LocalStorage | undefined = this.getUIContext()?.getSharedLocalStorage();
    let formRect = localStorage?.get<formInfo.Rect>('formRect');
    let borderRadius = localStorage?.get<number>('radius');
    this.formWidth = formRect? formRect.width : 0;
    this.formHeight = formRect? formRect.height : 0;
    this.formLeft = formRect? formRect.left : 0;
    this.formBottom = formRect? formRect.height * CommonConstants.LIVE_CARD_RATIO - formRect.top - formRect.height : 0;
    this.formRadius = borderRadius? borderRadius : 0;

    this.getImageColor();
  }

  getImageColor() {
    ImageUtils.getImageDealData(this.getUIContext().getHostContext()!, this.currentSong.label).then((data) => {
      this.imageColorHex = data.imageColorHex;
    })
  }

  private runEnlargeAnimation(): void {
    this.getUIContext().animateTo({
      duration: 1700,
      curve: Curve.Friction,
      delay: 100,
      iterations: -1,
      playMode: PlayMode.Alternate,
      expectedFrameRateRange: {
        min: 10,
        max: 120,
        expected: 60,
      }
    }, () => {
      this.columnScale = End_SCALE;
      this.columnTranslate = END_YTRANSLATE;
      this.rowTranslate = END_XTRANSLATE;
      this.rotateAngle = ROTATE_ANGLE;
    })
  }

  // [Start overflow]
  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      RelativeContainer() {
        // [StartExclude overflow]
        Text($r(this.currentSong.title))
          .fontSize(14)
          .fontWeight(700)
          .width('85%')
          .fontColor(Color.White)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .maxLines(1)
          .id('musicTitle')

        Text($r(this.currentSong.singer))
          .fontSize(12)
          .fontColor($r('sys.color.font_secondary'))
          .fontWeight(500)
          .maxLines(1)
          .alignRules(SingerAlignRules)
          .margin({ top: 2 })
          .id('singerText')

        SymbolGlyph(this.isCollected ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
          .fontSize(24)
          .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), true)
          .fontColor(['#E5FFFFFF'])
          .alignRules(CollectAlignRules)

        SymbolGlyph($r('sys.symbol.pause_round_triangle_fill'))
          .fontSize(36)
          .symbolEffect(new ReplaceSymbolEffect(EffectScope.WHOLE), true)
          .fontColor(['#E5FFFFFF'])
          .alignRules(PlayAlignRules)
        // [EndExclude overflow]
      }
      .height(this.formHeight)
      .width(this.formWidth)
      .borderRadius(this.formRadius)
      .padding(12)
      .linearGradient({
        direction: GradientDirection.Bottom,
        repeating: false,
        colors: [[`#ff${this.imageColorHex}`, 0.0], [`#ff${this.imageColorHex}`, 0.5],
          [`#ff${this.imageColorHex}`, 1.0]]
      })
      .margin({
        left: this.formLeft,
        bottom: this.formBottom
      })

      Stack({ alignContent: Alignment.Center }) {
        Image($r('app.media.blackVinyl'))
          .height(88)
          .width(88)

        Button()
          .backgroundImage(this.currentSong.label)
          .backgroundImageSize(ImageSize.Cover)
          .height(58)
          .width(58)
          .backgroundColor($r('sys.color.titlebar_icon_background_color'))
      }
      .alignRules(CoverAlignRules)
      .margin({
        left: CommonConstants.ANIMATE_COMPONENT_LEFT,
        bottom: CommonConstants.ANIMATE_COMPONENT_BOTTOM
      })
      .scale({
        x: this.columnScale,
        y: this.columnScale
      })
      .translate({
        x: this.columnTranslate,
        y: this.rowTranslate
      })
      .rotate({
        x: 0,
        y: 0,
        z: 1,
        angle: this.rotateAngle
      })
      .onAppear(() => {
        this.runEnlargeAnimation();
      })
    }
    .width('100%')
    .height('100%')
  }
  // [End overflow]
}