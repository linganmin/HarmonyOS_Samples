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

export class CustomButtonModifier implements AttributeModifier<ButtonAttribute>{
  applyNormalAttribute(instance:ButtonAttribute) {
    instance.width('100%')
      .height('40vp')
  }
}

export class CustomExeColumnModifier implements AttributeModifier<ColumnAttribute>{
  applyNormalAttribute(instance:ColumnAttribute) {
    instance.width('100%')
      .backgroundColor(0XFFFFFF)
      .borderRadius($r('sys.float.corner_radius_level8'))
  }
}

export class CustomColumnModifier implements AttributeModifier<ColumnAttribute>{
  applyNormalAttribute(instance:ColumnAttribute) {
    instance.width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Center)
      .padding({ left: '16vp', right: '16vp', bottom: '16vp' })
  }
}