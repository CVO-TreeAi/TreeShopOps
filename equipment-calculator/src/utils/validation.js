// Input Validation Utilities

import { VALIDATION_LIMITS, QUALITY_THRESHOLDS } from './constants.js';

/**
 * Validate required text fields
 */
export const validateRequired = (value, fieldName) => {
  if (!value || value.toString().trim() === '') {
    return `${fieldName} is required`;
  }
  return null;
};

/**
 * Validate year field
 */
export const validateYear = (year) => {
  const yearNum = Number(year);
  if (!yearNum) {
    return 'Valid year is required';
  }
  if (yearNum < VALIDATION_LIMITS.year.min || yearNum > VALIDATION_LIMITS.year.max) {
    return `Year must be between ${VALIDATION_LIMITS.year.min} and ${VALIDATION_LIMITS.year.max}`;
  }
  return null;
};

/**
 * Validate currency amounts
 */
export const validateCurrency = (amount, fieldName, min = 0, max = Infinity) => {
  const amountNum = Number(amount);
  if (isNaN(amountNum) || amountNum < 0) {
    return `${fieldName} must be a valid positive number`;
  }
  if (amountNum < min) {
    return `${fieldName} must be at least $${min.toLocaleString()}`;
  }
  if (amountNum > max) {
    return `${fieldName} must be less than $${max.toLocaleString()}`;
  }
  return null;
};

/**
 * Validate days per year
 */
export const validateDaysPerYear = (days) => {
  const daysNum = Number(days);
  if (!daysNum || daysNum < VALIDATION_LIMITS.daysPerYear.min || daysNum > VALIDATION_LIMITS.daysPerYear.max) {
    return `Days per year must be between ${VALIDATION_LIMITS.daysPerYear.min} and ${VALIDATION_LIMITS.daysPerYear.max}`;
  }
  return null;
};

/**
 * Validate hours per day
 */
export const validateHoursPerDay = (hours) => {
  const hoursNum = Number(hours);
  if (!hoursNum || hoursNum < VALIDATION_LIMITS.hoursPerDay.min || hoursNum > VALIDATION_LIMITS.hoursPerDay.max) {
    return `Hours per day must be between ${VALIDATION_LIMITS.hoursPerDay.min} and ${VALIDATION_LIMITS.hoursPerDay.max}`;
  }
  return null;
};

/**
 * Validate all equipment form data
 */
export const validateEquipmentForm = (equipmentData) => {
  const errors = {};
  
  // Step 1 - Identity
  const { identity = {} } = equipmentData;
  
  const nameError = validateRequired(identity.equipmentName, 'Equipment Name');
  if (nameError) errors.equipmentName = nameError;
  
  const yearError = validateYear(identity.year);
  if (yearError) errors.year = yearError;
  
  const makeError = validateRequired(identity.make, 'Make');
  if (makeError) errors.make = makeError;
  
  const modelError = validateRequired(identity.model, 'Model');
  if (modelError) errors.model = modelError;
  
  const categoryError = validateRequired(identity.category, 'Category');
  if (categoryError) errors.category = categoryError;

  // Step 2 - Usage
  const { usage = {} } = equipmentData;
  
  const daysError = validateDaysPerYear(usage.daysPerYear);
  if (daysError) errors.daysPerYear = daysError;
  
  const hoursError = validateHoursPerDay(usage.hoursPerDay);
  if (hoursError) errors.hoursPerDay = hoursError;

  // Step 3 - Purchase
  const { financial = {} } = equipmentData;
  
  const purchasePriceError = validateCurrency(
    financial.purchasePrice, 
    'Purchase Price', 
    VALIDATION_LIMITS.purchasePrice.min,
    VALIDATION_LIMITS.purchasePrice.max
  );
  if (purchasePriceError) errors.purchasePrice = purchasePriceError;
  
  const yearsError = financial.yearsOfService && 
    (Number(financial.yearsOfService) < VALIDATION_LIMITS.yearsOfService.min || 
     Number(financial.yearsOfService) > VALIDATION_LIMITS.yearsOfService.max)
    ? `Years of service must be between ${VALIDATION_LIMITS.yearsOfService.min} and ${VALIDATION_LIMITS.yearsOfService.max}`
    : null;
  if (yearsError) errors.yearsOfService = yearsError;

  // Step 4 - Fuel
  const fuelError = validateCurrency(
    financial.dailyFuelCost,
    'Daily Fuel Cost',
    VALIDATION_LIMITS.dailyFuelCost.min,
    VALIDATION_LIMITS.dailyFuelCost.max
  );
  if (fuelError) errors.dailyFuelCost = fuelError;

  // Step 5 - Maintenance
  if (!financial.maintenanceLevel && !financial.customMaintenanceCost) {
    errors.maintenanceLevel = 'Maintenance level is required';
  }

  // Step 6 - Insurance
  if (financial.annualInsuranceCost && Number(financial.annualInsuranceCost) < 0) {
    errors.annualInsuranceCost = 'Insurance cost cannot be negative';
  }

  return {
    isValid: Object.keys(errors).length === 0,
    errors
  };
};

/**
 * Generate quality alerts for equipment calculations
 */
export const generateQualityAlerts = (calculatedCosts, equipmentData) => {
  const alerts = [];
  const { hourlyCost, recommendedRate } = calculatedCosts;
  const { usage: { annualHours } = {} } = equipmentData;

  if (hourlyCost < QUALITY_THRESHOLDS.hourlyCostLow) {
    alerts.push({
      type: 'warning',
      message: 'Hourly cost seems low - verify inputs'
    });
  }

  if (hourlyCost > QUALITY_THRESHOLDS.hourlyCostHigh) {
    alerts.push({
      type: 'warning', 
      message: 'Hourly cost seems high - check fuel/maintenance'
    });
  }

  if (recommendedRate < QUALITY_THRESHOLDS.recommendedRateMinimum) {
    alerts.push({
      type: 'error',
      message: 'Rate may be unprofitable'
    });
  }

  if (Number(annualHours) < QUALITY_THRESHOLDS.lowUtilizationHours) {
    alerts.push({
      type: 'info',
      message: 'Low utilization - asset may be underused'
    });
  }

  return alerts;
};