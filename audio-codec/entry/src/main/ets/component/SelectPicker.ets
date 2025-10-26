/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import { CommonConstants } from "../common/CommonConstants";

@CustomDialog
@Component
export struct SelectPicker {
  controller?: CustomDialogController;
  @Link transCodeParam: string[];
  @Prop title: string = '';
  @Prop audioSamplingRate: number | undefined;
  @Prop audioChannelNumber: number | undefined;
  confirmBtn: () => void = () => {
  };
  confirmCancle: () => void = () => {
  };
  private codedFormat = ['AAC', 'MP3', 'G711mu', 'AMR'];
  private encapsulationFormat = [['m4a', 'aac'], ['mp3'], ['wav'], ['amr']];
  private samplingRate =
    [['8000', '12000', '16000', '22050', '24000', '32000', '44100', '48000', '64000', '88200', '96000'],
      ['16000', '22050', '24000', '32000', '44100', '48000'],
      ['8000'],
      ['8000', '16000'],
    ];
  private channelNumber =
    [['1', '2'], ['1', '2'], ['1'], ['1']];
  private cascade: TextCascadePickerRangeContent[] = [];

  aboutToAppear() {
    this.cascade = this.setRange();
    this.transCodeParam = ['AAC', 'm4a', '8000', '1']
  }

  setRange(): TextCascadePickerRangeContent[] {
    if (this.audioSamplingRate !== undefined && this.audioChannelNumber !== undefined) {
      const tempCodeFormat: string[] = [];
      const tempEncapsulationFormat: string[][] = [];
      for (let i = 0; i < this.codedFormat.length; i++) {
        const hasRate = this.samplingRate[i].find(items => Number(items) === this.audioSamplingRate);
        const hasChannel = this.channelNumber[i].find(items => Number(items) === this.audioChannelNumber);
        if (hasRate === undefined || hasChannel === undefined) {
          continue;
        }
        tempCodeFormat.push(this.codedFormat[i]);
        tempEncapsulationFormat.push(this.encapsulationFormat[i]);
      }
      return tempCodeFormat.map((code, codeIndex): TextCascadePickerRangeContent => {
        const encapsulationItems = tempEncapsulationFormat[codeIndex].map((encap): TextCascadePickerRangeContent => {
          return {
            text: encap
          };
        });

        return {
          text: code,
          children: encapsulationItems
        };
      });
    } else {
      return this.codedFormat.map((code, codeIndex): TextCascadePickerRangeContent => {
        const encapsulationItems = this.encapsulationFormat[codeIndex].map((encap): TextCascadePickerRangeContent => {
          const samplingRateItems = this.samplingRate[codeIndex].map((rate): TextCascadePickerRangeContent => {
            const channelItems = this.channelNumber[codeIndex].map((channel): TextCascadePickerRangeContent => ({
              text: channel
            }));

            return {
              text: rate,
              children: channelItems
            };
          });

          return {
            text: encap,
            children: samplingRateItems
          };
        });

        return {
          text: code,
          children: encapsulationItems
        };
      });
    }
  }

  build() {
    Column() {
      if (this.title) {
        Text(this.title)
          .fontSize(CommonConstants.BUTTON_TEXT_STYLE_FONT_SIZE)
          .fontColor($r('sys.color.black'))
          .fontSize(20)
          .height(56)
          .fontWeight(FontWeight.Bold)
      }
      TextPicker({ range: this.cascade })
        .onChange((value: string | string[]) => {
          this.transCodeParam = value as string[];
        })
        .canLoop(false)
        .margin({ bottom: $r('app.float.common_image') })

      Row() {
        Button($r('app.string.picker_btn_cancel'), { buttonStyle: ButtonStyleMode.TEXTUAL, role: ButtonRole.NORMAL, stateEffect: false })
          .fontSize(CommonConstants.BUTTON_TEXT_STYLE_FONT_SIZE)
          .fontColor('#0A59F7')
          .onClick(() => {
            this.confirmCancle();
          })
        Divider()
          .vertical(true)
          .height(22)
          .color($r('sys.color.mask_fourth'))
          .opacity(0.6)
          .margin({ left: 50, right: 50 })
        Button($r('app.string.picker_btn_confirm'), { buttonStyle: ButtonStyleMode.TEXTUAL, role: ButtonRole.NORMAL, stateEffect: false })
          .fontSize(CommonConstants.BUTTON_TEXT_STYLE_FONT_SIZE)
          .fontColor('#0A59F7')
          .onClick(() => {
            this.confirmBtn()
          })
      }
      .width(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Center)
      .margin({ bottom: $r('app.float.button_margin_bottom') })
    }
    .backgroundColor('#0C182431')
    .borderRadius($r('app.float.audio_border_raduis'))
    .padding({ left: $r('app.float.common_height'), right: $r('app.float.common_height') })
  }
}