/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { taskpool, worker, MessageEvents, util } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { offsetMomentum, energy, advance } from './NBody_ETS_6';
import Logger from '../utils/Logger';

const TAG: string = 'CalculateUtil';
let calculateResult: string = "Total time costed = %s ms."

class WorkerMessage {
  timeSteps: number;

  constructor(timeSteps: number) {
    this.timeSteps = timeSteps;
  }
}

/**
 * Run the celestial body orbit calculation program
 * @param totalTimeSteps Time lapse
 * @returns Calculation time
 */
@Concurrent
export function computeTask(totalTimeSteps: number): number {
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

/**
 * Use TaskPool to start a child thread to perform orbit calculation tasks
 * @param totalTimeSteps Time lapse
 */
export function computeNBodyByTaskPool(totalTimeSteps: number): void {
  Logger.info(TAG, "computeNBodyByTaskPool: start executing");
  let task: taskpool.Task = new taskpool.Task(computeTask, totalTimeSteps);
  try {
    Logger.info(TAG, 'computeNBodyByTaskPool: start calculating...');

    // Dispatch child thread tasks to the thread pool
    taskpool.execute(task, taskpool.Priority.HIGH).then((res) => {
      Logger.info(TAG, 'computeNBodyByTaskPool: executed successfully, total time costed = ' + res + ' ms.');
      AppStorage.set<String>('timeCost', util.format(calculateResult, res.toString()))
    })
  } catch (err) {
    Logger.error(TAG, "computeNBodyByTaskPool: execute failed, " + (err as BusinessError).toString());
  }
  Logger.info(TAG, "computeNBodyByTaskPool: finish executing");
}

/**
 * Use Worker to start a child thread to perform orbit calculation tasks
 * @param totalTimeSteps Time lapse
 */
export function computeNBodyByWorker(totalTimeSteps: number): void {
  Logger.info(TAG, "computeNBodyByWorker: start executing");
  let workerInstance = new worker.ThreadWorker("entry/ets/workers/CalculateWorker.ts");

  // Set how to handle messages from worker threads
  workerInstance.onmessage = (e: MessageEvents): void => {
    let data: Record<string, Object> = e.data;
    Logger.info(TAG, 'computeNBodyByWorker: executed successfully, total time costed = ' + data.result + ' ms.');
    AppStorage.set<String>('timeCost', util.format(calculateResult, data.result));
  }

  try {
    // Set what message to send from the main thread to the worker thread
    workerInstance.postMessage(new WorkerMessage(totalTimeSteps));
  } catch (error) {
    let err = error as BusinessError;
    Logger.error(TAG, `postMessage failed, error code=${err.code}, message=${err.message}`);
  }
}