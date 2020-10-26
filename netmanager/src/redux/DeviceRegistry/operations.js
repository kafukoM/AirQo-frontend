// for representing chained operations using redux-thunk
import {
    LOAD_ALL_DEVICES_SUCCESS,
    LOAD_ALL_DEVICES_FAILURE,
    LOAD_MAINTENANCE_LOGS_SUCCESS,
    LOAD_MAINTENANCE_LOGS_FAILURE,
    LOAD_DEVICE_COMPONENTS_SUCCESS,
    LOAD_DEVICE_COMPONENTS_FAILURE,
} from "./actions";
import { transformArray } from "../utils";
import {
    getAllDevicesApi,
    getDeviceMaintenanceLogsApi,
    getDeviceComponentsApi }
    from "../../views/apis/deviceRegistry";


export const loadDevicesData = () => {
  return async (dispatch) => {
    return await getAllDevicesApi()
      .then((responseData) => {
          if(responseData.devices){
              dispatch({
                  type: LOAD_ALL_DEVICES_SUCCESS,
                  payload: transformArray(responseData.devices, 'id'),
              });
          }

      })
      .catch((err) => {
        dispatch({
          type: LOAD_ALL_DEVICES_FAILURE,
          payload: err,
        });
      });
  };
};

export const loadDeviceMaintenanceLogs = (deviceName) => {
    return async (dispatch) => {
        return await getDeviceMaintenanceLogsApi(deviceName)
            .then((responseData) => {
                dispatch({
                    type: LOAD_MAINTENANCE_LOGS_SUCCESS,
                    payload: { [deviceName]: responseData }
                })
            })
            .catch((err) => {
                dispatch({
                  type: LOAD_MAINTENANCE_LOGS_FAILURE,
                  payload: err,
                });
            })
    }
}

export const loadDeviceComponentsData = (deviceName) => {
    return async (dispatch) => {
        return await getDeviceComponentsApi(deviceName)
            .then(responseData => {
                dispatch({
                    type: LOAD_DEVICE_COMPONENTS_SUCCESS,
                    payload: { [deviceName]: responseData.components }
                })
            })
            .catch(err => {
                dispatch({
                    type: LOAD_DEVICE_COMPONENTS_FAILURE,
                    payload: err,
                })
            })
    }
}
