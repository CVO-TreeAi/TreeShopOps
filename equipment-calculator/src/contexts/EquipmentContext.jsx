// Equipment Context for State Management

import React, { createContext, useContext, useReducer, useEffect } from 'react';
import { v4 as uuidv4 } from 'uuid';
import { loadEquipment, saveEquipment, addEquipment as addToStorage, updateEquipment as updateInStorage, deleteEquipment as deleteFromStorage } from '../utils/storage.js';
import { calculateEquipmentCosts } from '../utils/calculations.js';

// Action types
const EQUIPMENT_ACTIONS = {
  LOAD_EQUIPMENT: 'LOAD_EQUIPMENT',
  ADD_EQUIPMENT: 'ADD_EQUIPMENT', 
  UPDATE_EQUIPMENT: 'UPDATE_EQUIPMENT',
  DELETE_EQUIPMENT: 'DELETE_EQUIPMENT',
  SET_FILTER: 'SET_FILTER',
  SET_SEARCH: 'SET_SEARCH',
  SET_SORT: 'SET_SORT'
};

// Initial state
const initialState = {
  equipment: [],
  filteredEquipment: [],
  filters: {
    category: 'All',
    search: '',
    sortBy: 'name',
    sortOrder: 'asc'
  },
  loading: false,
  error: null
};

// Equipment reducer
function equipmentReducer(state, action) {
  switch (action.type) {
    case EQUIPMENT_ACTIONS.LOAD_EQUIPMENT:
      const equipment = action.payload;
      return {
        ...state,
        equipment,
        filteredEquipment: filterAndSortEquipment(equipment, state.filters),
        loading: false
      };

    case EQUIPMENT_ACTIONS.ADD_EQUIPMENT:
      const newEquipment = [...state.equipment, action.payload];
      return {
        ...state,
        equipment: newEquipment,
        filteredEquipment: filterAndSortEquipment(newEquipment, state.filters)
      };

    case EQUIPMENT_ACTIONS.UPDATE_EQUIPMENT:
      const updatedEquipment = state.equipment.map(item =>
        item.id === action.payload.id ? action.payload : item
      );
      return {
        ...state,
        equipment: updatedEquipment,
        filteredEquipment: filterAndSortEquipment(updatedEquipment, state.filters)
      };

    case EQUIPMENT_ACTIONS.DELETE_EQUIPMENT:
      const filtered = state.equipment.filter(item => item.id !== action.payload);
      return {
        ...state,
        equipment: filtered,
        filteredEquipment: filterAndSortEquipment(filtered, state.filters)
      };

    case EQUIPMENT_ACTIONS.SET_FILTER:
      const newFilters = { ...state.filters, ...action.payload };
      return {
        ...state,
        filters: newFilters,
        filteredEquipment: filterAndSortEquipment(state.equipment, newFilters)
      };

    case EQUIPMENT_ACTIONS.SET_SEARCH:
      const searchFilters = { ...state.filters, search: action.payload };
      return {
        ...state,
        filters: searchFilters,
        filteredEquipment: filterAndSortEquipment(state.equipment, searchFilters)
      };

    case EQUIPMENT_ACTIONS.SET_SORT:
      const sortFilters = { ...state.filters, ...action.payload };
      return {
        ...state,
        filters: sortFilters,
        filteredEquipment: filterAndSortEquipment(state.equipment, sortFilters)
      };

    default:
      return state;
  }
}

// Filter and sort utility function
function filterAndSortEquipment(equipment, filters) {
  let filtered = [...equipment];

  // Filter by category
  if (filters.category && filters.category !== 'All') {
    filtered = filtered.filter(item => 
      item.identity?.category === filters.category
    );
  }

  // Filter by search
  if (filters.search) {
    const searchLower = filters.search.toLowerCase();
    filtered = filtered.filter(item => 
      item.identity?.name?.toLowerCase().includes(searchLower) ||
      item.identity?.make?.toLowerCase().includes(searchLower) ||
      item.identity?.model?.toLowerCase().includes(searchLower)
    );
  }

  // Sort equipment
  filtered.sort((a, b) => {
    let aVal, bVal;
    
    switch (filters.sortBy) {
      case 'name':
        aVal = a.identity?.name || '';
        bVal = b.identity?.name || '';
        break;
      case 'cost':
        aVal = a.calculated?.hourlyCost || 0;
        bVal = b.calculated?.hourlyCost || 0;
        break;
      case 'date':
        aVal = new Date(a.metadata?.dateAdded || 0);
        bVal = new Date(b.metadata?.dateAdded || 0);
        break;
      case 'category':
        aVal = a.identity?.category || '';
        bVal = b.identity?.category || '';
        break;
      default:
        return 0;
    }
    
    if (filters.sortOrder === 'desc') {
      return aVal < bVal ? 1 : -1;
    }
    return aVal > bVal ? 1 : -1;
  });

  return filtered;
}

