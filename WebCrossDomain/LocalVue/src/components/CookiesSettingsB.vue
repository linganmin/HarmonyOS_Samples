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
  <div class='container'>
    <div class='section'>
      <div class='content'>
        <div>加载b.com域名下H5页面，自动调用getCookies接口，给服务器传递从a.com域名拿到的cookies，服务器返回信息显示在日志区。</div>
        <div>页面路径：</div>
        <div>http://www.b.harmonyos:8080/CookieSettingsB/dist/index.html</div>
        <div>接口路径：</div>
        <div>http://www.b.harmonyos:8080/api/getCookies</div>
      </div>
      <div class='logArea'>
        <div class='logArea_name'>日志区</div>
        <div v-if="result" :class="['result', success ? 'success' : 'error']">
          {{ result }}
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';

export default {
  data() {
    return {
      result: null,
      success: false
    };
  },
  mounted() {
    this.getCookies();
  },
  methods: {
    async getCookies() {
      try {
        // [Start http_request]
        const response = await axios.post('http://www.b.harmonyos:8080/api/getCookies', {}, {
          withCredentials: true
        });
        // [End http_request]
        const resStr = JSON.stringify(response.data, null, 2);
        if (resStr.includes('<title>Error</title>')) {
          this.success = false;
        } else {
          this.success = true;
        }
        this.result = response.data;
      } catch (error) {
        this.result = error.response?.data || '获取cookies失败';
        this.success = false;
      }
    }
  }
};
</script>

<style scoped>
  .container {
    padding: 16px 16px 32px;
    max-width: 750px;
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
    overflow-x: auto;
  }
  .success {
    border: 1px solid #42b983;
  }
  .error {
    border: 1px solid #ffaaaa;
    color: #ff4444;
  }
  .btn {
    display: inline-block;
    width: 100%;
    height: 40px;
    border-radius: 20px;
    background-color: #0a59f7;
    color: #f1f3f5;
    text-align: center;
    line-height: 40px;
  }
</style>