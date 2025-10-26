# 应用内支付-服务器API示例-Java

## 目录

* [介绍](#介绍)
* [支持环境](#支持环境)
* [依赖](#依赖)
* [配置](#配置)
* [示例代码](#示例代码)
* [开源许可](#开源许可)

## 介绍

应用内支付-服务器API示例 提供了一些关于IAP服务端的API代码示例，以供参考或使用。相关的类或包如下：

> > JWTGenetator：生成jwt的示例代码。更多详细信息，请参考[生成服务端请求的token](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/iap-jwt-description)。
>
> > IAPServer：请求IAP服务器的示例代码。更多详细信息，请参考[公共说明](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/iap-rest-common-statement)。
>
> > OrderService：订单相关的示例代码。更多详细信息，请参考[订单状态查询（消耗型/非消耗型/非续期订阅商品）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/iap-query-order-status)和[订单确认发货（消耗型/非消耗型/非续期订阅商品）](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/iap-confirm-purchase-for-order)。
>
> > SubscriptionService：订阅相关的示例代码。更多详细信息，请参考[订阅状态查询](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/iap-query-subscription-status)和[订阅确认发货](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/iap-confirm-purchase-for-sub)。
>
> > JWSChecker：jws校验的示例代码。更多详细信息，请参考[对返回结果验签](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/iap-verifying-signature)。
>
> > notification：关键事件通知的示例代码。更多详细信息，请参考[服务端关键事件通知](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/iap-key-event-notifications)。

## 支持环境

推荐使用JDK 1.8及以上版本。

## 依赖

### Maven

```xml

<dependencies>
    <!-- https://mvnrepository.com/artifact/com.auth0/java-jwt -->
    <dependency>
        <groupId>com.auth0</groupId>
        <artifactId>java-jwt</artifactId>
        <version>4.4.0</version>
    </dependency>

    <!-- https://mvnrepository.com/artifact/commons-codec/commons-codec -->
    <dependency>
        <groupId>commons-codec</groupId>
        <artifactId>commons-codec</artifactId>
        <version>1.9</version>
    </dependency>

    <!-- https://mvnrepository.com/artifact/com.fasterxml.jackson.core/jackson-databind -->
    <dependency>
        <groupId>com.fasterxml.jackson.core</groupId>
        <artifactId>jackson-databind</artifactId>
        <version>2.13.4.2</version>
        <scope>compile</scope>
    </dependency>
</dependencies>
```

## 配置

要使用示例中提供的方法，需要配置以下相关参数。

> JWTGenetator.java中的参数说明如下。更多详细信息，请参考[生成服务端请求的token](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/iap-jwt-description)。
>
> > | 参数               | 说明                                                    |
> > | ----------------- | ------------------------------------------------------- |
> > | JWT_PRI_KEY_PATH  | 私钥文件路径。                                          |
> > | ACTIVE_TIME_SECOND | JWT有效期，UTC时间戳，以秒为单位。有效期不能超过1小时。 |
> > | kid               | 密钥ID。                                                |
> > | iss               | 密钥颁发者ID。                                          |
> > | aid               | APP ID。                                                |
>
> JWSChecker.java中的参数说明如下。更多详细信息，请参考[对返回结果验签](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/iap-verifying-signature)。
>
> > | 参数                  | 说明                                 |
> > | --------------------- | ------------------------------------ |
> > | CA_CERT_FILE_PATH     | Huawei CBG Root CA G2 证书文件路径。 |
> > | CRL_SOFT_FAIL_ENABLED | 是否忽略CRL网络错误。                |

## 示例代码

APIExample中已提供了一些示例，可以参考以下代码进行测试。

```java
public class APIExample {
    public static void main(String[] args) throws Exception {
        testGenJwt();
    }

    public static void testGenJwt() throws Exception {
        Map<String, Object> bodyMap = new HashMap<>();
        bodyMap.put("purchaseOrderId", "purchaseOrderId");
        bodyMap.put("purchaseToken", "purchaseToken");
        ObjectMapper objectMapper = new ObjectMapper();
        String bodyJsonStr = objectMapper.writeValueAsString(bodyMap);
        String jwt = JWTGenerator.genJwt(bodyJsonStr);
        System.out.println(jwt);
    }
}
```


## 开源许可

应用内支付-服务器API示例在[Apache许可证，版本2.0](http://www.apache.org/licenses/LICENSE-2.0)下获得许可。

