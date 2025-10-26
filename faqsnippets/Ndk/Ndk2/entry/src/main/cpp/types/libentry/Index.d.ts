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
/**
 * FAQ: Native侧如何获取ArkTS侧的Uint8Array实例
 */
// [Start uint_arr_index]
export const uintArr: (a: Uint8Array) => object;
// [End uint_arr_index]

export const cal: (a: number, b: number, c: object, d: Boolean) => number;

/**
 * FAQ: Native侧使用napi_create_buffer接口构造的对象在ArkTS侧如何接收
 */
// DocsCode 3
export const testBuffer: () => ArrayBuffer;
// DocsCode 3

export const testCharBuf: () => ArrayBuffer;

/**
 * FAQ: 传入自定义类型对象到Native侧时，index.d.ts文件如何声明
 */
// [Start test_c_a_cpp]
import { testCa } from "../../../ets/pages/interface/CustomObject"
export const test1: (a: testCa) => void;
// [End test_c_a_cpp]
// [Start test_cpp]
export const test: (a: object) => void;
// [End test_cpp]
/**
 * FAQ: Native侧如何对ArkTS传递的Object类型的数据、属性进行修改
 */
// [Start rev_ark_ts_obj_modify]
export const modifyObject: (a: object) => object;
// [End rev_ark_ts_obj_modify]

export const arkTSConstructor: (a: string) => object;

export const MainThread: (a: number, b: number) => number;

export const tsPutMap: (a: string[], b: number[], c : number) => void;

export const mapJson: (a: string) => void;

export const napiLoadModule: (a: string) => object;

export const writeTemporaryFile: () => void;

export const getCurrentApplicationPackageName: () => void;

export const getDisplaySize: () => void;

export const mainThread: (fun: Function) => number