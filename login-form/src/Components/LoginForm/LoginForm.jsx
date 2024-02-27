import React, {useState, useEffect} from "react";
import './LoginForm.css'; 
import { FaUser, FaLock} from "react-icons/fa";
import { Link, Navigate} from "react-router-dom";
import { signInWithEmailAndPassword } from "firebase/auth";
import { auth } from "../firebase";
import { onAuthStateChanged, signOut } from "firebase/auth";



const LoginForm = () => {
    const [email, setEmail] = useState("");
    const [password, setPassword] = useState("");
    const [loggedIn, setLoggedIn] = useState(false);
    const [authUser, setAuthUser] = useState(null);

  useEffect(() => {
    const listen = onAuthStateChanged(auth, (user) => {
      if (user) {
        setAuthUser(user);
      } else {
        setAuthUser(null);
      }
    });

    return () => {
      listen();
    };
  }, []);

  const userSignOut = () => {
    signOut(auth)
      .then(() => {
        console.log("sign out successful");
        setAuthUser(null)
        sessionStorage.removeItem("email")
      })
      .catch((error) => console.log(error));
  };

    const signIn = (e) => {
        e.preventDefault();
        signInWithEmailAndPassword(auth, email, password)
        .then((userDetails) => {
            console.log(userDetails)
            setLoggedIn(true)
        }).catch((err) => {
            console.log(err)
        });
    };

    if(loggedIn) {
        return <Navigate to="/dashboard" />;
    }
    return (
        <div className="wrapper">
            <form onSubmit={signIn}>
                <h1>Login</h1>
                <div className="input-box">
                    <input type="email" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)}required/>
                    <FaUser className="icon"/>

                </div>
                <div className="input-box">
                    <input type="password" placeholder="Password" value={password} onChange={(e) => setPassword(e.target.value)} required/>
                    <FaLock className="icon"/>
                </div>


                {/* <div className="remember-forgot">
                    <label><input type="checkbox"/>Remember Me</label>
                    <a href="#">Forgot password?</a>
                </div> */}
                <button type="submit">Login</button>
                <div className="register-link">
                    <p>Don't have an account? <Link to="/signup">Register</Link></p>
                </div>
               
            </form>
        </div>
    );
};

export default LoginForm;

