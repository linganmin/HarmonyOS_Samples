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

import { CustomButton } from '../customcomponent/CustomButton'
import { audio } from '@kit.AudioKit';
import { SegmentButton, SegmentButtonItemTuple, SegmentButtonOptions } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  pageStack: NavPathStack = new NavPathStack();
  @State selectOptions: SegmentButtonOptions = SegmentButtonOptions.capsule({
    buttons: [{ text: 'Mix' }, { text: 'Duck' }, { text: 'Pause' }, { text: 'Default' }] as SegmentButtonItemTuple,
    multiply: false,
    fontSize: $r('sys.float.Body_M'),
    fontWeight: FontWeight.Medium,
    fontColor: $r('sys.color.font_secondary'),
    backgroundColor: $r('sys.color.comp_background_tertiary'),
    selectedFontSize: $r('sys.float.Body_M'),
    selectedFontWeight: FontWeight.Medium,
    selectedFontColor: $r('sys.color.font_primary'),
    selectedBackgroundColor: $r('sys.color.comp_background_primary_contrary'),
    backgroundBlurStyle: BlurStyle.COMPONENT_THIN,
    textPadding: { left: 16, right: 16 },
    buttonPadding: { top: 2, bottom: 2, left: 2, right: 2 }
  });
  @State @Watch('selectButtonCallBack') selectedIndexes: number[] = [3];

  selectButtonCallBack() {
    let audioMode: audio.AudioConcurrencyMode = audio.AudioConcurrencyMode.CONCURRENCY_DEFAULT;
    switch(this.selectedIndexes[0]) {
      case 0:
        audioMode = audio.AudioConcurrencyMode.CONCURRENCY_MIX_WITH_OTHERS;
        break;
      case 1:
        audioMode = audio.AudioConcurrencyMode.CONCURRENCY_DUCK_OTHERS;
        break;
      case 2:
        audioMode = audio.AudioConcurrencyMode.CONCURRENCY_PAUSE_OTHERS;
        break;
      case 3:
        audioMode = audio.AudioConcurrencyMode.CONCURRENCY_DEFAULT;
        break;
    }
    AppStorage.setOrCreate<audio.AudioConcurrencyMode>('audioConcurrencyMode', audioMode);
  }

  aboutToAppear(): void {
    AppStorage.setOrCreate<audio.AudioConcurrencyMode>(
      'audioConcurrencyMode', audio.AudioConcurrencyMode.CONCURRENCY_DEFAULT);
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        // Used to customize the focus policy selection for AudioSession
        SegmentButton({ options: this.selectOptions, selectedIndexes: this.selectedIndexes})
          .width(328)
          .height(40)
          .margin({ top: 16, bottom: 16})
        // Click to jump to the video scene
        CustomButton({
          buttonName: $r('app.string.video_scene_button'),
          buttonOnClick: () => {this.pageStack.pushPathByName('videoScenePage', null)}
        });

        // Click to jump to the music scene
        CustomButton({
          buttonName: $r('app.string.audio_scene_button'),
          buttonOnClick: () => {this.pageStack.pushPathByName('audioScenePage', null)}
        });

        // Click to jump to the voice call scenario
        CustomButton({
          buttonName: $r('app.string.voip_chart_button'),
          buttonOnClick: () => {this.pageStack.pushPathByName('voIPScenePage', null)}
        });
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
    }
    .title($r('app.string.audio_demo_title'))
  }
}