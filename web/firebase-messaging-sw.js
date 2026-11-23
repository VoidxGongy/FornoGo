importScripts(
  'https://www.gstatic.com/firebasejs/11.0.2/firebase-app-compat.js',
);
importScripts(
  'https://www.gstatic.com/firebasejs/11.0.2/firebase-messaging-compat.js',
);

firebase.initializeApp({
  apiKey: 'AIzaSyAdbb4M8bdRK15BO3dqnU1b7kO1YThjGuU',
  authDomain: 'fornogo-pizzeria-2026.firebaseapp.com',
  projectId: 'fornogo-pizzeria-2026',
  storageBucket: 'fornogo-pizzeria-2026.firebasestorage.app',
  messagingSenderId: '475926770159',
  appId: '1:475926770159:web:b074020b881948ad25861a',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification || {};
  self.registration.showNotification(notification.title || 'FornoGO', {
    body: notification.body || 'El estado de tu pedido cambió.',
    icon: '/icons/Icon-192.png',
    data: payload.data || {},
  });
});
