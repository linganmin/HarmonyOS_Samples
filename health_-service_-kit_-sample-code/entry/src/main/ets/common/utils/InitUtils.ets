/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2023-2023. All rights reserved.
 */

import { healthStore } from '@kit.HealthServiceKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export class InitUtils {
  private static dataSourceId: string;

  public static setDataSourceId(dataSourceId: string): void {
    InitUtils.dataSourceId = dataSourceId;
  }

  public static async getDataSourceId(): Promise<string> {
    try {
      if (InitUtils.dataSourceId) {
        return InitUtils.dataSourceId
      }

      const request: healthStore.DataSourceReadRequest = {
        deviceUniqueId: 'deviceUuid_test'
      }
      let res: healthStore.DataSource[] = await healthStore.readDataSource(request);
      if (res) {
        InitUtils.dataSourceId = res[0]?.dataSourceId;
        hilog.info(0x0000, 'testTag', `Succeeded in reading dataSource, the dataSourceId is ${InitUtils.dataSourceId}.`);
      }

      if (!InitUtils.dataSourceId) {
        const dataSource: healthStore.DataSourceBase = {
          deviceInfo: {
            uniqueId: 'deviceUuid_test',
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
        }

        let res: string = await healthStore.insertDataSource(dataSource);
        InitUtils.dataSourceId = res;
        hilog.info(0x0000, 'testTag', `Succeeded in inserting dataSource, the dataSourceId is ${res}.`);
      }

      return InitUtils.dataSourceId
    } catch (err) {
      hilog.error(0x0000, 'testTag', `Failed to getDataSourceId. Code: ${err.code}, message: ${err.message}`);
      return '';
    }
  }
}