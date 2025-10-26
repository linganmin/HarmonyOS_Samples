/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:如何在AVRecorder录制wav格式的音频文件时正确配置AVRecorderProfile参数？
 */
import { media } from '@kit.MediaKit';

@Entry
@Component
struct AVRecorderProfile {
  @State message: string = 'Hello World';
  // [Start AVRecorderProfile]
  private avProfile: media.AVRecorderProfile = {
    audioBitrate: 64000, // set audioBitrate according to device ability.
    audioChannels: 1, // set audioChannels,valid value 1-8,CFT_WAV supports 1.
    audioCodec: media.CodecMimeType.AUDIO_G711MU, // set audioCodec,AUDIO_G711MU matching CFT_WAV.
    audioSampleRate: 8000, // set audioSampleRate according to device ability.
    fileFormat: media.ContainerFormatType.CFT_WAV // set fileFormat,CFT_WAV.
  }

  // [End AVRecorderProfile]

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message = 'Welcome';
        })
    }
    .height('100%')
    .width('100%')
  }
}