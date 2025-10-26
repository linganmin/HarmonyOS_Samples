# Server-Side Sample Code for Sending Service Updates
- This demo provides sample code for sending service updates messages for an atomic service based on Java.
## Supported Java Versions
Java 8+
## Getting Started
### Download
Download the demo and open it in the IDE.
### Preparations
1. Apply for the service updates message permission of atomic services.
   - Sending service updates messages is a business-to-customer (B2C) message capability provided for developers. With this capability, you will be able to send real-time updates to users regarding key nodes of their orders, keeping them informed of their order status.\
     You can enable the service updates message permission by referring to [Pushing an Account-based Service Updates Message](https://developer.huawei.com/consumer/en/doc/atomic-guides/push-as-timeline).

2. Obtain the service account credential file.
   - Create the key file of a service account.\
     Create and download the key file of a service account to call Push Kit APIs on [API Console](https://developer.huawei.com/consumer/cn/console/overview) of HUAWEI Developers. For details, please refer to [API Console Operation Guide - Creating a Service Account Key](https://developer.huawei.com/consumer/en/doc/start/api-0000001062522591#section3554194116341).\
     The following is an example of the service account key file (with key information anonymized):
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
3. Set service updates parameters.
   - [projectId]: project ID. To obtain the value, sign in to [AppGallery Connect](https://developer.huawei.com/consumer/en/service/josp/agc/index.html), click **Development and services**, click the desired project, and go to **Project settings**.
   - [Authorization]: JWT string. For details about how to obtain the value, please refer to [Authorization](https://developer.huawei.com/consumer/en/doc/harmonyos-references/push-scenariozed-api-request-struct#section20573634202313). You can also generate the string using the service account credential file based on the demo.
   - [appId]: app Id of the atomic service. To obtain the value, sign in to [AppGallery Connect](https://developer.huawei.com/consumer/en/service/josp/agc/index.html), click **Apps**, go to **HarmonyOS** > **Distribute** > **Release app** > **App information**, and check the app ID.
   - [toOpenId]: OpenID of the recipient. Use the OpenId reported by the client or request [user information](https://developer.huawei.com/consumer/en/doc/harmonyos-references/account-api-get-user-info-quicklogin-getid#section2520125725115) from Account Kit.
   - [sceneId]: scenario ID.
   - [subSceneId]: sub-scenario ID.
   - [content]: status specified in a service updates message.
### Running the Demo
Replace the following items in the [service account credential file](./src/main/resources/service_account.json): project ID, appId(atomic service app ID), scenario ID, and sub-scenario ID in the [configuration file](./src/main/resources/config.json), as well as the code, OpenId of the recipient, and message body in the [project](./src/main/java/com/huawei/serviceTimeline/TakeawaysExamples.java). Then run the main method to send a service updates message.
