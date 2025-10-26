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

import { ObjectLinkComponent } from './ObjectLinkComponent';
import { ViewCodeText } from '../../../../../commoncomponents/ViewCodeText';

// The class of the element in the array, modified by @Observed.
@Observed
export class ClassObject {
  public elementType: Resource;
  public attributeType: Resource | string;

  constructor(elementType: Resource, attributeType: Resource | string) {
    this.elementType = elementType;
    this.attributeType = attributeType;
  }
}

// Initializes the data in the parent component.
const PARENT_DATA: ClassObject[] = [new ClassObject($r('app.string.partial_sync_element_one'), $r('app.string.partial_sync_attribute_one')),
  new ClassObject($r('app.string.partial_sync_element_two'), $r('app.string.partial_sync_attribute_two')),
  new ClassObject($r('app.string.partial_sync_element_three'), $r('app.string.partial_sync_attribute_three'))];

@Component
export struct ParentChildPartialContentSyncCode {
  // Initializes the state variable in the parent component.
  @State parentData: ClassObject[] = PARENT_DATA;
  // The data synchronized with the child component is the number of elements in the array, with the first selected by default.
  @State syncIndex: number = 0;

  build() {
    Column({ space: 10 }) {
      // Click to view source code.
      ViewCodeText({ webSrc: $rawfile('ParentChildPartialContentSyncCode.ets.html') })

      Text($r('app.string.partial_sync_parent_tips'))
        .fontColor($r('app.color.tips_font_color'))
        .fontSize($r('app.float.tips_font_size'))
        .width('100%')
        .textAlign(TextAlign.Start)
      // List in the parent component shows the contents of the state variable.
      Column() {
        ForEach(this.parentData, (item: ClassObject, index: number) => {
          Column() {
            ParentCompDataItem({ index: index, syncIndex: this.syncIndex, childObject: item })
          }
          .backgroundColor(index === this.syncIndex ? $r('app.color.component_background_pink') : undefined)
          .onClick(() => {
            this.syncIndex = index;
          })
        }, (item: ClassObject) => JSON.stringify(item))
      }
      .width('100%')
      .backgroundColor($r('app.color.component_background_pink'))

      // A child component whose state is synchronized with the parent component.
      ObjectLinkComponent({ childObjectData: this.parentData[this.syncIndex] })
    }
    .width('100%')
    .padding(10)
    .border({ radius: $r('app.float.component_radius'), color: Color.Grey, width: $r('app.float.border_width') })
  }
}

// Shows the child components of a single element in an array.
@Component
struct ParentCompDataItem {
  index: number = 0;
  @Prop syncIndex: number;
  // Decorated with @ObjectLink to synchronize with elements in the parent component.
  @ObjectLink childObject: ClassObject;

  build() {
    Column() {
      Text(this.childObject.elementType)
        .width('100%')
        .fontSize(20)
      if (this.index === this.syncIndex) {
        TextInput({ text: this.childObject.attributeType })
          .fontSize(20)
          .id(`attribute${this.index + 1}`)
          .onChange((value: string) => {
            // Update the attributes of elements in the parent component, and the child component synchronizes.
            this.childObject.attributeType = value;
          })
      } else {
        Text(this.childObject.attributeType)
          .width('100%')
          .fontSize(20)
      }
    }
    .padding(10)
    .id(`arrayElement${this.index}`)
  }
}

