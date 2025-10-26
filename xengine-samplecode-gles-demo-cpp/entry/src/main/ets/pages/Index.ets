/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import nativeRender from 'libnativerender.so';
import CommonConstants from '../common/CommonConstants';
import { ContextType } from '../entryability/EntryAbility';

const nativePageLifecycle: Record<string, () => void> =
  nativeRender.getContext(ContextType.PAGE_LIFECYCLE) as Record<string, () => void>;

@Entry
@Component
struct Index {
  private xComponentContext: Record<string, (a: number | boolean | undefined) => void> = {};

  aboutToAppear(): void {
    console.log('[LIFECYCLE-Index] aboutToAppear');
    nativePageLifecycle.aboutToAppear();
  }

  aboutToDisappear(): void {
    console.log('[LIFECYCLE-Index] aboutToDisappear');
    nativePageLifecycle.aboutToDisappear();
  }

  onPageShow(): void {
    console.log('[LIFECYCLE-Page] onPageShow');
    nativePageLifecycle.onPageShow();
  }

  onPageHide(): void {
    console.log('[LIFECYCLE-Page] onPageHide');
    nativePageLifecycle.onPageHide();
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      XComponent({
        id: CommonConstants.XCOMPONENT_ID,
        type: XComponentType.SURFACE,
        libraryname: CommonConstants.XCOMPONENT_LIBRARY_NAME
      })
        .onLoad((xComponentContext?: object| Record<string, (a: number | boolean |undefined) => void>) => {
          if (xComponentContext) {
            this.xComponentContext = xComponentContext as Record<string, (a: number | boolean | undefined) => void>;
          }})
        .width('100%')
        .height('100%')

      Row() {
        Column() {
          Select([{ value: 'no upscale'},
            { value: 'neural upscale'},
            { value: 'spatial upscale'},
            { value: 'fsr upscale'}
          ])
            .selected(0)
            .value('choose upscale method')
            .font({ size: 16, weight: 500 })
            .fontColor('#182431')
            .selectedOptionFont({ size: 16, weight: 400 })
            .optionFont({ size: 16, weight: 400 })
            .onSelect((index: number) => {
              console.info('Select:' + index)
              this.xComponentContext.setUpscaleMethod(index);
            })
        }.width('50%')

        Column() {
          Checkbox({name: 'checkbox1',  group: 'checkboxGroup'})
            .height(20)
            .width(20)
            .select(false)
            .selectedColor(0xed6f21)
            .onChange((value: boolean) => {
              if (this.xComponentContext) {
                this.xComponentContext.setVRSUsed(value);
              }
              console.info('Checkbox1 change is'+ value)
            })
          Text('useVRS')
        }

      }.height('10%').width('60%')

    }.width('100%').height('100%').align(Alignment.TopStart)
  }
}