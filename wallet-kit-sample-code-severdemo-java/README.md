# 华为钱包服务服务端示例代码
### 目录

* [简介](#简介)
* [环境要求](#环境要求)
* [申请华为钱包服务](#申请华为钱包服务)
* [配置参数](#配置参数)
* [卡券模板和实例](#卡券模板和实例)
* [编译Maven工程](#编译Maven工程)
* [示例方法](#示例方法)
   1. [卡券实例示例方法](#卡券实例示例方法)
   1. [生成JWE](#生成JWE)
* [技术支持](#技术支持)
* [授权许可](#授权许可)


## 简介
Wallet Kit（钱包服务）集成了终端“芯-端-云”全栈技术的开放能力，可实现车钥匙的凭证电子化。让用户能够轻松地将车钥匙保存在手机中，以便在适当的时间使用。

## 环境要求
示例代码的运行环境为Maven和Oracle Java（1.8.0.211及以上版本）。

## 申请华为钱包服务
参照[创建Wallet Kit服务](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/wallet-preparations) 申请华为钱包服务。<br>

请注意在申请钱包服务的过程中需要创建一个服务号，该服务号即为passTypeIdentifier的值，后续将在配置示例代码中用到。<br>

您在申请过程中还会创建一对RSA公私钥，请妥善保管。其中私钥用于后续对JWE进行签名 (详情请参阅 [生成JWE](#生成JWE). 公钥用于钱包服务器验签。<br>

在设置完一类卡券的服务号之后，你就可以运行这个卡券对应的示例代码了。如果你想测试其他卡券，则需申请其他卡券的服务号。

## 配置参数
运行示例代码前，在”src\test\resources\release.config.properties”文件中配置如下参数：”gw.appid”, “gw.appid.secret”, “gw.tokenUrl”, “walletServerBaseUrl”, “servicePrivateKey”和“walletWebsiteBaseUrl”。

#### 设置 "gw.appid" and "gw.appid.secret":
"gw.appid"和"gw.appid.secret"为应用的"APP ID"和"SecretKey"。登录[AppGallery Connect](https://developer.huawei.com/consumer/cn/service/josp/agc/index.html)，点击“我的应用”，选择目标应用，即可找到该应用的APP ID和SecretKey。

#### 设置 "gw.tokenUrl"
获取REST接口认证token的地址，将gw.tokenUrl设置为https://oauth-login.cloud.huawei.com/oauth2/v3/token

#### 设置 "walletServerBaseUrl":
"walletServerBaseUrl" 为REST接口请求的公共部分，格式为https://{walletkit_server_url}/hmspass。其中{walletkit_server_url}需要根据您的账号所属国家/地区自行替换，目前仅涉及中国大陆：wallet-passentrust-drcn.cloud.huawei.com.cn

#### 设置 "servicePrivateKety"
将"servicePrivateKey"设置为您在[申请华为钱包服务](#申请华为钱包服务)时生成的RSA私钥。您将用此参数对JWE进行签名。

#### 设置 "walletWebsiteBaseUrl"
"walletWebsiteBaseUrl" 是华为钱包H5服务器地址，格式为https://{walletkit_website_url}/walletkit/consumer/pass/save。其中{walletkit_server_url}需要根据您的账号所属国家/地区自行替换，目前仅涉及中国大陆：walletpass-drcn.cloud.huawei.com

## 卡券模板和实例
一个模板代表一种卡券。同一模板下的实例会共享某些参数。每一个卡券实例都有一个对应的模板。因此，您需要先创建一个卡券模板，然后才能创建卡券并进行其他操作。<br>

在示例代码中，卡券模板和实例的入参均通过"src\test\resources\data"文件夹下的JSON文件传入。您可以自行修改JSON文件来生成您想要的卡券。<br>

请把JSON文件中"passTypeIdentifier"的值设置为您在[AppGallery Connect](https://developer.huawei.com/consumer/cn/service/josp/agc/index.html)上设置的服务号。

## 编译Maven工程
设置完上述参数后，请将示例代码编译为Maven工程。将全部依赖部署完毕可能要花几分钟时间，具体取决于您的配置文件和网络状况。

## 示例方法
### 卡券实例示例方法
#### 1. 创建一个卡券模板
华为钱包服务器提供REST接口用于创建卡券模板。例如，您可通过调用createStdCarKeyModel添加车钥匙模板到服务器数据库，具体请参阅[预置模板](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/wallet-rest-api-carkey#section37263211548)。添加其他类型卡券方法类似。调用其他相关方法前须先创建卡券模板。

#### 2. 添加车钥匙实例
华为钱包服务器提供REST接口用于添加消息到卡券实例。例如，可通过调用addStdCarKeyInstance增加车钥匙实例，详情请参阅[申请钥匙卡片](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/wallet-rest-api-carkey#section129511211195)。添加其他类型卡券方法类似。调用其他相关方法前须先创建卡券。

### 生成JWE
华为钱包车钥匙卡片的开通是基于JWE（JSON Web Encryption）方式。因此DK业务管理服务向钱包云服务申请创建车钥匙成功后，基于创建成功的车钥匙serialNumber生成JWE数据，并将其返回给车厂app。更多信息请参阅[生成JWE数据](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/wallet-rest-api-carkey#section1310081523717)。

## 技术支持
如果您在尝试示例代码中遇到问题，请提交[在线提单](https://developer.huawei.com/consumer/cn/support/feedback/#/)。
## 授权许可
华为钱包服务服务端示例代码经过[Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0)授权许可。
