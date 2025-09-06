// Local Storage Management Utilities

const STORAGE_KEY = 'equipment-directory';
const DRAFT_KEY = 'equipment-draft';

/**
 * Load all equipment from localStorage
 */
export const loadEquipment = () => {
  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    return stored ? JSON.parse(stored) : [];
  } catch (error) {
    console.error('Failed to load equipment from storage:', error);
    return [];
  }
};

/**
 * Save equipment array to localStorage
 */
export const saveEquipment = (equipment) => {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(equipment));
    return true;
  } catch (error) {
    console.error('Failed to save equipment to storage:', error);
    return false;
  }
};

/**
 * Add new equipment item
 */
export const addEquipment = (equipmentData) => {
  const equipment = loadEquipment();
  const newEquipment = {
    ...equipmentData,
    metadata: {
      ...equipmentData.metadata,
      dateAdded: new Date().toISOString(),
      lastModified: new Date().toISOString()
    }
  };
  
  equipment.push(newEquipment);
  return saveEquipment(equipment) ? newEquipment : null;
};

/**
 * Update existing equipment item
 */
export const updateEquipment = (equipmentId, updatedData) => {
  const equipment = loadEquipment();
  const index = equipment.findIndex(item => item.id === equipmentId);
  
  if (index === -1) return false;
  
  equipment[index] = {
    ...equipment[index],
    ...updatedData,
    metadata: {
      ...equipment[index].metadata,
      ...updatedData.metadata,
      lastModified: new Date().toISOString()
    }
  };
  
  return saveEquipment(equipment);
};

/**
 * Delete equipment item
 */
export const deleteEquipment = (equipmentId) => {
  const equipment = loadEquipment();
  const filtered = equipment.filter(item => item.id !== equipmentId);
  return saveEquipment(filtered);
};

/**
 * Get equipment by ID
 */
export const getEquipmentById = (equipmentId) => {
  const equipment = loadEquipment();
  return equipment.find(item => item.id === equipmentId) || null;
};

/**
 * Save form draft to localStorage
 */
export const saveDraft = (draftData) => {
  try {
    localStorage.setItem(DRAFT_KEY, JSON.stringify({
      ...draftData,
      savedAt: new Date().toISOString()
    }));
    return true;
  } catch (error) {
    console.error('Failed to save draft:', error);
    return false;
  }
};

/**
 * Load form draft from localStorage
 */
export const loadDraft = () => {
  try {
    const stored = localStorage.getItem(DRAFT_KEY);
    return stored ? JSON.parse(stored) : null;
  } catch (error) {
    console.error('Failed to load draft:', error);
    return null;
  }
};

/**
 * Clear form draft
 */
export const clearDraft = () => {
  try {
    localStorage.removeItem(DRAFT_KEY);
    return true;
  } catch (error) {
    console.error('Failed to clear draft:', error);
    return false;
  }
};

/**
 * Export all equipment data as JSON
 */
export const exportEquipmentData = () => {
  const equipment = loadEquipment();
  const exportData = {
    equipment,
    exportDate: new Date().toISOString(),
    version: '1.0'
  };
  
  const dataStr = JSON.stringify(exportData, null, 2);
  const dataUri = 'data:application/json;charset=utf-8,'+ encodeURIComponent(dataStr);
  
  const exportFileDefaultName = `equipment-directory-${new Date().toISOString().split('T')[0]}.json`;
  
  return {
    dataUri,
    filename: exportFileDefaultName,
    data: exportData
  };
};

/**
 * Import equipment data from JSON
 */
export const importEquipmentData = (jsonData) => {
  try {
    const data = typeof jsonData === 'string' ? JSON.parse(jsonData) : jsonData;
    
    // Validate import data structure
    if (!data.equipment || !Array.isArray(data.equipment)) {
      throw new Error('Invalid import data format');
    }
    
    // Merge with existing equipment (avoiding duplicates by ID)
    const existing = loadEquipment();
    const existingIds = new Set(existing.map(item => item.id));
    
    const newEquipment = data.equipment.filter(item => !existingIds.has(item.id));
    const merged = [...existing, ...newEquipment];
    
    return saveEquipment(merged) ? merged : null;
  } catch (error) {
    console.error('Failed to import equipment data:', error);
    return null;
  }
};