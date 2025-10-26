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

const express = require('express');
const vhost = require('vhost');
const cors = require('cors');
const path = require('path');
const cookieParser = require('cookie-parser');

// Creating a Primary Server
const app = express();

app.use(express.json());

app.use(cookieParser());

app.use(express.static(path.join(__dirname, './web')));

// Create the server for a.com
const appA = express();

appA.get('/api/echo', (req, res) => {
  res.json({
    status: 'success',
    port: 8080,
    message: '请求成功',
    received: req.query,
  });
});

appA.post('/api/setCookies', (req, res) => {
  console.log('setCookies收到请求:', req.body);
  const { name, value } = req.body;

  if (!name || !value) {
    return res.status(400).json({ message: 'Cookie名称和值不能为空' });
  }

  res.cookie(name, value, {
    maxAge: 900000,
    httpOnly: true,
    secure: false,
    sameSite: 'lax'
  });

  res.json({
    message: 'a.com域名已设置cookie',
    cookie: { name, value }
  });
});

// Create the server for b.com
const appB = express();

// [Start CORS_configuration]
appB.use(cors({
  origin: 'http://www.a.harmonyos:8080',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true
}));
// [End CORS_configuration]

appB.post('/api/getCookies', (req, res) => {
  console.log('请求携带的 Cookie:', req.cookies);
  res.json({
    message: 'b.com域名已接收到cookie',
    cookies: req.cookies
  });
});

// Create the server for c.com
const appC = express();

appC.get('/api/data', (req, res) => {
  res.json({
    status: 'success',
    port: 8080,
    message: '请求成功',
    received: req.query,
  });
});

app.use(vhost('www.a.harmonyos', appA));
app.use(vhost('www.b.harmonyos', appB));
app.use(vhost('www.c.harmonyos', appC));

// Start the server and listen on port 8080.
const PORT = 8080;
app.listen(PORT, () => {
  console.log(`服务器运行在端口 ${PORT}`);
  console.log('访问地址:');
  console.log('http://www.a.harmonyos:8080');
  console.log('http://www.b.harmonyos:8080');
  console.log('http://www.c.harmonyos:8080');
});
