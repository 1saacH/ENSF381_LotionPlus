import { GoogleOAuthProvider, GoogleLogin } from '@react-oauth/google';

function Login() {
    const responseMessage = (response) => {
        console.log(response);
    };
    const errorMessage = (error) => {
        console.log(error);
    };
    return(
    <GoogleOAuthProvider clientId="691263297104-himbuumcpqbuufmm4ln8soh6ngd6j5jl.apps.googleusercontent.com">
        <div>
            <h2>Please Login to access Lotion</h2>
            <br />
            <br />
            <GoogleLogin onSuccess={responseMessage} onError={errorMessage} />
        </div>
    </GoogleOAuthProvider>
  )}
  
  export default Login;