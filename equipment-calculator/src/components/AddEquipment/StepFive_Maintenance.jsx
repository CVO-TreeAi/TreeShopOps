// Step 5: Maintenance Level

import React from 'react';
import { MAINTENANCE_PRESETS } from '../../utils/constants';
import { CurrencyInput } from '../shared/Input';

const StepFive_Maintenance = ({ 
  formData, 
  updateFormData, 
  errors = {} 
}) => {
  const financial = formData.financial || {};
  const selectedLevel = financial.maintenanceLevel;
  const customCost = financial.customMaintenanceCost;

  const handleMaintenanceUpdate = (updates) => {
    updateFormData({
      financial: {
        ...financial,
        ...updates
      }
    });
  };

  const selectPreset = (level) => {
    handleMaintenanceUpdate({
      maintenanceLevel: level,
      customMaintenanceCost: null // Clear custom cost when selecting preset
    });
  };

  const handleCustomCost = (value) => {
    handleMaintenanceUpdate({
      maintenanceLevel: 'custom',
      customMaintenanceCost: Number(value) || 0
    });
  };

  return (
    <div className="space-y-8">
      <div className="text-center mb-8">
        <h2 className="text-2xl font-bold text-text-primary mb-2">Maintenance Level</h2>
        <p className="text-text-secondary">Choose your annual maintenance approach</p>
      </div>

      <div className="space-y-6">
        {/* Maintenance Presets */}
        <div>
          <h3 className="text-lg font-medium text-text-primary mb-4">Maintenance Levels</h3>
          <div className="space-y-4">
            {Object.entries(MAINTENANCE_PRESETS).map(([key, preset]) => (
              <button
                key={key}
                type="button"
                onClick={() => selectPreset(key)}
                className={`w-full p-6 rounded-lg border-2 smooth-transition text-left ${
                  selectedLevel === key
                    ? 'border-accent bg-accent bg-opacity-10'
                    : 'border-gray-600 bg-secondary hover:border-accent hover:bg-accent hover:bg-opacity-5'
                }`}
              >
                <div className="flex items-center justify-between">
                  <div className="space-y-2">
                    <h4 className="text-lg font-medium text-text-primary">{preset.name}</h4>
                    <p className="text-text-secondary">{preset.description}</p>
                    
                    {/* Maintenance Details */}
                    <div className="space-y-1 text-xs text-text-secondary">
                      {key === 'minimal' && (
                        <>
                          <p>• Oil changes every 250 hours</p>
                          <p>• Basic filter replacements</p>
                          <p>• Minimal preventive maintenance</p>
                        </>
                      )}
                      {key === 'standard' && (
                        <>
                          <p>• Full manufacturer service schedule</p>
                          <p>• Regular inspections and tune-ups</p>
                          <p>• Preventive part replacements</p>
                        </>
                      )}
                      {key === 'intense' && (
                        <>
                          <p>• Aggressive preventive maintenance</p>
                          <p>• Frequent repairs and overhauls</p>
                          <p>• Premium parts and fluids</p>
                        </>
                      )}
                    </div>
                  </div>
                  <div className="text-right">
                    <p className="text-2xl font-bold text-accent">
                      ${preset.annualCost.toLocaleString()}
                    </p>
                    <p className="text-sm text-text-secondary">per year</p>
                  </div>
                </div>
              </button>
            ))}

            {/* Custom Maintenance Option */}
            <div className={`p-6 rounded-lg border-2 smooth-transition ${
              selectedLevel === 'custom'
                ? 'border-accent bg-accent bg-opacity-10'
                : 'border-gray-600 bg-secondary'
            }`}>
              <div className="space-y-4">
                <div className="flex items-center space-x-3">
                  <button
                    type="button"
                    onClick={() => selectPreset('custom')}
                    className={`w-4 h-4 rounded-full border-2 ${
                      selectedLevel === 'custom' 
                        ? 'border-accent bg-accent' 
                        : 'border-gray-600'
                    }`}
                  />
                  <h4 className="text-lg font-medium text-text-primary">Custom Maintenance</h4>
                </div>
                
                {selectedLevel === 'custom' && (
                  <div className="pl-7">
                    <CurrencyInput
                      label="Annual Maintenance Cost"
                      placeholder="3500"
                      value={customCost || ''}
                      onChange={handleCustomCost}
                      error={errors.customMaintenanceCost}
                      helpText="Enter your specific annual maintenance budget"
                    />
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Maintenance Impact Preview */}
      {(selectedLevel && selectedLevel !== 'custom') || (customCost > 0) && (
        <div className="bg-primary border border-gray-700 rounded-lg p-6">
          <h3 className="text-lg font-medium text-text-primary mb-4">Maintenance Impact</h3>
          <div className="grid grid-cols-2 gap-4">
            <div className="text-center">
              <p className="text-2xl font-bold text-accent">
                ${(selectedLevel === 'custom' ? customCost : MAINTENANCE_PRESETS[selectedLevel]?.annualCost || 0).toLocaleString()}
              </p>
              <p className="text-sm text-text-secondary">Annual Cost</p>
            </div>
            <div className="text-center">
              <p className="text-2xl font-bold text-text-primary">
                ${Math.round((selectedLevel === 'custom' ? customCost : MAINTENANCE_PRESETS[selectedLevel]?.annualCost || 0) / 12).toLocaleString()}
              </p>
              <p className="text-sm text-text-secondary">Monthly Cost</p>
            </div>
          </div>
        </div>
      )}

      {/* Maintenance Guidelines */}
      <div className="bg-orange-900 bg-opacity-20 border border-orange-700 rounded-lg p-4">
        <div className="flex items-start space-x-3">
          <svg className="flex-shrink-0 w-5 h-5 text-orange-400 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.732 15.5c-.77.833.192 2.5 1.732 2.5z" />
          </svg>
          <div>
            <h4 className="text-sm font-medium text-orange-400">Maintenance Cost Factors</h4>
            <ul className="text-sm text-orange-200 mt-1 space-y-1">
              <li>• Higher maintenance = better reliability and resale value</li>
              <li>• Intense use in debris requires aggressive maintenance</li>
              <li>• Track actual costs for 6 months to calibrate estimates</li>
              <li>• Include consumables: filters, fluids, wear parts</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default StepFive_Maintenance;