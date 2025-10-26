import { deviceInfo } from '@kit.BasicServicesKit';
import Logger from './Logger';

let logger = Logger.getLogger('[DeviceTypeChecker]');

export class DeviceTypeChecker {
  static isPC(): boolean {
    try {
      return deviceInfo.deviceType.toLowerCase() === '2in1';
    } catch (error) {
      logger.error(`packToData error. Code: ${error?.code}, message: ${error?.message}`);
      return false;
    }
  }
}