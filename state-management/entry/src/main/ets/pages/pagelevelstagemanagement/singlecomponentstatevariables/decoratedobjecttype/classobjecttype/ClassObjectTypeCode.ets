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

import { common } from '@kit.AbilityKit';
import { ViewCodeText } from '../../../../../commoncomponents/ViewCodeText';
import { getResourceString } from '../../../../../utils/ResourceUtils';

@Component
export struct ClassObjectTypeCode {
  // Object type state variable initialization.
  @State classObjectData: ParentClass =
    new ParentClass(getResourceString(this.getUIContext().getHostContext() as common.UIAbilityContext,
      $r('app.string.class_object')),
      getResourceString(this.getUIContext().getHostContext() as common.UIAbilityContext,
        $r('app.string.class_attribute')), 1,
      new ChildClass(getResourceString(this.getUIContext().getHostContext() as common.UIAbilityContext,
        $r('app.string.class_child_attribute')), 2));
  // The number of times an object was updated.
  private clickedCount: number = 0;

  build() {
    Column({ space: 10 }) {
      // Click to view source code.
      ViewCodeText({ webSrc: $rawfile('ClassObjectTypeCode.ets.html') })
      Column({ space: 15 }) {
        Row() {
          Text(this.classObjectData.title)
            .fontSize(20)
            .textAlign(TextAlign.End)
          Divider()
            .layoutWeight(1)
            .strokeWidth(1)
            .margin({ top: 20, left: 5 })
        }
        .width('100%')

        Column() {
          Row() {
            Text(this.classObjectData.attributeTitle)
              .fontSize(20)
            Text(`${this.classObjectData.attribute}`)
              .fontSize(20)
              .textAlign(TextAlign.End)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)

          Divider()
            .width('100%')
            .strokeWidth(1)
        }
        .width('100%')
        .padding({ left: 50 })

        ChildObjectComp({ childObject: this.classObjectData.child }) // The properties of the object, displayed using subcomponents.
      }
      .width('100%')
      .backgroundColor($r('app.color.component_background_pink'))
      .padding(10)
      // Click Update object.
      Button($r('app.string.class_type_update_object'))
        .onClick(() => {
          // Update the object, assigning the new object directly to the state variable.
          this.clickedCount++;
          let objectTitle: string = getResourceString(this.getUIContext().getHostContext() as common.UIAbilityContext,
            $r('app.string.class_object')) + this.clickedCount;
          let attributeTitle: string =
            getResourceString(this.getUIContext().getHostContext() as common.UIAbilityContext,
              $r('app.string.class_attribute')) + this.clickedCount;
          let childAttributeTitle: string =
            getResourceString(this.getUIContext().getHostContext() as common.UIAbilityContext,
              $r('app.string.class_child_attribute'))
              + this.clickedCount;
          let newObject = new ParentClass(objectTitle, attributeTitle, this.classObjectData.attribute + 1,
                          new ChildClass(childAttributeTitle, this.classObjectData.child.attribute + 1));
          this.classObjectData = newObject;
        })
        .id('updateObject')
        .fontColor($r('app.color.button_text_color'))
        .fontSize($r('app.float.button_text_size'))
        .type(ButtonType.Capsule)
        .buttonStyle(ButtonStyleMode.NORMAL)
      Button($r('app.string.class_type_update_attribute'))
        .onClick(() => {
          // Click Update object properties.
          this.classObjectData.attribute++;
        })
        .id('updateObjectAttribute')
        .fontColor($r('app.color.button_text_color'))
        .fontSize($r('app.float.button_text_size'))
        .type(ButtonType.Capsule)
        .buttonStyle(ButtonStyleMode.NORMAL)
      Button($r('app.string.class_type_update_child_attribute'))
        .onClick(() => {
          // Click the properties of Update object properties.
          this.classObjectData.child.attribute++;
        })
        .id('updateAttributeOfAttribute')
        .fontColor($r('app.color.button_text_color'))
        .fontSize($r('app.float.button_text_size'))
        .type(ButtonType.Capsule)
        .buttonStyle(ButtonStyleMode.NORMAL)
    }
    .width('100%')
    .padding(10)
    .border({ radius: $r('app.float.component_radius'), color: Color.Grey, width: $r('app.float.border_width') })
  }
}

// The component of the property in the object.
@Component
struct ChildObjectComp {
  // Use @ObjectLink to synchronize the object's properties with the parent component.
  @ObjectLink childObject: ChildClass;

  build() {
    Column() {
      Row() {
        Text(this.childObject.title)
          .fontSize(20)
        Text(`${this.childObject.attribute}`)
          .fontSize(20)
          .textAlign(TextAlign.End)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Divider()
        .width('100%')
        .strokeWidth(1)
    }
    .width('100%')
    .padding({ left: 100 })
  }
}

@Styles function buttonStyle() {
  .width('100%')
  .height($r('app.float.button_height'))
  .backgroundColor($r('app.color.button_background_color'))
}

// To update the attributes of an object attribute, the class of the object attribute needs to be modified with @Observed.
@Observed
class ChildClass {
  public title: string;
  public attribute: number;

  constructor(title: string, attribute: number) {
    this.title = title;
    this.attribute = attribute;
  }
}

class ParentClass {
  public title: string;
  public attributeTitle: string;
  public attribute: number;
  public child: ChildClass;

  constructor(title: string, attributeTitle: string, attribute: number, child: ChildClass) {
    this.title = title;
    this.attributeTitle = attributeTitle;
    this.attribute = attribute;
    this.child = child;

  }
}
