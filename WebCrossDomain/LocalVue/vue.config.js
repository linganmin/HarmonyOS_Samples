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

const fs = require('fs');
const path = require('path');

// 页面路径映射配置
const pageOutputMap = {
  LocalResource: '../entry/src/main/resources/resfile/LocalResource/dist',
  CustomProtocol: '../entry/src/main/resources/resfile/CustomProtocol/dist',
  RemoteRequest: '../LocalServer/web/RemoteRequest/dist',
  CookiesSettingsA: '../LocalServer/web/CookiesSettingsA/dist',
  CookiesSettingsB: '../LocalServer/web/CookiesSettingsB/dist',
  FatalPage: '../entry/src/main/resources/resfile/FatalPage/dist'
};

// 自定义协议场景配置
const getPublicPath = (targetPage) => {
  if (targetPage === 'CustomProtocol') {
    return 'app://';
  } else {
    return './';
  }
}

// 获取当前要构建的页面（从环境变量获取）
const targetPage = process.env.VUE_APP_TARGET_PAGE;

// 验证目标页面是否存在
const componentsDir = path.resolve(__dirname, 'src/components');
const validPages = fs.readdirSync(componentsDir)
  .filter(file => file.endsWith('.vue'))
  .map(file => file.replace('.vue', ''));

if (!targetPage) {
  console.error('请指定要构建的页面，例如: VUE_APP_TARGET_PAGE=LocalResource npm run build');
  process.exit(1);
}

if (!validPages.includes(targetPage)) {
  console.error(`无效的页面名称: ${targetPage}，可用页面: ${validPages.join(', ')}`);
  process.exit(1);
}

// 构建单页面配置
const pages = {};
pages[targetPage] = {
  entry: `src/pages/${targetPage}/main.js`,
  template: 'public/index.html',
  filename: 'index.html',
  title: targetPage.replace(/([A-Z])/g, ' $1').trim()
};

module.exports = {
  publicPath: getPublicPath(targetPage),
  outputDir: pageOutputMap[targetPage],
  pages,
};