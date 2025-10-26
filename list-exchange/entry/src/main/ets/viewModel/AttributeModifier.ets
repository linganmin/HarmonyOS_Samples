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

import { CommonConstants } from '../constants/CommonConstants';

/**
 * Custom Attribute Modifiers
 */
export class ListItemModifier implements AttributeModifier<ListItemAttribute> {
  public hasShadow: boolean = false;
  public isDeleted: boolean = false;
  public scale: number = 1;
  public offsetY: number = 0;
  public offsetX: number = 0;
  public opacity: number = CommonConstants.LIST_ITEM_NOT_SELECT_OPACITY;
  public static instance: ListItemModifier | null = null;

  public static getInstance(): ListItemModifier {
    if (!ListItemModifier.instance) {
      ListItemModifier.instance = new ListItemModifier();
    }
    return ListItemModifier.instance;
  }

  /**
   * Defines the style of a component in normal state.
   * @param instance
   */
  applyNormalAttribute(instance: ListItemAttribute): void {
    if (this.hasShadow) {
      instance.shadow({
        radius: $r('app.float.list_exchange_shadow_radius'),
        color: $r('app.color.list_exchange_box_shadow')
      });
      instance.zIndex(CommonConstants.COMPONENT_LEVEL1);
      instance.opacity(CommonConstants.LIST_ITEM_IS_SELECT_OPACITY);
    } else {
      instance.opacity(CommonConstants.LIST_ITEM_NOT_SELECT_OPACITY);
    }
    instance.translate({ x: this.offsetX, y: this.offsetY });
    instance.scale({ x: this.scale, y: this.scale });
  }
}