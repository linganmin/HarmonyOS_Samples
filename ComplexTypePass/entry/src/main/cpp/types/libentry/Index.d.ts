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

import { image } from '@kit.ImageKit';
import { SampleInputObject, SampleOutputObject } from '../../../ets/model/SampleObject';

// [Start uint8array_passing]
export const uint8ArrayPassing: (input: Uint8Array) => Uint8Array;
// [Start uint8array_passing]

export const objectPassing: (input: SampleInputObject) => SampleOutputObject;

export const hashMapPassing: (input: string) => string;

export const pixelMapPassing: (input: image.PixelMap) => image.PixelMap;

// [Start quick_start1]
// entry/src/main/cpp/types/libentry/Index.d.ts
export interface SampleClassTs2Napi {
  result: string;

  add(a: number, b: number): string;
}
// [End quick_start1]

// [Start quick_start2]
// entry/src/main/cpp/types/libentry/Index.d.ts
export class SampleClassNapi2Ts {
  private _hintStr: string;

  constructor(hintStr: string);

  times(a: number, b: number): string;
  public get hintStr();
  public set hintStr(value:string);
}
// [End quick_start2]

// [Start quick_start3]
// entry/src/main/cpp/types/libentry/Index.d.ts
export const classPassingTs2Napi: (input: SampleClassTs2Napi) => string;
// [End quick_start3]