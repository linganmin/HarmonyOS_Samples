# 服务动态 服务端 代码示例
- 本demo为面向Java的元服务服务动态消息推送示例代码。
## 支持的java版本
java 8+
## 快速开始
### 下载
下载此demo并在IDE中打开。
### 开发准备
1. 元服务服务动态消息权益申请
   - 服务动态消息是提供给开发者的B2C（Business-to-Customer）消息能力，通过服务动态消息，开发者可以基于订单向用户推送关键节点的动态消息，及时提醒用户订单进度。\
     开发者可以参考[基于账号的服务动态消息](https://developer.huawei.com/consumer/cn/doc/atomic-guides/push-as-timeline)开通动态消息服务。

2. 获取Service Account凭据文件，具体步骤如下：
   - 创建服务账号密钥文件\
     您需要在华为开发者联盟的[API Console](https://developer.huawei.com/consumer/cn/console/overview)上，在左侧”API服务“页签中点击”凭证“页面，创建并下载推送服务API的服务账号密钥文件，相关创建步骤请参见[API Console操作指南-服务账号密钥](https://developer.huawei.com/consumer/cn/doc/start/api-0000001062522591#section3554194116341)。\
     您申请后的服务账号密钥样例文件形式可参考（文件内容已经经过脱敏处理）：
     ~~~json
     {
       "project_id": "*****",
       "key_id": "*****",
       "private_key": "-----BEGIN PRIVATE KEY-----\n**********************************==\n-----END PRIVATE KEY-----\n",
       "sub_account": "*****",
       "auth_uri": "https://oauth-login.cloud.huawei.com/oauth2/v3/authorize",
       "token_uri": "https://oauth-login.cloud.huawei.com/oauth2/v3/token",
       "auth_provider_cert_uri": "https://oauth-login.cloud.huawei.com/oauth2/v3/certs",
       "client_cert_uri": "https://oauth-login.cloud.huawei.com/oauth2/v3/x509?client_id=*****"
     }
     ~~~
3. 推送服务动态消息的参数示例如下，更多详情请见[服务动态推送API接口](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/push-api-service-timeline-send)。
   - [projectId]：项目ID，登录[AppGallery Connect](https://developer.huawei.com/consumer/cn/service/josp/agc/index.html)网站，选择“开发与服务”，在项目列表中选择对应的项目，左侧导航栏选择“项目设置”，在该页面获取。
   - [Authorization]：JWT格式字符串，可参见[Authorization](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/push-scenariozed-api-request-struct#section20573634202313)获取。
   - [appId]：元服务的appId，登录[AppGallery Connect](https://developer.huawei.com/consumer/cn/service/josp/agc/index.html)网站，选择“APP”，在HarmonyOS页签下点击对应元服务，左侧导航栏选择“信息中心”，在该页面获取。
   - [toOpenId]：接收者（用户）账号登录的openId。使用从端侧上报的openId，或请求华为账号服务器获取[用户信息](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/account-api-get-user-info-quicklogin-getid#section2520125725115)。
   - [sceneId]：场景标识。详情请见[服务动态发送场景说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/push-api-service-timeline-param#section159496312255)。
   - [subSceneId]：子场景标识。详情请见[服务动态发送场景说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/push-api-service-timeline-param#section159496312255)。
   - [code]：授权码，用于服务动态消息推送和更新。获取方式：使用华为支付商户订单号[mercOrderNo](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/payment-prepay#section375413411591)。
   - [content]：服务动态指定状态参数。详情请见[请求体结构说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/push-api-service-timeline-send#section16714723163811)。
### 运行
替换[Service Account凭据文件](./src/main/resources/service_account.json)中的每一项，[配置文件](./src/main/resources/config.json)中的项目ID、元服务的appId、场景标识和子场景标识，[项目](./src/main/java/com/huawei/serviceTimeline/TakeawaysExamples.java)中的的code、接收者（用户）账号登录的openId以及消息体内容， 然后运行其 main 方法推送服务动态消息。