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
import { TextModifier, ListItemGroupModifier, ListItemModifier } from "@kit.ArkUI"

export class ItemListModifier implements AttributeModifier<ListItemModifier> {
  applyNormalAttribute(instance: ListItemModifier): void {
    instance.margin({ left: $r('app.float.item_list_margin'), right: $r('app.float.item_list_margin') })
    instance.height($r('app.float.item_list_height'))
  }
}

export class ItemTextModifier implements AttributeModifier<TextModifier> {
  applyNormalAttribute(instance: TextModifier): void {
    instance.layoutWeight(1)
    instance.fontSize($r('app.float.font_size_medium'))
    instance.fontWeight(FontWeight.Medium)
    instance.fontColor($r('app.color.item_text_color'))
  }
}

export class ItemButtonModifier implements AttributeModifier<ButtonAttribute> {
  applyNormalAttribute(instance: ButtonAttribute): void {
    instance.height($r('app.float.item_button_height'))
    instance.padding({
      top: $r('app.float.item_button_vertical_margin'),
      bottom: $r('app.float.item_button_vertical_margin'),
      left: $r('app.float.item_button_horizon_margin'),
      right: $r('app.float.item_button_horizon_margin'),
    })
    instance.fontSize($r('app.float.font_size_regular'))
    instance.fontColor($r('app.color.base_blue'))
    instance.backgroundColor($r('app.color.item_button_background'))
  }
}

export class ItemGroupModifier implements AttributeModifier<ListItemGroupModifier> {
  applyNormalAttribute(instance: ListItemGroupModifier): void {
    instance.backgroundColor(Color.White)
    instance.borderRadius($r('app.float.font_size_normal'))
    instance.divider({
      startMargin: $r('app.float.item_group_divider_margin'),
      endMargin: $r('app.float.item_group_divider_margin'),
      strokeWidth: $r('app.float.item_group_divider_width'),
      color: $r('app.color.item_group_divider_color')
    })
  }
}