/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License")
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

export const createNativeTextNode: (content: Object) =>void;
export const createSwiperNativeNode: (content: Object) =>void;
export const createNativeAccessibilityNode: (content: Object) => void;
export const createNativeEmbeddedComponentNode: (content: Object) => void;
export const createWaterFlowNativeNode: (content: Object) => void;
export const createGridNativeNode: (content: Object) => void;
export const createScrollNativeNode: (content: Object) => void;
export const createRefreshNativeNode: (content: Object) => void;
export const createListNativeNode: (content: Object) => void;
export const createNativeNodexc: (content: Object, tag: string) => void;
export const CreatePublicNativeNode: (content: Object) =>void;
export const createFormPage: (content: Object) => void;
export const createFormNode: (content: Object, callback: Object) => number;
export const setFormAttribute: (nodeId: number, nodeType: number, attributeType: number, attributeValue: string) => number;
export const getFormAttribute: (nodeId: number, nodeType: number, attributeType: number) => string;
export const resetFormAttribute: (nodeId: number, nodeType: number, attributeType: number) => number;
export const removeFormNode: (nodeId: number) => void;
export const createImageSpanPage: (content: Object) =>void;
export const createImageSpanNode: (nodeType: number) => number;
export const removeImageSpanNode: (nodeId: number) => void;
export const setImageSpanAttribute: (nodeId: number, nodeType: number, attributeType: number, attributeValue: string) => number;
export const getImageSpanAttribute: (nodeId: number, nodeType: number, attributeType: number) => string;
export const resetImageSpanAttribute: (nodeId: number, nodeType: number, attributeType: number) => number;
