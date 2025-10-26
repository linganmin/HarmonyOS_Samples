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

import { NodeContent,UIContext,RefreshModifier,ComponentContent } from '@kit.ArkUI';

// Define data objects for interaction between the Native side and ArkTS.
interface NativeRefreshAttribute {
  isRefreshing: boolean;
  width?: number;
  height?: number;
  backgroundColor?: number;
  refreshOffset?: number;
  pullToRefresh?: boolean
  onRefreshing?: () => void;
  onOffsetChange?: (offset: number) => void;
}

// Define the input format for the @ Builder function.
interface RefreshAttribute {
  isRefreshing: boolean;

  // Attribute settings are optimized for performance through Modifier.
  modifier?: RefreshModifier;
  slot?: NodeContent;
  onRefreshing?: () => void;
  onOffsetChange?: (offset: number) => void;
}

// WidgetContent encapsulates ArkTS components that rely on the global @ Builder function,
// involving complex custom component scenarios.
// @ Component custom components can be nested within the @ Builder function.
// @The Builder function provides a parameter input method,
// which facilitates parameter updates through the update interface of WidgetContent in the future.
@Builder
function mixedRefresh(attribute: RefreshAttribute) {
  Refresh({ refreshing: attribute.isRefreshing }) {
    // Refresh, as a container component, requires the use of ContentSlot mechanism to reserve sub component space
    ContentSlot(attribute.slot)
  }.attributeModifier(attribute.modifier)
  .onRefreshing(() => {
    console.info("on onRefreshing");
    if (attribute.onRefreshing) {
      console.info("on native onRefreshing");
      attribute.onRefreshing();
    }
  })
  .onOffsetChange((value: number) => {
    console.info("on offset change: " + value);
    if (attribute.onOffsetChange) {
      console.info("on native onOffsetChange");
      attribute.onOffsetChange(value);
    }
  })
}

// Define the return value of the creation function for interaction between the ArkTS side and the Native side.
interface MixedModuleResult {
  // Define a wrapper object for the Refresh build function,
  // used for converting the Native side to an ArkUI-NodeHandle object.
  content?: ComponentContent<RefreshAttribute>;

  // Refresh, as a container component, requires the use of ContentSlot mechanism to mount native side sub components.
  childSlot?: NodeContent;
}

// Provide an entry function for creating ArkTS components.
export function createMixedRefresh(value: NativeRefreshAttribute): MixedModuleResult {
  console.info("createMixedRefresh");
  // Maintain UI context objects through AppStore objects when Ability is launched.
  let uiContent = AppStorage.get<UIContext>("context");
  let modifier = new RefreshModifier();
  if (value.width) {
    modifier.width(value.width)
  }
  if (value.height) {
    modifier.height(value.height)
  }
  if (value.backgroundColor) {
    modifier.backgroundColor(value.backgroundColor)
  }
  if (value.pullToRefresh) {
    modifier.pullToRefresh(value.pullToRefresh)
  }
  if (value.refreshOffset) {
    modifier.refreshOffset(value.refreshOffset)
  }
  // Create a NodeContent slot object for mounting Refresh subcomponents.
  let nodeSlot = new NodeContent();
  // Create a Refresh component using WidgetContent and encapsulate it.
  let content = new ComponentContent<RefreshAttribute>(uiContent!,wrapBuilder<[RefreshAttribute]>(mixedRefresh),
    {
      isRefreshing: value.isRefreshing,
      modifier: modifier,
      slot: nodeSlot,
      onRefreshing: value.onRefreshing,
      onOffsetChange: value.onOffsetChange
    });
  // Pass the encapsulation object of the Refresh component and its sub component slot objects to the Native side.
  return { content: content,childSlot: nodeSlot };
}

// Define the update function of the Refresh component for native side updates.
// In the update scenario, it is necessary to return the encapsulated object of the Refresh component
// and its sub component slot objects to prevent the component from being recreated.
export function updateMixedRefresh(refresh: ComponentContent<RefreshAttribute>,childSlot: NodeContent,
  value: NativeRefreshAttribute): void {
  let modifier = new RefreshModifier();
  if (value.width) {
    modifier.width(value.width)
  }
  if (value.height) {
    modifier.height(value.height)
  }
  if (value.backgroundColor) {
    modifier.backgroundColor(value.backgroundColor)
  }
  if (value.pullToRefresh) {
    modifier.pullToRefresh(value.pullToRefresh)
  }
  if (value.refreshOffset) {
    modifier.refreshOffset(value.refreshOffset)
  }
  // 调用ComponentContent的update接口进行更新。
  refresh.update({
    isRefreshing: value.isRefreshing,
    modifier: modifier,
    slot: childSlot,
    onRefreshing: value.onRefreshing,
    onOffsetChange: value.onOffsetChange
  })
}