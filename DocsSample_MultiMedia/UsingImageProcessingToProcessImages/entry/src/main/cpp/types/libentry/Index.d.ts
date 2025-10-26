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

import { image } from "@kit.ImageKit";

export const createPixelMap: (a: number, b: number) => image.PixelMap;

export const hdrAIHDR: (a: image.PixelMap, b: image.PixelMap) => number;

export const generateMetadata: (a: image.PixelMap) => number;

export const getNativeImgFromPixelMap: (a: image.PixelMap, b: image.PixelMap) => number;

export const hdrCompose: (a: image.PixelMap, b: image.PixelMap, c: image.PixelMap) => number;

export const hdrDecompose: (a: image.PixelMap, b: image.PixelMap, c: image.PixelMap) => number;

export const detailEnhance: (srcImage: image.PixelMap, dstImage: image.PixelMap, width: number, height: number, level: number) => number;