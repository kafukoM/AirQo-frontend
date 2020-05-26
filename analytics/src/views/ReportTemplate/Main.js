import React, { Component } from "react";
import { EditorState, convertFromRaw, convertToRaw } from "draft-js";
import {
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogContentText,
  TextField,
} from "@material-ui/core";
import SaveIcon from "@material-ui/icons/Save";
import FolderIcon from "@material-ui/icons/Folder";
import Tooltip from "@material-ui/core/Tooltip";
import { Editor } from "react-draft-wysiwyg";
import "react-draft-wysiwyg/dist/react-draft-wysiwyg.css";
import "../../assets/scss/report.css";
import axios from "axios";

class Main extends Component {
  constructor(props) {
    super(props);
    this.state = {
      editorState: EditorState.createEmpty(),
      user_id: this.props.user_id,
      open: false,
      openSave: false,
      openConfirm: false,
      saved_report: {},
      report_body: {},
      report_name: "",
    };
    // bind to this
    this.handleClick = this.handleClick.bind(this);
    this.handleSaveClick = this.handleSaveClick.bind(this);
    this.handleSaveClose = this.handleSaveClose.bind(this);
    this.changeHandler = this.changeHandler.bind(this);
    this.handleConfirmClose = this.handleConfirmClose.bind(this);
  }

  onEditorStateChange = (editorState) => {
    // console.log(editorState)
    this.setState({
      editorState,
    });
  };

  componentDidMount() {
    axios
      .get("https://analytcs-bknd-service-dot-airqo-250220.uc.r.appspot.com/api/v1/report/get_default_report_template")
      //.get("http://127.0.0.1:5000/api/v1/report/get_default_report_template")
      .then((res) => {
        let result = res.data[0];
        this.setState({
          editorState: EditorState.createWithContent(
            convertFromRaw(JSON.parse(JSON.stringify(result.report_body)))
          ),
        });
        //console.log(result.report_body);
      })
      .catch((e) => {
        console.log(e);
      });
  }

  uploadImageCallBack = (file) => {
    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest(); // eslint-disable-line no-undef
      xhr.open("POST", "https://api.imgur.com/3/image");
      xhr.setRequestHeader("Authorization", "Client-ID 8d26ccd12712fca");
      const data = new FormData(); // eslint-disable-line no-undef
      data.append("image", file);
      xhr.send(data);
      xhr.addEventListener("load", () => {
        const response = JSON.parse(xhr.responseText);
        resolve(response);
      });
      xhr.addEventListener("error", () => {
        const error = JSON.parse(xhr.responseText);
        reject(error);
      });
    });
  };

  // save monthly report
  saveReport = () => {
    // head the save planning space dialog
    this.setState((prevState) => ({ openSave: !prevState.openSave }));
    // get status of the report
    let report_body = convertToRaw(this.state.editorState.getCurrentContent());

    console.log(this.state.report_name, report_body);

    // make api call to save report
    axios
      .post(
        "https://analytcs-bknd-service-dot-airqo-250220.uc.r.appspot.com/api/v1/report/save_monthly_report",
        //"http://127.0.0.1:5000/api/v1/report/save_monthly_report",
        {
          user_id: this.state.user_id,
          report_name: this.state.report_name,
          report_body: report_body,
        },
        {
          headers: {
            "Content-Type": "application/json",
          },
        }
      )
      .then((res) => {
        console.log(res);
        this.setState((prevState) => ({ openConfirm: !prevState.openConfirm })); //
      })
      .catch((e) => console.log(e));
  };

  // This deals with save report dialog box
  handleSaveClick = () => {
    this.setState((prevState) => ({ openSave: !prevState.openSave }));
  };
  handleSaveClose = () => {
    this.setState((prevState) => ({ openSave: !prevState.openSave }));
  };
  // hooks the monthly report textfield input
  changeHandler = (e) => {
    this.setState({ [e.target.name]: e.target.value });
  };

  // Handles saved report confirmation feedback
  handleConfirmClose = () => {
    this.setState((prevState) => ({ openConfirm: !prevState.openConfirm }));
  };

  // load previously saved report
  handleClick = () => {
    this.setState((prevState) => ({ open: !prevState.open }));
  };

  render() {
    const { editorState } = this.state;
    const editor = {
      height: "auto",
      width: "210mm",
      margin: "0 auto",
      textAlign: "justify",
    };
    console.log(this.state.user_id);

    return (
      <div>
        <div>
          <Tooltip title="Save report" placement="right" arrow>
            <Button
              color="primary"
              variant="contained"
              endIcon={<SaveIcon />}
              onClick={this.handleSaveClick}
              className="print"
            >
              <style>{"@media print {.print{display: none;}}"}</style>
              {/* Save Draft */}
            </Button>
          </Tooltip>
        </div>
        <div>
          <Tooltip title="Open previous report" placement="right" arrow>
            <Button
              color="primary"
              variant="contained"
              endIcon={<FolderIcon />}
              onClick=""
              className="print"
            >
              <style>{"@media print {.print{display: none;}}"}</style>
              {/* Load Draft */}
            </Button>
          </Tooltip>
        </div>
        <div style={editor}>
          <Editor
            editorState={editorState}
            onEditorStateChange={this.onEditorStateChange}
            toolbarClassName="hidden-on-print"
            toolbar={{
              inline: { inDropdown: true, className: "hidden-on-print" },
              list: { inDropdown: true },
              textAlign: { inDropdown: true },
              link: { inDropdown: true },
              history: { inDropdown: true },
              image: {
                uploadCallback: this.uploadImageCallBack.bind(this),
                alt: { present: false, mandatory: false },
                previewImage: true,
              },
            }}
          />
          <style>{"@media print {.hidden-on-print{display: none;}}"}</style>
        </div>
        <div>
          {/* Dialog for report */}
          <Dialog
            open={this.state.openSave}
            onClose={this.handleSaveClose}
            aria-labelledby="form-dialog-title"
          >
            <DialogContent>
              <DialogContentText>
                To save this report, please enter the name in the text field
                below.
              </DialogContentText>
              <TextField
                autoFocus
                margin="dense"
                id="name"
                name="report_name"
                value={this.state.report_name}
                onChange={this.changeHandler}
                label="Save As"
                type="text"
                placeholder="analytic_report_001"
                fullWidth
              />
            </DialogContent>
            <DialogActions>
              <Button onClick={this.handleSaveClose} color="primary">
                Cancel
              </Button>
              <Button onClick={this.saveReport} color="primary">
                Save
              </Button>
            </DialogActions>
          </Dialog>

          {/* Dialog for confirming saved report  */}
          <Dialog
            open={this.state.openConfirm}
            onClose={this.handleConfirmClose}
            aria-labelledby="alert-dialog-title"
            aria-describedby="alert-dialog-description"
          >
            <DialogContent>
              <DialogContentText id="alert-dialog-description">
                Your report has been saved successfully
              </DialogContentText>
            </DialogContent>
            <DialogActions>
              <Button onClick={this.handleConfirmClose} color="primary">
                OK
              </Button>
            </DialogActions>
          </Dialog>
        </div>
      </div>
    );
  }
}

export default Main;
