/**
 * 最佳实践：合理使用传感器资源
 */

// [Start sensor_resources]
import { UIAbility } from '@kit.AbilityKit';
import { sensor } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

export default class EntryAbility extends UIAbility {
  // ...
  onForeground(): void {
    try {
      //In the foreground, listen to the required type of sensor based on the service requirements
      sensor.on(sensor.SensorId.ACCELEROMETER, (data: sensor.AccelerometerResponse) => {
        console.info("Succeeded in obtaining data.x:" + data.x + "y:" + data.y + "z:" + data.z);
      }, {
        interval: 100000000
      });
    } catch (error) {
      let err = error as BusinessError;
      hilog.warn(0x000, 'testTag', `sensor on failed, code=${err.code}, message=${err.message}`);
    }
  }

  onBackground(): void {
    try {
      //The backstage cancels the listening
      sensor.off(sensor.SensorId.ACCELEROMETER);
    } catch (error) {
      let err = error as BusinessError;
      hilog.warn(0x000, 'testTag', `sensor off failed, code=${err.code}, message=${err.message}`);
    }
  }
}

// [End sensor_resources]