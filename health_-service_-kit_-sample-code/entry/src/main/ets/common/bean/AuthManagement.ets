/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */

import { healthStore } from '@kit.HealthServiceKit';
import { common } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class AuthManagement {
  public static async auth(context: common.UIAbilityContext) {
    try {
      let authorizationParameter: healthStore.AuthorizationRequest = {
        readDataTypes: [healthStore.exerciseSequenceHelper.DATA_TYPE, healthStore.samplePointHelper.dailyActivities.DATA_TYPE,
          healthStore.healthSequenceHelper.sleepRecord.DATA_TYPE, healthStore.samplePointHelper.bodyTemperature.DATA_TYPE],
        writeDataTypes: [healthStore.exerciseSequenceHelper.DATA_TYPE, healthStore.healthSequenceHelper.sleepRecord.DATA_TYPE,
          healthStore.samplePointHelper.bodyTemperature.DATA_TYPE]
      }

      let authorizationResponse: healthStore.AuthorizationResponse = await healthStore.requestAuthorizations(context, authorizationParameter);
      let result: string = 'Succeeded in requesting authorization.\n'
      hilog.info(0x0000, 'testTag', 'Succeeded in requesting authorization.');
      authorizationResponse.writeDataTypes.forEach(dataType => {
        result += `grantedWriteDataType is : ${dataType.name}` + '\n';
        hilog.info(0x0000, 'testTag', `grantedWriteDataType is : ${dataType.name}`);
      });
      authorizationResponse.readDataTypes.forEach(dataType => {
        result += `grantedReadDataTypes is : ${dataType.name}` + '\n';
        hilog.info(0x0000, 'testTag', `grantedReadDataTypes is : ${dataType.name}`);
      });

      return result;
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to request authorization. Code: ${err.code}, message: ${err.message}`);
      return `Failed to request authorization. Code: ${err.code}, message: ${err.message}`;
    }
  }

  public static async getAuth(): Promise<string> {
    try {
      let parameter: healthStore.AuthorizationRequest = {
        readDataTypes: [healthStore.exerciseSequenceHelper.DATA_TYPE, healthStore.samplePointHelper.dailyActivities.DATA_TYPE,
          healthStore.healthSequenceHelper.sleepRecord.DATA_TYPE, healthStore.samplePointHelper.bodyTemperature.DATA_TYPE],
        writeDataTypes: [healthStore.exerciseSequenceHelper.DATA_TYPE, healthStore.healthSequenceHelper.sleepRecord.DATA_TYPE,
          healthStore.samplePointHelper.bodyTemperature.DATA_TYPE]
      }

      let queryAuthorizationResponse = await healthStore.getAuthorizations(parameter);
      hilog.info(0x0000, 'testTag', 'Succeeded in getting authorization.');
      let result: string = 'Succeeded in getting authorization.\n';
      queryAuthorizationResponse.writeDataTypes.forEach(dataType => {
        hilog.info(0x0000, 'testTag', `grantedWriteDataType is : ${dataType.name}`);
        result += `grantedWriteDataType is : ${dataType.name}` + '\n';
      });
      queryAuthorizationResponse.readDataTypes.forEach(dataType => {
        hilog.info(0x0000, 'testTag', `grantedReadDataTypes is : ${dataType.name}`);
        result += `grantedReadDataTypes is : ${dataType.name}` + '\n';
      });
      return result;
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to get authorization. Code: ${err.code}, message: ${err.message}`);
      return `Failed to get authorization. Code: ${err.code}, message: ${err.message}`;
    }
  }

  public static async cancelAuthAll(): Promise<string> {
    try {
      await healthStore.cancelAuthorizations();
      hilog.info(0x0000, 'testTag', 'Succeeded in cancelling authorization.');
      return 'Succeeded in cancelling authorization.';
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to cancel authorization. Code: ${err.code}, message: ${err.message}`);
      return `Failed to cancel authorization. Code: ${err.code}, message: ${err.message}`;
    }
  }
}