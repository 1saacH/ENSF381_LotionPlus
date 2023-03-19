import { GoogleOAuthProvider, GoogleLogin, useGoogleLogin } from '@react-oauth/google';
import { useContext } from 'react';
import { useParams } from 'react-router-dom';
import { useEffect, useRef, useState } from "react";
import jwtDecode from "jwt-decode";

function Login({passEmail}) {
    const [ profile, setProfile ] = useState([]);

    const success = (profile) => {
        if (profile.credential != null) {
            const USER_CREDENTIAL = jwtDecode(profile.credential);
            console.log(USER_CREDENTIAL.email);
            passEmail(USER_CREDENTIAL.email);
    }};

    const errorMessage = (error) => {
        console.log("didnt work: " + error);
    };
    return(
    <GoogleOAuthProvider clientId="691263297104-himbuumcpqbuufmm4ln8soh6ngd6j5jl.apps.googleusercontent.com">
        <div id="oath">
            <h2>Please Login to access Lotion</h2>
            <br />
            <br />
            <GoogleLogin onSuccess={(user) => success(user)} onError={errorMessage} />
        </div>
    </GoogleOAuthProvider>
  )}
  
  export default Login;