/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import React from 'react';
import {NavigationContainer} from "@react-navigation/native";
import { createStackNavigator } from "@react-navigation/stack";
import { enableScreens } from "react-native-screens";
import HomePageDetail from './pages/HomePage';
import PersonalInfoPage from './pages/PersonalInfoPage';
import QuickLoginPage from './pages/QuickLoginPage';
import HuaweiPrivacyPage from './pages/HuaweiPrivacyPage';
import { useLanguageDetector } from './common/Utils';
import '@formatjs/intl-getcanonicallocales/polyfill';

enableScreens(false);
const Stack = createStackNavigator();

function NativeNavigation() {
  return (
    <NavigationContainer>
      {/*Register required screens.*/}
      <Stack.Navigator initialRouteName="Home">
        <Stack.Screen name="Home" component={HomePageDetail} options={{header: () => null}}/>
        <Stack.Screen name="HuaweiPrivacyPage" component={HuaweiPrivacyPage} options={{header: () => null}}/>
        <Stack.Screen name="QuickLoginPage" component={QuickLoginPage}options={{header: () => null}}/>
        <Stack.Screen name="PersonalInfoPage" component={PersonalInfoPage} options={{header: () => null}}/>
      </Stack.Navigator>
    </NavigationContainer>
  );
}

export default function App() {
  useLanguageDetector();
  return <NativeNavigation/>;
}
