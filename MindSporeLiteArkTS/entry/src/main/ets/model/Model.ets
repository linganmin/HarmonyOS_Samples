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

import { mindSporeLite } from '@kit.MindSporeLiteKit'
import Logger from '../common/utils/Logger';

export default async function modelPredict(
  modelBuffer: ArrayBuffer, inputsBuffer: ArrayBuffer[]): Promise<mindSporeLite.MSTensor[]> {

  let context: mindSporeLite.Context = {};
  context.target = ['cpu'];
  context.cpu = {}
  context.cpu.threadNum = 2;
  context.cpu.threadAffinityMode = 1;
  context.cpu.precisionMode = 'enforce_fp32';
  let msLiteModel: mindSporeLite.Model = await mindSporeLite.loadModelFromBuffer(modelBuffer, context);
  let modelInputs: mindSporeLite.MSTensor[] = msLiteModel.getInputs();
  for (let i = 0; i < inputsBuffer.length; i++) {
    let inputBuffer = inputsBuffer[i];
    if (inputBuffer != null) {
      modelInputs[i].setData(inputBuffer as ArrayBuffer);
    }
  }
  Logger.info('=========MS_LITE_LOG: MS_LITE predict start=====');
  let modelOutputs: mindSporeLite.MSTensor[] = await msLiteModel.predict(modelInputs);
  return modelOutputs;
}


