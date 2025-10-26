import { hilog } from '@kit.PerformanceAnalysisKit';
import { deviceCertificate } from '@kit.DeviceSecurityKit';
import { BusinessError } from '@kit.BasicServicesKit';

const TAG: string = '[DevCertManagerModel]';

function deviceTokenPromise(): Promise<String> {
  return new Promise((resolve, reject) => {
    try {
      deviceCertificate.getDeviceToken().then((token) => {
        hilog.info(0x0000, TAG, 'Succeeded in executing getDeviceToken success');
        resolve(token);
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, '%{public}s', 'getDeviceToken failed! err code: ' + err.code +
          ' ,err message: ' + err.message);
        reject(err);
      });
    } catch (err) {
      let error: BusinessError = err as BusinessError;
      hilog.error(0x0000, TAG, '%{public}s', 'getDeviceToken failed! catch err code: ' + error.code +
        ' ,err message: ' + error.message);
      reject(err);
    }
  });
}

export class DevCertManagerModel {
  private displayText: String = '';

  async displayDeviceToken(callback: Function) {
    this.displayText = '';
    hilog.info(0x0000, TAG, 'getDeviceToken start');
    await deviceTokenPromise().then((token) => {
      hilog.info(0x0000, TAG, '%{public}s', 'Succeeded in executing getDeviceToken, deviceToken is ' + token);
      this.displayText = token;
      callback(this.displayText);
    }).catch((err: BusinessError) => {
      this.displayText = 'get deviceToken failed, err code: ' + err.code + ' ,err message: ' + err.message;
      callback(this.displayText);
    });
  }
}

let devCertMangerModel = new DevCertManagerModel();

export default devCertMangerModel as DevCertManagerModel;