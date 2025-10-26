/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import React from "react";
import { View } from "react-native";
import { StyleSheet, Image, Pressable } from 'react-native';
import { WebView } from "react-native-webview";

export default function HuaweiPrivacyPage({ navigation }) {
  // URL for HUAWEI ID User Authentication Agreement.
  const huwProtocolUrl: string =
    "https://privacy.consumer.huawei.com/legal/id/authentication-terms.htm?code=CN&language=cn";
  // Screen style.
  return (
      <View style={{ flex: 1 }}>
        <View style={styles.backButtonTitle}>
          <Pressable
              style={({ pressed }) => [
                styles.backButton,
                pressed && styles.pressedStyle
              ]}
              onPress={() => navigation.pop()}
          >
            <Image
                source={require('../img/hwid_next_ic_appback.svg')} // Prepare an icon to be returned or use a system icon.
            />
          </Pressable>
        </View>

        <View style={{ height: '100%',width: '100%', paddingBottom: 28, backgroundColor: '#fff', paddingTop: 94 }}>
          <WebView
            source={{ uri: huwProtocolUrl }}
            style={{ flex: 1 }}
          />
        </View>
      </View>
  );
};

const styles = StyleSheet.create({
  backButtonTitle: {
    justifyContent: 'flex-start',
    height: 56,
    width: '100%',
    paddingVertical: 8,
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: -56,
    marginHorizontal: 16,
    top: 94,
    zIndex: 2024,
    position: 'absolute'
  },
  backButton: {
    alignSelf: 'flex-start',
    borderRadius: 20,
    width: 40,
    height: 40,
    backgroundColor: '#e7e8ea',
    maxWidth: 448
  },
  pressedStyle: {
    backgroundColor: '#c5c6c8',
  }
})
