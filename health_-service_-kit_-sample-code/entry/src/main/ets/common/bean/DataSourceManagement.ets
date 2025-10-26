/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */


import { healthStore } from '@kit.HealthServiceKit';
import { InitUtils } from '../utils/InitUtils';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class DataSourceManagement {
  private static uniqueId: string;

  public static async insertDataSource() {
    try {
      DataSourceManagement.uniqueId = `deviceUuid_test` + new Date().getTime();
      const dataSource: healthStore.DataSourceBase = {
        deviceInfo: {
          uniqueId: DataSourceManagement.uniqueId,
          name: `testDevice`,
          category: healthStore.DeviceCategory.SMART_PHONE,
          productId: `0554`,
          model: `lotana`,
          manufacturer: `HUAWEI`,
          mac: `testDeviceMac`,
          sn: `testDeviceSn`,
          hardwareVersion: `1`,
          softwareVersion: `2`,
          firmwareVersion: `3`
        }
      };

      let res: string = await healthStore.insertDataSource(dataSource);
      hilog.info(0x0000, 'testTag', `Succeeded in inserting dataSource, the dataSourceId is ${res}.`);
      InitUtils.setDataSourceId(res);
      return `Succeeded in inserting dataSource, the dataSourceId is ${res}.`;
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to insert dataSource. Code: ${err.code}, message: ${err.message}`);
      return `Failed to insert dataSource. Code: ${err.code}, message: ${err.message}`;
    }
  }

  public static async updateDataSource(): Promise<string> {
    try {
      if (!DataSourceManagement.uniqueId) {
        return 'Failed to update dataSource.Please insertDataSource first.'
      }

      const dataSourceId = await InitUtils.getDataSourceId();

      const dataSource: healthStore.DataSource= {
        deviceInfo: {
          uniqueId: DataSourceManagement.uniqueId,
          name: `testDevice1`,
          category: healthStore.DeviceCategory.SMART_PHONE,
          productId: `0554`,
          model: `lotana`,
          manufacturer: `HUAWEI`,
          mac: `testDeviceMac`,
          sn: `testDeviceSn`,
          hardwareVersion: `1`,
          softwareVersion: `2`,
          firmwareVersion: `3`
        },
        dataSourceId: dataSourceId
      };

      await healthStore.updateDataSource(dataSource);
      hilog.info(0x0000, 'testTag', 'Succeeded in updating dataSource.');
      return 'Succeeded in updating dataSource.';
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to update dataSource. Code: ${err.code}, message: ${err.message}`);
      return `Failed to update dataSource. Code: ${err.code}, message: ${err.message}`;
    }
  }

  public static async readDataSource(): Promise<string> {
    if (!DataSourceManagement.uniqueId) {
      return 'Failed to read dataSource.Please insertDataSource first.'
    }

    try {
      const request: healthStore.DataSourceReadRequest = {
        deviceUniqueId: DataSourceManagement.uniqueId
      };
      let dataSources: healthStore.DataSource[] = await healthStore.readDataSource(request);
      let res: string = '';
      dataSources.forEach((dataSource) => {
        res += `Succeeded in reading dataSource, the dataSourceId is ${dataSource.dataSourceId}.` + '\n';
        hilog.info(0x0000, 'testTag', `Succeeded in reading dataSource, the dataSourceId is ${dataSource.dataSourceId}.`);
      });
      return res;
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to read dataSource. Code: ${err.code}, message: ${err.message}`);
      return `Failed to read dataSource. Code: ${err.code}, message: ${err.message}`;
    }
  }
}