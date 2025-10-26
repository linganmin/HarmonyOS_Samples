/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */


import { healthStore } from '@kit.HealthServiceKit';
import { InitUtils } from '../utils/InitUtils';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class HealthSequenceManagement {
  public static async saveData() {
    try {
      const dataSourceId = await InitUtils.getDataSourceId()

      let healthSequence: healthStore.healthSequenceHelper.sleepRecord.Model = {
        summaries: {
          fallAsleepTime: 1695740400000, // 2023-09-26 23:00:00
          wakeupTime: 1695769200000, // 2023-09-27 7:00:00
          sleepScore: 80,
          wakeCount: 2,
          sleepType: 1,
          shallowDuration: 14400,
          deepDuration: 7200,
          dreamDuration: 7200,
          wakeDuration: 0,
          duration: 28800
        },
        dataType: healthStore.healthSequenceHelper.sleepRecord.DATA_TYPE,

        dataSourceId: dataSourceId,
        localDate: '09/26/2023',
        startTime: 1695740400000,
        endTime: 1695769200000,
        timeZone: '+0800',
        modifiedTime: 1695769200000,
        details: {
          sleepSegment: [
            {
              startTime: 1695740400000, // 2023-09-26 23:00:00
              endTime: 1695747600000, // 2023-09-27 01:00:00
              sleepStatus: 2
            },
            {
              startTime: 1695747600000, // 2023-09-27 01:00:00
              endTime: 1695754800000, // 2023-09-27 03:00:00
              sleepStatus: 1
            },
            {
              startTime: 1695754800000, // 2023-09-27 03:00:00
              endTime: 1695762000000, // 2023-09-27 05:00:00
              sleepStatus: 3
            },
            {
              startTime: 1695762000000, // 2023-09-27 05:00:00
              endTime: 1695769200000, // 2023-09-27 07:00:00
              sleepStatus: 2
            }
          ]
        }
      }

      await healthStore.saveData(healthSequence);
      hilog.info(0x0000, 'testTag', 'Succeeded in saving data.');
      return 'Succeeded in saving data.';
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to save data. Code: ${err.code}, message: ${err.message}`);
      return `Failed to save data. Code: ${err.code}, message: ${err.message}`;
    }
  }

  public static async readData(): Promise<string> {
    try {
      const dataSourceId = await InitUtils.getDataSourceId()

      let healthSequenceReadRequest: healthStore.HealthSequenceReadRequest = {
        healthSequenceDataType: healthStore.healthSequenceHelper.sleepRecord.DATA_TYPE,
        startTime: 1695740400000,
        endTime: 1695769200000,
        dataSourceOptions: {
          dataSourceId: dataSourceId
        },
        readOptions: {
          withDetails: true
        }
      };

      let healthSequences: healthStore.HealthSequence[] = await healthStore.readData<healthStore.healthSequenceHelper.sleepRecord.Model>(healthSequenceReadRequest);
      hilog.info(0x0000, 'testTag', 'Succeeded in reading data.');
      let result: string = 'Succeeded in reading data.\n';
      healthSequences.forEach((healthSequence) => {
        hilog.info(0x0000, 'testTag', `the start time is ${healthSequence.startTime}.`);
        hilog.info(0x0000, 'testTag', `the end time is ${healthSequence.endTime}.`);
        result += `the start time is ${healthSequence.startTime}.` + '\n' + `the end time is ${healthSequence.endTime}.` + '\n';
        Object.keys(healthSequence.summaries).forEach((key) => {
          hilog.info(0x0000, 'testTag', `the summaries of ${key} is ${healthSequence.summaries[key]}.`);
          result += `the summaries of ${key} is ${healthSequence.summaries[key]}.` + '\n';
        });
      });
      return result;
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to read data. Code: ${err.code}, message: ${err.message}`);
      return `Failed to read data. Code: ${err.code}, message: ${err.message}`;
    }
  }

  public static async deleteByRequest(): Promise<string> {
    try {
      const healthSequenceDeleteRequest: healthStore.HealthSequenceDeleteRequest = {
        healthSequenceDataType: healthStore.healthSequenceHelper.sleepRecord.DATA_TYPE,
        startTime: 1695740400000,
        endTime: 1695769200000,
      };
      await healthStore.deleteData(healthSequenceDeleteRequest);
      hilog.info(0x0000, 'testTag', 'Succeeded in deleting data.');
      return 'Succeeded in deleting data.';
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to delete data. Code: ${err.code}, message: ${err.message}`);
      return `Failed to delete data. Code: ${err.code}, message: ${err.message}`;
    }
  }

  public static async deleteByHealthSequence(): Promise<string> {
    try {
      const dataSourceId = await InitUtils.getDataSourceId()

      let healthSequence: healthStore.healthSequenceHelper.sleepRecord.Model = {
        summaries: {
          fallAsleepTime: 1695740400000, // 2023-09-26 23:00:00
          wakeupTime: 1695769200000, // 2023-09-27 7:00:00
          sleepScore: 80,
          wakeCount: 2,
          sleepType: 1,
          shallowDuration: 14400,
          deepDuration: 7200,
          dreamDuration: 7200,
          wakeDuration: 0,
          duration: 28800
        },
        dataType: healthStore.healthSequenceHelper.sleepRecord.DATA_TYPE,

        dataSourceId: dataSourceId,
        localDate: '09/26/2023',
        startTime: 1695740400000,
        endTime: 1695769200000,
        timeZone: '+0800',
        modifiedTime: 1695769200000
      }

      await healthStore.deleteData(healthSequence);
      hilog.info(0x0000, 'testTag', 'Succeeded in deleting data.');
      return 'Succeeded in deleting data.';
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to delete data. Code: ${err.code}, message: ${err.message}`);
      return `Failed to delete data. Code: ${err.code}, message: ${err.message}`;
    }
  }
}