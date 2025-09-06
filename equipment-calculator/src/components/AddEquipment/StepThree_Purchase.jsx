// Step 3: Purchase Details

import React from 'react';
import { CurrencyInput, Slider } from '../shared/Input';
import { calculateEstimatedResale } from '../../utils/calculations';

const StepThree_Purchase = ({ 
  formData, 
  updateFormData, 
  errors = {} 
}) => {
  const financial = formData.financial || {};
  const purchasePrice = Number(financial.purchasePrice) || 0;
  const yearsOfService = financial.yearsOfService || 7;
  const estimatedResaleValue = financial.estimatedResaleValue || 
    calculateEstimatedResale(purchasePrice);

  const handleFinancialUpdate = (updates) => {
    updateFormData({
      financial: {
        ...financial,
        ...updates
      }
    });
  };

  const handlePurchasePriceChange = (value) => {
    const numValue = Number(value) || 0;
    handleFinancialUpdate({
      purchasePrice: numValue,
      // Auto-calculate resale value if not manually set
      estimatedResaleValue: financial.manualResaleValue ? 
        financial.estimatedResaleValue : 
        calculateEstimatedResale(numValue)
    });
  };

  const handleResaleValueChange = (value) => {
    handleFinancialUpdate({
      estimatedResaleValue: Number(value) || 0,
      manualResaleValue: true // Mark as manually set
    });
  };

  return (
    <div className="space-y-8">
      <div className="text-center mb-8">
        <h2 className="text-2xl font-bold text-text-primary mb-2">Purchase Details</h2>
        <p className="text-text-secondary">Equipment investment and depreciation</p>
      </div>

      <div className="space-y-6">
        {/* Purchase Price */}
        <CurrencyInput
          label="Purchase Price"
          placeholder="65000"
          value={financial.purchasePrice || ''}
          onChange={handlePurchasePriceChange}
          error={errors.purchasePrice}
          helpText="What did you pay for this equipment?"
          required
        />

        {/* Years of Service Slider */}
        <div>
          <Slider
            label="Expected Years of Service"
            value={yearsOfService}
            onChange={(value) => handleFinancialUpdate({ yearsOfService: value })}
            min={1}
            max={15}
            step={1}
            unit=" years"
          />
          {errors.yearsOfService && (
            <p className="text-sm text-error mt-1">{errors.yearsOfService}</p>
          )}
        </div>

        {/* Estimated Resale Value */}
        <CurrencyInput
          label="Estimated Resale Value"
          placeholder={calculateEstimatedResale(purchasePrice).toString()}
          value={financial.estimatedResaleValue || ''}
          onChange={handleResaleValueChange}
          error={errors.estimatedResaleValue}
          helpText="What will it be worth at the end of its service life?"
        />

        {/* Auto-calculate button */}
        {financial.manualResaleValue && (
          <button
            type="button"
            onClick={() => handleFinancialUpdate({
              estimatedResaleValue: calculateEstimatedResale(purchasePrice),
              manualResaleValue: false
            })}
            className="text-accent text-sm hover:text-green-400 smooth-transition"
          >
            ↻ Auto-calculate resale value (20% of purchase price)
          </button>
        )}
      </div>

      {/* Depreciation Preview */}
      {purchasePrice > 0 && yearsOfService > 0 && (
        <div className="bg-primary border border-gray-700 rounded-lg p-6">
          <h3 className="text-lg font-medium text-text-primary mb-4">Depreciation Analysis</h3>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="text-center">
              <p className="text-2xl font-bold text-text-primary">
                ${((purchasePrice - estimatedResaleValue) / yearsOfService).toLocaleString()}
              </p>
              <p className="text-sm text-text-secondary">Annual Depreciation</p>
            </div>
            <div className="text-center">
              <p className="text-2xl font-bold text-text-primary">
                {Math.round(((purchasePrice - estimatedResaleValue) / purchasePrice) * 100)}%
              </p>
              <p className="text-sm text-text-secondary">Total Depreciation</p>
            </div>
            <div className="text-center">
              <p className="text-2xl font-bold text-accent">
                ${estimatedResaleValue.toLocaleString()}
              </p>
              <p className="text-sm text-text-secondary">Resale Value</p>
            </div>
            <div className="text-center">
              <p className="text-2xl font-bold text-text-primary">
                {yearsOfService}
              </p>
              <p className="text-sm text-text-secondary">Years of Service</p>
            </div>
          </div>
        </div>
      )}

      {/* Financial Guidelines */}
      <div className="bg-blue-900 bg-opacity-20 border border-blue-700 rounded-lg p-4">
        <div className="flex items-start space-x-3">
          <svg className="flex-shrink-0 w-5 h-5 text-blue-400 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <div>
            <h4 className="text-sm font-medium text-blue-400">Depreciation Tips</h4>
            <ul className="text-sm text-blue-200 mt-1 space-y-1">
              <li>• Heavy-duty equipment typically retains 15-25% value</li>
              <li>• Well-maintained equipment holds value better</li>
              <li>• Consider market demand for your equipment type</li>
              <li>• Longer service life reduces annual depreciation cost</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
};

export default StepThree_Purchase;