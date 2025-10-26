/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import React from 'react';
import { Text, View, StyleSheet, Image, TouchableOpacity } from 'react-native';
import { useTranslation } from 'react-i18next';

export default function PersonalInfoPage({ route, navigation }) {
    const { t } = useTranslation();
    // Obtain the anonymous mobile number.
    const { quickLoginAnonymousPhone } = route.params;
    // Screen style.
    return (
        <View style={styles.container}>
            <Text style={styles.pageTile}>{t('personalInfo')}</Text>
            <View style={styles.phone}>
                <Text style={styles.phoneLable}>{t('phone')}</Text>
                <View style={styles.phoneRight}>
                    <Text style={styles.phoneValue}>{quickLoginAnonymousPhone}</Text>
                    <Image style={styles.rightImage} source={require('../img/hwid_ic_right_arrow.svg')}></Image>
                </View>
            </View>
            <View style={{flex: 1}}></View>
            <TouchableOpacity style={{ width: '100%', borderRadius: 20, backgroundColor: '#e7e8ea', maxWidth: 448 }}
              onPress={() => { navigation.popToTop() }}>
                <Text style={{
                    width: '100%', textAlign: 'center', fontWeight: '400',
                    fontSize: 16, color: '#CE0E2D', lineHeight: 40,
                }}>{t('logout')}</Text>
            </TouchableOpacity>
        </View>
    )
}

const styles = StyleSheet.create({
    container: {
        paddingTop: 38,
        paddingBottom: 28,
        paddingLeft: 16,
        paddingRight: 16,
        height: '100%',
        backgroundColor: '#f1f3f5',
        alignItems: 'center',
    },
    pageTile: {
        fontSize: 20,
        fontWeight: '700',
        lineHeight: 40,
        width: '100%',
    },
    phone: {
        height: 56,
        borderRadius: 20,
        paddingLeft: 12,
        paddingRight: 12,
        paddingTop: 4,
        paddingBottom: 4,
        marginTop: 8,
        display: 'flex',
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        backgroundColor: '#fff',
        width: '100%',
    },
    phoneLable: {
        fontSize: 16,
        color: 'rgba(0,0,0,0.9)'
    },
    phoneValue: {
        color: 'rgba(0,0,0,0.6)',
        fontSize: 14
    },
    phoneRight: {
        display: 'flex',
        flexDirection: 'row',
        alignItems: 'center'
    },
    rightImage: {
        width: 12,
        height: 12,
        marginLeft: 4
    }
})
