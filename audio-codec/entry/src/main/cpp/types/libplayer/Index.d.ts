/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
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

export const playNative: (
  inputFileFd: number,
  inputFileOffset: number,
  inputFileSize: number,
) => number;
export const pause: () => number;
export const capturerStart: () => number;
export const getFramesWritten: () => number;
export const getFileSize: (
  inputFile: number,
) => number;
export const getCurrentPosition: () => number;

export const release: () => number;

export const init: (inputFileFd: number, inputFileOffset: number, inputFileSize: number, desFile: number, audioCodecMime: string,
  audioEncapsulationFormat: string, ) => void

export const stop: () => void;

export const transcodingInit: (
  inputFileFd: number,
  inputFileOffset: number,
  inputFileSize: number,
) => { sampleRate: number; channelCount: number };

export const transcodingStop: () => void;