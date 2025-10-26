/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { HMService } from '@hadss/hmrouter';

export interface TempObj {
  paramA: string,
  paramB: number
}

export class CustomService {
  @HMService({serviceName: 'testConsole'})
  testConsole(): void {
    console.log('Calling service testConsole');
  }

  @HMService({serviceName: 'testFunWithReturn'})
  testFunWithReturn(): string {
    return 'Calling service testFunWithReturn';
  }

  @HMService({serviceName: 'testFunWithParams', singleton: true})
  testFunWithParams(str: string, num: number, bool: boolean, obj: TempObj) {
    console.log('The 1st parameter of service testFunWithParams: ' + str);
    console.log('The 2nd parameter of service testFunWithParams: ' + num);
    console.log('The 3rd parameter of service testFunWithParams: ' + bool);
    console.log('The 4th parameter of service testFunWithParams: ' + JSON.stringify(obj));

    return obj.paramA || obj.paramB;
  }

  // Define asynchronous services, where the service name and function name can be different
  @HMService({serviceName: 'testAsyncFun', singleton: true})
  async testAsyncFunction(): Promise<string> {
    return new Promise((resolve) => {
      resolve('Calling asynchronous service testAsyncFun');
    });
  }
}