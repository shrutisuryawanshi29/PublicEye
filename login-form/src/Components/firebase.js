// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import {getFirestore} from "firebase/firestore"

// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
// For Firebase JS SDK v7.20.0 and later, measurementId is optional
const firebaseConfig = {
  apiKey: "AIzaSyCsdaIysUrVCJ2oAGzxQcw7Ed78vUzZfuc",
  authDomain: "publiceye-aaac5.firebaseapp.com",
  databaseURL: "https://publiceye-aaac5-default-rtdb.firebaseio.com",
  projectId: "publiceye-aaac5",
  storageBucket: "publiceye-aaac5.appspot.com",
  messagingSenderId: "521893222330",
  appId: "1:521893222330:web:13d3d6ab7d8a23777baf83",
  measurementId: "G-L4GGEY2PJV"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getFirestore(app)
export const auth = getAuth(app);
export default db