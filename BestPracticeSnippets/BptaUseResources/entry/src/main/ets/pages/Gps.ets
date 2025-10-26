/**
 * 最佳实践：合理使用GPS资源
 */

// [Start gps_resources]
import { UIAbility } from '@kit.AbilityKit';
import { geoLocationManager } from '@kit.LocationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

// [StartExclude gps_resources]
let locationChange = (location: geoLocationManager.Location): void => {
  console.log('locationChanger:data:' + JSON.stringify(location));
};

// [EndExclude gps_resources]

export default class EntryAbility extends UIAbility {
  // ...
  onForeground(): void {
    // Create a location request based on service requirements at the foreground
    let requestInfo: geoLocationManager.LocationRequest = {
      'priority': geoLocationManager.LocationRequestPriority.ACCURACY,
      'timeInterval': 0,
      'distanceInterval': 0,
      'maxAccuracy': 0
    };
    let locationChange = (location: geoLocationManager.Location): void => {
      console.log('locationChanger:data:' + JSON.stringify(location));
    };
    try {
      //The change of the listening position
      geoLocationManager.on('locationChange', requestInfo, locationChange);
    } catch (error) {
      let err = error as BusinessError;
      hilog.warn(0x000, 'testTag', `geoLocationManager on failed, code=${err.code}, message=${err.message}`);
    }
  }

  onBackground(): void {
    try {
      //The backstage cancels the listening
      geoLocationManager.off('locationChange', locationChange);
    } catch (error) {
      let err = error as BusinessError;
      hilog.warn(0x000, 'testTag', `geoLocationManager off failed, code=${err.code}, message=${err.message}`);
    }
  }
}

// [End gps_resources]