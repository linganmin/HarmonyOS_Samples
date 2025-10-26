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

// Get params from url
let urlSearchParams = new URLSearchParams(window.location.search);
let aid = urlSearchParams.get('aid');

// [Start web_ua_adapter]
function matchHarmonyOS() {
  // Determine whether the recognition system is HarmonyOS.
  const isHarmonyOS = /OpenHarmony/i.test(navigator.userAgent);
  // Get system version number
  const matches = navigator.userAgent.match(/OpenHarmony (\d+\.?\d*)/);
  return isHarmonyOS && matches?.length && Number(matches[1]) >= 5;
}

// [Start web_open_link]
function openLink() {
  // [Start 5]
  if (matchHarmonyOS()) {
    // Launch the application through app linking.
    // [StartExclude web_ua_adapter]
    // Replace with a real usable app linking link.
    window.location.href = 'https://www.example.com?aid=' + aid;
    // [EndExclude web_ua_adapter]
  } else {
    // Redirect logic for other platforms
  }
  // [End 5]
}
// [End web_open_link]
// [End web_ua_adapter]
// [Start web_to_appgallery]
function toAppgallery() {
  // Replace with a real usable application market app linking link.
  window.location.href = 'https://appgallery.huawei.com/app/detail?id=com.huawei.hmsapp.books';
}
// [End web_to_appgallery]


const lang = navigator.language || navigator.userLanguage;
let pageData;
if (lang.toLowerCase().startsWith('zh')) {
  pageData = dataZh;
} else {
  pageData = dataEn;
}
let articleData = pageData.articeList.find((item) => (item.aId === aid));
document.getElementById('user-name').innerHTML = articleData.author;
document.getElementById('article-title').innerHTML = articleData.title;
document.getElementById('detail-text').innerHTML = articleData.content;
document.getElementById('btn-follow').innerHTML = pageData.follow;
document.getElementById('bottom-button').innerHTML = pageData.skip;
document.getElementById('app-name').innerHTML = pageData.appName;
document.getElementById('app-description').innerHTML = pageData.appDesc;