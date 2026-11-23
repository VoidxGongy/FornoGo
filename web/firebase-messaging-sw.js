'use strict';

importScripts('https://www.gstatic.com/firebasejs/13.3.0/firebase-app-compat.js',
    'https://www.gstatic.com/firebasejs/13.3.0/firebase-messaging-compat.js');

firebase.initializeApp({
  "apiKey": "AIzaSyAdbb4M8bdRK15BO3dqnU1b7kO1YThjGuU",
  "appId": "1:475926770159:web:b074020b881948ad25861a",
  "messagingSenderId": "475926770159",
  "projectId": "fornogo-pizzeria-2026",
  "authDomain": "fornogo-pizzeria-2026.firebaseapp.com"
});

// FCM muestra las notificaciones con payload notification en segundo plano.
firebase.messaging();
