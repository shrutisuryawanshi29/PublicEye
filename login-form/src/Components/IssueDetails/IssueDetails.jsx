import React, { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import db from "../firebase";
import { doc, getDoc, refEqual, coll } from "firebase/firestore";
import { getDatabase, ref, child, get } from "firebase/database";
import { collection, query, where, getDocs, updateDoc, setDoc } from "firebase/firestore";
import "./issueDetails.css"


const IssueDetails = () => {
  const { issueId } = useParams();
  const [issueData, setIssueData] = useState(null);
  const [loading, setLoading] = useState(true)
  const [selectedStatus, setSelectedStatus] = useState("")
  console.log(issueId);

  useEffect(() => {
    const fetchIssueData = async () => {
    
      try {
       // const docRef = doc(db, "issues", issueId);
        //const docSnap = await getDoc(docRef);
        const q = query(collection(db, "issues"), where("issue_id", "==", issueId));
        const querySnapshot = await getDocs(q);
        querySnapshot.forEach((doc) => {
          setIssueData(doc.data());
        });
       
    

        if (issueData !== null) {
          setLoading(false)
          console.log(issueData)
        } else {
          console.log("No such document!");
        }
      } catch (error) {
        console.error("Error fetching document:", error);
      }
    };


    fetchIssueData();
  }, [issueId]);

  const handleStatusChange = async () => {
    try {
      // Update the status in the Firestore document
      const docRef = doc(db, "issues", issueId);
  
      // Fetch the updated data from Firestore and update the state
      const updatedDocSnap = await updateDoc(docRef, {status: selectedStatus})
    //   if (updatedDocSnap.exists()) {
    //     setIssueData(updatedDocSnap.data());
    //     console.log("Status updated successfully");
    //   } else {
    //     console.log("Document does not exist after update");
      }
     catch (error) {
      console.error("Error updating status:", error);
    }
  };
  


  return (
    <div>
      {issueData ? (
        <>
          <h2>Issue Details</h2>
          <p>Description: {issueData.description}</p>
          <p>Pincode: {issueData.pincode}</p>
         {/* Dropdown for status */}
         <label htmlFor="status">Select Status:</label>
          <select
            id="status"
            value={selectedStatus}
            onChange={(e) => setSelectedStatus(e.target.value)}
          >
            <option value="open">Open</option>
            <option value="closed">Closed</option>
            <option value="in progress">In Progress</option>
          </select>

          {/* Button to update status */}
          <button onClick={handleStatusChange}>Update Status</button>
           
        </>
      ) : (
        <p>Loading...</p>
      )}
    </div>
  );
};

export default IssueDetails;