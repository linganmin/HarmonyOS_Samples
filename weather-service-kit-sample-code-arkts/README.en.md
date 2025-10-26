## Obtaining Weather Data

### Introduction
Weather Service Kit is a data provision service in the HarmonyOS ecosystem.
With the support of multiple top meteorological suppliers, it provides professional, accurate, and stable ultra-local weather data services.
You can obtain weather data through the open capabilities provided by Weather Service Kit.

### Preview

![](screenshots/device/preview.png)

### Project Directory
```
├──entry/src/main/ets/
│  ├──entryability
│  │  ├──EntryAbility.ts    // Ability for local startup.
│  └──pages
│     └── Index.ets          // UI for obtaining weather data.
└──entry/src/main/resources            // Static resources of the app.
```

### How to Implement
Call Weather Service Kit to obtain weather data.
```ts
// Import required modules of Weather Service Kit.
import { weatherService } from '@kit.WeatherServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

// Create a weather data request.
let weatherRequest: weatherService.WeatherRequest = {
  location: {
    latitude: 0,
    longitude: 0
  },
  limitedDatasets: [
    weatherService.Dataset.CURRENT, weatherService.Dataset.DAILY, weatherService.Dataset.HOURLY,
    weatherService.Dataset.MINUTE, weatherService.Dataset.ALERTS, weatherService.Dataset.INDICES,
    weatherService.Dataset.TIDES
  ]
};

// Call the **getWeather** method to execute the query request and process the returned result.
try {
  let weather: weatherService.Weather = await weatherService.getWeather(weatherRequest);
  hilog.info(0x0000, 'testTag', `Success to get weather: ${JSON.stringify(weather)}`);
} catch (err) {
  let businessError: BusinessError = err as BusinessError;
  hilog.error(0x0000, 'testTag',
    `Failed to get weather. Code: ${businessError.code}, message: ${businessError.message}`);
}
```

### Required Permissions
Enable the Weather Service Kit permission in [AppGallery Connect](https://developer.huawei.com/consumer/en/service/josp/agc/index.html#/) and apply for a new profile for signing.

![alt text](screenshots/device/image.png)

### Constraints
1. Device types: phone, tablet, PC/2-in-1 device, and wearable.

2. HarmonyOS: HarmonyOS NEXT Developer Beta2 or later.

3. DevEco Studio: DevEco Studio NEXT Developer Beta2 or later.

4. HarmonyOS SDK: HarmonyOS NEXT Developer Beta2 SDK or later.

5. Weather Service Kit is currently available only to system apps and cannot be accessed by external apps.
