// [Start application_events7]
// Enable the observer to start monitoring subscribed events.
import testNapi from 'libentry.so'

// Add interface calls in the onCreate () function
// At startup, register the application event observer
testNapi.registerWatcher();
// [End application_events7]