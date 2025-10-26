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

import { CommonConstants } from '../common/constants/CommonConstants';
import { AvPlayerController } from '../controller/AvPlayerController';
import { WindowUtil } from '../common/utils/WindowUtil';
import { SpeedDialog } from './SpeedDialog';
import { LanguageDialog } from './LanguageDialog';

AppStorage.setOrCreate('isMuted', false);
AppStorage.setOrCreate('speedName', $r('app.string.video_speed_1_0X'));

@Component
export default struct VideoToolBar {
  @Link avPlayerController: AvPlayerController;
  @Link isSliding: boolean;
  private windowUtil: WindowUtil = WindowUtil.getInstance();
  @StorageLink('isFullLandscapeScreen') isFullLandscapeScreen: boolean = false;
  @StorageLink('isMuted') isMuted: boolean = false;
  @StorageLink('speedIndex') speedIndex: number = 0; // Index of the playback rate list.
  @StorageLink('speedName') speedName: Resource = $r('app.string.video_speed_1_0X');
  @State speedSelect: number = 0; // Speed Magnification Selection
  @State languageSelect: number = 0;
  @StorageLink('currentLanguageType') currentLanguageType: number = 0;
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: SpeedDialog({ speedSelect: $speedSelect, avPlayerController: this.avPlayerController }),
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: $r('app.float.size_down_20') }
  });
  private languageDialogController: CustomDialogController = new CustomDialogController({
    builder: LanguageDialog({ languageSelect: $languageSelect, avPlayerController: this.avPlayerController }),
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: $r('app.float.size_down_20') }
  });
  @BuilderParam
  toolBarButtonBuilder: () => void = this.defaultToolBarButtonBuilder;

  @Builder
  defaultToolBarButtonBuilder() {
  }

  @Builder
  showFeatureIcon(src: ResourceStr, content?: ResourceStr) {
    Row({ space: 3 }) {
      Image(src)
        .width(22)
      if (content) {
        Text(content)
          .fontSize(14)
          .lineHeight(19)
          .fontColor(Color.White)
      }
    }
  }

  build() {
    Column() {
      Row() {
        Slider({
          value: this.avPlayerController.currentTime,
          min: CommonConstants.SLIDER_PROGRESS_MIN,
          max: this.avPlayerController.durationTime,
          step: CommonConstants.SLIDER_PROGRESS_STEP,
          direction: Axis.Horizontal,
          style: SliderStyle.NONE
        })
          .blockColor(Color.White)
          .trackColor($r('app.color.white_opacity_1_color'))
          .selectedColor(Color.Gray)
          .trackThickness(this.isSliding ? 10 : 3)
          .onChange((value: number, mode: SliderChangeMode) => {
            if (mode === SliderChangeMode.Moving) {
              this.isSliding = true
              this.avPlayerController.videoSeek(value);
            } else if (mode === SliderChangeMode.End) {
              this.isSliding = false;
            }
          })
          .zIndex(0)
          .layoutWeight(1)

        // [Start video_speed_button]
        Button(this.speedName, { type: ButtonType.Normal })
          .border({ width: $r('app.float.size_1'), color: Color.White })
          .width($r('app.float.size_64'))
          .height($r('app.float.size_25'))
          .fontSize($r('app.float.size_15'))
          .borderRadius($r('app.float.size_20'))
          .fontColor(Color.White)
          .backgroundColor('rgba(0, 0, 0, 0)')
          .opacity($r('app.float.size_1'))
          .padding({ left: $r('app.float.size_5'), right: $r('app.float.size_5') })
          .margin({ left: $r('app.float.size_8') })
          .id('Speed')
          .visibility(this.isFullLandscapeScreen ? Visibility.Visible : Visibility.None)
          .onClick(() => {
            this.speedSelect = this.speedIndex;
            this.dialogController.open();
          })
        // [End video_speed_button]

        Button() {
          Image(this.isMuted ? $r('app.media.ic_video_speaker_slash') : $r('app.media.ic_video_speaker'))
            .width($r('app.float.size_25'))
            .height($r('app.float.size_25'))
        }
        .visibility(this.isFullLandscapeScreen ? Visibility.Visible : Visibility.None)
        .type(ButtonType.Normal)
        .width($r('app.float.size_40'))
        .height($r('app.float.size_40'))
        .borderRadius($r('app.float.size_20'))
        .backgroundColor('rgba(0, 0, 0, 0)')
        .margin({ left: $r('app.float.size_5') })
        .fontColor(Color.White)
        .onClick(() => {
          this.isMuted = !this.isMuted;
          this.avPlayerController.videoMuted(this.isMuted)
        })

        Image($r('app.media.translate'))
          .fillColor($r('sys.color.white'))
          .width($r('app.float.size_25'))
          .height($r('app.float.size_25'))
          .margin({ left: 5 })
          .onClick(() => {
            this.languageSelect = this.currentLanguageType;
            this.languageDialogController.open();
          })
        Stack() {
          Image($r('app.media.ic_video_menu_landscape_fullscreen'))
            .fillColor($r('sys.color.white'))
            .width($r('app.float.size_25'))
            .height($r('app.float.size_25'))
            .margin({ left: 5 })
        }
        .width(30)
        .height(30)
        .onClick(() => {
          this.windowUtil.handleFullScreen(true);
        })
        .visibility(this.isFullLandscapeScreen ? Visibility.None : Visibility.Visible)

        this.toolBarButtonBuilder()
      }
      .width('100%')
      .padding({ left: 5, right: 5 })
      .zIndex(CommonConstants.ROW_CONTROLLER_Z_INDEX)

      Row({ space: 18 }) {
        this.showFeatureIcon($r('app.media.menu_icon_like'), '1557')
        this.showFeatureIcon($r('app.media.menu_icon_comment'), '566')
        this.showFeatureIcon($r('app.media.menu_icon_share'), '147')
      }
      .justifyContent(FlexAlign.Start)
      .width('100%')
      .margin({ left: 25 })
      .visibility(this.isFullLandscapeScreen ? Visibility.Visible : Visibility.None)
    }

  }
}