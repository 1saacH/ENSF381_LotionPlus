import { useEffect, useRef, useState } from "react";
import { Outlet, useNavigate, Link } from "react-router-dom";
import NoteList from "./NoteList";
import Login from "./Login";
import { v4 as uuidv4 } from "uuid";
import { currentDate } from "./utils";



const localStorageKey = "lotion-v1";

const getUrl = "https://2y7lq3ffkvxnaffr3fbm4dajya0hrubw.lambda-url.ca-central-1.on.aws/";
const saveUrl = "https://2pkfvt7jung6vh7pqiocipgnoq0gqkjl.lambda-url.ca-central-1.on.aws/";
const delUrl = "https://mpo4kk2ozv3dy4jftw4ug2nxf40glxed.lambda-url.ca-central-1.on.aws/";

function Layout() {
  const navigate = useNavigate();
  const mainContainerRef = useRef(null);
  const [collapse, setCollapse] = useState(false);
  const [notes, setNotes] = useState([]);
  const [editMode, setEditMode] = useState(false);
  const [currentNote, setCurrentNote] = useState(-1);

  const [email, setEmail] = useState("none");
//--------------------------------------------------------------------------------------------------------------------------
// GOOGLE OATH
async function passEmail(email){
  console.log("email: " + email);
  setEmail(email);
  setNotes([]);

  // init the notes array, idk how to know how to get all the notes tho, will need to debug this after aws
  // const notesArray = [];
  // const res = getNote(0);
  // let i = 1;
  // while(res != null){
  //   res = getNote(i)
  //   notesArray.push(res);
  //   i++;
  // };
  // setNotes(notesArray);
}



//--------------------------------------------------------------------------------------------------------------------------
//AWS FUNCTIONS

  async function getNote(id){
    // calls the get function, sends email and id for the keys
    // returns the notes object (i think)

    const args = {"email" : email, "id":id};
    const res = await fetch(getUrl,{method : "GET", headers: {"Conent-Type": "application.json"}, body: JSON.stringify(args)});
    
    return res.body
  }
  
  async function saveNoteAWS(note,id){
    // deletes note from aws then replaces it, basically an update
    // arg note is anouther json inside (jsonseption), to be unpacked in lambda
    // also updates the react state so the ui updates
    delNoteAWS(id);
    const args = {"email" : email, "id":id, "note": note};
    const res = await fetch(saveUrl,{method : "POST", headers: {"Conent-Type": "application.json"}, body: JSON.stringify(args)});
    setNotes([
      ...notes.slice(0, id),
      { ...note },
      ...notes.slice(id + 1),
    ]);
  }

  async function delNoteAWS(id){
    // calls aws func to delete the note with the id from the args

    const args = {"email" : email, "id":id};
    const res = await fetch(delUrl,{method : "GET", headers: {"Conent-Type": "application.json"}, body: JSON.stringify(args)});
  }


  //--------------------------------------------------------------------------------------------------------
  //REACT FUNTIONS

  useEffect(() => {
    const height = mainContainerRef.current.offsetHeight;
    mainContainerRef.current.style.maxHeight = `${height}px`;
    const existing = localStorage.getItem(localStorageKey);
    if (existing) {
      try {
        setNotes(JSON.parse(existing));
      } catch {
        setNotes([]);
      }
    }
  }, []);

  useEffect(() => {
    localStorage.setItem(localStorageKey, JSON.stringify(notes));
  }, [notes]);

  useEffect(() => {
    if (currentNote < 0) {
      return;
    }
    if (!editMode) {
      navigate(`/notes/${currentNote + 1}`);
      return;
    }
    navigate(`/notes/${currentNote + 1}/edit`);
  }, [notes]);

  const saveNote = (note, id) => {
    note.body = note.body.replaceAll("<p><br></p>", "");
    saveNoteAWS(note,id);
    setCurrentNote(id);
    setEditMode(false);
  };

  const deleteNote = (id) => {
    setNotes([...notes.slice(0, id), ...notes.slice(id + 1)]);
    delNoteAWS(id);
    setCurrentNote(0);
    setEditMode(false);
  };

  const addNote = () => {
    console.log(email);
    setNotes([
      {
        id: uuidv4(),
        title: "Untitled",
        body: "",
        when: currentDate(),
      },
      ...notes,
    ]);
    setEditMode(true);
    setCurrentNote(0);
  };

  const logout = () => {
    setEmail("none");
  }





  return ( 
  <div>
  {email == "none" ? (
    <>
      <header>
          <aside >
            <button id="menu-button" onClick={() => {console.log("Good try hacker, lol ")}}>
              &#9776;
            </button>
          </aside>
          <div id="app-header">
            <h1>
              <Link to="/notes">Lotion</Link>
            </h1>
            <h6 id="app-moto">Like Notion, but worse.</h6>
          </div>
          <aside>&nbsp;</aside>
        </header>
      <div id="main-container" className="google" ref={mainContainerRef}>
        <Login  passEmail = {passEmail}/>
      </div>
    </>
    ) : (
    <>
    <div id="container">
      <header>
        <aside>
          <button id="menu-button" onClick={() => setCollapse(!collapse)}>
            &#9776;
          </button>
        </aside>
        <div id="app-header">
          <h1>
            <Link to="/notes">Lotion</Link>
          </h1>
          <h6 id="app-moto">Like Notion, but worse.</h6>
        </div>
        <aside>
          <span id = "info">
            <span>{email}</span>
            <button onClick = {logout}>(Log out)</button>
          </span>
        </aside>
      </header>
      <div id="main-container" ref={mainContainerRef}>
        <aside id="sidebar" className={collapse ? "hidden" : null}>
          <header>
            <div id="notes-list-heading">
              <h2>Notes</h2>
              <button id="new-note-button" onClick={addNote}>
                +
              </button>
            </div>
          </header>
          <div id="notes-holder">
            <NoteList notes={notes} />
          </div>
        </aside>
        <div id="write-box">
          <Outlet context={[notes, saveNote, deleteNote]} />
        </div>
      </div>
    </div>
    </>
  )}
  </div>)
}

export default Layout;
