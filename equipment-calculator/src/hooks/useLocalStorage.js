// Custom hook for localStorage management

import { useState, useEffect } from 'react';

/**
 * Hook for managing localStorage with React state
 */
export function useLocalStorage(key, initialValue) {
  // Get initial value from localStorage or use provided initial value
  const [storedValue, setStoredValue] = useState(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch (error) {
      console.error(`Error loading localStorage key "${key}":`, error);
      return initialValue;
    }
  });

  // Return a wrapped version of useState's setter function that persists the new value to localStorage
  const setValue = (value) => {
    try {
      // Allow value to be a function so we have the same API as useState
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      
      // Save state
      setStoredValue(valueToStore);
      
      // Save to localStorage
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error(`Error saving localStorage key "${key}":`, error);
    }
  };

  return [storedValue, setValue];
}

/**
 * Hook for managing form drafts
 */
export function useFormDraft(formKey, initialValues = {}) {
  const [draft, setDraft] = useLocalStorage(`draft_${formKey}`, initialValues);
  
  // Auto-save draft on changes with debouncing
  useEffect(() => {
    const timeoutId = setTimeout(() => {
      if (Object.keys(draft).length > 0) {
        console.log(`Auto-saved draft for ${formKey}`);
      }
    }, 1000);
    
    return () => clearTimeout(timeoutId);
  }, [draft, formKey]);

  const clearDraft = () => {
    try {
      window.localStorage.removeItem(`draft_${formKey}`);
      setDraft(initialValues);
    } catch (error) {
      console.error(`Error clearing draft for "${formKey}":`, error);
    }
  };

  const updateDraft = (updates) => {
    setDraft(prev => ({ ...prev, ...updates }));
  };

  return {
    draft,
    setDraft,
    updateDraft,
    clearDraft,
    hasDraft: Object.keys(draft).length > 0
  };
}

/**
 * Hook for managing application preferences
 */
export function useAppPreferences() {
  const [preferences, setPreferences] = useLocalStorage('app_preferences', {
    theme: 'dark',
    currency: 'USD',
    defaultCategory: 'Forestry Mulcher',
    autoSave: true,
    showCalculations: true
  });

  const updatePreference = (key, value) => {
    setPreferences(prev => ({ ...prev, [key]: value }));
  };

  return {
    preferences,
    setPreferences,
    updatePreference
  };
}