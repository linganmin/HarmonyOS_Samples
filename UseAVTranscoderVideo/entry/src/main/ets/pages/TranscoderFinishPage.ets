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
import { bundleManager } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { outputPathCommon } from '../utils/AVTranscoderManager'

@Component
export struct TranscoderFinishPage {
  @Consume('pathInfos') pathInfos: NavPathStack;
  @State outputFilePath: string = '';
  @State filePath: string = '';

  getParamsPrint() {
    const params: outputPathCommon = JSON.parse(JSON.stringify(this.pathInfos.getParamByName('TranscoderFinishPage')[0]));
    console.info('params', params);
    this.outputFilePath = params.outputFilePath;
    const bundleName: string = this.getBundleName();
    this.filePath = 'file://' + bundleName + params.outputFilePath;
  }

  // Get the current HAP package name
  getBundleName(): string {
    let bundleFlags = bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT;
    let bundleName: string = '';
    try {
      bundleManager.getBundleInfoForSelf(bundleFlags).then((data) => {
        bundleName = data.name;
        hilog.info(0x0000, 'testTag', 'getBundleInfoForSelf successfully. Data: %{public}s', JSON.stringify(data));
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, 'testTag', 'getBundleInfoForSelf failed. Cause: %{public}s', err.message);
      });
    } catch (err) {
      let message = (err as BusinessError).message;
      hilog.error(0x0000, 'testTag', 'getBundleInfoForSelf failed: %{public}s', message);
    }
    return bundleName;
  }
  build() {
    NavDestination() {
      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
        Column() {
          Video({ src: this.filePath })
            .autoPlay(true)
            .controls(false)
            .loop(true)
        }
        .width('100%')
        .height('292vp')
        .flexShrink(0)

        Column() {
          Row() {
            Text() {
              SymbolSpan($r('sys.symbol.checkmark_circle'))
                .fontSize('22vp')
                .fontColor(['#64BB5C'])
            }
            Text($r('app.string.convert_success'))
              .fontSize('14vp')
              .fontColor('rgba(0, 0, 0, 0.9)')
              .margin({ left: '9vp' })
          }
          .justifyContent(FlexAlign.Center)
          .padding({ top: '12.5vp', bottom: '12.5vp' })
          .width('100%')
          .backgroundColor(Color.White)
          .borderRadius('12vp')

          Row() {
            Text(`Storage Path：${this.outputFilePath}`)
              .fontSize('12vp')
              .fontColor('rgba(0, 0, 0, 0.6)')
              .maxLines(2)
          }
          .width('100%')
          .margin({ top: '12vp' })
        }
        .margin({ top: '8vp' })
        .padding('16vp')
        .flexGrow(1)

        Column() {
          Button($r('app.string.button_back'), { buttonStyle: ButtonStyleMode.EMPHASIZED, role: ButtonRole.NORMAL })
            .width('100%')
            .onClick(() => {
              this.pathInfos.pop();
            })
        }
        .width('100%')
        .padding('16vp')
        .flexShrink(0)
      }
    }
    .title($r('app.string.transcoder_result'))
    .height('100%')
    .width('100%')
    .backgroundColor('#F1F3F5')
    .onShown(() => {
      this.getParamsPrint();
    })
  }
}