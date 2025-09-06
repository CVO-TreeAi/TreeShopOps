// Step 4: Fuel Cost

import React from 'react';
import { CurrencyInput } from '../shared/Input';
import { calculateAnnualFuel } from '../../utils/calculations';

const StepFour_Fuel = ({ 
  formData, 
  updateFormData, 
  errors = {} 
}) => {
  const financial = formData.financial || {};
  const usage = formData.usage || {};
  const dailyFuelCost = Number(financial.dailyFuelCost) || 0;
  const daysPerYear = usage.daysPerYear || 200;
  const annualFuelCost = calculateAnnualFuel(dailyFuelCost, daysPerYear);

  const handleFuelUpdate = (value) => {
    updateFormData({
      financial: {
        ...financial,
        dailyFuelCost: Number(value) || 0
      }
    });
  };

  // Sample daily fuel costs by equipment type
  const fuelEstimates = {
    'Forestry Mulcher': { low: 120, high: 200, avg: 160 },
    'Skid Steer': { low: 50, high: 100, avg: 75 },
    'Pickup Truck': { low: 30, high: 60, avg: 45 },
    'Dump Truck': { low: 80, high: 150, avg: 115 },
    'Chipper': { low: 70, high: 130, avg: 100 },
    'Stump Grinder': { low: 90, high: 160, avg: 125 },
    'Other': { low: 50, high: 150, avg: 100 }
  };

  const categoryEstimate = fuelEstimates[formData.identity?.category] || fuelEstimates['Other'];

  return (
    <div className="space-y-8">
      <div className="text-center mb-8">
        <h2 className="text-2xl font-bold text-text-primary mb-2">Daily Fuel Cost</h2>
        <p className="text-text-secondary">Track fuel consumption for accurate costs</p>
      </div>

      <div className="space-y-6">
        {/* Daily Fuel Cost Input */}
        <CurrencyInput
          label="Daily Fuel Cost"
          placeholder="150"
          value={financial.dailyFuelCost || ''}
          onChange={handleFuelUpdate}
          error={errors.dailyFuelCost}
          helpText="Track fuel costs for one week, then divide by working days"
          required
        />

        {/* Fuel Cost Estimates for Category */}
        {formData.identity?.category && (
          <div className="bg-secondary border border-gray-700 rounded-lg p-4">
            <h3 className="text-sm font-medium text-text-primary mb-3">
              Typical {formData.identity.category} Fuel Costs
            </h3>
            <div className="grid grid-cols-3 gap-4 text-center">
              <button
                type="button"
                onClick={() => handleFuelUpdate(categoryEstimate.low)}
                className="p-3 rounded-lg bg-primary hover:bg-gray-600 smooth-transition"
              >
                <p className="text-lg font-bold text-text-primary">${categoryEstimate.low}</p>
                <p className="text-xs text-text-secondary">Low Usage</p>
              </button>
              <button
                type="button"
                onClick={() => handleFuelUpdate(categoryEstimate.avg)}
                className="p-3 rounded-lg bg-primary hover:bg-gray-600 smooth-transition border-2 border-accent"
              >
                <p className="text-lg font-bold text-accent">${categoryEstimate.avg}</p>
                <p className="text-xs text-accent">Average</p>
              </button>
              <button
                type="button"
                onClick={() => handleFuelUpdate(categoryEstimate.high)}
                className="p-3 rounded-lg bg-primary hover:bg-gray-600 smooth-transition"
              >
                <p className="text-lg font-bold text-text-primary">${categoryEstimate.high}</p>
                <p className="text-xs text-text-secondary">Heavy Usage</p>
              </button>
            </div>
          </div>
        )}

        {/* Annual Fuel Cost Preview */}
        {dailyFuelCost > 0 && (
          <div className="bg-accent bg-opacity-10 border border-accent rounded-lg p-4">
            <div className="flex items-center justify-between">
              <div>
                <h4 className="text-lg font-medium text-text-primary">Annual Fuel Cost</h4>
                <p className="text-text-secondary">
                  ${dailyFuelCost}/day × {daysPerYear} days
                </p>
              </div>
              <div className="text-right">
                <p className="text-3xl font-bold text-accent">
                  ${annualFuelCost.toLocaleString()}
                </p>
                <p className="text-sm text-text-secondary">per year</p>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Fuel Tracking Tips */}
      <div className="bg-blue-900 bg-opacity-20 border border-blue-700 rounded-lg p-4">
        <div className="flex items-start space-x-3">
          <svg className="flex-shrink-0 w-5 h-5 text-blue-400 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <div>
            <h4 className="text-sm font-medium text-blue-400">Fuel Tracking Best Practices</h4>
            <ul className="text-sm text-blue-200 mt-1 space-y-1">
              <li>• Include both diesel and hydraulic fluid costs</li>
              <li>• Track for a full week of typical operation</li>
              <li>• Account for equipment warm-up and idle time</li>
              <li>• Consider seasonal variations in fuel consumption</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default StepFour_Fuel;