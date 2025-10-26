// [Start unlock_screen]
import screenLock from '@ohos.screenLock';

// [StartExclude unlock_screen]
export default {
    data: {
        title: ""
    },
    onInit() {
        this.title = "Hello World";
    }
};

// [EndExclude unlock_screen]

function unlockScreen() {
    let result;
    screenLock.unlockScreen((err) => {
        if (err) {
            result = `Failed to unlock the screen, Code: ${err.code}, ${err.message}`;
        } else {
            result = `call unlockScreen sucess`;
        }
    });

    return result;
}
// [End unlock_screen]
// [Start is_screen_locked]
function isScreenLocked() {
    let isLocked = false;
    let result;
    screenLock.isScreenLocked((err, data) => {
        if (err) {
            result = `call isScreenLocked erro ${err.message}`;
        } else {
            isLocked = data
            result = `call isScreenLocked sucess islocked: ${isLocked}`
        }
    });
    return result;
}
// [End is_screen_locked]
// [Start is_secure_mode]
function isSecureMode() {
    let result;
    let isSafety = false;
    screenLock.isSecureMode((err, data) => {
        if (err) {
            result = `call isSecureMode erro ${err.message}`;
        } else {
            isSafety = data
            result = `call isSecureMode sucess isSafety ${isSafety}`;
        }
    });
    return result;
}
// [End is_secure_mode]