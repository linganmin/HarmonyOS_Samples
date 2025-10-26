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

import { promptAction } from '@kit.ArkUI';
import { ViewCodeText } from '../../../../../commoncomponents/ViewCodeText';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

// The class of an element in an array.
export class ArrayDataType {
  public id: number;
  public name: string;
  public age: number;

  constructor(id: number, name: string, age: number) {
    this.id = id;
    this.name = name;
    this.age = age;
  }
}

// Initializes the array data.
const ARRAY_TYPE_AGE_DATA: ArrayDataType[] = [new ArrayDataType(0, 'name', 17), new ArrayDataType(1, 'name', 18),
  new ArrayDataType(2, 'name', 19)]
// Initializes the function button string data.
const ARRAY_TYPE_BTN: Resource[] = [$r('app.string.array_type_add'), $r('app.string.array_type_delete'),
  $r('app.string.array_type_update')];

@Component
export struct ArrayTypeCode {
  // Array type state variable initialization.
  @State arrayTypeData: ArrayDataType[] = ARRAY_TYPE_AGE_DATA;

  build() {
    Column({ space: 10 }) {
      // Click to view source code.
      ViewCodeText({ webSrc: $rawfile('ArrayTypeCode.ets.html') })
      // Array content presentation.
      List() {
        ForEach(this.arrayTypeData, (item: ArrayDataType, index: number) => {
          ListItem() {
            ArrayDataItem({ arrayDataItem: item, itemIndex: index })
          }
        }, (item: ArrayDataType) => JSON.stringify(item))
      }
      .width('100%')
      .height('40%')
      .backgroundColor($r('app.color.component_background_pink'))
      .padding({ left: 10, right: 10 })

      // Function button area.
      ForEach(ARRAY_TYPE_BTN, (item: Resource, index: number) => {
        Button(item)
          .id(`arrayTypeBtn${index}`)
          .width('100%')
          .height($r('app.float.button_height'))
          .fontColor($r('app.color.button_text_color'))
          .fontSize($r('app.float.button_text_size'))
          .type(ButtonType.Capsule)
          .backgroundColor($r('app.color.button_background_color'))
          .onClick(() => {
            this.handleButtonClick(index)
          })
      }, (item: Resource) => JSON.stringify(item))
    }
    .padding(10)
    .border({ radius: $r('app.float.component_radius'), color: Color.Grey, width: $r('app.float.border_width') })
  }

  handleButtonClick(index: number) {
    switch (index) {
      case 0:
      // Array addition element.
        this.arrayTypeData.push(new ArrayDataType(this.arrayTypeData.length, `name`, 18)); // 新增元素数据，age为18
        break;
      case 1:
        if (this.arrayTypeData.length === 0) {
          // When there is no data, click the delete button and a pop-up window will appear.
          try {
            this.getUIContext().getPromptAction().showToast({
              message: $r('app.string.array_type_deletetoast')
            });
          } catch (error) {
            let err = error as BusinessError;
            hilog.error(0x0000, 'ArrayTypeCode', `showToast failed. code=${err.code}, message=${err.message}`);
          }
        } else {
          // Array deletion element.
          this.arrayTypeData.splice(this.arrayTypeData.length - 1, 1); // 删除最后一个元素
        }
        break;
      case 2:
        if (this.arrayTypeData.length === 0) {
          // When there is no data, click the update button and a pop-up window will appear.
          try {
            this.getUIContext().getPromptAction().showToast({
              message: $r('app.string.array_type_updatetoast')
            });
          } catch (error) {
            let err = error as BusinessError;
            hilog.error(0x0000, 'ArrayTypeCode', `showToast failed. code=${err.code}, message=${err.message}`);
          }
          break;
        }
      // Update array elements after initializing an object by assigning values to the elements in the array.
        let temp = new ArrayDataType(this.arrayTypeData[0].id, this.arrayTypeData[0].name, this.arrayTypeData[0].age + 1);
        this.arrayTypeData[0] = temp;
        break;
      default:
        break;
    }
  }
}

// Array Item content component.
@Component
struct ArrayDataItem {
  arrayDataItem: ArrayDataType = new ArrayDataType(0, '', 0);
  itemIndex: number = 0;

  build() {
    Column() {
      Text(`${this.arrayDataItem.name}${this.itemIndex}`)
        .width('100%')
        .fontColor($r('app.color.button_text_color'))
        .fontSize(20)
      Text(`age:${this.arrayDataItem.age}`)
        .width('100%')
        .fontColor($r('app.color.button_text_color'))
        .fontSize(20)
      Divider().width('100%')
        .strokeWidth(1)
        .margin({ top: 20 })
    }
    .margin({ top: 20 })
  }
}