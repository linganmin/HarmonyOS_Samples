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

import { unifiedDataChannel, uniformDataStruct, uniformTypeDescriptor } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { getStringSync } from '../../utils/StringUtil';

const TAG = '[Sample_DragFramework]';

@Builder
export function PageListBuilder() {
  ListDrag();
}

@Component
struct SelectTableList {
  @State arr: Array<string> = [];
  @State selectedArr: Array<boolean> = [];
  public tag: string = '';

  build() {
    List({ space: '8vp' }) {
      ForEach(this.arr, (item: string, index) => {
        ListItem() {
          Row() {
            Checkbox()
              .shape(CheckBoxShape.CIRCLE)
              .select(this.selectedArr[index])
              .onChange((value: boolean) => {
                if (value) {
                  this.selectedArr[index] = true;
                } else {
                  this.selectedArr[index] = false;
                }
              })
              .mark({
                size: 24
              })
              .margin({ right: '12vp' })
            Text(item)
          }.width('100%')
        }
        .draggable(this.selectedArr[index])
        .height('48vp')
        .width('100%')
        .padding({ left: '12vp' })
        .backgroundColor($r('sys.color.comp_background_primary'))
        .borderRadius(16)
        .onDragStart((event: DragEvent) => {
          let unifiedData = new unifiedDataChannel.UnifiedData();
          this.selectedArr.forEach((value: boolean, index: number) => {
            if (value) {
              let textData: uniformDataStruct.PlainText = {
                uniformDataType: 'general.plain-text',
                textContent: this.arr[index]
              }
              let unifiedRecord =
                new unifiedDataChannel.UnifiedRecord(uniformTypeDescriptor.UniformDataType.PLAIN_TEXT, textData);
              unifiedData.addRecord(unifiedRecord);
            }
          })
          event.setData(unifiedData);
        })
      }, (item: string, index) => item + this.selectedArr[index])
    }
    .width('100%')
    .height('100%')
    .allowDrop([uniformTypeDescriptor.UniformDataType.PLAIN_TEXT])
    .onDrop((event: DragEvent) => {
      try {
        let dragData = event.getData();
        let records = dragData.getRecords();
        for (let record of records) {
          let types = record.getTypes();
          if (types.includes(uniformTypeDescriptor.UniformDataType.PLAIN_TEXT)) {
            const plainTextUds =
              record.getEntry(uniformTypeDescriptor.UniformDataType.PLAIN_TEXT) as uniformDataStruct.PlainText;
            let textIndex = this.arr.indexOf(plainTextUds.textContent);
            if (textIndex < 0) {
              this.arr.splice(this.arr.length, 0, plainTextUds.textContent);
              this.selectedArr.push(false);
            }
          }
        }
        event.setResult(DragResult.DRAG_SUCCESSFUL);
      } catch (error) {
        const err = error as BusinessError;
        hilog.error(0x0000, TAG, `startDataLoading errorCode: ${err.code}, errorMessage: ${err.message}`);
      }
    })
  }

  aboutToAppear() {
    for (let i = 0; i < 8; i++) {
      this.arr.push(this.tag + ' item' + i.toString());
    }
  }
}

@Entry
@Component
struct ListDrag {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  private context: UIContext = this.getUIContext();

  build() {
    NavDestination() {
      Row({ space: '8vp' }) {
        SelectTableList({ tag: 'List1' }).layoutWeight(1);
        SelectTableList({ tag: 'List2' }).layoutWeight(1);
      }
      .width('100%')
      .constraintSize({ maxWidth: '100%' })
      .backgroundColor($r('sys.color.background_secondary'))
      .margin({
        top: '8vp',
        bottom: '16vp',
        left: '16vp',
        right: '16vp'
      })
    }
    .title(getStringSync(this.context.getHostContext()!, $r('app.string.list_title').id))
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}