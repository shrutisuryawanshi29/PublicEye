import React, { useEffect, useState } from "react";
import "./dashBoard.css";
import db from "../firebase";
import { collection, getDocs } from "firebase/firestore";
import {Link, useNavigate} from "react-router-dom"
import { auth } from "../firebase";
import { onAuthStateChanged, signOut } from "firebase/auth";
import { FaUser } from "react-icons/fa";
import appLogo from "../Assets/appLogo.jpeg"

const DashBoard = () => {
  const [data, setData] = useState(null);
  const [authUser, setAuthUser] = useState(null);
    const history = useNavigate();

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
        history("/");
      })
      .catch((error) => console.log(error));
  };

  const findAll = async () => {
    try {
      const querySnapshot = await getDocs(collection(db, 'issues'));
      const groupedData = querySnapshot.docs.reduce((acc, doc) => {
        const pincode = doc.data().pincode; // Assuming pincode is directly accessible from document data
        if (!acc[pincode]) {
          acc[pincode] = [];
        }
        acc[pincode].push(doc.data());
        return acc;
      }, {});

      setData(groupedData);
    } catch (error) {
      console.error('Error fetching data:', error);
    }
  };

  useEffect(() => {
    findAll();
  }, []);

  return (
   
    <>
    <div className="header">
        <img src={appLogo} className="logo" alt="app-logo" />
        <div className="dashboard-text">Public Eye Dashboard
        </div>
        
    </div>
    
     {authUser ? (
        <div className="user-info">
         
          <button className="sign-out-button" onClick={userSignOut}>Sign Out</button>
          
        </div>
      ) : (
        <p>Signed Out</p>
      )}
        <div className="back">
        {data === null ? (
            <p className="loading-container">Loading...</p>
        ) : Object.entries(data).map(([pincode, records]) => (
            <div key={pincode} className="card">
            <h2>Pincode: {pincode}</h2>
            <ul>
                {records.map((record, index) => (
                <li key={index}>
                    <Link to={`/issue/${record.issue_id}`}>
                    <p>Description: {record.description}</p>
                    </Link>
                    <p>Status: {record.status}</p>
                    <p className="text">Landmark : <a href={record.landmark}>{record.landmark}</a></p>

                </li>
                ))}
            </ul>
            </div>
        ))}
        </div>
    </>
  );
};

export default DashBoard;
