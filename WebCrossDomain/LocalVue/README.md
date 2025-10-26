# Web页面跨域解决方案

### 介绍

本工程为【基于ArkWeb拦截器和Cookie管理能力实现Web页面跨域】的Vue工程，主要用于为该最佳实践的Sample工程提供场景所需的H5页面资源。

### 工程目录

```
├──src                              
│  ├──assets/css                  
│  │  └──global.css                     // 公共css样式
│  ├──components                 
│  │  ├──CookiesSettingsA.vue           // 跨域Cookies设置场景A域名页面
│  │  ├──CookiesSettingsB.vue           // 跨域Cookies设置场景B域名页面
│  │  ├──CustomProtocol.vue             // 自定义协议跨域场景页面
│  │  ├──FatalPage.vue                  // 通用错误页面
│  │  ├──LocalResource.vue              // 本地资源跨域场景页面
│  │  └──RemoteRequest.vue              // 远程请求跨域场景页面
│  └──pages                 
│     ├──CookiesSettingsA/main.js       // 跨域Cookies设置场景A域名页面入口文件
│     ├──CookiesSettingsB/main.js       // 跨域Cookies设置场景B域名页面入口文件
│     ├──CustomProtocol/main.js         // 自定义协议跨域场景页面入口文件
│     ├──FatalPage/main.js              // 通用错误页面入口文件
│     ├──LocalResource/main.js          // 本地资源跨域场景页面入口文件
│     └──RemoteRequest/main.js          // 远程请求跨域场景页面入口文件
└──vue.config.js                        // Vue构建配置文件
```

### 运行步骤

在根目录下执行以下命令，用于构建应用所需的全部页面：

   ```sh
   npm i
   npm run build:all
   ```
注：若只构建某一场景页面，可参考package.json的命令脚本。
   

