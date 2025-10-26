/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */


import { healthStore } from '@kit.HealthServiceKit';
import { DateUtils } from '../utils/DateUtils';
import { InitUtils } from '../utils/InitUtils';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class SamplePointManagement {
  public static async saveData() {
    try {
      const dataSourceId = await InitUtils.getDataSourceId()

      let sampleData: healthStore.samplePointHelper.bodyTemperature.Model = {
        dataType: healthStore.samplePointHelper.bodyTemperature.DATA_TYPE,
        startTime:1690888800000,
        endTime: 1690888800000,
        localDate: DateUtils.parseYyyyMmDdToDate(DateUtils.getYyyyMmDd(1690888800000)),
        timeZone: '+0800',
        modifiedTime: new Date().getTime(),
        dataSourceId: dataSourceId,
        fields: {
          bodyTemperature: 36.5
        }
      };

      await healthStore.saveData(sampleData);
      hilog.info(0x0000, 'testTag', 'Succeeded in saving data.');
      return 'Succeeded in saving data.';
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to save data. Code: ${err.code}, message: ${err.message}`);
      return `Failed to save data. Code: ${err.code}, message: ${err.message}`;
    }
  }

  public static async readData(): Promise<string> {
    try {
      const samplePointReadRequest: healthStore.SamplePointReadRequest = {
        samplePointDataType: healthStore.samplePointHelper.bodyTemperature.DATA_TYPE,
        startTime: 1690888800000,
        endTime: 1690888900000
      };

      let samplePoints: healthStore.SamplePoint[] = await healthStore.readData<healthStore.samplePointHelper.bodyTemperature.Model>(samplePointReadRequest);
      let result = 'Succeeded in reading data\n';
      samplePoints.forEach((samplePoint) => {
        hilog.info(0x0000, 'testTag', `Succeeded in reading data, the bodyTemperature is ${samplePoint.fields.bodyTemperature}.`);
        result += `the bodyTemperature is ${samplePoint.fields.bodyTemperature}.` + '\n';
      });
      return result;
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to read data. Code: ${err.code}, message: ${err.message}`);
      return `Failed to read data. Code: ${err.code}, message: ${err.message}`;
    }
  }

  public static async aggregateData(): Promise<string> {
    try {
      let aggregateRequest: healthStore.AggregateRequest<healthStore.samplePointHelper.dailyActivities.AggregateFields> = {
        dataType: healthStore.samplePointHelper.dailyActivities.DATA_TYPE,
        metrics: {
          step: ['sum'],
          calorie: ['sum'],
          distance: ['sum'],
          climbHighAltitude:['sum'],
          isIntensity: ['sum'],
          isStand: ['sum']
        },
        groupBy: {
          unitType: healthStore.GroupUnitType.DAY,
        },
        startLocalDate: DateUtils.parseYyyyMmDdToDate(DateUtils.getYyyyMmDd(1690888800000)),
        endLocalDate: DateUtils.parseYyyyMmDdToDate(DateUtils.getYyyyMmDd(1690888900000))
      };

      let aggregateResults: healthStore.AggregateResult[] = await healthStore.aggregateData<healthStore.samplePointHelper.dailyActivities.AggregateResult>(aggregateRequest);
      hilog.info(0x0000, 'testTag', 'Succeeded in reading data.');
      let result: string = 'Succeeded in reading data.\n';
      aggregateResults.forEach((aggregateResult) => {
        hilog.info(0x0000, 'testTag', `the start time is ${aggregateResult.startTime}.`);
        hilog.info(0x0000, 'testTag', `the end time is ${aggregateResult.endTime}.`);
        result += `the start time is ${aggregateResult.startTime}.` + '\n' + `the end time is ${aggregateResult.endTime}.` + '\n';
        Object.keys(aggregateResult.fields).forEach((fieldName) => {
          hilog.info(0x0000, 'testTag', `the sum of ${fieldName} is ${aggregateResult.fields[fieldName].sum}.`);
          result += `the sum of ${fieldName} is ${aggregateResult.fields[fieldName].sum}.` + '\n';
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
      const samplePointDeleteRequest: healthStore.SamplePointDeleteRequest = {
        dataType: healthStore.samplePointHelper.bodyTemperature.DATA_TYPE,
        startTime: 1690888800000,
        endTime: 1690888900000
      };
      await healthStore.deleteData(samplePointDeleteRequest);
      hilog.info(0x0000, 'testTag', 'Succeeded in deleting data.');
      return 'Succeeded in deleting data.';
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to delete data. Code: ${err.code}, message: ${err.message}`);
      return `Failed to delete data. Code: ${err.code}, message: ${err.message}`;
    }
  }

  public static async deleteBySamplePoint(): Promise<string> {
    try {
      const dataSourceId = await InitUtils.getDataSourceId()

      let sampleData: healthStore.samplePointHelper.bodyTemperature.Model = {
        dataType: healthStore.samplePointHelper.bodyTemperature.DATA_TYPE,
        startTime:1690888800000,
        endTime: 1690888800000,
        localDate: DateUtils.parseYyyyMmDdToDate(DateUtils.getYyyyMmDd(1690888800000)),
        timeZone: '+0800',
        modifiedTime: new Date().getTime(),
        dataSourceId: dataSourceId,
        fields: {
          bodyTemperature: 36.5
        }
      };

      await healthStore.deleteData(sampleData);
      hilog.info(0x0000, 'testTag', 'Succeeded in deleting data.');
      return 'Succeeded in deleting data.';
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to delete data. Code: ${err.code}, message: ${err.message}`);
      return `Failed to delete data. Code: ${err.code}, message: ${err.message}`;
    }
  }
}