// Create context
const EquipmentContext = createContext();

// Equipment provider component
export function EquipmentProvider({ children }) {
  const [state, dispatch] = useReducer(equipmentReducer, initialState);

  // Load equipment on mount
  useEffect(() => {
    const equipment = loadEquipment();
    dispatch({ type: EQUIPMENT_ACTIONS.LOAD_EQUIPMENT, payload: equipment });
  }, []);

  // Action creators
  const actions = {
    // Load equipment from storage
    loadEquipment: () => {
      const equipment = loadEquipment();
      dispatch({ type: EQUIPMENT_ACTIONS.LOAD_EQUIPMENT, payload: equipment });
    },

    // Add new equipment
    addEquipment: (equipmentData) => {
      // Calculate costs
      const calculated = calculateEquipmentCosts(equipmentData);
      
      // Create complete equipment object
      const newEquipment = {
        id: uuidv4(),
        ...equipmentData,
        calculated,
        metadata: {
          dateAdded: new Date().toISOString(),
          lastModified: new Date().toISOString(),
          status: 'active',
          usageHours: 0,
          utilization: 0
        }
      };

      // Save to storage
      const saved = addToStorage(newEquipment);
      if (saved) {
        dispatch({ type: EQUIPMENT_ACTIONS.ADD_EQUIPMENT, payload: saved });
        return saved;
      }
      return null;
    },

    // Update existing equipment
    updateEquipment: (equipmentId, updatedData) => {
      // Recalculate costs
      const calculated = calculateEquipmentCosts(updatedData);
      
      const equipmentWithCalculations = {
        ...updatedData,
        calculated,
        metadata: {
          ...updatedData.metadata,
          lastModified: new Date().toISOString()
        }
      };

      // Update in storage
      const success = updateInStorage(equipmentId, equipmentWithCalculations);
      if (success) {
        dispatch({
          type: EQUIPMENT_ACTIONS.UPDATE_EQUIPMENT,
          payload: { id: equipmentId, ...equipmentWithCalculations }
        });
        return true;
      }
      return false;
    },

    // Delete equipment
    deleteEquipment: (equipmentId) => {
      const success = deleteFromStorage(equipmentId);
      if (success) {
        dispatch({ type: EQUIPMENT_ACTIONS.DELETE_EQUIPMENT, payload: equipmentId });
        return true;
      }
      return false;
    },

    // Set category filter
    setFilter: (filters) => {
      dispatch({ type: EQUIPMENT_ACTIONS.SET_FILTER, payload: filters });
    },

    // Set search term
    setSearch: (searchTerm) => {
      dispatch({ type: EQUIPMENT_ACTIONS.SET_SEARCH, payload: searchTerm });
    },

    // Set sort options
    setSort: (sortBy, sortOrder = 'asc') => {
      dispatch({ type: EQUIPMENT_ACTIONS.SET_SORT, payload: { sortBy, sortOrder } });
    },

    // Get equipment by ID
    getEquipmentById: (equipmentId) => {
      return state.equipment.find(item => item.id === equipmentId) || null;
    },

    // Calculate fleet statistics
    getFleetStats: () => {
      const equipment = state.equipment;
      const totalCount = equipment.length;
      const totalValue = equipment.reduce((sum, item) => 
        sum + (Number(item.financial?.purchasePrice) || 0), 0
      );
      const totalHourlyCost = equipment.reduce((sum, item) => 
        sum + (Number(item.calculated?.hourlyCost) || 0), 0
      );
      const averageHourlyCost = totalCount > 0 ? totalHourlyCost / totalCount : 0;

      return {
        totalCount,
        totalValue,
        averageHourlyCost: Math.round(averageHourlyCost * 100) / 100,
        activeCount: equipment.filter(item => item.metadata?.status === 'active').length
      };
    }
  };

  return (
    <EquipmentContext.Provider value={{ ...state, ...actions }}>
      {children}
    </EquipmentContext.Provider>
  );
}

// Custom hook to use equipment context
export function useEquipment() {
  const context = useContext(EquipmentContext);
  if (!context) {
    throw new Error('useEquipment must be used within an EquipmentProvider');
  }
  return context;
}