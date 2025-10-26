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

import { bundleManager } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { Logger } from '@ohos/utils';
import { AspectInfoParams } from '../service/AspectParams';
import { AspectNetFunc } from '../service/AspectNetFunc';

const TAG = '[AspectUtil]';

export class AspectUtil {
  private static funNetwork: AspectNetFunc = new AspectNetFunc();
  private static versionName: string;

  /**
   * Insert some logic before the method.
   * @param methodClassName - The name of the operated class.
   * @param targetClass - The operated class
   * @param methodName- The name of the operated method.
   * @param isStatic - The flag whether the method is static.
   * @param beforeFun - The logic inserted before the method.
   * @param insteadFun - The logic replaced with the method.
   */
  public static addBefore(methodClassName: string, targetClass: Object, methodName: string, isStatic: boolean) {
    util.Aspect.addBefore(targetClass, methodName, isStatic, (instance: Object, ...args: Object[]) => {
      const currentTime: number = (new Date()).getTime();
      const params: string = JSON.stringify([...args]);
      AspectUtil.uploadAspectInfo({
        methodClassName: methodClassName,
        methodName: methodName,
        isStatic: isStatic,
        versionName: AspectUtil.getVersionName(),
        time: currentTime + '',
        params: params,
        type: 'start'
      } as AspectInfoParams);
      Logger.info(TAG,
        `method ${methodName} is called by ${JSON.stringify(typeof instance)} , start at ${currentTime}, args is ${params}.`);
    });
  }

  /**
   * Replace the original method with a new function.
   * @param targetClass - The operated class
   * @param methodName- The name of the operated method.
   * @param isStatic - The flag whether the method is static.
   * @param replaceFun - The logic replaced with the method.
   */
  public static replace(targetClass: Object, methodName: string, isStatic: boolean,
    replaceFun?: Function) {
    util.Aspect.replace(targetClass, methodName, isStatic, replaceFun);
  }

  /**
   * Insert some logic after the method.
   * @param methodClassName - The name of the operated class.
   * @param targetClass - The operated class
   * @param methodName- The name of the operated method.
   * @param isStatic - The flag whether the method is static.
   * @param afterFun - The logic inserted after the method
   */
  public static addAfter<T>(methodClassName: string, targetClass: Object, methodName: string, isStatic: boolean,
    afterFunc?: Function) {
    util.Aspect.addAfter(targetClass, methodName, isStatic, (instance: Object, ret: T, ...args: Object[]): T => {
      afterFunc && afterFunc(...args);
      const currentTime: number = (new Date()).getTime();
      const params: string = JSON.stringify([...args]);
      AspectUtil.uploadAspectInfo({
        methodClassName: methodClassName,
        methodName: methodName,
        isStatic: isStatic,
        versionName: AspectUtil.getVersionName(),
        time: currentTime + '',
        params: params,
        type: 'end'
      } as AspectInfoParams);
      Logger.info(TAG,
        `method ${methodName} is called by ${JSON.stringify(typeof instance)} , end at ${currentTime}, args is ${params}.`);
      return ret;
    });
  }

  private static getVersionName(): string {
    if (!AspectUtil.versionName) {
      const bundleInfo: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
      AspectUtil.versionName = bundleInfo.versionName;
    }
    return AspectUtil.versionName;
  }

  private static uploadAspectInfo(aspectInfo: AspectInfoParams) {
    AspectUtil.funNetwork.uploadAspectInfo(aspectInfo);
  }
}