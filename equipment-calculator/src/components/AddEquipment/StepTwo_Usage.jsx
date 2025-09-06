// Step 2: Usage Pattern

import React from 'react';
import { Slider } from '../shared/Input';
import { USAGE_PRESETS } from '../../utils/constants';
import { calculateAnnualHours } from '../../utils/calculations';

const StepTwo_Usage = ({ 
  formData, 
  updateFormData, 
  errors = {} 
}) => {
  const usage = formData.usage || {};
  const daysPerYear = usage.daysPerYear || 200;
  const hoursPerDay = usage.hoursPerDay || 6;
  const annualHours = calculateAnnualHours(daysPerYear, hoursPerDay);

  const handleUsageUpdate = (updates) => {
    updateFormData({
      usage: {
        ...usage,
        ...updates
      }
    });
  };

  const applyPreset = (presetKey) => {
    const preset = USAGE_PRESETS[presetKey];
    handleUsageUpdate({
      daysPerYear: preset.daysPerYear,
      hoursPerDay: preset.hoursPerDay,
      usagePattern: preset.name,
      annualHours: calculateAnnualHours(preset.daysPerYear, preset.hoursPerDay)
    });
  };

  return (
    <div className="space-y-8">
      <div className="text-center mb-8">
        <h2 className="text-2xl font-bold text-text-primary mb-2">Usage Pattern</h2>
        <p className="text-text-secondary">How often will this equipment be used?</p>
      </div>

      {/* Usage Presets */}
      <div>
        <h3 className="text-lg font-medium text-text-primary mb-4">Choose Usage Level</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          {Object.entries(USAGE_PRESETS).map(([key, preset]) => (
            <button
              key={key}
              type="button"
              onClick={() => applyPreset(key)}
              className={`p-4 rounded-lg border-2 smooth-transition text-left ${
                usage.usagePattern === preset.name
                  ? 'border-accent bg-accent bg-opacity-10 text-text-primary'
                  : 'border-gray-600 bg-secondary hover:border-accent hover:bg-accent hover:bg-opacity-5 text-text-secondary hover:text-text-primary'
              }`}
            >
              <div className="space-y-2">
                <h4 className="font-medium text-lg">{preset.name}</h4>
                <p className="text-sm opacity-80">{preset.description}</p>
                <div className="flex items-center space-x-4 text-xs">
                  <span>{preset.daysPerYear} days/year</span>
                  <span>{preset.hoursPerDay} hrs/day</span>
                </div>
                <p className="text-accent font-medium text-sm">
                  {calculateAnnualHours(preset.daysPerYear, preset.hoursPerDay).toLocaleString()} hours/year
                </p>
              </div>
            </button>
          ))}
        </div>
      </div>

      {/* Custom Usage Controls */}
      <div className="space-y-6">
        <h3 className="text-lg font-medium text-text-primary">Fine-tune Usage</h3>
        
        {/* Days Per Year Slider */}
        <div>
          <Slider
            label="Days Per Year"
            value={daysPerYear}
            onChange={(value) => handleUsageUpdate({ 
              daysPerYear: value,
              annualHours: calculateAnnualHours(value, hoursPerDay)
            })}
            min={100}
            max={300}
            step={5}
            unit=" days"
          />
          {errors.daysPerYear && (
            <p className="text-sm text-error mt-1">{errors.daysPerYear}</p>
          )}
        </div>

        {/* Hours Per Day Slider */}
        <div>
          <Slider
            label="Hours Per Day"
            value={hoursPerDay}
            onChange={(value) => handleUsageUpdate({ 
              hoursPerDay: value,
              annualHours: calculateAnnualHours(daysPerYear, value)
            })}
            min={2}
            max={16}
            step={0.5}
            unit=" hrs"
          />
          {errors.hoursPerDay && (
            <p className="text-sm text-error mt-1">{errors.hoursPerDay}</p>
          )}
        </div>

        {/* Annual Hours Display */}
        <div className="bg-accent bg-opacity-10 border border-accent rounded-lg p-4">
          <div className="flex items-center justify-between">
            <div>
              <h4 className="text-lg font-medium text-text-primary">Total Annual Hours</h4>
              <p className="text-text-secondary">Based on your usage pattern</p>
            </div>
            <div className="text-right">
              <p className="text-3xl font-bold text-accent">
                {annualHours.toLocaleString()}
              </p>
              <p className="text-sm text-text-secondary">hours per year</p>
            </div>
          </div>
        </div>
      </div>

      {/* Usage Guidelines */}
      <div className="bg-orange-900 bg-opacity-20 border border-orange-700 rounded-lg p-4">
        <div className="flex items-start space-x-3">
          <svg className="flex-shrink-0 w-5 h-5 text-orange-400 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.732 15.5c-.77.833.192 2.5 1.732 2.5z" />
          </svg>
          <div>
            <h4 className="text-sm font-medium text-orange-400">Usage Guidelines</h4>
            <ul className="text-sm text-orange-200 mt-1 space-y-1">
              <li>• Track actual usage for 2-3 weeks to get accurate averages</li>
              <li>• Include weather downtime and maintenance days</li>
              <li>• Higher utilization = lower cost per hour</li>
              <li>• Most profitable equipment runs 1,000+ hours per year</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default StepTwo_Usage;