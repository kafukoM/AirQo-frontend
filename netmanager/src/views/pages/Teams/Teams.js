import React, { useState, useEffect } from 'react';
import DataTable from './Table';
import ErrorBoundary from '../../ErrorBoundary/ErrorBoundary';
import HorizontalLoader from '../../components/HorizontalLoader/HorizontalLoader';
import { makeStyles } from '@material-ui/styles';
import { useHistory } from 'react-router-dom';
import { useDispatch } from 'react-redux';
import Alert from '@material-ui/lab/Alert';
import {
  Button,
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  TextField,
  Grid,
  IconButton
} from '@material-ui/core';
import { createTeamApi } from '../../apis/accessControl';
import { updateMainAlert } from 'redux/MainAlert/operations';
import DeleteIcon from '@material-ui/icons/Delete';
import Tooltip from '@material-ui/core/Tooltip';
import { getUserDetails } from 'redux/Join/actions';
import { Close as CloseIcon } from '@material-ui/icons';

const useStyles = makeStyles((theme) => ({
  root: {
    padding: theme.spacing(2),
    [theme.breakpoints.down('sm')]: {
      padding: theme.spacing(1)
    }
  },
  modelWidth: {
    minWidth: 450,
    [theme.breakpoints.down('sm')]: {
      minWidth: '100%'
    }
  },
  actionButtonContainer: {
    display: 'flex',
    justifyContent: 'flex-end',
    alignItems: 'center',
    marginBottom: theme.spacing(2)
  },
  confirm_con: {
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'left',
    flexDirection: 'column',
    padding: theme.spacing(2)
  },
  confirm_field: {
    margin: theme.spacing(1, 0),
    fontSize: '16px'
  },
  confirm_field_title: {
    fontSize: '16px',
    fontWeight: 'bold',
    color: '#000000',
    marginRight: theme.spacing(2)
  }
}));

const CreateTeam = ({
  showCreateTeamDialog,
  setShowCreateTeamDialog,
  setIsLoading,
  setRefresh
}) => {
  const dispatch = useDispatch();
  const [team, setTeam] = useState({ name: '', description: '' });
  const [errors, setErrors] = useState({
    name: '',
    description: '',
    showError: false,
    errorMessage: ''
  });

  const handleClose = () => {
    setShowCreateTeamDialog(false);
    setTeam({ name: '', description: '' });
    setErrors({ name: '', description: '' });
  };

  const handleChange = (name) => (event) => {
    setTeam({ ...team, [name]: event.target.value });
    setErrors({ ...errors, [name]: '' });
  };

  const handleCreateTeam = async () => {
    setIsLoading(true);
    setErrors({
      name: team.name ? '' : 'Team Name is required',
      description: team.description ? '' : 'Team Description is required'
    });

    if (team.name && team.description) {
      let teamData = {
        grp_title: team.name,
        grp_description: team.description
      };

      try {
        const res = await createTeamApi(teamData);
        handleClose();
        dispatch(
          updateMainAlert({
            severity: 'success',
            message: 'Team created successfully',
            show: true
          })
        );
        setRefresh(true);
      } catch (err) {
        if (err.response.status === 409) {
          setErrors({
            showError: true,
            errorMessage: 'Team with this name already exists.'
          });
        } else {
          setErrors({
            showError: true,
            errorMessage: 'Something went wrong. Please try again later.'
          });
        }
      }
    }
    setIsLoading(false);
  };

  return (
    <Dialog
      open={showCreateTeamDialog}
      onClose={handleClose}
      aria-labelledby="form-dialog-title"
      aria-describedby="form-dialog-description">
      <DialogTitle id="form-dialog-title" style={{ textTransform: 'uppercase' }}>
        Create a New Team
      </DialogTitle>
      <DialogContent style={{ maxHeight: 'auto' }}>
        {errors.showError && (
          <Alert
            style={{ marginBottom: 10 }}
            severity="error"
            action={
              <IconButton
                aria-label="close"
                color="inherit"
                size="small"
                onClick={() => {
                  setErrors({ showError: false });
                }}>
                <CloseIcon fontSize="inherit" />
              </IconButton>
            }>
            {errors.errorMessage}
          </Alert>
        )}

        <TextField
          fullWidth
          margin="dense"
          label="Team Name"
          variant="outlined"
          value={team.name}
          onChange={handleChange('name')}
          required
          error={!!errors.name}
          helperText={errors.name}
        />
        <TextField
          fullWidth
          margin="dense"
          label="Team Description"
          variant="outlined"
          value={team.description}
          onChange={handleChange('description')}
          required
          error={!!errors.description}
          helperText={errors.description}
        />
      </DialogContent>
      <DialogActions>
        <Grid container alignItems="flex-end" alignContent="flex-end" justify="flex-end">
          <Button variant="contained" type="button" onClick={handleClose}>
            Cancel
          </Button>
          <Button
            variant="contained"
            color="primary"
            type="submit"
            onClick={handleCreateTeam}
            style={{ margin: '0 15px' }}>
            Create Team
          </Button>
        </Grid>
        <br />
      </DialogActions>
    </Dialog>
  );
};

