// Custom Equipment Management Hook

import { useContext } from 'react';
import { useEquipment as useEquipmentContext } from '../contexts/EquipmentContext.jsx';

/**
 * Enhanced hook for equipment operations with computed values
 */
export function useEquipmentOperations() {
  const context = useEquipmentContext();
  
  if (!context) {
    throw new Error('useEquipmentOperations must be used within an EquipmentProvider');
  }

  const {
    equipment,
    filteredEquipment,
    filters,
    addEquipment,
    updateEquipment,
    deleteEquipment,
    setFilter,
    setSearch,
    setSort,
    getEquipmentById,
    getFleetStats
  } = context;

  // Enhanced equipment operations
  const operations = {
    // Get equipment with enhanced data
    getEquipmentWithMetrics: (equipmentId) => {
      const item = getEquipmentById(equipmentId);
      if (!item) return null;

      // Calculate additional metrics
      const currentYear = new Date().getFullYear();
      const equipmentAge = currentYear - (item.identity?.year || currentYear);
      const depreciation = (item.calculated?.annualDepreciation || 0) * equipmentAge;
      const currentValue = Math.max(0, (item.financial?.purchasePrice || 0) - depreciation);

      return {
        ...item,
        metrics: {
          age: equipmentAge,
          currentValue,
          totalDepreciation: depreciation,
          utilizationRate: item.metadata?.utilization || 0
        }
      };
    },

    // Search with advanced filters
    searchEquipment: (query) => {
      setSearch(query);
    },

    // Filter by multiple criteria  
    filterEquipment: (filterOptions) => {
      setFilter(filterOptions);
    },

    // Sort with custom options
    sortEquipment: (sortBy, order = 'asc') => {
      setSort(sortBy, order);
    },

    // Get equipment by category with stats
    getEquipmentByCategory: () => {
      const byCategory = equipment.reduce((acc, item) => {
        const category = item.identity?.category || 'Other';
        if (!acc[category]) {
          acc[category] = [];
        }
        acc[category].push(item);
        return acc;
      }, {});

      // Add stats for each category
      Object.keys(byCategory).forEach(category => {
        const items = byCategory[category];
        byCategory[category] = {
          items,
          count: items.length,
          totalValue: items.reduce((sum, item) => 
            sum + (Number(item.financial?.purchasePrice) || 0), 0
          ),
          avgHourlyCost: items.reduce((sum, item) => 
            sum + (Number(item.calculated?.hourlyCost) || 0), 0
          ) / items.length
        };
      });

      return byCategory;
    },

    // Get recent equipment additions
    getRecentEquipment: (limit = 5) => {
      return [...equipment]
        .sort((a, b) => new Date(b.metadata?.dateAdded) - new Date(a.metadata?.dateAdded))
        .slice(0, limit);
    },

    // Get equipment needing attention (high costs, old equipment)
    getEquipmentNeedingAttention: () => {
      return equipment.filter(item => {
        const hourlyCost = item.calculated?.hourlyCost || 0;
        const age = new Date().getFullYear() - (item.identity?.year || new Date().getFullYear());
        const utilization = item.metadata?.utilization || 0;
        
        return (
          hourlyCost > 150 || // High hourly cost
          age > 10 ||         // Old equipment
          utilization < 30    // Low utilization
        );
      });
    },

    // Duplicate equipment with new ID
    duplicateEquipment: (equipmentId) => {
      const original = getEquipmentById(equipmentId);
      if (!original) return null;

      const duplicate = {
        ...original,
        identity: {
          ...original.identity,
          name: `${original.identity.name} (Copy)`
        }
      };

      // Remove ID to generate new one
      delete duplicate.id;
      delete duplicate.metadata;
      
      return addEquipment(duplicate);
    }
  };

  return {
    // State
    equipment,
    filteredEquipment, 
    filters,
    
    // Basic operations
    addEquipment,
    updateEquipment,
    deleteEquipment,
    getEquipmentById,
    getFleetStats,
    
    // Enhanced operations
    ...operations
  };
}