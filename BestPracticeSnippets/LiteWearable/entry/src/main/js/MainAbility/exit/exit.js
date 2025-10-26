// [Start exit_js]
// index.js
import router from '@ohos.router';
// Import the app module.
import app from '@system.app';

export default {
    data: {
        title: 'World'
    },
    clickAction() {
        router.replaceUrl({
            uri: 'pages/details/details'
        });
    },
    touchMove(e) { // Handle swipe events.
        if (e.direction == 'right') { // Swipe right to exit.
            app.terminate();
        }
    }
};
// [End exit_js]