const Teams = () => {
  const classes = useStyles();
  const history = useHistory();
  const [teams, setTeams] = useState([]);
  const [loading, setLoading] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [refresh, setRefresh] = useState(false);
  const dispatch = useDispatch();
  const [showCreateTeamDialog, setShowCreateTeamDialog] = useState(false);

  //   get currentUser from localStorage
  const currentUser = JSON.parse(localStorage.getItem('currentUser'));

  const handleDelete = (id) => {
    console.log('Deleting team with id:', id);
  };

  useEffect(() => {
    setLoading(true);
    if (currentUser) {
      getUserDetails(currentUser._id)
        .then((res) => {
          setTeams(res.users[0].groups);
        })
        .catch((err) => {
          console.error(err);
        })
        .finally(() => {
          setLoading(false);
        });
    }
  }, [refresh]);

  return (
    <ErrorBoundary>
      <HorizontalLoader loading={isLoading} />
      <div className={classes.root}>
        <div
          style={{
            display: 'flex',
            justifyContent: 'flex-end',
            alignItems: 'center',
            marginBottom: 20
          }}>
          <Button variant="contained" color="primary" onClick={() => setShowCreateTeamDialog(true)}>
            Create a Team
          </Button>
        </div>
        <DataTable
          title="Teams"
          tableBodyHeight={{
            height: 'calc(100vh - 300px)'
          }}
          columns={[
            {
              id: 'grp_title',
              label: 'Team title'
            },
            {
              id: 'status',
              label: 'Status',
              format: (value, row) => {
                return (
                  <span style={{ color: row.status === 'ACTIVE' ? 'green' : 'red' }}>
                    {row.status}
                  </span>
                );
              }
            },
            {
              id: 'createdAt',
              label: 'Formed on',
              format: (value, row) => {
                const date = new Date(row.createdAt);
                const options = { year: 'numeric', month: 'long', day: 'numeric' };
                return date.toLocaleDateString('en-US', options);
              }
            },
            {
              id: 'actions',
              label: 'Actions',
              format: (value, row) => (
                <Tooltip title="Delete" placement="bottom" arrow>
                  <IconButton onClick={() => handleDelete(row._id)} disabled>
                    <DeleteIcon />
                  </IconButton>
                </Tooltip>
              )
            }
          ]}
          onRowClick={(row) => {
            history.push(`/teams/${row._id}`);
          }}
          rows={teams}
          loading={loading}
        />
        <CreateTeam
          showCreateTeamDialog={showCreateTeamDialog}
          setShowCreateTeamDialog={setShowCreateTeamDialog}
          setIsLoading={setIsLoading}
          setRefresh={setRefresh}
        />
      </div>
    </ErrorBoundary>
  );
};

export default Teams;