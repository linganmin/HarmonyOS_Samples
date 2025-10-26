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

import { NodeContent } from "@kit.ArkUI";

export const CreateTextListNativeRoot: (content: NodeContent) => void;

export const DestroyTextListNativeRoot: () => void;

export const CreateMonitorEventListNativeRoot: (content: NodeContent) => void;

export const DestroyMonitorEventListNativeRoot: () => void;

export const CreateLazyTextListNativeRoot: (content: NodeContent) => void;

export const DestroyLazyTextListNativeRoot: () => void;

export const CreateTextGroupListNativeRoot: (content: NodeContent) => void;

export const DestroyTextGroupListNativeRoot: () => void;

export const CreateCustomContainerNativeRoot: (content: NodeContent) => void;

export const DestroyCustomContainerNativeRoot: () => void;

export const CreateMixedRefreshListNativeRoot: (content: NodeContent) => void;

export const DestroyMixedRefreshListNativeRoot: () => void;

export const registerCreateMixedRefreshNode: (createMixedRefresh: object) => void;

export const registerUpdateMixedRefreshNode: (updateMixedRefresh: object) => void;

export const CreatePopupNativeRoot: (content: NodeContent) => void;

export const DestroyPopupNativeRoot: () => void;

export const CreateAnimationViewNativeRoot: (content: NodeContent) => void;

export const DestroyAnimationViewNativeRoot: () => void;

export const CreateAttributeAnimationNativeRoot: (content: NodeContent, uicontect: object) => void;

export const DestroyAttributeAnimationNativeRoot: () => void;

export const CreateGestureViewNativeRoot: (content: NodeContent) => void;

export const DestroyGestureViewNativeRoot: () => void;

export const CreateCustomGestureViewNativeRoot: (content: NodeContent) => void;

export const DestroyCustomGestureViewNativeRoot: () => void;