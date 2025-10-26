/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */


import { healthStore } from '@kit.HealthServiceKit';
import { DateUtils } from '../utils/DateUtils';
import { InitUtils } from '../utils/InitUtils';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class ExerciseSequenceManagement {
  public static async saveData() {
    try {
      const startTime = 1698040800000; // 2023-10-23 14:00:00
      const endTime = 1698042600000; // 2023-10-23 14:30:00

      const dataSourceId = await InitUtils.getDataSourceId();

      const runningSequence: healthStore.exerciseSequenceHelper.running.Model = {
        dataType: healthStore.exerciseSequenceHelper.DATA_TYPE,
        dataSourceId: dataSourceId,
        startTime: startTime, // 2023-10-23 14:00:00
        endTime: endTime, // 2023-10-23 14:30:00
        localDate: DateUtils.parseYyyyMmDdToDate(DateUtils.getYyyyMmDd(1698040800000)),
        timeZone: '+0800',
        modifiedTime: new Date().getTime(),

        exerciseType: healthStore.exerciseSequenceHelper.running.EXERCISE_TYPE,
        duration: 1800000,
        summaries: {
          distance: {
            totalDistance: 2000
          },
          calorie: {
            totalCalories: 20
          },
          speed: {
            avg: 5,
            max: 6
          }
        },
        details: {
          exerciseHeartRate: [
            {
              startTime: startTime,
              bpm: 88
            },
            {
              startTime: startTime + 5000,
              bpm: 89
            }
          ],
          speed: [
            {
              startTime: startTime,
              speed: 2.5
            },
            {
              startTime: startTime + 5000,
              speed: 2.3
            }
          ],
          altitude: [
            {
              startTime: startTime,
              altitude: 100
            },
            {
              startTime: startTime + 5000,
              altitude: 101
            }
          ],
          location: [
            {
              startTime: startTime,
              latitude: 45,
              longitude: 46
            }
          ]
        }
      };

      await healthStore.saveData(runningSequence);
      hilog.info(0x0000, 'testTag', 'Succeeded in saving data.');
      return 'Succeeded in saving data.';
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to save data. Code: ${err.code}, message: ${err.message}`);
      return `Failed to save data. Code: ${err.code}, message: ${err.message}`;
    }
  }

  public static async readData(): Promise<string> {
    try {
      const startTime = 1698040800000; // 2023-10-23 14:00:00
      const endTime = 1698042600000; // 2023-10-23 14:30:00

      const sequenceReadRequest: healthStore.ExerciseSequenceReadRequest = {
        startTime: startTime,
        endTime: endTime,
        exerciseType: healthStore.exerciseSequenceHelper.running.EXERCISE_TYPE,
        count: 1,
        sortOrder: 1,
        readOptions: {
          withDetails: true,
        }
      };

      const runningSequences: healthStore.exerciseSequenceHelper.running.Model[] = await healthStore.readData<healthStore.exerciseSequenceHelper.running.Model>(sequenceReadRequest);
      hilog.info(0x0000, 'testTag', 'Succeeded in reading data.');
      let result: string = 'Succeeded in reading data.\n';
      runningSequences.forEach((runningSequence) => {
        hilog.info(0x0000, 'testTag', `the start time is ${runningSequence.startTime}.`);
        hilog.info(0x0000, 'testTag', `the end time is ${runningSequence.endTime}.`);
        result += `the start time is ${runningSequence.startTime}.` + '\n' + `the end time is ${runningSequence.endTime}.` + '\n';
        Object.keys(runningSequence.summaries).forEach((key) => {
          Object.keys(runningSequence.summaries[key]).forEach((fieldName) => {
            result += `the summaries of ${key} field ${fieldName} is ${runningSequence.summaries[key][fieldName]}.` + '\n';
            hilog.info(0x0000, 'testTag', `the summaries of ${key} field ${fieldName} is ${runningSequence.summaries[key][fieldName]}.`);
          });
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
      let exerciseSequenceDeleteRequest: healthStore.ExerciseSequenceDeleteRequest= {
        exerciseType: healthStore.exerciseSequenceHelper.running.EXERCISE_TYPE,
        startTime: 1698040800000,
        endTime: 1698042600000
      };
      await healthStore.deleteData(exerciseSequenceDeleteRequest);
      hilog.info(0x0000, 'testTag', 'Succeeded in deleting data.');
      return 'Succeeded in deleting data.';
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to delete data. Code: ${err.code}, message: ${err.message}`);
      return `Failed to delete data. Code: ${err.code}, message: ${err.message}`;
    }
  }

  public static async deleteByExerciseSequence(): Promise<string> {
    try {
      const startTime = 1698040800000; // 2023-10-23 14:00:00
      const endTime = 1698042600000; // 2023-10-23 14:30:00

      const dataSourceId = await InitUtils.getDataSourceId()

      const runningSequence: healthStore.exerciseSequenceHelper.running.Model = {
        dataType: healthStore.exerciseSequenceHelper.DATA_TYPE,
        dataSourceId: dataSourceId,
        startTime: startTime, // 2023-10-23 14:00:00
        endTime: endTime, // 2023-10-23 14:30:00
        localDate: DateUtils.parseYyyyMmDdToDate(DateUtils.getYyyyMmDd(1698040800000)),
        timeZone: '+0800',
        modifiedTime: new Date().getTime(),

        exerciseType: healthStore.exerciseSequenceHelper.running.EXERCISE_TYPE,
        duration: 1800,
        summaries: {
          distance: {
            totalDistance: 0
          },
          calorie: {
            totalCalories: 0
          },
          speed: {
            avg: 0,
            max: 0
          }
        }
      };

      await healthStore.deleteData(runningSequence);
      hilog.info(0x0000, 'testTag', 'Succeeded in deleting data.');
      return 'Succeeded in deleting data.';
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to delete data. Code: ${err.code}, message: ${err.message}`);
      return `Failed to delete data. Code: ${err.code}, message: ${err.message}`;
    }
  }
}