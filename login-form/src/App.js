import './App.css';
import React from 'react';
import LoginForm from "./Components/LoginForm/LoginForm.jsx";
import SignUp from './Components/SignUp/SignUp.jsx';
import { BrowserRouter as Router, Route, Routes, Link} from "react-router-dom"
import IssueDetails from './Components/IssueDetails/IssueDetails.jsx';
import DashBoard from './Components/DashBoard/DashBoard.jsx';

function App() {
  return (
    
    <Router>
      <Routes>
        <Route path="/" exact element={<LoginForm/>} />
        <Route path="/signup" element={<SignUp/>} />
        <Route path="/dashboard" element={<DashBoard/>} />
        <Route path="/issue/:issueId" element={<IssueDetails/>} />
      </Routes>
    </Router>
   
  );
};

export default App;
