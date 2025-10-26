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

import { mindSporeLite } from '@kit.MindSporeLiteKit';
import Logger from './Logger';

export default async function modelPredict
  (modelBuffer: ArrayBuffer, inputsBuffer: ArrayBuffer[]): Promise<mindSporeLite.MSTensor[]> {
  // 1. Create Context
  let context: mindSporeLite.Context = {};
  context.target = ['cpu'];
  context.cpu = {};
  context.cpu.threadNum = 2;
  context.cpu.threadAffinityMode = 1;
  context.cpu.precisionMode = 'enforce_fp32';
  Logger.info('MS_LITE_LOG load model before ...')
  // 2. Load Model
  let msLiteModel: mindSporeLite.Model = await mindSporeLite.loadModelFromBuffer(modelBuffer, context);
  Logger.info('MS_LITE_LOG load model after...')
  // 3. Set input data
  let modelInputs: mindSporeLite.MSTensor[] = msLiteModel.getInputs();
  Logger.info('MS_LITE_L06 msLiteModel.getInputs ...')
  // This model does not support resizing other shapes.
  for (let i = 0; i < inputsBuffer.length; i++) {
    let inputBuffer = inputsBuffer[i];
    if (inputBuffer !== null) {
      modelInputs[i].setData(inputBuffer as ArrayBuffer);
    }
  }
  // 4. Execute reasoning
  Logger.info('=========MS_LITE_L06: MS_LITE predict start=====');
  let modelOutputs: mindSporeLite.MSTensor[] = await msLiteModel.predict(modelInputs) ;
  Logger.info('MS_LITE_LOG predict after ...');
  return modelOutputs;
}