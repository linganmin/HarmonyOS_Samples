# IAPKit-Sample-SeverDemo-Java

## Table of Contents

* [Introduction](#introduction)
* [Supported Environments](#supported-environments)
* [Installation](#installation)
* [Configuration ](#configuration)
* [Sample Code](#sample-code)
* [License](#license)

## Introduction

IAPKit-Sample-SeverDemo provides some API code samples about the IAP server for reference or use. The related classes or packages are as follows:  

> > JWTGenetator：sample code for generating jwt. For more details, please refer to [Generating a Token for a Server-Side API Call](https://developer.huawei.com/consumer/en/doc/harmonyos-references/iap-jwt-description).
> 
> > IAPServer: sample code for requesting an IAP server. For more details, please refer to [Overview](https://developer.huawei.com/consumer/en/doc/harmonyos-references/iap-rest-common-statement).
>
> > OrderService: sample code related to orders. For more details, please refer to [Acknowledging the Delivery for a Consumable, Querying the Order Status for a Consumable, Non-consumable, or Non-renewable Subscription](https://developer.huawei.com/consumer/en/doc/harmonyos-references/iap-query-order-status) and [Acknowledging the Delivery for a Consumable, Non-consumable, or Non-renewable Subscription](https://developer.huawei.com/consumer/en/doc/harmonyos-references/iap-confirm-purchase-for-order).
>
> > SubscriptionService: sample code related to subscription. For more details, please refer to [Querying the Subscription Status](https://developer.huawei.com/consumer/en/doc/harmonyos-references/iap-query-subscription-status) and [Acknowledging the Delivery for a Subscription](https://developer.huawei.com/consumer/en/doc/harmonyos-references/iap-confirm-purchase-for-sub).
>
> > JWSChecker: sample code for JWS validation. For more details, please refer to [Verifying the Signature in the Returned Result](https://developer.huawei.com/consumer/en/doc/harmonyos-references/iap-verifying-signature).
>
> > notification: sample code of a key event notification. For more details, please refer to [Key Event Notifications](https://developer.huawei.com/consumer/en/doc/harmonyos-references/iap-key-event-notifications).

## Supported Environments

JDK 1.8 or a later version is recommended.

## Installation

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

## Configuration

To use functions provided in examples, need to configure the following parameters.

> The following describes parameters in JWTGenetator.java. For more details, please refer to [Generating a Token for a Server-Side API Call](https://developer.huawei.com/consumer/en/doc/harmonyos-references/iap-jwt-description).
> 
> > | Parameter | Description |
> > | :----------------- | ------------------------------------------------------- |
> > | JWT_PRI_KEY_PATH | Private key file path.  |
> > | ACTIVE_TIME_SECOND | JWT validity period, which is a UTC timestamp in seconds. The validity period cannot exceed 1 hour. |
> > | kid | Key ID. |
> > | iss | Key issuer ID. |
> > | aid |  App ID. |
> 
> The following describes parameters in JWSChecker.java. For more details, please refer to [Verifying the Signature in the Returned Result](https://developer.huawei.com/consumer/en/doc/harmonyos-references/iap-verifying-signature).
> 
> > | Parameter | Description |
> > | :----------------- | ------------------------------------------------------- |
> > | CA_CERT_FILE_PATH | Huawei CBG Root CA G2 Certificate File Path. |
> > | CRL_SOFT_FAIL_ENABLED | Whether to ignore CRL network errors. |

## Sample Code

Some examples are provided in the APIExample. Can refer to the following code for testing.

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

## License

IAPKit-Sample-SeverDemo is licensed under the [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0).

