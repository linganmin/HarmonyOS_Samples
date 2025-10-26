
let h5Port; // Initialize the data channel.
const logTag = 'login_html'; // Log tag.
let disabled = false; // Indicate whether the button is disabled.
const clickAbleClass = {};

const QUICK_LOGIN_ANONYMOUS_PHONE  = 'quickLoginAnonymousPhone';
const NOT_ACCEPTED = 'notAccepted';
const HIDDEN_PRIVACY_MODEL = 'hiddenPrivacyModel';
const LOGIN_START  = 'loginStart';
const LOGIN_END = 'loginEnd';

window.addEventListener('message', function (event) {
    if (event.data === '__init_port__') {
        // Save the port sent from the app side.
        h5Port = event.ports.at(0);
        if (h5Port != null) {
            console.log("hwid In html got message");
            h5Port.onmessage = handleMessage;
            h5Port.onmessageerror = (event) => {
                console.error(`hwid In html Error receiving message: ${event}`);
            };
        }
    }
});

window.addEventListener('load', () => {
    clickAbleClass.links = document.querySelectorAll('.link-text');
    clickAbleClass.otherButton = document.querySelector('.other-login-button');
    clickAbleClass.checkbox = document.querySelector('.checkbox');
    clickAbleClass.backButton = document.querySelector('.back-press');
    // Add the tap event to all agreement URLs.
    const links = clickAbleClass.links;
    for (let i = 0; i < links.length; i++) {
        links[i].addEventListener('click', (e) => {
            if (!disabled) {
                const { url } = e.target.dataset;
                console.log(logTag, url);
                if(url) {
                    // Send the message to the Native side and let the user check the privacy agreement.
                    postMsgToEts("openPrivacy", url);
                }
            }
        });
    }

    // Add the tap event to the back button.
    clickAbleClass.backButton.addEventListener('click', () => {
        console.log('backPress ', disabled);
        if(!disabled) {
            postMsgToEts('backPress');
        }
    });
})


// After the user changes the status of the checkbox, send the message to the Native side.
document.querySelector('#privacy-checkbox').addEventListener('change', (e) => {
    postMsgToEts("agreePrivacy", e.target.checked);
})

// Receive the message from the app side.
function handleMessage(event) {
    let eventId, value;
    try {
        const eventData = JSON.parse(event.data);
        eventId = eventData.eventId;
        value = eventData.value;
    } catch (err) {
        console.error(logTag, 'Invalid event data');
        return;
    }

    switch (eventId) {
        case QUICK_LOGIN_ANONYMOUS_PHONE:
            // Display the anonymous mobile number.
            console.log(logTag, `quickLoginAnonymousPhone is ${value}`);
            document.querySelector('#quick-login-anonymous-phone').innerHTML = value;
            break;
        case NOT_ACCEPTED:
            // Show a pop-up asking the user to check the agreements.
            showToast();
            break;
        case HIDDEN_PRIVACY_MODEL:
            // Close the pop-up.
            hiddenToast();
            break;
        case LOGIN_START:
            // Sign-in starts.
            setDisabled(true);
            break;
        case LOGIN_END:
            // Sign-in is complete.
            setDisabled(false);
            break;
        default:
            console.log(logTag, `eventId: ${eventId}, value: ${value}`);
            break;
    }
}

// Use h5Port to send the message to the app side.
function postMsgToEts(eventId, value) {
    if (h5Port) {
        h5Port.postMessage(JSON.stringify({ eventId, value }));
    } else {
        console.error(logTag, 'h5Port is null, Please initialize first');
    }
}

function showToast() {
    const model = document.querySelector('.toast-model');
    model.classList.add('show');
    model.classList.remove('hide');
}

function hiddenToast() {
    const model = document.querySelector('.toast-model');
    model.classList.add('hide');
    model.classList.remove('show');
    postMsgToEts('hiddenPrivacyModel');
}

// After the user accepts the agreements, send the message to the Native side, where one-tap sign-in will be triggered.
function agreeLogin() {
    postMsgToEts('agreeLogin');
    var checkbox = document.getElementById("privacy-checkbox");
    checkbox.checked = true;
    hiddenToast();
    setDisabled(true);
}

// Set the availability of tappable elements on the screen.
function setDisabled(value) {
    disabled = value;
    // Modify the URL style.
    const links = Array.from(clickAbleClass.links);
    links.forEach(link => {
        if (disabled) {
            link.classList.add('disabled-class');
        } else {
            link.classList.remove('disabled-class');
        }
    });
    if (disabled) {
        clickAbleClass.backButton.classList.add('disabled-class');
        clickAbleClass.otherButton.classList.add('disabled-class');
        clickAbleClass.checkbox.classList.add('disabled-class');
    } else {
        clickAbleClass.backButton.classList.remove('disabled-class');
        clickAbleClass.otherButton.classList.remove('disabled-class');
        clickAbleClass.checkbox.classList.remove('disabled-class');
    }
    clickAbleClass.checkbox.disabled = disabled;
}