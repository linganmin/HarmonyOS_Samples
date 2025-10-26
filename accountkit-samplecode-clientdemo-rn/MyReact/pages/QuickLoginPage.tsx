/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import React, { useState, useEffect, useCallback } from 'react';
import { Text, View, StyleSheet, Image, TouchableOpacity, Pressable } from 'react-native';
import { NativeStackNavigationProp } from "react-native-screens";
import { ParamListBase } from "@react-navigation/native";
import CheckBox from "@react-native-community/checkbox";
import LoginWithHuaweiIDButton from 'react-native-huawei-authentication';
import { dealAllError, ErrorCode } from '../common/Utils';
import { useTranslation } from 'react-i18next';
import { GestureHandlerRootView, GestureDetector, Gesture } from 'react-native-gesture-handler';

const LOG_TAG: string = 'QuickLoginPage';

export default function QuickLoginPage({ route, navigation }: {
  navigation: NativeStackNavigationProp<ParamListBase>,
}) {
  const { quickLoginAnonymousPhone } = route.params;
  const ref = React.useRef<LoginWithHuaweiIDButton>(null);
  const [getHuaweiButtonVisible, setHuaweiButtonVisible] = useState(true);
  const [toggleCheckBox, setToggleCheckBox] = useState(false); // Indicate whether the checkbox is checked.
  const [disabled, setDisabled] = useState(false);
  const { t } = useTranslation();
  const [gestureStartX, setGestureStartX] = useState(0);
  const [gestureEndX, setGestureEndX] = useState(0);
  const [isProcessing, setIsProcessing] = useState(false);

  const handleGestureEnd = useCallback((event) => {
    if (isProcessing) return;

    setGestureEndX(event.x);
    const distance = Math.abs(gestureEndX - gestureStartX);
    const isRightToLeft = gestureEndX < gestureStartX;
    const isTrigger = distance > 40 && isRightToLeft;

    if (isTrigger) {
      setIsProcessing(true);

      if (!getHuaweiButtonVisible) {
        setHuaweiButtonVisible(true);
        event.preventDefault();
        setTimeout(() => setIsProcessing(false), 300);
      } else {
        navigation.goBack();
        setIsProcessing(false);
      }
    } else {
      setIsProcessing(false);
    }
  }, [getHuaweiButtonVisible, gestureStartX]);

  const gesture = Gesture.Pan()
      .onStart((event) => {
        setGestureStartX(event.x);
        setIsProcessing(false);
      })
      .onEnd(handleGestureEnd);

  useEffect(() => {
    return navigation.addListener('beforeRemove', (e) => {
      if (!getHuaweiButtonVisible) {
        e.preventDefault();
        setHuaweiButtonVisible(true);
      }
    });
  }, [navigation, getHuaweiButtonVisible]);

  // Function related to agreement acceptance. Call the setAgreementStatus command wrapped through Fabric.
  const changePrivacy = (value: boolean) => {
    if (ref) {
      if (value) {
        console.log(LOG_TAG, 'ACCEPTED', `value is ${value}`);
        ref.current?.setAgreementStatus('ACCEPTED');
      } else {
        console.log(LOG_TAG, 'NOT_ACCEPTED', `value is ${value}`);
        ref.current?.setAgreementStatus('NOT_ACCEPTED');
      }
    }
  };

  // If the user accepts the agreements, continue with the sign-in process. Call the setAgreementStatus and continueLogin commands wrapped through Fabric.
  const continueLogin = () => {
    if (ref) {
      ref.current?.setAgreementStatus('ACCEPTED');
      setToggleCheckBox(true);
      ref.current?.continueLogin();
    }
  }

  // Screen style.
  return (
      <GestureHandlerRootView style={{ flex: 1 }}>
        <GestureDetector gesture={gesture}>
          <View style={{ height: '100%', width: '100%', justifyContent: "center", alignItems: 'center',
            backgroundColor: "#F1F3F5" }}>

            <View style={[getHuaweiButtonVisible ? styles.agreeLoginRoot : styles.agreeLoginNotRoot]}>
              <View style={{
                height: '100%', width: '100%', position: 'absolute', top: 0, left: 0, right: 0, bottom: 0,
                backgroundColor: '#333333', opacity: 0.2
              }}>
              </View>

              {/*Display the User Agreement and Privacy Policy pop-up*/}
              <View style={[styles.agreeNotLogin]}>
                <View style={{ flex: 1, justifyContent: "center", marginHorizontal: 8, marginTop: 16, marginBottom: 8 }}>
                  <Text style={{ fontSize: 20, fontWeight: "700", color: "black", textAlign: 'center' }}>
                    {t('user_agreement_and_privacy_policy')}
                  </Text>
                </View>

                <View style={{ flex: 1, justifyContent: "flex-end", width: '100%', paddingLeft:8, marginRight: 12,
                  marginTop: 8 }}>
                  <View style={{ flexDirection: "row", height: '100%', width: '100%' }}>
                    <Text>
                      <Text style={{ fontSize: 16, fontWeight: "400", color: "black" }}
                      >{t('agree')}</Text>
                      <Text style={{ fontSize: 16, color: "#CE0E2D", fontWeight: "600" }}
                      >{t('shopping_user_agreement')}</Text>
                      <Text style={{ fontSize: 16, fontWeight: "400", color: "black" }}
                      >{t('protocol_separator')}</Text>
                      <Text style={{ fontSize: 16, color: "#CE0E2D", fontWeight: "600" }}
                      >{t('shopping_privacy_policy')}</Text>
                      <Text style={{ fontSize: 16, fontWeight: "400", color: "black" }}
                      >{t('protocol_separator')}</Text>
                      <Text style={{ fontSize: 16, fontWeight: "400", color: "black" }}
                      >{t('and')}</Text>
                      <Text style={{ fontSize: 16, color: "#CE0E2D", fontWeight: "600" }}
                            onPress={() => navigation.navigate('HuaweiPrivacyPage')}
                      >{t('huaweiId_user_authentication_protocol')}
                      </Text>
                      <Text style={{ fontSize: 16, fontWeight: "400", color: "black" }}
                      >{t('end')}</Text>
                    </Text>
                  </View>
                </View>


                <View style={{
                  flex: 1,
                  flexDirection: "row",
                  height: '100%',
                  width: '100%',
                  alignItems: 'center',
                  justifyContent: 'flex-start',
                  marginTop: 8,
                  marginBottom: 16,
                  paddingRight: 16
                }}>
                  <View style={{
                    borderRadius: 24,
                    width: '50%',
                    minHeight: 40,
                    maxWidth: 400,
                    overflow: 'hidden',
                    marginRight: 8
                  }}>
                    <Pressable
                        style={({ pressed }) => [
                          {
                            width: '100%',
                            backgroundColor: pressed ? '#F5F5F5' : 'transparent',
                            justifyContent: 'center',
                            alignItems: 'center',
                            height: 40
                          }
                        ]}
                        onPress={() => setHuaweiButtonVisible(true)}
                    >
                      <Text style={{
                        textAlign: 'center',
                        fontWeight: '400',
                        fontSize: 16,
                        color: '#000000'
                      }}>
                        {t('cancel')}
                      </Text>
                    </Pressable>
                  </View>

                  <View style={{
                    borderRadius: 20,
                    marginRight: 16,
                    marginLeft: 8,
                    width: '50%',
                    minHeight: 40,
                    maxWidth: 400,
                    overflow: 'hidden'
                  }}>
                    <Pressable
                        style={({ pressed }) => [
                          {
                            width: '100%',
                            backgroundColor: pressed ? '#a00c24' : '#CE0E2D',
                            justifyContent: 'center',
                            alignItems: 'center',
                            height: 40
                          }
                        ]}
                        onPress={() => {
                          setDisabled(true);
                          setHuaweiButtonVisible(true);
                          continueLogin();
                        }}
                    >
                      <Text style={{
                        textAlign: 'center',
                        fontWeight: '400',
                        fontSize: 16,
                        color: '#FFFFFF'
                      }}>
                        {t('agree_and_sign_in')}
                      </Text>
                    </Pressable>
                  </View>
                </View>
              </View>

            </View>

            {/*One-tap sign-in screen*/}
            <View style={[getHuaweiButtonVisible ? styles.containerLogin : styles.containerNotLogin]}>

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

              <View style={{ flex: 1, justifyContent: "flex-end", height: "100%", marginTop: 28 }}>
                <Image source={require('../img/appmarket.png')} alt='I am A' style={{ width: 80, height: 80, borderRadius: 20 }} />
              </View>
              <View style={{ flex: 1, justifyContent: "center", width: "100%", marginTop: 36 }}>
                <Text style={styles.anonymousText}>{quickLoginAnonymousPhone}</Text>
                <Text style={styles.bindText}>{t('bind_huaweiId_number')}</Text>
              </View>
              <View style={{ flex: 1, width: "100%", alignItems: "center" }}>
                {/*One-tap sign-in button*/}
                <LoginWithHuaweiIDButton
                    buttonStyle={0}
                    buttonBorderRadius={24}
                    loginType={3}
                    ref={ref}
                    style={styles.huaweiButton}
                    onLoginSuccess={data => {
                      // Callback for successful sign-in.
                      console.info(`request success`);
                      const successData = {
                        authorizationCode: data.nativeEvent.authorizationCode
                      };
                      navigation.replace('PersonalInfoPage', { successData, quickLoginAnonymousPhone });
                      setDisabled(false);
                    }}
                    onLoginFailure={e => {
                      // Callback for sign-in failure.
                      const { errorCode, errorMessage } = e.nativeEvent
                      console.info(`request fail: errorCode is ${errorCode}, errorMessage is ${errorMessage}`);
                      if (errorCode.toString() === ErrorCode.ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED) {
                        setHuaweiButtonVisible(false);
                      } else {
                        setHuaweiButtonVisible(true);
                        dealAllError({ errorCode: errorCode.toString(), message: errorMessage });
                      }
                      setDisabled(false);
                    }}
                    onClickEventResult={e=>{
                      // Callback for click event
                      if (toggleCheckBox) {
                        setDisabled(true);
                      }
                    }}
                />

                <View style={styles.otherButton}>
                  <TouchableOpacity style={{ width: '100%' }} activeOpacity={0.6}>
                    <Text style={{
                      width: '100%', textAlign: 'center', fontWeight: '400', paddingLeft: 8,
                      paddingRight: 8, fontSize: 16
                    }}>{t('other_login_models')}</Text>
                  </TouchableOpacity>
                </View>
              </View>
              <View style={{ flex: 1, justifyContent: "flex-end", width: '100%', paddingBottom: 44, paddingHorizontal: 8 }}>
                <View style={{ flexDirection: "row", width: '100%', justifyContent: "center", alignItems: 'center' }}>
                  <CheckBox
                      disabled={disabled}
                      value={toggleCheckBox}
                      style={styles.checkBox}
                      tintColor='#999999'
                      onCheckColor="#cd2424"
                      onValueChange={(newValue: boolean) => {
                        setToggleCheckBox(newValue);
                        changePrivacy(newValue);
                      }}
                  />
                  <View style={{ paddingLeft: 12, minHeight: 24, justifyContent: 'center' }}>
                    <Text>
                      <Text style={{ fontSize: 12, fontWeight: "300", color: "gray" }}
                      >{t('agree')}</Text>
                      <Text style={{ fontSize: 12, color: disabled ? "gray" : "black", fontWeight: "500" }}>
                        {t('shopping_user_agreement')}</Text>
                      <Text style={{ fontSize: 12, fontWeight: "300", color: "gray" }}>{t('protocol_separator')}</Text>
                      <Text style={{ fontSize: 12, color: disabled ? "gray" : "black", fontWeight: "500" }}>
                        {t('shopping_privacy_policy')}</Text>
                      <Text style={{ fontSize: 12, fontWeight: "300", color: "gray" }}>{t('protocol_separator')}</Text>
                      <Text style={{ fontSize: 12, fontWeight: "300", color: "gray" }}>{t('and')}</Text>
                      <Text style={{ fontSize: 12, color: disabled ? "gray" : "black", fontWeight: "500" }}
                            onPress={() => navigation.navigate('HuaweiPrivacyPage')}
                      >{t('huaweiId_user_authentication_protocol')}</Text>
                      <Text style={{ fontSize: 12, fontWeight: "300", color: "gray" }}>{t('end')}</Text>
                    </Text>
                  </View>
                </View>
              </View>
            </View>
          </View>
        </GestureDetector>
      </GestureHandlerRootView>
  );
}
const styles = StyleSheet.create({
  agreeLoginRoot: {
    opacity: 0,
    zIndex: 0,
  },
  agreeLoginNotRoot: {
    height: '100%',
    width: '100%',
    zIndex: 2,
    flexDirection: "column",
    justifyContent: "center",
    alignItems: 'center',
    position: 'relative',
  },
  agreeLogin: {
    flexDirection: "column",
    justifyContent: "center",
    alignItems: 'center',
    position: 'absolute',
  },
  agreeNotLogin: {
    flexDirection: "column",
    justifyContent: "center",
    alignItems: 'center',
    position: 'absolute',
    width: '92%',
    borderRadius: 32,
    backgroundColor: '#FFFFFF',
    zIndex: 4,
    maxWidth: 400,
    paddingHorizontal: 16,
  },
  containerLogin: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    flexDirection: "column",
    position: 'absolute',
    height: '100%',
    width: '100%',
    zIndex: 2,
    backgroundColor: '#00000000',
    paddingHorizontal: 16
  },
  containerNotLogin: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    flexDirection: "column",
    position: 'absolute',
    height: '100%',
    width: '100%',
    zIndex: 0,
    backgroundColor: '#00000000',
    paddingHorizontal: 16
  },
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
  },
  checkboxContainer: {
    flexDirection: "row",
    marginBottom: 20,
  },
  anonymousText: {
    fontSize: 36,
    color: 'black',
    fontWeight: 'bold',
    lineHeight: 48,
    textAlign: 'center',
    justifyContent: 'center',
    maxWidth: '100%',
    minHeight: 48
  },
  bindText: {
    fontSize: 12,
    color: 'gray',
    fontWeight: 'regular',
    lineHeight: 16,
    textAlign: 'center',
    justifyContent: 'center',
    maxWidth: '100%',
    marginTop: 8
  },
  huaweiButton: {
    height: 40,
    width: '100%',
    minHeight: 40,
    maxWidth: 448,
    justifyContent: 'center'
  },
  otherButton: {
    marginTop: 16,
    borderRadius: 40,
    width: '100%',
    backgroundColor: 'rgba(0,0,0,0.05)',
    justifyContent: 'center',
    minHeight: 40,
    maxWidth: 448
  },
  checkBox: {
    width: 20,
    height: 20,
    backgroundColor: 'rgba(0,0,0,0)',
    borderRadius: 10,
    padding: 2
  }
})
