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

const { execSync } = require('child_process');
let serverFlag: boolean = false;

export function addPort() {
  try {
    const result = execSync('hdc rport tcp:8080 tcp:8080', { encoding: 'utf8' });
    console.log(result);
  } catch (err) {
    console.error('Execution failed:', err.message);
  }
}

export function delPort() {
  try {
    const result = execSync('hdc fport rm tcp:8080 tcp:8080', { encoding: 'utf8' });
    console.log(result);
  } catch (err) {
    console.error('Execution failed:', err.message);
  }
}

export function installServer() {
  try {
    const result = execSync('npm i', {cwd: './LocalServer', encoding: 'utf8' });
    console.log(result);
  } catch (err) {
    console.error('Execution failed:', err.message);
  }
}

export function startServer() {
  try {
    serverFlag = true;
    const result = execSync('npm run forever:start', {cwd: './LocalServer', encoding: 'utf8' });
    console.log(result);
  } catch (err) {
    console.error('Execution failed:', err.message);
  }
}

export function restartServer() {
  try {
    const result = execSync('npm run forever:restart', {cwd: './LocalServer', encoding: 'utf8' });
    console.log(result);
  } catch (err) {
    console.error('Execution failed:', err.message);
  }
}

export function stopServer() {
  try {
    serverFlag = false;
    const result = execSync('npm run forever:stop', {cwd: './LocalServer', encoding: 'utf8' });
    console.log(result);
  } catch (err) {
    console.error('Execution failed:', err.message);
  }
}

export function runTask() {
  try {
    addPort();
    if (!serverFlag) {
      installServer();
      startServer();
    } else {
      restartServer();
    }
  } catch (err) {
    console.error('Execution failed:', err.message);
  }
}

export function rerunTask() {
  try {
    delPort();
    addPort();
    restartServer();
  } catch (err) {
    console.error('Execution failed:', err.message);
  }
}

export function stopTask() {
  try {
    delPort();
    stopServer();
  } catch (err) {
    console.error('Execution failed:', err.message);
  }
}