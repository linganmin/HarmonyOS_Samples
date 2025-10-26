/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { worker, MessageEvents, ThreadWorkerGlobalScope, ErrorEvent } from '@kit.ArkTS';
import { offsetMomentum, energy, advance } from '../model/NBody_ETS_6';
import Logger from '../utils/Logger';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;
const TAG: string = 'CalculateWorker';

/**
 * Defines the event handler to be called when the worker thread receives a message sent by the host thread.
 * The event handler is executed in the worker thread.
 *
 * @param e message data
 */
workerPort.onmessage = function (e: MessageEvents): void {
  Logger.info(TAG, 'CalculateWorker: start calculating...');
  let data = e.data;
  console.info(TAG, 'message from main thread' + JSON.stringify(data));
  let res: number = computeTask(data.timeSteps);
  workerPort.postMessage({ result: res });
};

/**
 * Defines the event handler to be called when the worker receives a message that cannot be deserialized.
 * The event handler is executed in the worker thread.
 *
 * @param e message data
 */
workerPort.onmessageerror = function (e: MessageEvents): void {
  Logger.error(TAG, 'CalculateWorker: onmessageerror = ' + e.data);
};

/**
 * Defines the event handler to be called when an exception occurs during worker execution.
 * The event handler is executed in the worker thread.
 *
 * @param e error message
 */
workerPort.onerror = function (e: ErrorEvent): void {
  Logger.error(TAG, 'CalculateWorker: onerror = ' + e.message);
};

/**
 * Run the celestial body orbit calculation program
 * @param totalTimeSteps Time lapse
 * @returns Calculation time
 */
function computeTask(totalTimeSteps: number): number {
  const tagInTask: string = 'computeTask';
  const timeStep: number = 0.01; // Unit:hour
  const fractionDigits: number = 9; // Mechanical energy value decimal places
  let start: number = new Date().getTime();

  // Establish the conservation of momentum for an isolated system
  offsetMomentum();
  Logger.info(tagInTask, energy().toFixed(fractionDigits));

  // Update the position information of celestial bodies after they change according to the specified time
  for (let i: number = 0; i < totalTimeSteps; i++) {
    advance(timeStep);
  }

  // Determine whether the mechanical energy of the system is conserved before and after calculation
  Logger.info(tagInTask, energy().toFixed(fractionDigits));
  let end: number = new Date().getTime();
  return end - start;
}