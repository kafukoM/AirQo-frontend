import React, { useState, useEffect, useCallback } from 'react';
import { getAllLocationsTrackingApi } from '../../../apis';

const LocationTracker = ({ countries }) => {
  const [storedCountry, setStoredCountry] = useState(localStorage.getItem('userCountry'));

  // function to update the users country
  const updateUserCountry = useCallback(async () => {
    try {
      const { geolocation } = navigator;

      if (!geolocation) {
        console.error('Geolocation is not supported by this browser.');
        return;
      }

      let permissionResult;
      if (localStorage.getItem('permissionResult')) {
        permissionResult = JSON.parse(localStorage.getItem('permissionResult'));
      } else {
        permissionResult = await new Promise((resolve, reject) => {
          geolocation.getCurrentPosition(resolve, reject);
        });

        if (permissionResult.code === 1) {
          console.error('Geolocation permission denied.');
          return;
        }

        localStorage.setItem('permissionResult', JSON.stringify(permissionResult));
      }

      if (permissionResult) {
        const countryName = await getAllLocationsTrackingApi();

        const selectedCountry = countries.some((country) => countryName === country.name)
          ? countryName
          : 'Uganda';

        if (selectedCountry !== storedCountry) {
          setStoredCountry(selectedCountry);
          localStorage.setItem('userCountry', selectedCountry);
        }
        return selectedCountry;
      }
    } catch (error) {
      console.error('Error fetching user country:', error);
    }
  }, [countries, storedCountry]);

  useEffect(() => {
    updateUserCountry();
  }, [updateUserCountry]);

  return storedCountry;
};

export default LocationTracker;
