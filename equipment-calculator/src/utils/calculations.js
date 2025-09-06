// Equipment Cost Calculation Engine

import { MAINTENANCE_COSTS, DEFAULT_RESALE_PERCENTAGE, RECOMMENDED_MARKUP } from './constants.js';

/**
 * Calculate annual hours from days per year and hours per day
 */
export const calculateAnnualHours = (daysPerYear, hoursPerDay) => {
  const days = Number(daysPerYear) || 0;
  const hours = Number(hoursPerDay) || 0;
  return Math.round(days * hours);
};

/**
 * Calculate annual depreciation 
 */
export const calculateAnnualDepreciation = (purchasePrice, estimatedResaleValue, yearsOfService) => {
  const purchase = Number(purchasePrice) || 0;
  const resale = Number(estimatedResaleValue) || 0;
  const years = Number(yearsOfService) || 1;
  
  return Math.round((purchase - resale) / years);
};

/**
 * Calculate annual fuel cost
 */
export const calculateAnnualFuel = (dailyFuelCost, daysPerYear) => {
  const daily = Number(dailyFuelCost) || 0;
  const days = Number(daysPerYear) || 0;
  return Math.round(daily * days);
};

/**
 * Calculate annual maintenance cost
 */
export const calculateAnnualMaintenance = (maintenanceLevel, customMaintenanceCost) => {
  if (customMaintenanceCost && Number(customMaintenanceCost) > 0) {
    return Number(customMaintenanceCost);
  }
  
  return MAINTENANCE_COSTS[maintenanceLevel] || MAINTENANCE_COSTS.standard;
};

/**
 * Calculate total annual operating cost
 */
export const calculateTotalAnnualCost = (annualDepreciation, annualFuel, annualMaintenance, annualInsurance) => {
  const depreciation = Number(annualDepreciation) || 0;
  const fuel = Number(annualFuel) || 0;
  const maintenance = Number(annualMaintenance) || 0;
  const insurance = Number(annualInsurance) || 0;
  
  return Math.round(depreciation + fuel + maintenance + insurance);
};

/**
 * Calculate hourly operating cost
 */
export const calculateHourlyCost = (totalAnnualCost, annualHours) => {
  const annual = Number(totalAnnualCost) || 0;
  const hours = Number(annualHours) || 1;
  
  return Math.round((annual / hours) * 100) / 100; // Round to 2 decimal places
};

/**
 * Calculate recommended billing rate (30% markup)
 */
export const calculateRecommendedRate = (hourlyCost) => {
  const cost = Number(hourlyCost) || 0;
  return Math.round(cost * RECOMMENDED_MARKUP * 100) / 100; // Round to 2 decimal places
};

/**
 * Calculate estimated resale value based on percentage
 */
export const calculateEstimatedResale = (purchasePrice, percentage = DEFAULT_RESALE_PERCENTAGE) => {
  const price = Number(purchasePrice) || 0;
  const percent = Number(percentage) || DEFAULT_RESALE_PERCENTAGE;
  return Math.round(price * percent);
};

/**
 * Calculate utilization percentage
 */
export const calculateUtilization = (actualHours, annualHours) => {
  const actual = Number(actualHours) || 0;
  const annual = Number(annualHours) || 1;
  return Math.round((actual / annual) * 100);
};

/**
 * Complete equipment cost calculation
 * Returns all calculated values for an equipment object
 */
export const calculateEquipmentCosts = (equipmentData) => {
  const {
    usage: { daysPerYear, hoursPerDay } = {},
    financial: {
      purchasePrice,
      estimatedResaleValue,
      yearsOfService,
      dailyFuelCost,
      maintenanceLevel,
      customMaintenanceCost,
      annualInsuranceCost
    } = {}
  } = equipmentData;

  // Calculate annual hours
  const annualHours = calculateAnnualHours(daysPerYear, hoursPerDay);

  // Calculate annual costs
  const annualDepreciation = calculateAnnualDepreciation(
    purchasePrice, 
    estimatedResaleValue, 
    yearsOfService
  );
  
  const annualFuel = calculateAnnualFuel(dailyFuelCost, daysPerYear);
  
  const annualMaintenance = calculateAnnualMaintenance(
    maintenanceLevel, 
    customMaintenanceCost
  );
  
  const totalAnnualCost = calculateTotalAnnualCost(
    annualDepreciation,
    annualFuel, 
    annualMaintenance,
    annualInsuranceCost
  );

  // Calculate hourly metrics
  const hourlyCost = calculateHourlyCost(totalAnnualCost, annualHours);
  const recommendedRate = calculateRecommendedRate(hourlyCost);

  return {
    annualHours,
    annualDepreciation,
    annualFuel,
    annualMaintenance,
    totalAnnualCost,
    hourlyCost,
    recommendedRate
  };
};

/**
 * Format currency values for display
 */
export const formatCurrency = (amount, includeCents = true) => {
  const value = Number(amount) || 0;
  return new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
    minimumFractionDigits: includeCents ? 2 : 0,
    maximumFractionDigits: includeCents ? 2 : 0,
  }).format(value);
};

/**
 * Format percentage for display
 */
export const formatPercentage = (decimal) => {
  const value = Number(decimal) || 0;
  return `${Math.round(value * 100)}%`;
};