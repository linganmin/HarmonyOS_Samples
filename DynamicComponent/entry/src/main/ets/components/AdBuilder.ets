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

import { AdParams } from '../model/AdParams';
import { AdNodeController, nodeMap } from './AdController';

// [Start AdComponent_start]
@Builder
export function adBuilder(param: AdParams) {
  AdComponent({ params: param });
}

@Component
struct AdComponent {
  params ?: AdParams;
  closeAdDialogController: CustomDialogController = new CustomDialogController({
    builder: CloseAdDialog({
      adId: this.params!.id
    }),
    backgroundBlurStyle: BlurStyle.COMPONENT_THICK,
  });

  build() {
    if (this.params!.isVideo) {
      videoAdBuilder(this.closeAdDialogController);
    } else {
      picAdBuilder(this.closeAdDialogController);
    }
  }
}
// [End AdComponent_start]

@Builder
function picAdBuilder(closeAdDialogController: CustomDialogController) {
  Stack() {
    Image($r('app.media.AdImage'))
      .objectFit(ImageFit.Cover)
      .borderRadius($r('app.string.border_radius_s'))

    upperText(closeAdDialogController)
  }
  .width($r('app.string.percent_100'))
  .height($r('app.string.pic_height'))
  .margin({ top: $r('app.string.spacing_l'), bottom: $r('app.string.spacing_l') })
}

@Builder
function videoAdBuilder(closeAdDialogController: CustomDialogController) {
  Stack() {
    VideoComponent()
    upperText(closeAdDialogController)
  }
  .width($r('app.string.percent_100'))
  .height($r('app.string.video_height'))
  .alignContent(Alignment.TopEnd)
}

@Component
struct VideoComponent {
  @State videoSrc: Resource = $rawfile('video1.mp4');
  @State previewUri: Resource = $r('app.media.app_icon');
  @State videoPlaying: boolean = false;
  controller: VideoController = new VideoController();

  build() {
    Stack() {
      Video({
        src: this.videoSrc,
        previewUri: this.previewUri,
        currentProgressRate: PlaybackSpeed.Speed_Forward_1_00_X,
        controller: this.controller
      })
        .muted(false)
        .controls(false)
        .autoPlay(false)
        .loop(false)
        .objectFit(ImageFit.Contain)
        .onClick(() => {
          this.videoPlaying = !this.videoPlaying;
          this.videoPlaying ? this.controller.start() : this.controller.pause();
        })
        .onStart(() => {
          this.videoPlaying = true;
        })
        .onPause(() => {
          this.videoPlaying = false;
        })
        .borderRadius($r('app.string.border_radius_m'))

      Image($r('app.media.VideoPlayIcon'))
        .height($r('app.string.video_play_icon_height'))
        .visibility(this.videoPlaying ? Visibility.None : Visibility.Visible)
        .hitTestBehavior(HitTestMode.Transparent)
    }
  }
}

@Builder
function upperText(closeAdDialogController: CustomDialogController) {
  Column() {
    Row() {
      Text($r('app.string.text_ad_icon'))
        .fontSize($r('app.string.ad_icon_font_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .lineHeight($r('app.string.ad_icon_line_height'))
        .padding({
          left: $r('app.string.spacing_m'),
          right: $r('app.string.spacing_m')
        })
        .borderRadius($r('app.string.border_radius_s'))
        .borderWidth($r('app.string.line_width_thin'))
        .borderColor(Color.White)
        .margin({ top: $r('app.string.spacing_s') })

      Stack() {
        Circle()
          .height($r('app.string.close_icon_size'))
          .width($r('app.string.close_icon_size'))
          .fill($r('app.string.close_icon_color'))

        Text($r('app.string.close_icon_symbol'))
          .fontColor(Color.White)
          .fontSize($r('app.string.close_icon_font_size'))
      }
      .onClick(() => {
        closeAdDialogController.open();
      })

    }
    .width($r('app.string.percent_100'))
    .padding({
      top: $r('app.string.spacing_m'),
      left: $r('app.string.spacing_l'),
      right: $r('app.string.spacing_l')
    })
    .justifyContent(FlexAlign.SpaceBetween)
  }
  .height($r('app.string.percent_100'))
  .width($r('app.string.percent_100'))
  .justifyContent(FlexAlign.SpaceBetween)
  .hitTestBehavior(HitTestMode.Transparent)
}

@CustomDialog
struct CloseAdDialog {
  dialogController: CustomDialogController;
  private adId: string = '';

  build() {
    Stack() {
      Column() {
        Text($r('app.string.text_dialog_title'))
          .fontSize($r('app.string.dialog_title_font_size'))
          .fontWeight(FontWeight.Bold)
          .lineHeight($r('app.string.dialog_title_line_height'))
          .margin({
            top: $r('app.string.spacing_xl'),
            bottom: $r('app.string.spacing_xl')
          })

        Text($r('app.string.text_dialog_description'))
          .fontSize($r('app.string.dialog_description_font_size'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.string.dialog_description_font_color'))
          .lineHeight($r('app.string.dialog_description_line_height'))
          .margin({ bottom: $r('app.string.spacing_m') })

        Row() {
          Button($r('app.string.text_dialog_cancel'))
            .onClick(() => {
              this.dialogController.close();
            })
            .buttonStyle(ButtonStyleMode.TEXTUAL)
            .height($r('app.string.dialog_button_height'))
            .width($r('app.string.dialog_button_width'))

          Divider()
            .vertical(true)
            .height($r('app.string.dialog_divider_height'))
            .strokeWidth(0.5)
            .color($r('app.string.divider_color'))
            .margin({
              left: $r('app.string.spacing_s'),
              right: $r('app.string.spacing_s'),
              top: $r('app.string.spacing_m')
            })

          // [Start block_start]
          Button($r('app.string.text_dialog_shield'))
            .onClick(() => {
              let node: AdNodeController | undefined = nodeMap.get(this.adId);
              if (node !== undefined) {
                node.remove();
                node.rebuild();
              }
              this.dialogController.close();
            })
              // [End block_start]
            .role(ButtonRole.ERROR)
            .buttonStyle(ButtonStyleMode.TEXTUAL)
            .height($r('app.string.dialog_button_height'))
            .width($r('app.string.dialog_button_width'))
        }
        .margin({ bottom: $r('app.string.spacing_xxl') })
      }
    }
    .width($r('app.string.percent_100'))
  }
}