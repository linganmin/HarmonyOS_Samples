/*
* Copyright (c) 2025 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
  */

/**
* 最佳实践：应用安全编码实践
* 场景三十一：建议正确设置发布版本应用调试属性
  */
// [Start app_json]
// app.json5   
{  
  {  
  "app": {  
  "bundleName": "com.application.music",  
  "vendor": "application",  
  "versionCode": 1,  
  "versionName": "1.0",  
  "minCompatibleVersionCode": 1,  
  "minAPIVersion": 7,  
  "targetAPIVersion": 8,  
  "apiReleaseType": "Release",  
  "debug": false,  
  "icon": "$media:app_icon",  
  "label": "$string:app_name",  
  "description": "$string:description_application",  
  "distributedNotificationEnabled": true,  
  "entityType": "game",  
  "car": {  
  "apiCompatibleVersion": 8  
   }  
  }  
}  
// [End app_json]