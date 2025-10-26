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
        <div>加载页面出现错误！</div>
        <div>请检查服务器是否正常启动，设备端口是否转发。</div>
      </div>
      <div class="logArea">
        <div class="logArea_name">日志区</div>
        <div v-if="result" class="error">
          {{ result }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      result: null,
    };
  },
  mounted() {
    this.parseRequest();
  },
  methods: {
    parseRequest() {
      const errorInfo = window.location.search.split('=')[1];
      switch (errorInfo) {
        case 'ERR_CONNECTION_REFUSED':
          this.result = 'ERR_CONNECTION_REFUSED 连接被拒绝。';
          break;
        case 'ERR_CONNECTION_FAILED':
          this.result = 'ERR_CONNECTION_FAILED 连接失败。';
          break;
        case 'ERR_NAME_NOT_RESOLVED':
          this.result = 'ERR_NAME_NOT_RESOLVED 域名无法解析。';
          break;
        case 'ERR_INTERNET_DISCONNECTED':
          this.result = 'ERR_INTERNET_DISCONNECTED 网络断开连接。';
          break;
        case 'ERR_ADDRESS_INVALID':
          this.result = 'ERR_ADDRESS_INVALID IP地址或端口号无效。';
          break;
        case 'ERR_FILE_NOT_FOUND':
          this.result = 'ERR_FILE_NOT_FOUND 文件未找到，请检查本地资源文件';
          break;
        default:
          this.result = '页面加载失败，请检查资源文件或网络';
      }
    }
  }
};
</script>

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
  .error {
    padding: 4px;
    border: 1px solid #ff4444;
    color: #ff4444;
  }
  .btn {
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