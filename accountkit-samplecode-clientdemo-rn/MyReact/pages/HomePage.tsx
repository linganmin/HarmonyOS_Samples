/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import React from 'react';
import { Text, View, StyleSheet, Image, TouchableOpacity } from 'react-native';
import { HuaweiAuthTurboModule } from 'react-native-huawei-authentication';
import { dealAllError, AvoidRepeatClick } from '../common/Utils'
import { useTranslation } from 'react-i18next';

// Home screen style.
export default function HomePageDetail({ navigation }) {
    const { t } = useTranslation();
    // Screen redirection.
    function jumpToLoginPage() {
        AvoidRepeatClick.avoidRepeatClick(() => {
            // Call the wrapped TurboModule API to get the anonymized mobile number.
            HuaweiAuthTurboModule.getQuickLoginAnonymousPhone().then(requestRes => {
                const quickLoginAnonymousPhone = requestRes.data.extraInfo.quickLoginAnonymousPhone;
                if (requestRes.errorCode) {
                    // Error handling.
                    console.error(`Get quickLoginAnonymousPhone Failed. errorCode is ${requestRes.errorCode}`);
                    const { errorCode, errorMessage } = requestRes;
                    dealAllError({ errorCode, message: errorMessage });
                    return;
                }
                if (quickLoginAnonymousPhone) {
                    console.log(`Succeeded in getting quickLoginAnonymousPhone: ${quickLoginAnonymousPhone}`)
                    // If the anonymous mobile number is successfully obtained, direct the user to the one-tap sign-in screen.
                    navigation.push('QuickLoginPage', { quickLoginAnonymousPhone });
                } else {
                    // Error handling.
                    console.error('Get quickLoginAnonymousPhone Failed. quickLoginAnonymousPhone is null');
                }
            }).catch((err) => {
                // Error handling.
                console.error('Get quickLoginAnonymousPhone Failed.', JSON.stringify(err));
            })
            }
        );
    }

    // Screen style.
    return (
        <View style={styles.container}>
            <TouchableOpacity onPress={jumpToLoginPage} style={styles.header} activeOpacity={1}>
                <Image style={styles.headerAvatar} source={require('../img/avatar.svg')}></Image>
                <View style={styles.headerTextBox}>
                    <Text style={styles.headerLine1}>{t('login')}</Text>
                    <Text style={styles.headerLine2}>{t('login_for_enjoy_service')}</Text>
                </View>
            </TouchableOpacity>

            <View style={{ flex: 1 }}>
                <View style={[styles.card, { height: 72 }]}></View>
                <View style={[styles.card, { height: 144 }]}></View>
                <View style={[styles.card, { height: 88 }]}></View>
                <View style={[styles.card, { height: 192 }]}></View>
            </View>

            <View style={styles.barBox}>
                <View style={styles.bar}>
                    <Image source={require('../img/ic_me_normal.svg')} alt=""></Image>
                    <Text style={styles.barText}>Tab</Text>
                </View>
                <View style={styles.bar}>
                    <Image source={require('../img/ic_me_normal.svg')} alt=""></Image>
                    <Text style={styles.barText}>Tab</Text>
                </View>
                <View style={styles.bar}>
                    <Image source={require('../img/ic_me_normal.svg')} alt=""></Image>
                    <Text style={styles.barText}>Tab</Text>
                </View>
                <View style={styles.bar}>
                    <Image source={require('../img/ic_me.svg')} alt=""></Image>
                    <Text style={styles.barActiveText}>Tab</Text>
                </View>
            </View>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        paddingLeft: 16,
        paddingRight: 16,
        paddingTop: 36,
        display: 'flex',
        height: '100%'
    },
    header: {
        height: 80,
        display: 'flex',
        padding: 12,
        flexDirection: 'row',
        alignItems: 'center'
    },
    headerAvatar: {
        width: 56,
        height: 56
    },
    headerTextBox: { marginLeft: 12 },
    headerLine1: {
        fontSize: 18,
        fontWeight: "700",
        color: 'rgba(0, 0, 0, 0.81)',
    },
    headerLine2: {
        fontSize: 14,
        color: 'rgba(0, 0, 0, 0.54)'
    },
    card: {
        backgroundColor: '#fff',
        borderRadius: 20,
        marginBottom: 12,
        width: '100%'
    },
    barBox: {
        display: 'flex',
        flexDirection: 'row',
        height: 80,
        paddingBottom: 28,
        borderColor: '#f1f3f5'
    },
    bar: {
        display: 'flex',
        justifyContent: 'space-around',
        flexDirection: 'column',
        alignItems: 'center',
        width: '25%'
    },
    barIcon: {
        width: 22,
        height: 22
    },
    barText: {
        color: 'rgba(0, 0, 0, 0.6) ',
        fontSize: 12
    },
    barActiveText: {
        color: '#CE0E2D',
        fontSize: 12
    }
})
