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

<template>
  <div class="container">
    <div class="section">
      <div class="content">
        <div>加载自定义协议H5页面，拦截并替换为本地H5页面，点击下方按钮调用自定义协议请求，拦截并弹出系统提示框。</div>
        <div>页面路径：</div>
        <div>app://index.html</div>
        <div>接口路径：</div>
        <div>app://api/openDialog</div>
      </div>
      <div class="logArea">
        <div class="logArea_name">自定义协议页面部分代码（资源文件使用自定义协议引用）</div>
        <div>...<br>
          {{ '<script defer="defer" src="app://js/chunk-vendors.xxx.js"></script>' }}<br>
          {{ '<script defer="defer" src="app://js/app.xxx.js"></script>' }}<br>
          {{ '<link href="app://css/app.xxx.css" rel="stylesheet">' }}<br>
          ...
        </div>
      </div>
    </div>
    <div class="footer">
      <a class="btn" href="app://api/openDialog">发起自定义协议请求，弹出拦截弹框</a>
    </div>
  </div>
</template>

<style scoped>
  .container {
    padding: 16px 16px 32px;
    max-width: 750px;
    height: calc(100vh - 56px);
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    overflow-y: auto;
  }
  .section .content {
    font-size: 16px;
    line-height: 1.6;
    word-wrap: break-word;
  }
  .logArea {
    margin: 16px 0px 32px;
    box-sizing: border-box;
    padding: 16px 16px;
    width: 100%;
    min-height: 200px;
    max-height: 350px;
    overflow-y: auto;
    border-radius: 20px;
    background-color: #ffffff;
    box-shadow: 0 0 4px rgba(0,0,0,0.1);
  }
  .result {
    margin-top: 15px;
    padding: 15px;
    border-radius: 4px;
    background-color: #f8f9fa;
    white-space: pre-wrap;
    font-family: monospace;
  }
  .success {
    border: 1px solid #42b983;
  }
  .error {
    border: 1px solid #ff4444;
    color: #ff4444;
  }
  .btn {
    display: inline-block;
    width: 100%;
    height: 40px;
    border-radius: 20px;
    background-color: #0a59f7;
    display: inline-block;
    color: #f1f3f5;
    text-align: center;
    line-height: 40px;
  }
</style>