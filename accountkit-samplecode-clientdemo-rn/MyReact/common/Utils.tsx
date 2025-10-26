/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */
import { Alert, AppState } from "react-native";
import React from "react";
import 'intl-pluralrules';
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import * as RNLocalize from '@react-native-oh-tpl/react-native-localize';
import en from '../resources/en/string.json';
import zh from '../resources/zh/string.json';

// Initialize i18n.
i18n
    .use(initReactI18next)
    .init({
        fallbackLng: 'zh',
        resources: {
            en: { translation: en },
            zh: { translation: zh },
        },
        compatibilityJSON: 'v3', // Fix Intl API compatibility issues.
        interpolation: {
            escapeValue: false,
        },
    });

// Switch the app language.
export const changeLanguage = (language: string) => {
    i18n.changeLanguage(language)
        .catch(error => {
            console.error('Failed to change language:', error);
        });
};

// Obtain the current language.
export const getCurrentLanguage = () => {
    return i18n.language;
};

// Translation function.
export const translate = (key: string, params?: object) => {
    return i18n.t(key, params);
};

// Language detection hook.
export const useLanguageDetector = () => {
    const [currentLang, setCurrentLang] = React.useState(getCurrentLanguage());

    // Detect the language change and update the language.
    const checkLanguage = React.useCallback(() => {
        const systemLang = RNLocalize.getLocales()[0]?.languageCode || 'zh';
        const supportedLanguage = ['zh', 'en'].includes(systemLang)
            ? systemLang
            : 'zh';

        if (supportedLanguage !== currentLang) {
            console.log(`system language change: ${supportedLanguage}`);
            changeLanguage(supportedLanguage);
            setCurrentLang(supportedLanguage);
        }
    }, [currentLang]);

    // Detect the language when the component is mounted.
    React.useEffect(() => {
        checkLanguage();
    }, [checkLanguage]);

    // Listen to AppState changes (when the app is switched from the background to the foreground).
    React.useEffect(() => {
        const handleAppStateChange = (nextAppState: string) => {
            if (nextAppState === 'active') {
                checkLanguage();
            }
        };

        const subscription = AppState.addEventListener('change', handleAppStateChange);
        return () => subscription.remove();
    }, [checkLanguage]);

    return currentLang;
};

export enum ErrorCode {
    // The agreements are not accepted.
    ERROR_CODE_AGREEMENT_STATUS_NOT_ACCEPTED = '1005300001',
    // No HUAWEI ID has been signed in.
    ERROR_CODE_LOGIN_OUT = '1001502001',
    // A network exception occurs in the authorization API.
    AUTHENTICATION_NETWORK_ERROR = '1001502005',
    // Internal error.
    ERROR_CODE_INTERNAL_ERROR = '1001502009',
    // Authorization revoking is performed.
    ERROR_CODE_USER_CANCEL = '1001502012',
    // System service exception.
    ERROR_CODE_SYSTEM_SERVICE = '12300001',
    // Repeated request.
    ERROR_CODE_REQUEST_REFUSE = '1001500002'
}

export function dealAllError(error: {errorCode?: string, message: string}): void {
    console.error(`errorCode: ${error.errorCode}, errorMsg: ${error.message}`);
    // In app sign-in scenarios involving UI interactions, it is recommended to guide users with the following error code prompts:
    if (error.errorCode === ErrorCode.ERROR_CODE_LOGIN_OUT) {
        // The user has not signed in with a HUAWEI ID. Use a HUAWEI ID to sign in and try again, or sign in to the app in another way.
    } else if (error.errorCode === ErrorCode.AUTHENTICATION_NETWORK_ERROR) {
        // Network exception. Check the current network status and try again, or sign in to the app in another way.
        showNetWorkError();
    } else if (error.errorCode === ErrorCode.ERROR_CODE_INTERNAL_ERROR) {
        // Sign-in failed. Try another sign-in option.
    } else if (error.errorCode === ErrorCode.ERROR_CODE_USER_CANCEL) {
        // The user cancels the authorization.
    } else if (error.errorCode === ErrorCode.ERROR_CODE_SYSTEM_SERVICE) {
        // System service exception. Try again later or sign in to the app in another way.
    } else if (error.errorCode === ErrorCode.ERROR_CODE_REQUEST_REFUSE) {
        // Repeated request. No further action is needed.
    } else {
        // Sign-in failed. Try another sign-in option.
    }
}

// Common method for displaying the network error dialog box.
function showNetWorkError() {
    Alert.alert('', translate('hwid_no_internet_connect'), [
        {
            text: translate('hwid_text_button_known')
        }
    ])
}

// Common method for preventing repeated taps.
export class AvoidRepeatClick {
    private static lastClickTime: number = 0; // Record the time of the last repeated tap.

    public static avoidRepeatClick(callback: () => void, interval: number = 400) {
        const currentTime = Date.now();
        if (currentTime - AvoidRepeatClick.lastClickTime > interval) {
            console.info('currentTime:' + currentTime);
            console.info('lastClickTime:' + AvoidRepeatClick.lastClickTime);
            AvoidRepeatClick.lastClickTime = currentTime;
            console.info('Effective click');
            callback();
        } else {
            console.info('Invalid click');
        }
    }
}
