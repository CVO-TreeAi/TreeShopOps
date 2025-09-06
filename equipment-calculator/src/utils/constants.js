// Equipment Calculator Constants

export const EQUIPMENT_CATEGORIES = [
  'All',
  'Forestry Mulcher',
  'Skid Steer', 
  'Pickup Truck',
  'Dump Truck',
  'Chipper',
  'Stump Grinder',
  'Other'
];

export const MAINTENANCE_COSTS = {
  minimal: 1300,
  standard: 2600,
  intense: 4550
};

export const MAINTENANCE_PRESETS = {
  minimal: {
    name: 'Minimal',
    description: 'Basic oil changes, filters',
    annualCost: 1300
  },
  standard: {
    name: 'Standard', 
    description: 'Regular service schedule',
    annualCost: 2600
  },
  intense: {
    name: 'Intense',
    description: 'Heavy-duty operations, frequent repairs', 
    annualCost: 4550
  }
};

export const USAGE_PRESETS = {
  light: {
    name: 'Light',
    description: '2-4 hours/day',
    hoursRange: '2-4',
    hoursPerDay: 3,
    daysPerYear: 150
  },
  moderate: {
    name: 'Moderate',
    description: '4-8 hours/day', 
    hoursRange: '4-8',
    hoursPerDay: 6,
    daysPerYear: 200
  },
  heavy: {
    name: 'Heavy',
    description: '8+ hours/day',
    hoursRange: '8-12', 
    hoursPerDay: 10,
    daysPerYear: 250
  }
};

export const DEFAULT_RESALE_PERCENTAGE = 0.2;
export const RECOMMENDED_MARKUP = 1.3;

// Validation limits
export const VALIDATION_LIMITS = {
  year: { min: 1990, max: 2030 },
  daysPerYear: { min: 100, max: 300 },
  hoursPerDay: { min: 2, max: 16 },
  annualHours: { min: 200, max: 4800 },
  yearsOfService: { min: 1, max: 15 },
  purchasePrice: { min: 1000, max: 1000000 },
  dailyFuelCost: { min: 1, max: 1000 },
  annualInsuranceCost: { min: 0, max: 100000 }
};

// Quality check thresholds
export const QUALITY_THRESHOLDS = {
  hourlyCostLow: 10,
  hourlyCostHigh: 200,
  recommendedRateMinimum: 25,
  lowUtilizationHours: 400
};